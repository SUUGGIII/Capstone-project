package com.example.webrtc_signal_server.domain.session.repository;

import com.example.webrtc_signal_server.domain.session.entity.SessionEntity;
import com.example.webrtc_signal_server.domain.user.entity.UserEntity;
import org.springframework.data.jpa.repository.JpaRepository;
import java.util.Optional;

public interface SessionRepository extends JpaRepository<SessionEntity, Long> {
    Optional<SessionEntity> findByName(String name);
}

