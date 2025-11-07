// 기능: AI 어시스턴트 사이드바 위젯을 구현함. 사용자가 투표, 요약, 실행 항목 카드들을 동적으로 추가하고 제거할 수 있도록 관리하며, 각 카드의 표시 여부를 제어함.
// 호출: AiVoteCard, AiSummaryCard, AiActionItemsCard 위젯을 직접 호출하여 사이드바 내부에 표시함.
// 호출됨: room_screen.dart 파일에서 AiAssistantSidebar 위젯 형태로 호출되어 화상 회의 화면의 사이드바 영역에 표시될 것으로 추정됨.
import 'package:flutter/material.dart';
import 'package:meeting_app/widgets/Rooms/AI_sidebar/ai_vote_card.dart';
import 'package:meeting_app/widgets/Rooms/AI_sidebar/ai_summary_card.dart';
import 'package:meeting_app/widgets/Rooms/AI_sidebar/ai_action_items_card.dart';

enum CardType { vote, summary, actionItem }

class AiAssistantSidebar extends StatefulWidget {
  const AiAssistantSidebar({super.key});

  @override
  State<AiAssistantSidebar> createState() => _AiAssistantSidebarState();
}

class _AiAssistantSidebarState extends State<AiAssistantSidebar> {
  List<CardType> _activeCards = [];
  bool _showAddVoteButton = true;
  bool _showAddSummaryButton = true;
  bool _showAddActionItemButton = true;

  @override
  void initState() {
    super.initState();
    // No initial card added automatically
  }

  void _addCard(CardType type) {
    setState(() {
      _activeCards.add(type);
      if (type == CardType.vote) _showAddVoteButton = false;
      if (type == CardType.summary) _showAddSummaryButton = false;
      if (type == CardType.actionItem) _showAddActionItemButton = false;
    });
  }

  void _removeCard(CardType type) {
    setState(() {
      _activeCards.remove(type); // Remove the first occurrence of this type
      if (type == CardType.vote) _showAddVoteButton = true;
      if (type == CardType.summary) _showAddSummaryButton = true;
      if (type == CardType.actionItem) _showAddActionItemButton = true;
    });
  }

  Widget _buildCardWidget(CardType type) {
    switch (type) {
      case CardType.vote:
        return AiVoteCard(onRemove: () => _removeCard(CardType.vote));
      case CardType.summary:
        return AiSummaryCard(onRemove: () => _removeCard(CardType.summary));
      case CardType.actionItem:
        return AiActionItemsCard(onRemove: () => _removeCard(CardType.actionItem));
    }
  }

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
            if (_showAddVoteButton)
              Column(
                children: [
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: Colors.black,
                    ),
                    onPressed: () => _addCard(CardType.vote),
                    child: const Text('Add Vote'),
                  ),
                  const SizedBox(height: 10),
                ],
              ),
            if (_activeCards.contains(CardType.vote))
              Padding(
                padding: const EdgeInsets.only(bottom: 20),
                child: _buildCardWidget(CardType.vote),
              ),
            if (_showAddSummaryButton)
              Column(
                children: [
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: Colors.black,
                    ),
                    onPressed: () => _addCard(CardType.summary),
                    child: const Text('Add Summary'),
                  ),
                  const SizedBox(height: 10),
                ],
              ),
            if (_activeCards.contains(CardType.summary))
              Padding(
                padding: const EdgeInsets.only(bottom: 20),
                child: _buildCardWidget(CardType.summary),
              ),
            if (_showAddActionItemButton)
              Column(
                children: [
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: Colors.black,
                    ),
                    onPressed: () => _addCard(CardType.actionItem),
                    child: const Text('Add Action-Item'),
                  ),
                  const SizedBox(height: 10),
                ],
              ),
            if (_activeCards.contains(CardType.actionItem))
              Padding(
                padding: const EdgeInsets.only(bottom: 20),
                child: _buildCardWidget(CardType.actionItem),
              ),
          ],
        ),
      ),
    );
  }
}
