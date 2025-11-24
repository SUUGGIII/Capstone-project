package com.example.webrtc_signal_server.domain.vote.dto;

import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@NoArgsConstructor
public class VoteCastRequest {
    private Long voteId;
    private String voterId;
    private String selectedOption;
}
