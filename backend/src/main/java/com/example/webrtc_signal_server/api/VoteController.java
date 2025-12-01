package com.example.webrtc_signal_server.api;

import com.example.webrtc_signal_server.domain.vote.dto.VoteCastRequest;
import com.example.webrtc_signal_server.domain.vote.dto.VoteResponse;
import com.example.webrtc_signal_server.domain.vote.dto.VoteStartRequest;
import com.example.webrtc_signal_server.domain.vote.service.VoteService;
import com.fasterxml.jackson.core.JsonProcessingException;
import java.util.List;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

@RestController
@RequiredArgsConstructor
@RequestMapping("/api/votes")
public class VoteController {

    private final VoteService voteService;

    @PostMapping("/start")
    public ResponseEntity<Void> startVote(@RequestBody VoteStartRequest request) throws JsonProcessingException {
        voteService.startVote(request);
        return ResponseEntity.ok().build();
    }

    @PostMapping("/cast")
    public ResponseEntity<Void> castVote(@RequestBody VoteCastRequest request) {
        voteService.castVote(request);
        return ResponseEntity.ok().build();
    }

    @PostMapping("/{id}/close")
    public ResponseEntity<Void> closeVote(@PathVariable("id") Long voteId) throws JsonProcessingException {
        voteService.closeVote(voteId);
        return ResponseEntity.ok().build();
    }

    @GetMapping("/room/{roomName}")
    public ResponseEntity<List<VoteResponse>> getVotesByRoom(@PathVariable("roomName") String roomName) {
        return ResponseEntity.ok(voteService.getVotesByRoom(roomName));
    }
}
