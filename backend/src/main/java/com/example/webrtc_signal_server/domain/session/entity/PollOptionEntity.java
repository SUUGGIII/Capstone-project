package com.example.webrtc_signal_server.domain.session.entity;


import jakarta.persistence.*;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Getter;
import lombok.NoArgsConstructor;

import java.util.ArrayList;
import java.util.List;

@Entity
@Getter
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class PollOptionEntity {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "poll_option_id")
    private Long id;

    private String context;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "poll_id")
    private PollEntity poll;

    @OneToMany(mappedBy = "pollOption", cascade = CascadeType.ALL)
    private List<PollVoteEntity> pollVotes = new ArrayList<>();

    public void associatePoll(PollEntity poll) {
        this.poll = poll;
    }

    //연관관계편의 메소드(pollVotes)
    public void addVote(PollVoteEntity pollVote) {
        this.pollVotes.add(pollVote);
        pollVote.associatePollOption(this);
    }
}
