package com.example.webrtc_signal_server.domain.livekit.service;

import com.example.webrtc_signal_server.domain.livekit.dto.LiveKitRequestDTO;
import io.livekit.server.*;
import livekit.LivekitEgress;
import livekit.LivekitModels;
import livekit.LivekitRtc;
import org.springframework.stereotype.Service;
import retrofit2.Call;
import retrofit2.Response;

import java.io.IOException;
import java.nio.charset.StandardCharsets;

@Service
public class LiveKitService {

    public RoomServiceClient roomServiceClient;
    public EgressServiceClient egressServiceClient;
    public AccessToken accessToken;

    public LiveKitService(RoomServiceClient roomServiceClient, EgressServiceClient egressServiceClient, AccessToken accessToken) {
        this.roomServiceClient = roomServiceClient;
        this.egressServiceClient = egressServiceClient;
        this.accessToken = accessToken;
    }

    /**
     * LiveKit 서버에 새 방을 생성하고 방 정보를 반환합니다.
     */
    public LivekitModels.Room createRoom(String roomName) throws IOException {
        // LiveKit 서버 SDK의 RoomServiceClient를 사용하여 방 생성 API를 호출합니다.

        Call<LivekitModels.Room> call = roomServiceClient.createRoom(roomName);

        Response<LivekitModels.Room> response = call.execute(); // Use call.enqueue for async
        return response.body();
    }

    /**
     * 클라이언트가 LiveKit 방에 접속하는 데 사용할 액세스 토큰을 생성합니다.
     * 이 토큰은 서버 SDK가 로컬에서 JWT 방식으로 생성하며, LiveKit 서버에 요청을 보내지 않습니다.
     */
    public String createLiveKitToken(LiveKitRequestDTO dto) {
        // 1. AccessToken 객체 주입 (API Key와 Secret을 사용하여 서명 준비)

        // 2. 토큰 메타데이터 및 권한 설정
        accessToken.setName(dto.getName());
        accessToken.setIdentity(dto.getIdentity());
        accessToken.setMetadata(dto.getMetadata());

        accessToken.addGrants(new RoomJoin(true), new RoomName(dto.getRoomName()));

        // 4. JWT 문자열로 서명하고 변환
        return accessToken.toJwt();
    }

    /**
     * 특정 방의 모든 참가자에게 데이터를 전송합니다.
     * @param roomName 데이터를 보낼 방의 이름
     * @param data 전송할 문자열 데이터
     */
    public void sendDataToRoom(String roomName, String data) {
        try {
            byte[] dataPayload = data.getBytes(StandardCharsets.UTF_8);

            // The correct method signature for this SDK version
            Call<Void> call = roomServiceClient.sendData(roomName, dataPayload, LivekitModels.DataPacket.Kind.RELIABLE);

            // 비동기 실행을 원하면 .enqueue() 사용
            call.execute();
        } catch (IOException e) {
            // 실제 프로덕션 코드에서는 로깅 프레임워크 사용을 권장합니다.
            e.printStackTrace();
        }
    }
    // 트랙 Egress 시작 API 호출 시뮬레이션
//    public Call<LivekitEgress.EgressInfo> startTrackEgress(
//            String roomName,
//            LivekitEgress.DirectFileOutput fileOutput,
//            String trackId) {
//
//        System.out.println("\n--- MOCK API CALL SENT ---");
//        System.out.println("Action: Start Track Egress");
//        System.out.println("Room: " + roomName);
//        System.out.println("Track ID: " + trackId);
//        System.out.println("Output Path: " + fileOutput.filepath);
//        // Simulate a successful API response
//        return new LivekitEgress.Call<LivekitEgress.EgressInfo>() {
//            @Override
//            public LivekitEgress.Response<LivekitEgress.EgressInfo> execute() throws IOException {
//                try {
//                    // 네트워크 지연 시뮬레이션
//                    TimeUnit.MILLISECONDS.sleep(500);
//                } catch (InterruptedException e) {
//                    Thread.currentThread().interrupt();
//                    throw new IOException("API call interrupted", e);
//                }
//                return new LivekitEgress.Response<>(new LivekitEgress.EgressInfo());
//            }
//        };
//    }
}
