// 기능: 사용자 로그인 기능을 제공하는 페이지를 구현함. 이메일/비밀번호 기반의 자체 로그인과 Naver, Google 등 소셜 로그인 기능을 지원함. 로그인 성공 시 사용자 인증 토큰을 저장하고 메인 페이지로 이동함.
// 호출: home_page.dart의 HomePage를 호출하여 로그인 성공 시 메인 화면으로 이동함. http 패키지를 사용하여 백엔드 API와 통신하여 로그인 및 토큰 갱신을 처리함. shared_preferences를 사용하여 인증 토큰을 저장함. url_launcher를 사용하여 소셜 로그인 시 외부 브라우저를 실행함.
// 호출됨: main.dart 파일에서 앱의 초기 화면으로 LoginPage 위젯 형태로 호출됨.
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../home_page.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:io';
import 'package:url_launcher/url_launcher.dart';


const String _backendApiBaseUrl = 'http://localhost:8080';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {

  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 48.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset('assets/zoom_logo.png', height: 50),
              const SizedBox(height: 12),
              Text(
                'MeetingApp',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).textTheme.bodyLarge?.color,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                '캡스톤디자인 1',
                style: TextStyle(
                  fontSize: 14,
                  color: Theme.of(context).textTheme.bodyMedium?.color,
                ),
              ),
              const SizedBox(height: 40),
              Align(
                alignment: Alignment.centerLeft,
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  child: IconButton(
                    icon: Icon(Icons.arrow_back, color: Theme.of(context).iconTheme.color),
                    onPressed: () {},
                    tooltip: '뒤로',
                  ),
                ),
              ),
              const SizedBox(height: 24),
              TextField(
                controller: _usernameController,
                decoration: InputDecoration(
                  hintText: '이메일 또는 전화번호',
                ),
                style: const TextStyle(color: Colors.black87),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _passwordController,
                obscureText: true, // 비밀번호를 가리는 속성
                decoration: InputDecoration(
                  hintText: '비밀번호',
                ),
                style: const TextStyle(color: Colors.black87),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () async {
                  final username = _usernameController.text;
                  final password = _passwordController.text;
                  print('username: $username, Password: $password');
                  try {
                    await login(username, password);
                    print('Login successful.');
                    if (mounted) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const HomePage()),
                      );
                    }
                  } catch (e) {
                    print('Login failed: $e');
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('로그인 실패: 이메일 또는 비밀번호를 확인해주세요.'),
                          backgroundColor: Colors.red,
                        ),
                      );
                    }
                  }
                },
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size.fromHeight(55),
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.0),
                  ),
                  elevation: 0,
                ),
                child: const Text(
                  '다음',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
              const SizedBox(height: 30),
              Row(
                children: [
                  Expanded(child: Divider(color: Colors.grey[300])),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Text(
                      '또는 다음으로 로그인',
                      style: TextStyle(color: Colors.grey[600], fontSize: 13),
                    ),
                  ),
                  Expanded(child: Divider(color: Colors.grey[300])),
                ],
              ),
              const SizedBox(height: 30),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildSocialLoginButton(
                    'Naver',
                    Icons.vpn_key,
                    onPressed: () => handleSocialLogin("naver"),
                  ),
                  _buildSocialLoginButton(
                    'Google',
                    Icons.g_mobiledata,
                    onPressed: () => handleSocialLogin("google"),
                  ),
                  _buildSocialLoginButton(
                    'Apple',
                    Icons.apple,
                    onPressed: () {},
                  ),
                  _buildSocialLoginButton(
                    'Facebook',
                    Icons.facebook,
                    onPressed: () {},
                  ),
                  _buildSocialLoginButton(
                    'Microsoft',
                    Icons.business,
                    onPressed: () {},),
                ],
              ),
              const SizedBox(height: 40),
              TextButton(
                onPressed: () {},
                child: Text(
                  '계정이 없으신가요? 가입',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.primary,
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const SizedBox(height: 60),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  TextButton(
                    onPressed: () {},
                    child: Text(
                      '약관',
                      style: TextStyle(color: Theme.of(context).colorScheme.primary, fontSize: 13),
                    ),
                  ),
                  Text(
                    ' | ',
                    style: TextStyle(color: Colors.grey[400], fontSize: 13),
                  ),
                  TextButton(
                    onPressed: () {},
                    child: Text(
                      '개인정보 보호',
                      style: TextStyle(color: Theme.of(context).colorScheme.primary, fontSize: 13),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
  Widget _buildSocialLoginButton(String text, IconData icon, {required VoidCallback onPressed}) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        width: 60,
        height: 60,
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: Colors.grey.shade300, width: 1.5),
          borderRadius: BorderRadius.circular(12.0),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              spreadRadius: 1,
              blurRadius: 3,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 28, color: Colors.black54),
            const SizedBox(height: 4),
            Text(text, style: const TextStyle(fontSize: 10, color: Colors.black54)),
          ],
        ),
      ),
    );
  }

  // 자체 로그인
  Future<void> login(String username, String password) async {
    final url = Uri.parse('$_backendApiBaseUrl/login');
    final response = await http.post(
      url,
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, String>{
        'username': username,
        'password': password,
      }),
    );
    if (response.statusCode == 200) {
      // 응답 본문에서 JWT 추출
      final Map<String, dynamic> data = jsonDecode(response.body);
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('accessToken', data['accessToken']);
      await prefs.setString('refreshToken', data['refreshToken']);
    } else {
      throw Exception('로그인 실패 (HTTP ${response.statusCode})');
    }
  }


  // 소셜 로그인
  void handleSocialLogin(String provider) async {

    // 💡 1. 로컬 포트 및 리다이렉트 URI 설정
    const int localPort = 8085; // 임의의 포트 설정

    HttpServer? server;
    try {
      // 로컬 HTTP 서버 시작
      server = await HttpServer.bind(InternetAddress.loopbackIPv4, localPort);
      final String redirectUri = 'http://localhost:$localPort/oauth_callback';
      print('Local server listening on $redirectUri');


      // 브라우저 열기 (백엔드에 로컬 리다이렉트 URI 전달)
      // 백엔드가 이 redirect_uri를 최종 토큰 전달에 사용한다고 가정합니다.
      final String authUrl = '$_backendApiBaseUrl/oauth2/authorization/$provider?redirect_uri=$redirectUri';
      await launchUrl(Uri.parse(authUrl), mode: LaunchMode.externalApplication);

      // 💡 4. 리다이렉트 대기 및 토큰 처리
      await for (var request in server) {

        if (request.uri.path == '/oauth_callback') {

          // 💡 토큰 파싱 (백엔드가 쿼리 파라미터로 토큰을 전달한다고 가정)
          final uri = request.uri;
          final String? receivedRefreshToken = uri.queryParameters['refreshToken'];

          // 사용자에게 성공 메시지를 브라우저에 표시하고 창을 닫도록 유도
          request.response
            ..statusCode = HttpStatus.ok
            ..headers.contentType = ContentType.html
            ..write('<html><body><h1>인증 성공!</h1><p>토큰 교환 후 앱으로 돌아갑니다. 이 창을 닫아주세요.</p></body></html>')
            ..close();
          await request.response.close();

          // 💡 5. 서버 중지 및 인증 완료
          await server.close(force: true);

          if (receivedRefreshToken != null) {

            // 수신된 Refresh Token을 사용하여 Access/New Refresh Token 교환 요청
            try {
              await refreshAndSaveTokens(receivedRefreshToken);

              if (mounted) {
                // 홈 페이지로 이동 (Navigator.pushReplacement로 변경하여 뒤로 가기 방지)
                Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const HomePage()));
              }
            } catch (e) {
              _showErrorSnackBar('토큰 교환 실패: $e');
            }

          } else {
          _showErrorSnackBar('소셜 로그인 실패: Refresh Token을 받지 못했습니다.');
        }
        return; // 리스너 루프 종료
      } else {
        // 기타 요청 무시
        request.response.statusCode = HttpStatus.notFound;
        request.response.close();
        }
      }
    } catch (e) {
      // 포트 0은 충돌이 없어야 하므로, 바인딩 자체가 실패하면 다른 네트워크 오류일 가능성이 높습니다.
      _showErrorSnackBar('로컬 서버 시작 중 치명적인 오류 발생: $e');
      server?.close(force: true);
      return;
    }
  }

  // 새로운 토큰 교환 로직 추가 (Access/New Refresh Token을 얻기 위해 사용)
  Future<void> refreshAndSaveTokens(String refreshToken) async {
    // POST /jwt/refresh 엔드포인트 호출
    final url = Uri.parse('$_backendApiBaseUrl/jwt/refresh');
    final response = await http.post(
      url,
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      // RefreshRequestDTO 구조에 맞춰 'refreshToken' 키 사용
      body: jsonEncode(<String, String>{
        'refreshToken': refreshToken,
      }),
    );

    if (response.statusCode == 200) {
      // JWTResponseDTO에서 두 토큰을 받습니다.
      final Map<String, dynamic> data = jsonDecode(response.body);
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('accessToken', data['accessToken']);
      await prefs.setString('refreshToken', data['refreshToken']);
    } else {
      throw Exception('Refresh Token 교환 실패: HTTP ${response.statusCode}');
    }
  }

  // 토큰 저장 도우미 함수 (SharedPreferences)
  Future<void> _saveTokens(String accessToken, String refreshToken) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('accessToken', accessToken);
    await prefs.setString('refreshToken', refreshToken);
  }

  // 에러 메시지 표시 도우미 함수
  void _showErrorSnackBar(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}
