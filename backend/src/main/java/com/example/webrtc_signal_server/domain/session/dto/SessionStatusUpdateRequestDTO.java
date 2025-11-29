package com.example.webrtc_signal_server.domain.session.dto;

import com.example.webrtc_signal_server.domain.session.entity.SessionStatus;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@NoArgsConstructor
public class SessionStatusUpdateRequestDTO {
    private String roomName;
    private SessionStatus status;
}
