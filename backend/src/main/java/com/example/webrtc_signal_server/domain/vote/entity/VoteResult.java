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

    private String roomName;

    private String topic;

    private String voterId;

    private String selectedOption;

    @CreatedDate
    @Column(updatable = false)
    private LocalDateTime createdAt;

    public static VoteResult of(String roomName, String topic, String voterId, String selectedOption) {
        VoteResult voteResult = new VoteResult();
        voteResult.roomName = roomName;
        voteResult.topic = topic;
        voteResult.voterId = voterId;
        voteResult.selectedOption = selectedOption;
        return voteResult;
    }
}
