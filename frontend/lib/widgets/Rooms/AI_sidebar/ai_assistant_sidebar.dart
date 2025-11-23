// 기능: AI 어시스턴트 사이드바의 컨테이너 역할을 하는 위젯. 외부에서 전달된 자식 위젯들을 리스트 형태로 표시함.
// 호출: 자식 위젯들을 인자로 받아 Column 내부에 표시함.
// 호출됨: room.dart 파일에서 호출되며, 표시할 카드(자식 위젯)들은 room.dart에서 결정하여 전달함.
import 'package:flutter/material.dart';

class AiAssistantSidebar extends StatelessWidget {
  final List<Widget> children;

  const AiAssistantSidebar({
    super.key,
    this.children = const [],
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
              style: TextStyle(color: Colors.black, fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            ...children,
          ],
        ),
      ),
    );
  }
}
