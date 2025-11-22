package com.example.webrtc_signal_server.api;

import com.example.webrtc_signal_server.domain.vote.dto.VoteRequest;
import com.example.webrtc_signal_server.domain.vote.entity.VoteResult;
import com.example.webrtc_signal_server.domain.vote.repository.VoteResultRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

@RestController
@RequiredArgsConstructor
@RequestMapping("/api/votes")
public class VoteController {

    private final VoteResultRepository voteResultRepository;

    @PostMapping
    public ResponseEntity<Void> submitVote(@RequestBody VoteRequest request) {
        VoteResult voteResult = VoteResult.of(
                request.getRoomName(),
                request.getTopic(),
                request.getVoterId(),
                request.getSelectedOption()
        );
        voteResultRepository.save(voteResult);
        return ResponseEntity.ok().build();
    }
}
