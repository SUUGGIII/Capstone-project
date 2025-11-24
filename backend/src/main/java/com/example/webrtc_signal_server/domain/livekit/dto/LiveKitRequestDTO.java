package com.example.webrtc_signal_server.domain.livekit.dto;

import com.example.webrtc_signal_server.domain.user.dto.UserRequestDTO;
import jakarta.validation.constraints.NotBlank;
import lombok.Getter;
import lombok.Setter;

@Getter



@Setter
public class LiveKitRequestDTO {
    public interface roomGroup {} // 회원 가입시 username 존재 확인
    public interface tokenGroup {}

    @NotBlank(groups = {LiveKitRequestDTO.tokenGroup.class})
    String name;
    @NotBlank(groups = {LiveKitRequestDTO.tokenGroup.class})
    String identity;
    @NotBlank(groups = {LiveKitRequestDTO.tokenGroup.class})
    String metadata;
    @NotBlank(groups = {LiveKitRequestDTO.tokenGroup.class, LiveKitRequestDTO.roomGroup.class})
    String roomName;

}
