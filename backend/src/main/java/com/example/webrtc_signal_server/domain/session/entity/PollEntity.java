package com.example.webrtc_signal_server.domain.session.entity;


import com.fasterxml.jackson.annotation.JsonIgnore;
import jakarta.persistence.*;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Getter;
import lombok.NoArgsConstructor;
import org.springframework.data.annotation.CreatedDate;
import org.springframework.data.annotation.LastModifiedDate;
import org.springframework.data.jpa.domain.support.AuditingEntityListener;

import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.List;

@Entity
@Getter
@Builder
@NoArgsConstructor
@AllArgsConstructor
@EntityListeners(AuditingEntityListener.class)
public class PollEntity {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "poll_id")
    private Long id;

    private String title;

    private boolean is_anonymous;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "session_id")
    private SessionEntity session;

    @CreatedDate
    @Column(name = "created_date", updatable = false)
    private LocalDateTime createdDate;

    @LastModifiedDate
    @Column(name = "updated_date")
    private LocalDateTime updatedDate;

    public void associateSession(SessionEntity session) {
        this.session = session;
    }

    @JsonIgnore
    @OneToMany(mappedBy = "poll", cascade = CascadeType.ALL)
    private List<PollOptionEntity> pollOptions = new ArrayList<>();


    @OneToMany(mappedBy = "poll", cascade = CascadeType.ALL)
    private List<PollVoteEntity> pollVotes = new ArrayList<>();

    //연관관계편의 메소드(pollOptions)
    public void addPollOption(PollOptionEntity pollOption) {
        this.pollOptions.add(pollOption);
        pollOption.associatePoll(this);
    }
    //연관관계편의 메소드(pollVotes)
    public void addPollVote(PollVoteEntity pollVote) {
        this.pollVotes.add(pollVote);
        pollVote.associatePoll(this);
    }
}
