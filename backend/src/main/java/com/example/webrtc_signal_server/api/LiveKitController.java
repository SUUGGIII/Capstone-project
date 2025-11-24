package com.example.webrtc_signal_server.api;

import com.example.webrtc_signal_server.domain.livekit.dto.LiveKitRequestDTO;
import com.example.webrtc_signal_server.domain.livekit.service.LiveKitService;
import livekit.LivekitModels;
import org.springframework.http.HttpStatus;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.validation.annotation.Validated;
import org.springframework.web.bind.annotation.*;
import org.springframework.beans.factory.annotation.Value;


import java.io.IOException;
import java.util.HashMap;
import java.util.Map;


@RestController
@RequestMapping("/api")
public class LiveKitController {

    private final LiveKitService liveKitService;

    public LiveKitController(LiveKitService liveKitService) {
        this.liveKitService = liveKitService;
    }

    // 여기에서 설정에서 읽어온 URL을 저장
    @Value("${livekit.ws-url}")
    private String livekitWsUrl;

    /**
     * LiveKit 서버에 새 방을 생성합니다.
     */
    @PostMapping(
            value = "/livekit/room",
            consumes = MediaType.APPLICATION_JSON_VALUE,
            produces = MediaType.APPLICATION_JSON_VALUE
    )
    public ResponseEntity<LivekitModels.Room> createRoom(@Validated(LiveKitRequestDTO.roomGroup.class) @RequestBody LiveKitRequestDTO dto) {
        try {
            LivekitModels.Room room = liveKitService.createRoom(dto.getRoomName());
            return ResponseEntity.ok(room);
        } catch (IOException e) {
            // 예외 발생 시 500 Internal Server Error 반환
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).build();
        }
    }

    /**
     * 클라이언트가 방에 접속할 수 있도록 액세스 토큰(JWT)을 생성합니다.
     * 이 토큰은 클라이언트 SDK가 LiveKit 서버에 연결할 때 사용됩니다.
     */
    @PostMapping(value = "/livekit/token", consumes = MediaType.APPLICATION_JSON_VALUE)
    public ResponseEntity<Map<String, String>> createJoinToken(@Validated(LiveKitRequestDTO.tokenGroup.class) @RequestBody LiveKitRequestDTO dto) {
        // 서비스 레이어를 통해 토큰 생성 로직을 호출합니다.
        String token = liveKitService.createLiveKitToken(dto);

        // 클라이언트에게 토큰을 JSON 형태로 전달
        Map<String, String> response = new HashMap<>();
        response.put("identity", dto.getIdentity());
        response.put("token", token);
        // 설정에서 가져온 lviekit의 주소 설정
        response.put("url", livekitWsUrl);

        return ResponseEntity.ok(response);
    }
}