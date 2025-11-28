package com.example.webrtc_signal_server.domain.user.dto;

public record UserResponseDTO(Long id, String username, Boolean social, String nickname, String email, int age, String occupation, String sex) {
}
