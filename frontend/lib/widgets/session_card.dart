import 'package:flutter/material.dart';
import '../services/user_store.dart';

import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../pages/summarize_page.dart';
import '../pages/vote_results_page.dart';

class SessionCard extends StatefulWidget {
  final int sessionId;
  final String sessionName;
  final List<dynamic> participantNicknames;
  final String initialStatus;
  final VoidCallback onTap;

  const SessionCard({
    super.key,
    required this.sessionId,
    required this.sessionName,
    required this.participantNicknames,
    required this.initialStatus,
    required this.onTap,
  });

  @override
  State<SessionCard> createState() => _SessionCardState();
}

class _SessionCardState extends State<SessionCard> {
  bool _isGenerating = false;

  String _getOtherParticipantsString() {
    final myNickname = UserStore().user?.nickname;
    final others = widget.participantNicknames.where((name) => name != myNickname).toList();

    if (others.isEmpty) {
      return "나 혼자 참여 중";
    }
    return others.join(", ");
  }

  Future<String> _fetchLatestStatus() async {
    try {
      final url = Uri.parse('http://localhost:8080/api/sessions/${widget.sessionId}/status');
      final response = await http.get(url);
      
      if (response.statusCode == 200) {
        return response.body;
      } else {
        print("Failed to fetch status: ${response.statusCode}");
        return widget.initialStatus;
      }
    } catch (e) {
      print("Error fetching status: $e");
      return widget.initialStatus;
    }
  }

  Future<void> _handleRecapButton() async {
    if (_isGenerating) return; // 이미 진행 중이면 무시

    // 1. 최신 상태 조회
    final currentStatus = await _fetchLatestStatus();
    print("Session ${widget.sessionId} status: $currentStatus");

    if (!mounted) return;

    // 2. 상태에 따른 로직 수행
    if (currentStatus == "BEFORE_START") {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("아직 회의록 생성이 시작되지 않았습니다. 회의가 종료되었는지 확인해주세요"),
          duration: Duration(seconds: 2),
        ),
      );
    } else if (currentStatus == "IN_PROGRESS") {
      // 버튼 상태 변경
      setState(() {
        _isGenerating = true;
      });

      // 5초 대기 (시뮬레이션)
      await Future.delayed(const Duration(seconds: 5));

      if (mounted) {
        setState(() {
          _isGenerating = false;
        });
      }
    } else if (currentStatus == "COMPLETED") {
      try {
        final url = Uri.parse('http://localhost:8080/api/sessions/${widget.sessionId}/recap');
        final response = await http.get(url);

        if (!mounted) return;

        if (response.statusCode == 200) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => SummarizePage(
                sessionName: widget.sessionName,
                content: response.body,
              ),
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("회의록을 불러오는데 실패했습니다: ${response.statusCode}")),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("오류 발생: $e")),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: widget.onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      widget.sessionName,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Row(
                    children: [
                      ElevatedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => VoteResultsPage(sessionName: widget.sessionName),
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.purple[50],
                          foregroundColor: Colors.purple,
                          elevation: 0,
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        ),
                        child: const Text("투표 결과 보기", style: TextStyle(fontSize: 12)),
                      ),
                      const SizedBox(width: 8), // 간격 추가
                      ElevatedButton(
                        onPressed: _isGenerating ? null : _handleRecapButton,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue[50],
                          foregroundColor: Colors.blue,
                          elevation: 0,
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          disabledBackgroundColor: Colors.blue[50],
                          disabledForegroundColor: Colors.blue,
                        ),
                        child: _isGenerating
                            ? const SizedBox(
                                width: 60,
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    SizedBox(
                                      width: 12,
                                      height: 12,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
                                      ),
                                    ),
                                    SizedBox(width: 8),
                                    Text("생성중..", style: TextStyle(fontSize: 12)),
                                  ],
                                ),
                              )
                            : const Text("회의록 보기", style: TextStyle(fontSize: 12)),
                      ),
                    ],
                  ),
                ],
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
                      _getOtherParticipantsString(),
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
  }
}
