package com.example.webrtc_signal_server.domain.vote.repository;

import com.example.webrtc_signal_server.domain.vote.entity.VoteResult;
import org.springframework.data.jpa.repository.JpaRepository;

public interface VoteResultRepository extends JpaRepository<VoteResult, Long> {
}
