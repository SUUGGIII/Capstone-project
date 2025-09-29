package com.example.webrtc_signal_server.handler;

import com.example.webrtc_signal_server.domain.jwt.service.JwtService;
import com.example.webrtc_signal_server.util.JWTUtil;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import org.springframework.beans.factory.annotation.Qualifier;
import org.springframework.security.core.Authentication;
import org.springframework.security.web.authentication.AuthenticationSuccessHandler;
import org.springframework.stereotype.Component;

import java.io.IOException;

@Component
@Qualifier("LoginSuccessHandler") //자체로그인 성공 핸들러 나중에 소셜로그인 성공핸들러도 만들예정이므로
public class LoginSuccessHandler implements AuthenticationSuccessHandler {

    private final JwtService jwtService;

    public LoginSuccessHandler(JwtService jwtService) {
        this.jwtService = jwtService;
    }

    @Override
    public void onAuthenticationSuccess(HttpServletRequest request, HttpServletResponse response, Authentication authentication) throws IOException, ServletException {

        // username, role
        String username = authentication.getName();
        String role = authentication.getAuthorities().iterator().next().getAuthority();

        // JWT(Access/Refresh) 발급
        String accessToken = JWTUtil.createJWT(username, role, true);
        String refreshToken = JWTUtil.createJWT(username, role, false);

        // 발급한 Refresh DB 테이블 저장 (Refresh whitelist)
        jwtService.addRefresh(username, refreshToken);

        // 응답
        response.setContentType("application/json");
        response.setCharacterEncoding("UTF-8");

        String json = String.format("{\"accessToken\":\"%s\", \"refreshToken\":\"%s\"}", accessToken, refreshToken);
        response.getWriter().write(json);
        response.getWriter().flush();
    }
}
