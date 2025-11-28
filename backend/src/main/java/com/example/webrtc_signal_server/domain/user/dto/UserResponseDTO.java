package com.example.webrtc_signal_server.domain.user.dto;

public record UserResponseDTO(Long id, String username, String nickname, String email, Integer age, String sex, String occupation) {
}
