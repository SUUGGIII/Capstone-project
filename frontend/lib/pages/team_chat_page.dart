import 'package:flutter/material.dart';

class TeamChatPage extends StatelessWidget {
  const TeamChatPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 250,
          color: Colors.grey[100],
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    '팀 채팅',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  IconButton(
                    icon: const Icon(Icons.add_circle_outline),
                    onPressed: () {},
                  ),
                ],
              ),
              const SizedBox(height: 16),
              TextField(
                decoration: InputDecoration(
                  hintText: '검색',
                  prefixIcon: const Icon(Icons.search),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.0),
                    borderSide: BorderSide.none,
                  ),
                  filled: true,
                  fillColor: Colors.white,
                  contentPadding: const EdgeInsets.symmetric(vertical: 8.0),
                ),
              ),
              const SizedBox(height: 16),
              ListTile(
                leading: const Icon(Icons.star_border),
                title: const Text('즐겨찾기'),
                onTap: () {},
              ),
              ListTile(
                leading: const Icon(Icons.person_outline),
                title: const Text('DM 및 채널'),
                onTap: () {},
              ),
              ListTile(
                leading: const Icon(Icons.group_outlined),
                title: const Text('채널'),
                onTap: () {},
              ),
              const Spacer(),
              ListTile(
                leading: const Icon(Icons.more_horiz),
                title: const Text('더 보기'),
                onTap: () {},
              ),
            ],
          ),
        ),
        Expanded(
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(16.0),
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border(bottom: BorderSide(color: Colors.grey.shade200)),
                ),
                child: Row(
                  children: [
                    const Text(
                      '받는 사람:',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: TextField(
                        decoration: InputDecoration(
                          hintText: '이름, 그룹, 채널 또는 이메일 주소',
                          border: InputBorder.none,
                          isDense: true,
                          contentPadding: EdgeInsets.zero,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Image.asset(
                        'assets/hi_hand.png',
                        height: 120,
                      ),
                      const SizedBox(height: 24),
                      Text(
                        '새 대화를 시작합니다.',
                        style: TextStyle(fontSize: 18, color: Colors.grey[700]),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '아래에서 메시지 작성을 시작하세요.',
                        style: TextStyle(fontSize: 14, color: Colors.grey[500]),
                      ),
                    ],
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.all(16.0),
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border(top: BorderSide(color: Colors.grey.shade200)),
                ),
                child: Column(
                  children: [
                    TextField(
                      decoration: InputDecoration(
                        hintText: '메시지...',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8.0),
                          borderSide: BorderSide.none,
                        ),
                        filled: true,
                        fillColor: Colors.grey[50],
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
                      ),
                      maxLines: 3,
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            IconButton(icon: const Icon(Icons.format_bold), onPressed: () {}),
                            IconButton(icon: const Icon(Icons.format_italic), onPressed: () {}),
                            IconButton(icon: const Icon(Icons.format_underline), onPressed: () {}),
                            IconButton(icon: const Icon(Icons.insert_emoticon), onPressed: () {}),
                            IconButton(icon: const Icon(Icons.attach_file), onPressed: () {}),
                            IconButton(icon: const Icon(Icons.image), onPressed: () {}),
                            IconButton(icon: const Icon(Icons.code), onPressed: () {}),
                          ],
                        ),
                        Row(
                          children: [
                            IconButton(icon: const Icon(Icons.more_horiz), onPressed: () {}),
                            IconButton(icon: const Icon(Icons.send), onPressed: () {}),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
