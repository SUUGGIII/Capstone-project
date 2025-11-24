package com.example.webrtc_signal_server.config;

import com.example.webrtc_signal_server.handler.WebSocketSignalHandler;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.web.socket.config.annotation.EnableWebSocket;
import org.springframework.web.socket.config.annotation.WebSocketConfigurer;
import org.springframework.web.socket.config.annotation.WebSocketHandlerRegistry;

@Configuration
@EnableWebSocket
public class WebSocketConfig implements WebSocketConfigurer {

    @Override
    public void registerWebSocketHandlers(WebSocketHandlerRegistry registry) {
        // "/signal" 엔드포인트에 WebSocketSignalHandler를 매핑합니다.
        // setAllowedOrigins("*")는 모든 도메인에서의 접속을 허용합니다 (CORS).
        registry.addHandler(signalHandler(), "/signal")
                .setAllowedOrigins("*");
    }

    @Bean
    public WebSocketSignalHandler signalHandler() {
        return new WebSocketSignalHandler();
    }
}
