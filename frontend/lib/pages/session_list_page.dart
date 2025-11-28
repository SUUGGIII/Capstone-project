import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../services/user_store.dart';

class SessionListPage extends StatefulWidget {
  const SessionListPage({super.key});

  @override
  State<SessionListPage> createState() => _SessionListPageState();
}

class _SessionListPageState extends State<SessionListPage> {
  List<dynamic> _sessions = [];
  bool _isInitialLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _fetchMySessions();
  }

  // 버튼 클릭 시 호출될 함수
  Future<void> _fetchMySessions() async {
    // 로딩바를 다시 보여주고 싶다면 주석 해제
    // setState(() { _isInitialLoading = true; });

    final userStore = UserStore();
    final myUserId = userStore.user?.userId;
    final myNickname = userStore.user?.nickname;

    if (myUserId == null || myNickname == null) {
      if (mounted) {
        setState(() {
          _errorMessage = "사용자 정보를 찾을 수 없습니다.";
          _isInitialLoading = false;
        });
      }
      return;
    }

    final url = Uri.parse('http://localhost:8080/api/sessions/user/$myUserId');

    try {
      final prefs = await SharedPreferences.getInstance();
      final accessToken = prefs.getString('accessToken');

      if (accessToken == null) {
        if (mounted) {
          setState(() {
            _errorMessage = "로그인이 필요합니다.";
            _isInitialLoading = false;
          });
        }
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
        final List<dynamic> allSessions = jsonDecode(response.body);

        final filteredSessions = allSessions.where((session) {
          final participants = session['participantNicknames'] as List<dynamic>? ?? [];
          return participants.contains(myNickname);
        }).toList();

        if (mounted) {
          setState(() {
            _sessions = filteredSessions;
            _errorMessage = null;
            _isInitialLoading = false;
          });
        }
      } else {
        if (mounted) {
          setState(() {
            _errorMessage = "불러오기 실패: ${response.statusCode}";
            _isInitialLoading = false;
          });
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = "오류 발생: $e";
          _isInitialLoading = false;
        });
      }
    }
  }

  String _getOtherParticipantsString(List<dynamic> allNicknames) {
    final myNickname = UserStore().user?.nickname;
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
        // 새로고침 버튼 (이제 이것이 유일한 갱신 수단입니다)
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.black),
            tooltip: '새로고침',
            onPressed: _fetchMySessions,
          ),
        ],
      ),
      backgroundColor: Colors.grey[100],
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    // 1. 로딩 중
    if (_isInitialLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    // 2. 에러 발생 시
    if (_errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 48, color: Colors.red),
            const SizedBox(height: 16),
            Text(_errorMessage!),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _fetchMySessions,
              child: const Text("다시 시도"),
            )
          ],
        ),
      );
    }

    // 3. 데이터가 없을 때
    if (_sessions.isEmpty) {
      return const Center(child: Text("참여한 회의가 없습니다."));
    }

    // 4. 데이터 리스트 (RefreshIndicator 제거됨)
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _sessions.length,
      itemBuilder: (context, index) {
        final session = _sessions[index];
        final sessionName = session['sessionName'] ?? '이름 없음';
        final nicknames = session['participantNicknames'] ?? [];
        final otherParticipants = _getOtherParticipantsString(nicknames);

        return Card(
          elevation: 2,
          margin: const EdgeInsets.only(bottom: 12),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: InkWell(
            onTap: () async {
              print("세션 클릭 ID: ${session['sessionId']}");
              // 상세 페이지 이동 로직...
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