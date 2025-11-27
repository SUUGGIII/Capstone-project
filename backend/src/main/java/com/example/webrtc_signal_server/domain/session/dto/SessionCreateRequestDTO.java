package com.example.webrtc_signal_server.domain.session.dto;

import lombok.Data;
import lombok.NoArgsConstructor;
import java.util.List;

@Data
@NoArgsConstructor
public class SessionCreateRequestDTO {
    private String roomName;
    private String createdAt; // Flutter에서 보낸 시간 (필요시 사용)
    private List<SessionParticipantDTO> participants;

    @Data
    @NoArgsConstructor
    public static class SessionParticipantDTO {
        private Long identity; // UserEntity를 찾기 위한 Key (예: 이메일 또는 유저 ID)
        private String name;
        private String joinedAt;
    }
}
