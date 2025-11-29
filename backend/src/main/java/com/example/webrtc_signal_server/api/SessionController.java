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

    @PatchMapping("/status")
    public ResponseEntity<String> updateSessionStatus(
            @RequestBody com.example.webrtc_signal_server.domain.session.dto.SessionStatusUpdateRequestDTO requestDto
    ) {
        sessionService.updateSessionStatusByName(requestDto.getRoomName(), requestDto.getStatus());
        return ResponseEntity.ok("Session status updated to " + requestDto.getStatus());
    }

    @GetMapping("/{sessionId}/status")
    public ResponseEntity<String> getSessionStatus(@PathVariable Long sessionId) {
        String status = sessionService.getSessionStatus(sessionId);
        return ResponseEntity.ok(status);
    }
}
