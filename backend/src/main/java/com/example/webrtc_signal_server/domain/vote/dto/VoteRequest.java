package com.example.webrtc_signal_server.domain.vote.dto;

import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@NoArgsConstructor
public class VoteRequest {
    private String roomName;
    private String topic;
    private String voterId;
    private String selectedOption;
}
