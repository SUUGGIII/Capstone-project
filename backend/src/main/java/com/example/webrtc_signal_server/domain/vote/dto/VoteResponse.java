package com.example.webrtc_signal_server.domain.vote.dto;

import lombok.AllArgsConstructor;
import lombok.Getter;
import lombok.NoArgsConstructor;

import java.util.Map;

@Getter
@NoArgsConstructor
@AllArgsConstructor
public class VoteResponse {
    private Long id;
    private String roomName;
    private String topic;
    private Map<String, Long> results;
    private String status;
}
