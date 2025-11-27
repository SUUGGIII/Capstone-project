package com.example.webrtc_signal_server.api;


import com.example.webrtc_signal_server.domain.session.dto.SessionCreateRequestDTO;
import com.example.webrtc_signal_server.domain.session.dto.SessionSummaryResponseDTO;
import com.example.webrtc_signal_server.domain.session.service.SessionService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/sessions")
@RequiredArgsConstructor
public class SessionController {
    private final SessionService sessionService;

    @PostMapping
    public ResponseEntity<String> createSession(@RequestBody SessionCreateRequestDTO requestDto) {
        Long sessionId = sessionService.createSession(requestDto);
        return ResponseEntity.ok("Session created successfully. ID: " + sessionId);
    }

    @GetMapping("/user/{userId}")
    public ResponseEntity<List<SessionSummaryResponseDTO>> getMySessions(
            @PathVariable Long userId
    ) {
        List<SessionSummaryResponseDTO> sessions = sessionService.getMySessions(userId);
        return ResponseEntity.ok(sessions);
    }
}
