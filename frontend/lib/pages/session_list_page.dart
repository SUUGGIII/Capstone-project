import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../services/user_store.dart'; // 내 닉네임 확인용

class SessionListPage extends StatefulWidget {
  const SessionListPage({super.key});

  @override
  State<SessionListPage> createState() => _SessionListPageState();
}

class _SessionListPageState extends State<SessionListPage> {
  // 모델 클래스 대신 Map 리스트를 사용합니다.
  List<dynamic> _sessions = [];
  bool _isLoading = true;
  String? _errorMessage;


  @override
  void initState() {
    super.initState();
    // 페이지가 로드될 때마다 서버에 요청합니다.
    _fetchMySessions();
  }

  Future<void> _fetchMySessions() async {
    final myUserId = UserStore().user?.userId;
    final url = Uri.parse('http://localhost:8080/api/sessions/user/$myUserId');

    try {
      final prefs = await SharedPreferences.getInstance();
      final accessToken = prefs.getString('accessToken');

      if (accessToken == null) {
        setState(() {
          _errorMessage = "로그인이 필요합니다.";
          _isLoading = false;
        });
        return;
      }

      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $accessToken',
        },
      );

      if (response.statusCode == 200) {
        // 모델 변환 과정 없이 바로 JSON 리스트를 저장합니다.
        setState(() {
          _sessions = jsonDecode(response.body);
          _isLoading = false;
        });
      } else {
        setState(() {
          _errorMessage = "불러오기 실패: ${response.statusCode}";
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = "오류 발생: $e";
        _isLoading = false;
      });
    }
  }

  // 닉네임 목록(List<dynamic>)에서 내 닉네임을 뺀 문자열 생성
  String _getOtherParticipantsString(List<dynamic> allNicknames) {
    final myNickname = UserStore().user?.nickname;

    // 내 닉네임 제외
    final others = allNicknames.where((name) => name != myNickname).toList();

    if (others.isEmpty) {
      return "나 혼자 참여 중";
    }
    return others.join(", ");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("내 회의 기록"),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0.5,
      ),
      backgroundColor: Colors.grey[100],
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 48, color: Colors.red),
            const SizedBox(height: 16),
            Text(_errorMessage!),
            ElevatedButton(onPressed: _fetchMySessions, child: const Text("다시 시도"))
          ],
        ),
      );
    }

    if (_sessions.isEmpty) {
      return const Center(child: Text("참여한 회의가 없습니다."));
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _sessions.length,
      itemBuilder: (context, index) {
        // JSON 객체(Map)에 바로 접근합니다. ['키이름']
        final session = _sessions[index];
        final sessionName = session['sessionName'] ?? '이름 없음';
        final nicknames = session['participantNicknames'] ?? [];

        final otherParticipants = _getOtherParticipantsString(nicknames);

        return Card(
          elevation: 2,
          margin: const EdgeInsets.only(bottom: 12),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: InkWell(
            onTap: () {
              // 세션 ID도 Map에서 바로 꺼내서 사용
              print("세션 클릭 ID: ${session['sessionId']}");
            },
            borderRadius: BorderRadius.circular(12),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    sessionName,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Divider(),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(Icons.people, size: 16, color: Colors.grey),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          otherParticipants,
                          style: TextStyle(fontSize: 14, color: Colors.grey[700]),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}