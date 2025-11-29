package com.example.webrtc_signal_server.domain.session.dto;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Getter;
import lombok.NoArgsConstructor;

import java.util.List;

@Getter
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class SessionSummaryResponseDTO {
    private Long sessionId;
    private String sessionName;
    private List<String> participantNicknames; // 세션에 참여 중인 사람들의 닉네임 목록
    private String status;
}
