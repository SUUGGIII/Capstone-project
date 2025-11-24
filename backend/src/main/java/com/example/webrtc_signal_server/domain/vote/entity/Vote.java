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
public class Vote {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(nullable = false)
    private String roomName;

    @Column(nullable = false)
    private String topic;

    @Lob
    @Column(nullable = false)
    private String options; // JSON string of List<String>

    @Column(nullable = false)
    private String proposerId;

    @Enumerated(EnumType.STRING)
    @Column(nullable = false)
    private VoteStatus status;

    @CreatedDate
    @Column(updatable = false)
    private LocalDateTime createdAt;

    public static Vote of(String roomName, String topic, String options, String proposerId) {
        Vote vote = new Vote();
        vote.roomName = roomName;
        vote.topic = topic;
        vote.options = options;
        vote.proposerId = proposerId;
        vote.status = VoteStatus.OPEN;
        return vote;
    }

    public void close() {
        this.status = VoteStatus.CLOSED;
    }
}
