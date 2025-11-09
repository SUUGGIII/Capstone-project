package com.example.webrtc_signal_server.config;

import io.livekit.server.AccessToken;
import io.livekit.server.EgressServiceClient;
import io.livekit.server.RoomServiceClient;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;

@Configuration
public class LiveKitConfig {
    private final String host;
    private final String apiKey;
    private final String apiSecret;

    public LiveKitConfig(
            @Value("${livekit.host}") String host,
            @Value("${livekit.api.key}") String apiKey,
            @Value("${livekit.api.secret}") String apiSecret
    ) {
        this.host = host;
        this.apiKey = apiKey;
        this.apiSecret = apiSecret;
    }

    @Bean
    public RoomServiceClient roomClient() {
        RoomServiceClient client = RoomServiceClient.createClient(host, apiKey, apiSecret);
        return client;
    }

    @Bean
    public EgressServiceClient egressClient() {
        EgressServiceClient client = EgressServiceClient.createClient(host, apiKey, apiSecret);
        return client;
    }

    @Bean
    public AccessToken accessToken() {
        return new AccessToken(apiKey, apiSecret);
    }
}
