// 기능: AI 어시스턴트 사이드바 위젯을 구현함. 외부에서 전달된 voteEvent가 있을 경우, 투표 카드를 표시함.
// 호출: AiVoteCard 위젯을 직접 호출하여 사이드바 내부에 표시함.
// 호출됨: room.dart 파일에서 AiAssistantSidebar 위젯 형태로 호출되어 화상 회의 화면의 사이드바 영역에 표시될 것으로 추정됨.
import 'package:flutter/material.dart';
import 'package:meeting_app/models/vote_model.dart';
import 'package:meeting_app/widgets/Rooms/AI_sidebar/ai_vote_card.dart';

class AiAssistantSidebar extends StatelessWidget {
  final VoteEvent? voteEvent;
  final VoidCallback onVoteClear;
  final String? roomName;
  final String? voterId;

  const AiAssistantSidebar({
    super.key,
    this.voteEvent,
    required this.onVoteClear,
    this.roomName,
    this.voterId,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 300,
      color: Colors.lightBlue.shade50,
      padding: const EdgeInsets.all(16.0),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'AI 어시스턴트',
              style: TextStyle(color: Colors.black, fontSize: 20),
            ),
            const SizedBox(height: 20),
            if (voteEvent != null && roomName != null && voterId != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 20),
                child: AiVoteCard(
                  voteEvent: voteEvent!,
                  roomName: roomName!,
                  voterId: voterId!,
                  onRemove: onVoteClear,
                ),
              ),
            // Other cards like Summary and Action-Items can be added here
            // based on state passed from the parent widget.
          ],
        ),
      ),
    );
  }
}
