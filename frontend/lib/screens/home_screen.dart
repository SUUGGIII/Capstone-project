// 기능: Room ID를 입력받아 특정 화상 회의 방에 참여하는 기능을 제공하는 화면을 구현함. (현재 앱의 주된 흐름에서는 MeetingPage에서 "참가" 버튼 클릭 시 호출되지만, PreJoinPage를 거치지 않고 바로 RoomScreen으로 이동하는 방식이므로, PreJoinPage를 사용하는 create_room.dart와는 다른 흐름으로 보임.)
// 호출: room_screen.dart의 RoomScreen을 호출하여 입력된 Room ID로 회의 화면으로 이동함.
// 호출됨: meeting_page.dart 파일에서 "참가" 버튼 클릭 시 HomeScreen 위젯 형태로 호출됨.
import 'package:flutter/material.dart';
import 'package:meeting_app/screens/room_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _roomIdController = TextEditingController();

  @override
  void dispose() {
    _roomIdController.dispose();
    super.dispose();
  }

  void _joinRoom() {
    if (_roomIdController.text.isNotEmpty) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => RoomScreen(roomId: _roomIdController.text),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('WebRTC Audio Chat'),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextField(
                controller: _roomIdController,
                decoration: const InputDecoration(
                  labelText: 'Enter Room ID',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _joinRoom,
                child: const Text('Join Room'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
