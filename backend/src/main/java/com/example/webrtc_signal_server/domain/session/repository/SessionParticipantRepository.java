package com.example.webrtc_signal_server.domain.session.repository;

import com.example.webrtc_signal_server.domain.session.entity.SessionParticipantEntity;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;

public interface SessionParticipantRepository extends JpaRepository<SessionParticipantEntity, Long> {
    List<SessionParticipantEntity> findByUser_Id(Long userId);
}