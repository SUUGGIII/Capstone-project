package com.example.webrtc_signal_server.domain.vote.repository;

import com.example.webrtc_signal_server.domain.vote.entity.VoteResult;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;

public interface VoteResultRepository extends JpaRepository<VoteResult, Long> {
    List<VoteResult> findAllByVote_Id(Long voteId);
}
