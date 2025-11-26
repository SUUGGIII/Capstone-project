// 기능: AI 어시스턴트 사이드바 내에서 회의 요약(Summary)을 표시하는 카드 위젯을 구현함. 닫기 버튼을 통해 카드 제거 기능을 제공함.
// 호출: flutter/material.dart의 기본 위젯들을 사용하여 UI를 구성함. 다른 커스텀 위젯이나 파일을 직접 호출하지 않음.
// 호출됨: ai_assistant_sidebar.dart 파일에서 AiSummaryCard 위젯 형태로 호출되어 사용됨.
import 'package:flutter/material.dart';

class AiSummaryCard extends StatelessWidget {
  const AiSummaryCard({super.key});

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
              onPressed: () {
                // No action for now
              },
              child: const Text('요청'),
            ),
          ),
        ],
      ),
    );
  }
}
