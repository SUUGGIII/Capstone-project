package com.example.webrtc_signal_server.domain.vote.repository;

import com.example.webrtc_signal_server.domain.vote.entity.Vote;
import org.springframework.data.jpa.repository.JpaRepository;

public interface VoteRepository extends JpaRepository<Vote, Long> {
}
