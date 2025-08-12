package com.example.webrtc_signal_server.model;

import lombok.Getter;
import lombok.Setter;

@Getter
@Setter
public class SignalMessage {
    private String type;      // 메시지 타입: "join", "offer", "answer", "ice-candidate", "leave"
    private String sender;    // 메시지를 보낸 사용자 ID
    private String receiver;  // 메시지를 받을 사용자 ID (offer, answer, ice-candidate에서 사용)
    private String room;      // 방 ID
    private Object data;      // 실제 데이터 (SDP, ICE Candidate 정보 등)
}
