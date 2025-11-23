package com.example.webrtc_signal_server.domain.session.entity;

import com.fasterxml.jackson.annotation.JsonIgnore;
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
public class SessionEntity {

    @Id @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "session_id")
    private Long id;

    private String name;

    @OneToMany(mappedBy = "session", cascade = CascadeType.ALL)
    private List<SessionParticipantEntity> participants = new ArrayList<>();

    @JsonIgnore
    @OneToMany(mappedBy = "session")
    private List<BoardEntity> boards = new ArrayList<>();


    //연관관계편의 메소드(participants)
    public void addParticipant(SessionParticipantEntity participant) {
        this.participants.add(participant);
        participant.associateSession(this);
    }

    //연관관계편의 메소드(boards)
    public void addBoard(BoardEntity board) {
        this.boards.add(board);
        board.associateSession(this);
    }

}
