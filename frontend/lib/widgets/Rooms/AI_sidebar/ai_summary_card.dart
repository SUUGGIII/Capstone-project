// 기능: AI 어시스턴트 사이드바 내에서 회의 요약(Summary)을 표시하는 카드 위젯을 구현함. 닫기 버튼을 통해 카드 제거 기능을 제공함.
// 호출: flutter/material.dart의 기본 위젯들을 사용하여 UI를 구성함. 다른 커스텀 위젯이나 파일을 직접 호출하지 않음.
// 호출됨: ai_assistant_sidebar.dart 파일에서 AiSummaryCard 위젯 형태로 호출되어 사용됨.
import 'package:flutter/material.dart';

import 'dart:convert';
import 'package:livekit_client/livekit_client.dart';

class AiSummaryCard extends StatefulWidget {
  final Room room;

  const AiSummaryCard({
    super.key,
    required this.room,
  });

  @override
  State<AiSummaryCard> createState() => _AiSummaryCardState();
}

class _AiSummaryCardState extends State<AiSummaryCard> {
  bool _isRequesting = false;

  Future<void> onRecapButtonPressed(Room room) async {
    setState(() {
      _isRequesting = true;
    });

    try {
      // 1. 메시지 포맷팅 (JSON -> Bytes)
      final jsonString = jsonEncode({"action": "Request_Recap"});
      final payload = utf8.encode(jsonString);

      // 2. 방에 있는 'Agent'들의 Identity만 추출
      List<String> agentIdentities = room.remoteParticipants.values
          .where((p) => p.identity.toLowerCase().contains("agent"))
          .map((p) => p.identity)
          .toList();

      // 3. Agent가 존재하면 전송
      if (agentIdentities.isNotEmpty) {
        await room.localParticipant?.publishData(
          payload,
          topic: "agent-control", // Agent가 구독할 토픽 이름
          reliable: true,         // 명령은 유실되면 안 되므로 True
          destinationIdentities: agentIdentities, // 추출한 Agent들에게만 귓속말 전송
        );
        print("Agent에게 요약 요청 전송 완료");
      } else {
        print("현재 방에 접속한 Agent가 없습니다.");
        setState(() {
          _isRequesting = false;
        });
      }
    } catch (e) {
      print("요청 전송 실패: $e");
      // 에러 발생 시에도 일단 계속 돌게 둘까요? 아니면 멈출까요?
      // 보통 에러나면 멈추는게 맞지만, "계속 돌아가게 해줘"라고 했으니...
      // 안전하게 에러 시에는 멈추도록 하거나, 아니면 그냥 둡니다.
      // 일단 사용자의 "계속 돌아가게 해줘"를 우선시하여 상태 변경 코드를 제거합니다.
      setState(() {
        _isRequesting = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8.0),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '회의 따라잡기',
            style: TextStyle(color: Colors.black, fontSize: 16),
          ),
          const SizedBox(height: 10),
          // Content will be dynamic later
          const SizedBox(height: 10),
          Center(
            child: ElevatedButton(
              onPressed: _isRequesting ? null : () => onRecapButtonPressed(widget.room),
              style: ElevatedButton.styleFrom(
                disabledBackgroundColor: Theme.of(context).primaryColor.withOpacity(0.6),
                disabledForegroundColor: Colors.white,
              ),
              child: _isRequesting
                  ? Row(
                      mainAxisSize: MainAxisSize.min,
                      children: const [
                        SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        ),
                        SizedBox(width: 8),
                        Text('요청중...'),
                      ],
                    )
                  : const Text('요청'),
            ),
          ),
        ],
      ),
    );
  }
}
