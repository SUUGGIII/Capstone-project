package com.example.webrtc_signal_server.domain.livekit.service;

import com.example.webrtc_signal_server.domain.livekit.dto.LiveKitRequestDTO;
import io.livekit.server.*;
import livekit.LivekitEgress;
import livekit.LivekitModels;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;
import retrofit2.Call;
import retrofit2.Response;

import java.io.IOException;
import java.util.List;
import java.util.Optional;
import java.util.concurrent.Executors;
import java.util.concurrent.ScheduledExecutorService;
import java.util.concurrent.TimeUnit;
import java.util.concurrent.atomic.AtomicInteger;

@Service
public class LiveKitService {

    public RoomServiceClient roomServiceClient;
    public EgressServiceClient egressServiceClient;
    public AccessToken accessToken;

    @Value("${cloud.aws.credentials.access-key}")
    private String accessKey;

    @Value("${cloud.aws.credentials.secret-key}")
    private String secretKey;

    @Value("${cloud.aws.s3.bucket}")
    private String bucket;

    @Value("${cloud.aws.region.static}")
    private String region;


    private static final long INTERVAL_MINUTES = 5;
    private final ScheduledExecutorService scheduler = Executors.newSingleThreadScheduledExecutor();

    private volatile LivekitEgress.EgressInfo currentEgressInfo = null;

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

    public void startService(String roomName, String Identity) {
        Runnable periodicTask = () -> {
            try {
                // 1. 이전 Egress 세션 중지
                if (currentEgressInfo != null) {
                    egressServiceClient.stopEgress(currentEgressInfo.getEgressId()).execute();
                }
                LivekitEgress.EgressInfo newInfo = startS3Egress(roomName, Identity);
                if (newInfo != null) {
                    currentEgressInfo = newInfo;
                }
            } catch (IOException e) {
                System.err.println("Egress cycle failed due to network/API error: " + e.getMessage());
                // 오류 발생 시 현재 Egress 상태를 초기화하여 다음 시도에서 재시작을 시도하도록 할 수 있습니다.
                currentEgressInfo = null;
            }
        };

        // 서비스 시작 시 첫 호출을 즉시 실행하고, 이후 5분 간격으로 반복 실행합니다.
        // initialDelay: 30 (즉시 시작), period: INTERVAL_MINUTES (5분 간격), unit: TimeUnit.MINUTES
        this.scheduler.scheduleAtFixedRate(
                periodicTask,
                30,
                INTERVAL_MINUTES * 60,
                TimeUnit.SECONDS
        );
    }
    private String getParticipants(String roomName, String identity) throws IOException {
        Call<List<LivekitModels.ParticipantInfo>> listCall = roomServiceClient.listParticipants(roomName);
        Optional<LivekitModels.ParticipantInfo> targetParticipant = listCall.execute().body().stream().filter(p -> p.getIdentity().equals(identity)).findFirst();
        if (!targetParticipant.isPresent()) {
            System.out.println("Participant " + identity + " not found in room " + roomName);
            return null;
        }
        List<LivekitModels.TrackInfo> tracks = targetParticipant.get().getTracksList();
        return tracks.get(0).getSid();
    }

    private final AtomicInteger egressCounter = new AtomicInteger(0);
    private LivekitEgress.EgressInfo startS3Egress(String roomName, String identity) throws IOException {
        int counter = egressCounter.getAndIncrement();
        String filePath = String.format("%s/%s/%s.wav", roomName, identity, counter); //0.ogg 순차 증가
        LivekitEgress.DirectFileOutput fileOutput = LivekitEgress.DirectFileOutput.newBuilder().
                setFilepath(filePath).
                setS3(LivekitEgress.S3Upload.newBuilder()
                        .setAccessKey(accessKey)
                        .setSecret(secretKey)
                        .setBucket(bucket)
                        .setRegion(region)
                        .setForcePathStyle(true)).
                build();
        String trackId = getParticipants(roomName, identity);
        if (trackId == null) {
            return null;
        } else {
            Call<LivekitEgress.EgressInfo> call = egressServiceClient.startTrackEgress(
                    roomName,
                    fileOutput,
                    trackId);
            Response<LivekitEgress.EgressInfo> response = call.execute();
            return response.body();
        }
    }
//    public LivekitEgress.EgressInfo startWebsocketEgress(LiveKitRequestDTO dto) throws IOException {
//        Call<LivekitEgress.EgressInfo> call = egressServiceClient.startTrackEgress(
//                dto.getRoomName(),
//                "",
//                dto.getIdentity());
//        Response<LivekitEgress.EgressInfo> response = call.execute();
//        LivekitEgress.EgressInfo egressInfo = response.body();
//        return egressInfo;
//    }
}
