package com.example.webrtc_signal_server.model;
public class SignalMessage {
    private String type;      // 메시지 타입: "join", "offer", "answer", "ice-candidate", "leave"
    private String sender;    // 메시지를 보낸 사용자 ID
    private String receiver;  // 메시지를 받을 사용자 ID (offer, answer, ice-candidate에서 사용)
    private String room;      // 방 ID
    private Object data;      // 실제 데이터 (SDP, ICE Candidate 정보 등)

    // Lombok 어노테이션(@Data)을 사용하거나 직접 Getter/Setter를 생성합니다.
    // Getters and Setters ...
    public String getType() { return type; }
    public void setType(String type) { this.type = type; }
    public String getSender() { return sender; }
    public void setSender(String sender) { this.sender = sender; }
    public String getReceiver() { return receiver; }
    public void setReceiver(String receiver) { this.receiver = receiver; }
    public String getRoom() { return room; }
    public void setRoom(String room) { this.room = room; }
    public Object getData() { return data; }
    public void setData(Object data) { this.data = data; }
}
