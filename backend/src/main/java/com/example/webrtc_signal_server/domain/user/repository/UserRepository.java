package com.example.webrtc_signal_server.domain.user.repository;

import com.example.webrtc_signal_server.domain.user.entity.UserEntity;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.transaction.annotation.Transactional;

import java.util.Optional;

public interface UserRepository extends JpaRepository<UserEntity, Long> {

    Boolean existsByUsername(String username);

    Optional<UserEntity> findByUsernameAndIsLockAndIsSocial(String username, Boolean isLock, Boolean isSocial);

    Optional<UserEntity> findByUsernameAndIsLock(String username, Boolean isLock);

    Optional<UserEntity> findByUsernameAndIsSocial(String username, Boolean social);

    @Transactional
    void deleteByUsername(String username);
}
