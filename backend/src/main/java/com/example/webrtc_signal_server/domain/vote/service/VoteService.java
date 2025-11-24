package com.example.webrtc_signal_server.domain.vote.service;

import com.example.webrtc_signal_server.domain.livekit.service.LiveKitService;
import com.example.webrtc_signal_server.domain.vote.dto.VoteCastRequest;
import com.example.webrtc_signal_server.domain.vote.dto.VoteStartRequest;
import com.example.webrtc_signal_server.domain.vote.entity.Vote;
import com.example.webrtc_signal_server.domain.vote.entity.VoteResult;
import com.example.webrtc_signal_server.domain.vote.repository.VoteRepository;
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
}
