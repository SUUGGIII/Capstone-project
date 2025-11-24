package com.example.webrtc_signal_server.domain.vote.dto;

import lombok.Data;
import lombok.NoArgsConstructor;

import java.util.List;

@Data
@NoArgsConstructor
public class VoteStartRequest {
    private String roomName;
    private String topic;
    private List<String> options;
    private String proposerId;
}
