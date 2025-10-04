package com.example.webrtc_signal_server.domain.livekit.service;

import com.example.webrtc_signal_server.domain.livekit.dto.LiveKitRequestDTO;
import io.livekit.server.*;
import livekit.LivekitModels;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;
import retrofit2.Call;
import retrofit2.Response;

import java.io.IOException;

@Service
public class LiveKitService {

    private final String host;
    private final String apiKey;
    private final String apiSecret;

    public LiveKitService(
            @Value("${livekit.host}") String host,
            @Value("${livekit.api.key}") String apiKey,
            @Value("${livekit.api.secret}") String apiSecret
    ) {
        this.host = host;
        this.apiKey = apiKey;
        this.apiSecret = apiSecret;
    }

    /**
     * LiveKit 서버에 새 방을 생성하고 방 정보를 반환합니다.
     */
    public LivekitModels.Room createRoom(String roomName) throws IOException {
        // LiveKit 서버 SDK의 RoomServiceClient를 사용하여 방 생성 API를 호출합니다.

        RoomServiceClient client = RoomServiceClient.createClient(host, apiKey, apiSecret);

        Call<LivekitModels.Room> call = client.createRoom(roomName);

        Response<LivekitModels.Room> response = call.execute(); // Use call.enqueue for async
        return response.body();
    }

    /**
     * 클라이언트가 LiveKit 방에 접속하는 데 사용할 액세스 토큰을 생성합니다.
     * 이 토큰은 서버 SDK가 로컬에서 JWT 방식으로 생성하며, LiveKit 서버에 요청을 보내지 않습니다.
     */
    public String createLiveKitToken(LiveKitRequestDTO dto) {
        // 1. AccessToken 객체 생성 (API Key와 Secret을 사용하여 서명 준비)
        AccessToken token = new AccessToken(apiKey, apiSecret);
        // 2. 토큰 메타데이터 및 권한 설정
        token.setName(dto.getName());
        token.setIdentity(dto.getIdentity());
        token.setMetadata(dto.getMetadata());

        token.addGrants(new RoomJoin(true), new RoomName(dto.getRoomName()));

        // 4. JWT 문자열로 서명하고 변환
        return token.toJwt();
    }
}
