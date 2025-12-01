package com.example.webrtc_signal_server.domain.vote.repository;

import com.example.webrtc_signal_server.domain.vote.entity.Vote;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;

public interface VoteRepository extends JpaRepository<Vote, Long> {
    List<Vote> findAllByRoomName(String roomName);
}
