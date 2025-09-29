package com.example.webrtc_signal_server.handler;

import com.example.webrtc_signal_server.domain.jwt.service.JwtService;
import com.example.webrtc_signal_server.util.JWTUtil;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.Cookie;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import org.springframework.beans.factory.annotation.Qualifier;
import org.springframework.security.core.Authentication;
import org.springframework.security.web.authentication.AuthenticationSuccessHandler;
import org.springframework.stereotype.Component;

import java.io.IOException;

@Component
@Qualifier("SocialSuccessHandler")
public class SocialSuccessHandler implements AuthenticationSuccessHandler {

    private final JwtService jwtService;

    public SocialSuccessHandler(JwtService jwtService) {
        this.jwtService = jwtService;
    }

    @Override
    public void onAuthenticationSuccess(HttpServletRequest request, HttpServletResponse response, Authentication authentication) throws IOException, ServletException {

        // username, role
        String username =  authentication.getName();
        String role = authentication.getAuthorities().iterator().next().getAuthority();

        // JWT(Refresh) 발급
        String refreshToken = JWTUtil.createJWT(username, "ROLE_" + role, false);

        // 발급한 Refresh DB 테이블 저장 (Refresh whitelist)
        jwtService.addRefresh(username, refreshToken);

        // 응답
//        Cookie refreshCookie = new Cookie("refreshToken", refreshToken);
//        refreshCookie.setHttpOnly(true);
//        refreshCookie.setSecure(false);
//        refreshCookie.setPath("/");
//        refreshCookie.setMaxAge(10); // 10초 (프론트에서 발급 후 바로 헤더 전환 로직 진행 예정)
//
//        response.addCookie(refreshCookie);
//        response.sendRedirect("http://localhost:3000/cookie");


        // 임시로, Flutter Desktop 앱이 사용하는 로컬 리스너 주소를 사용한다고 가정
        String defaultDesktopRedirect = "http://localhost:8085/oauth_callback";

        String redirectUrlWithTokens = String.format("%s?refreshToken=%s", defaultDesktopRedirect, refreshToken);

        // 최종적으로 클라이언트 (브라우저)를 로컬 리스너로 리다이렉트
        response.sendRedirect(redirectUrlWithTokens);


    }
}
