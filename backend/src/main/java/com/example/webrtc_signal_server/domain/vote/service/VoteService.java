package com.example.webrtc_signal_server.domain.vote.service;

import com.example.webrtc_signal_server.domain.livekit.service.LiveKitService;
import com.example.webrtc_signal_server.domain.vote.dto.VoteCastRequest;
import com.example.webrtc_signal_server.domain.vote.dto.VoteResponse;
import com.example.webrtc_signal_server.domain.vote.dto.VoteStartRequest;
import com.example.webrtc_signal_server.domain.vote.entity.Vote;
import com.example.webrtc_signal_server.domain.vote.entity.VoteResult;
import com.example.webrtc_signal_server.domain.vote.repository.VoteRepository;
import com.example.webrtc_signal_server.domain.user.entity.UserEntity;
import com.example.webrtc_signal_server.domain.user.repository.UserRepository;
import com.example.webrtc_signal_server.domain.vote.repository.VoteResultRepository;
import com.fasterxml.jackson.core.JsonProcessingException;
import com.fasterxml.jackson.databind.ObjectMapper;
import jakarta.transaction.Transactional;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.stream.Collectors;

@Service
@Transactional
@RequiredArgsConstructor
public class VoteService {

    private final VoteRepository voteRepository;
    private final VoteResultRepository voteResultRepository;
    private final UserRepository userRepository;
    private final LiveKitService liveKitService;
    private final ObjectMapper objectMapper;

    public void startVote(VoteStartRequest request) throws JsonProcessingException {
        // 1. Convert options list to JSON string
        String optionsJson = objectMapper.writeValueAsString(request.getOptions());

        // 2. Create and save Vote entity
        Vote vote = Vote.of(request.getRoomName(), request.getTopic(), optionsJson, request.getProposerId());
        voteRepository.save(vote);

        // 3. Broadcast VOTE_STARTED event via LiveKit
        Map<String, Object> payload = new HashMap<>();
        payload.put("type", "VOTE_STARTED");
        Map<String, Object> data = new HashMap<>();
        data.put("voteId", vote.getId());
        data.put("topic", vote.getTopic());
        data.put("options", request.getOptions());
        data.put("proposerId", vote.getProposerId()); // Include proposerId
        payload.put("data", data);

        String payloadJson = objectMapper.writeValueAsString(payload);
        liveKitService.sendDataToRoom(request.getRoomName(), payloadJson);
    }

    public void castVote(VoteCastRequest request) {
        Vote vote = voteRepository.findById(request.getVoteId())
                .orElseThrow(() -> new IllegalArgumentException("Vote not found"));

        VoteResult voteResult = VoteResult.of(vote, request.getVoterId(), request.getSelectedOption());
        voteResultRepository.save(voteResult);
    }

    public void closeVote(Long voteId) throws JsonProcessingException {
        Vote vote = voteRepository.findById(voteId)
                .orElseThrow(() -> new IllegalArgumentException("Vote not found"));
        vote.close();

        // 1. Tally results
        List<VoteResult> results = voteResultRepository.findAllByVote_Id(voteId);
        Map<String, Long> talliedResults = results.stream()
                .collect(Collectors.groupingBy(VoteResult::getSelectedOption, Collectors.counting()));

        // 2. Broadcast VOTE_ENDED event with results via LiveKit
        Map<String, Object> payload = new HashMap<>();
        payload.put("type", "VOTE_ENDED");
        Map<String, Object> data = new HashMap<>();
        data.put("voteId", vote.getId());
        data.put("topic", vote.getTopic());
        data.put("results", talliedResults);
        payload.put("data", data);

        String payloadJson = objectMapper.writeValueAsString(payload);
        liveKitService.sendDataToRoom(vote.getRoomName(), payloadJson);
    }

    public List<VoteResponse> getVotesByRoom(String roomName) {
        List<Vote> votes = voteRepository.findAllByRoomName(roomName);

        return votes.stream().map(vote -> {
            try {
                List<String> options = objectMapper.readValue(vote.getOptions(), new com.fasterxml.jackson.core.type.TypeReference<List<String>>() {});
                
                Map<String, List<String>> resultsMap = new HashMap<>();
                for (String option : options) {
                    resultsMap.put(option, new java.util.ArrayList<>());
                }

                List<VoteResult> voteResults = voteResultRepository.findAllByVote_Id(vote.getId());
                
                // Collect all voter IDs (Convert String to Long)
                List<Long> voterIds = voteResults.stream()
                        .map(result -> {
                            try {
                                return Long.parseLong(result.getVoterId());
                            } catch (NumberFormatException e) {
                                return null;
                            }
                        })
                        .filter(id -> id != null)
                        .collect(Collectors.toList());

                // Fetch users and map id to nickname
                List<UserEntity> users = userRepository.findAllById(voterIds);
                Map<String, String> nicknameMap = users.stream()
                        .collect(Collectors.toMap(user -> String.valueOf(user.getId()), UserEntity::getNickname));

                for (VoteResult result : voteResults) {
                    if (resultsMap.containsKey(result.getSelectedOption())) {
                        String nickname = nicknameMap.getOrDefault(result.getVoterId(), result.getVoterId());
                        resultsMap.get(result.getSelectedOption()).add(nickname);
                    }
                }

                return new VoteResponse(
                        vote.getId(),
                        vote.getRoomName(),
                        vote.getTopic(),
                        resultsMap,
                        vote.getStatus().name()
                );
            } catch (JsonProcessingException e) {
                throw new RuntimeException("Error parsing vote options", e);
            }
        }).collect(Collectors.toList());
    }
}
