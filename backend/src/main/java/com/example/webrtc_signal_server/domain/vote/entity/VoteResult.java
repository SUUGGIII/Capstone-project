package com.example.webrtc_signal_server.domain.vote.entity;

import jakarta.persistence.*;
import lombok.AccessLevel;
import lombok.Getter;
import lombok.NoArgsConstructor;
import org.springframework.data.annotation.CreatedDate;
import org.springframework.data.jpa.domain.support.AuditingEntityListener;

import java.time.LocalDateTime;

@Getter
@Entity
@NoArgsConstructor(access = AccessLevel.PROTECTED)
@EntityListeners(AuditingEntityListener.class)
public class VoteResult {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "vote_id", nullable = false)
    private Vote vote;

    @Column(nullable = false)
    private String voterId;

    @Column(nullable = false)
    private String selectedOption;

    @CreatedDate
    @Column(updatable = false)
    private LocalDateTime createdAt;

    public static VoteResult of(Vote vote, String voterId, String selectedOption) {
        VoteResult voteResult = new VoteResult();
        voteResult.vote = vote;
        voteResult.voterId = voterId;
        voteResult.selectedOption = selectedOption;
        return voteResult;
    }
}
