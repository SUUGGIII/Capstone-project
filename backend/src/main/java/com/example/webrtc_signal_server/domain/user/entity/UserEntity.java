package com.example.webrtc_signal_server.domain.user.entity;

import com.example.webrtc_signal_server.domain.session.entity.SessionParticipantEntity;
import com.example.webrtc_signal_server.domain.user.dto.UserRequestDTO;
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
@EntityListeners(AuditingEntityListener.class) //엔티티의 변화를 감지하여 자동으로 생성일과 수정일 업데이트 이떄 config 필요
@Table(name="users")
@Getter
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class UserEntity {

    @Id
    @GeneratedValue(strategy=GenerationType.IDENTITY)
    @Column(name = "user_id")
    private Long id;

    @Column(name = "username", unique = true, nullable = false, updatable = false)
    private String username;

    @Column(name = "password", nullable = false)
    private String password;

    @Column(name = "is_lock", nullable = false)
    private Boolean isLock;

    @Column(name = "is_social", nullable = false)
    private Boolean isSocial;

    @Enumerated(EnumType.STRING)
    @Column(name = "social_provider_type")
    private SocialProviderType socialProviderType;

    @Enumerated(EnumType.STRING)
    @Column(name = "role_type", nullable = false)
    private UserRoleType roleType;

    @Column(name = "nickname")
    private String nickname;

    @Column(name = "email")
    private String email;

    private int age;

    private String sex;

    private String occupation;

    @CreatedDate
    @Column(name = "created_date", updatable = false)
    private LocalDateTime createdDate;

    @LastModifiedDate
    @Column(name = "updated_date")
    private LocalDateTime updatedDate;

    @OneToMany(mappedBy = "user", cascade = CascadeType.ALL)
    private List<SessionParticipantEntity> sessionParticipants = new ArrayList<>();



    public void updateUser(UserRequestDTO dto) {
        this.email = dto.getEmail();
        this.nickname = dto.getNickname();
    }

    public void updatePassword(String encodedPassword) {
        this.password = encodedPassword;
    }

    //연관관계편의 메소드(sessionParticipants)
    public void addSessionParticipant(SessionParticipantEntity sessionParticipant) {
        this.sessionParticipants.add(sessionParticipant);
        sessionParticipant.associateUser(this);
    }


}
