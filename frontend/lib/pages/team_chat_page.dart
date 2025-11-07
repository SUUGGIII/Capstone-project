// 기능: 팀원 간의 실시간 채팅 기능을 제공하는 페이지를 구현함. 메시지 목록을 표시하고, 메시지 입력 필드를 통해 새로운 메시지를 전송할 수 있도록 함.
// 호출: _ChatMessage 위젯을 호출하여 개별 채팅 메시지를 표시하고, _MessageInputField 위젯을 호출하여 메시지 입력 UI를 구성함. flutter/material.dart의 기본 위젯들을 사용하여 UI를 구성함.
// 호출됨: home_page.dart 파일에서 TeamChatPage 위젯 형태로 호출되어 메인 화면의 탭 중 하나로 사용됨.
import 'package:flutter/material.dart';

class TeamChatPage extends StatelessWidget {
  const TeamChatPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('팀 채팅'),
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        elevation: 1,
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16.0),
              children: const [
                _ChatMessage(isMe: false, sender: '이땡땡', text: '안녕하세요, 오늘 회의 자료입니다.'),
                _ChatMessage(isMe: true, sender: '나', text: '네, 감사합니다. 확인해보겠습니다.'),
                _ChatMessage(isMe: false, sender: '박땡땡', text: '자료 잘 받았습니다!'),
              ],
            ),
          ),
          _MessageInputField(),
        ],
      ),
    );
  }
}

class _ChatMessage extends StatelessWidget {
  final bool isMe;
  final String sender;
  final String text;

  const _ChatMessage({
    required this.isMe,
    required this.sender,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!isMe)
            const CircleAvatar(
              child: Icon(Icons.person),
            ),
          const SizedBox(width: 8),
          Flexible(
            child: Column(
              crossAxisAlignment: isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
              children: [
                if (!isMe)
                  Text(
                    sender,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Colors.grey),
                  ),
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: isMe ? Colors.blue[600] : Colors.grey[200],
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text(
                    text,
                    style: TextStyle(color: isMe ? Colors.white : Colors.black87),
                  ),
                ),
              ],
            ),
          ),
          if (isMe)
            const SizedBox(width: 8),
          if (isMe)
            const CircleAvatar(
              child: Icon(Icons.person),
            ),
        ],
      ),
    );
  }
}

class _MessageInputField extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(8.0),
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        border: Border(top: BorderSide(color: Colors.grey.shade200)),
      ),
      child: Row(
        children: [
          IconButton(icon: const Icon(Icons.add), onPressed: () {}),
          const Expanded(
            child: TextField(
              decoration: InputDecoration(
                hintText: '메시지 보내기...',
                border: InputBorder.none,
                filled: true,
                fillColor: Colors.white,
              ),
            ),
          ),
          IconButton(icon: const Icon(Icons.send), onPressed: () {}),
        ],
      ),
    );
  }
}