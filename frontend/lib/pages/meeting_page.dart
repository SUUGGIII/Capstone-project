// 기능: 회의 관련 주요 기능을 제공하는 페이지를 구현함. "새 회의", "참가", "예약" 버튼을 통해 각각 회의 생성, 회의 참여, 회의 예약 기능으로 연결됨. 예정된 회의 목록을 표시하는 영역을 포함함.
// 호출: create_room.dart의 CreateRoomPage를 호출하여 새 회의 생성 화면으로 이동함. NavigationProvider를 통해 SchedulerPage로 전환하도록 요청함.
// 호출됨: home_page.dart 파일에서 MeetingPage 위젯 형태로 호출되어 메인 화면의 탭 중 하나로 사용됨.
import 'package:flutter/material.dart';
import 'package:meeting_app/pages/Rooms/create_room.dart';
import '../providers/navigation_provider.dart';
import 'package:provider/provider.dart';


class MeetingPage extends StatelessWidget {
  const MeetingPage({super.key});

  @override
  Widget build(BuildContext context) {
    final navProvider = Provider.of<NavigationProvider>(context, listen: false);

    return Container(
      padding: const EdgeInsets.all(32.0),
      alignment: Alignment.topLeft,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '내 회의',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              _buildMeetingActionButton(
                icon: Icons.add_circle,
                label: '새 회의',
                color: Colors.blue,
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const CreateRoomPage()),
                  );
                },
              ),
              const SizedBox(width: 24),
              _buildMeetingActionButton(
                icon: Icons.join_full,
                label: '참가',
                color: Colors.green,
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => Scaffold(
                      appBar: AppBar(title: const Text('Join Room (Placeholder)')),
                      body: const Center(child: Text('This is a placeholder page.')),
                    )),
                  );
                },
              ),
              const SizedBox(width: 24),
              _buildMeetingActionButton(
                icon: Icons.schedule,
                label: '예약',
                color: Colors.orange,
                onPressed: () {
                  navProvider.setSelectedIndex(3);
                },
              ),
            ],
          ),
          const SizedBox(height: 48),
          const Text(
            '예정된 회의',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.calendar_today,
                    size: 80,
                    color: Colors.grey[300],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    '예정된 회의가 없습니다.',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.grey[500],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMeetingActionButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onPressed,
  }) {
    return Column(
      children: [
        ElevatedButton(
          onPressed: onPressed,
          style: ElevatedButton.styleFrom(
            shape: const CircleBorder(),
            padding: const EdgeInsets.all(20),
            backgroundColor: color,
            elevation: 4,
          ),
          child: Icon(icon, size: 30, color: Colors.white),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: const TextStyle(fontSize: 16, color: Colors.black87),
        ),
      ],
    );
  }
}
