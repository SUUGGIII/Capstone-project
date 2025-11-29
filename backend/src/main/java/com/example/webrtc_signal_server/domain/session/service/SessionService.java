package com.example.webrtc_signal_server.domain.session.service;

import com.example.webrtc_signal_server.domain.session.dto.SessionCreateRequestDTO;
import com.example.webrtc_signal_server.domain.session.dto.SessionSummaryResponseDTO;
import com.example.webrtc_signal_server.domain.session.entity.SessionEntity;
import com.example.webrtc_signal_server.domain.session.entity.SessionParticipantEntity;
import com.example.webrtc_signal_server.domain.session.repository.SessionParticipantRepository;
import com.example.webrtc_signal_server.domain.session.repository.SessionRepository;
import com.example.webrtc_signal_server.domain.user.entity.UserEntity;
import com.example.webrtc_signal_server.domain.user.repository.UserRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.ArrayList;
import java.util.List;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
public class SessionService {

    private final SessionRepository sessionRepository;
    private final UserRepository userRepository;
    private final SessionParticipantRepository sessionParticipantRepository;
    private final com.example.webrtc_signal_server.global.service.S3Service s3Service;

    @Transactional
    public Long createSession(SessionCreateRequestDTO requestDto) {

        // 1. 세션 생성
        SessionEntity session = SessionEntity.builder()
                .name(requestDto.getRoomName())
                .participants(new ArrayList<>()) // 초기화
                .boards(new ArrayList<>())       // 초기화
                .build();

        // 2. 참여자 목록 순회 및 저장
        for (SessionCreateRequestDTO.SessionParticipantDTO pDto : requestDto.getParticipants()) {

            // Flutter에서 보낸 identity를 이용해 DB에서 유저 조회
            UserEntity user = userRepository.findById(pDto.getIdentity())
                    .orElseThrow(() -> new IllegalArgumentException("사용자를 찾을 수 없습니다: " + pDto.getIdentity()));

            // 참여자 엔티티 생성
            SessionParticipantEntity participantEntity = SessionParticipantEntity.builder()
                    .build();

            // 3. 연관관계 설정 (제공해주신 편의 메소드 활용)
            participantEntity.associateUser(user); // 유저 연결
            session.addParticipant(participantEntity); // 세션 연결 (양방향)
        }

        // 4. 세션 저장 (CascadeType.ALL 설정이 되어있으므로 participants도 함께 저장됨)
        SessionEntity savedSession = sessionRepository.save(session);

        return savedSession.getId();
    }
    public List<SessionSummaryResponseDTO> getMySessions(Long userId) {

        // 1. ID로 조회
        List<SessionParticipantEntity> myParticipations = sessionParticipantRepository.findByUser_Id(userId);

        // 2. DTO 변환 로직 (이전과 동일)
        return myParticipations.stream().map(participation -> {
            SessionEntity session = participation.getSession();

            List<String> nicknames = session.getParticipants().stream()
                    .map(sp -> sp.getUser().getNickname())
                    .collect(Collectors.toList());

            return SessionSummaryResponseDTO.builder()
                    .sessionId(session.getId())
                    .sessionName(session.getName())
                    .participantNicknames(nicknames)
                    .status(session.getStatus().name())
                    .build();
        }).collect(Collectors.toList());
    }


    @Transactional(readOnly = true)
    public String getSessionStatus(Long sessionId) {
        SessionEntity session = sessionRepository.findById(sessionId)
                .orElseThrow(() -> new IllegalArgumentException("Session not found: " + sessionId));
        return session.getStatus().name();
    }

    @Transactional
    public void updateSessionStatusByName(String roomName, com.example.webrtc_signal_server.domain.session.entity.SessionStatus status) {
        SessionEntity session = sessionRepository.findByName(roomName)
                .orElseThrow(() -> new IllegalArgumentException("Session not found with name: " + roomName));
        session.updateStatus(status);
    }

    public String getSessionRecap(Long sessionId) {
        SessionEntity session = sessionRepository.findById(sessionId)
                .orElseThrow(() -> new IllegalArgumentException("Session not found: " + sessionId));
        
        String roomName = session.getName();
        String key = s3Service.findLatestRecapFile(roomName);
        return s3Service.getFileContent(key);
    }
}