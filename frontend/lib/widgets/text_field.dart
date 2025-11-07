// 기능: 앱 전반에서 일관된 디자인과 기능을 제공하는 커스텀 텍스트 입력 필드 위젯을 구현함. 라벨과 입력 컨트롤러를 받아 Flutter의 기본 TextField를 감싸서 사용함.
// 호출: flutter/material.dart의 Column, Text, Container, TextField 등 기본 위젯들을 사용하여 UI를 구성함.
// 호출됨: create_room.dart 파일에서 사용자 입력을 받는 필드로 LKTextField 위젯 형태로 호출되어 사용됨. TeamChatPage에서도 사용될 수 있음.
import 'package:flutter/material.dart';

class LKTextField extends StatelessWidget {
  final String label;
  final TextEditingController? ctrl;
  const LKTextField({
    required this.label,
    this.ctrl,
    super.key,
  });

  @override
  Widget build(BuildContext context) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(
              vertical: 15,
              horizontal: 15,
            ),
            decoration: BoxDecoration(
              border: Border.all(
                width: 1,
                color: Colors.white.withValues(alpha: .3),
              ),
              borderRadius: BorderRadius.circular(8),
            ),
            child: TextField(
              controller: ctrl,
              decoration: const InputDecoration.collapsed(
                hintText: '',
              ),
              keyboardType: TextInputType.url,
              autocorrect: false,
            ),
          ),
        ],
      );
}
