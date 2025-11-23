package com.example.webrtc_signal_server.handler;

import com.example.webrtc_signal_server.model.SignalMessage;
import com.fasterxml.jackson.databind.ObjectMapper;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.web.socket.CloseStatus;
import org.springframework.web.socket.TextMessage;
import org.springframework.web.socket.WebSocketSession;
import org.springframework.web.socket.handler.TextWebSocketHandler;

import java.io.IOException;
import java.util.Map;
import java.util.concurrent.ConcurrentHashMap;

public class WebSocketSignalHandler extends TextWebSocketHandler {

    private final Logger logger = LoggerFactory.getLogger(WebSocketSignalHandler.class);
    private final ObjectMapper objectMapper = new ObjectMapper();

    // {roomId -> {userId -> session}} 구조로 방과 사용자 세션을 관리합니다.
    private final Map<String, Map<String, WebSocketSession>> rooms = new ConcurrentHashMap<>();
    // {sessionId -> userId} 및 {sessionId -> roomId} 맵으로 빠른 조회를 지원합니다.
    private final Map<String, String> sessionToUserId = new ConcurrentHashMap<>();
    private final Map<String, String> sessionToRoomId = new ConcurrentHashMap<>();

    @Override
    public void afterConnectionEstablished(WebSocketSession session) {
        logger.info("Connection established: {}", session.getId());
    }

    @Override
    protected void handleTextMessage(WebSocketSession session, TextMessage message) throws Exception {
        SignalMessage signalMessage = objectMapper.readValue(message.getPayload(), SignalMessage.class);
        String userId = signalMessage.getSender();
        String roomId = signalMessage.getRoom();

        switch (signalMessage.getType()) {
            case "join":
                handleJoin(session, userId, roomId);
                break;
            case "offer":
            case "answer":
            case "ice-candidate":
                handleSignalingMessage(signalMessage);
                break;
            default:
                logger.warn("Unknown message type: {}", signalMessage.getType());
        }
    }

    private void handleJoin(WebSocketSession session, String userId, String roomId) throws IOException {
        logger.info("User {} joining room {}", userId, roomId);

        // 1. 방이 없으면 새로 생성합니다.
        rooms.putIfAbsent(roomId, new ConcurrentHashMap<>());
        Map<String, WebSocketSession> room = rooms.get(roomId);

        // 2. 새로운 사용자에게 기존 사용자 목록을 전송합니다.
        SignalMessage existingUsersMessage = new SignalMessage();
        existingUsersMessage.setType("all-users");
        existingUsersMessage.setData(room.keySet()); // 세션 객체 대신 ID 목록 전송
        sendMessage(session, existingUsersMessage);

        // 3. 기존 사용자들에게 새로운 사용자의 입장을 알립니다.
        SignalMessage newUserMessage = new SignalMessage();
        newUserMessage.setType("new-user");
        newUserMessage.setSender(userId);
        broadcast(room, newUserMessage, session);

        // 4. 세션 정보를 저장합니다.
        room.put(userId, session);
        sessionToUserId.put(session.getId(), userId);
        sessionToRoomId.put(session.getId(), roomId);
    }

    private void handleSignalingMessage(SignalMessage signalMessage) throws IOException {
        String roomId = signalMessage.getRoom();
        String receiverId = signalMessage.getReceiver();
        Map<String, WebSocketSession> room = rooms.get(roomId);

        if (room != null) {
            WebSocketSession receiverSession = room.get(receiverId);
            if (receiverSession != null && receiverSession.isOpen()) {
                logger.info("Relaying '{}' from {} to {}", signalMessage.getType(), signalMessage.getSender(), receiverId);
                sendMessage(receiverSession, signalMessage);
            }
        }
    }

    private void handleLeave(WebSocketSession session) throws IOException {
        String userId = sessionToUserId.remove(session.getId());
        String roomId = sessionToRoomId.remove(session.getId());

        if (userId == null || roomId == null) return;

        logger.info("User {} leaving room {}", userId, roomId);
        Map<String, WebSocketSession> room = rooms.get(roomId);
        if (room != null) {
            room.remove(userId);
            if (room.isEmpty()) {
                rooms.remove(roomId);
                logger.info("Room {} is now empty and removed.", roomId);
            } else {
                // 남은 사용자들에게 퇴장 알림
                SignalMessage leaveMessage = new SignalMessage();
                leaveMessage.setType("user-left");
                leaveMessage.setSender(userId);
                broadcast(room, leaveMessage, null);
            }
        }
    }

    @Override
    public void afterConnectionClosed(WebSocketSession session, CloseStatus status) throws Exception {
        handleLeave(session);
        logger.info("Connection closed: {} with status: {}", session.getId(), status);
    }

    // 유틸리티 메소드
    private void sendMessage(WebSocketSession session, Object message) throws IOException {
        session.sendMessage(new TextMessage(objectMapper.writeValueAsString(message)));
    }

    private void broadcast(Map<String, WebSocketSession> room, Object message, WebSocketSession exclude) {
        room.values().forEach(session -> {
            if (session.isOpen() && (exclude == null || !session.getId().equals(exclude.getId()))) {
                try {
                    sendMessage(session, message);
                } catch (IOException e) {
                    logger.error("Error broadcasting message", e);
                }
            }
        });
    }
}
