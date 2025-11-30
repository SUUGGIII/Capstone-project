import 'package:flutter/material.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  // 설정 상태를 관리하기 위한 더미 변수들
  bool _videoOnEntry = false;
  bool _audioOnEntry = false;
  bool _autoConnectAudio = true;
  bool _pushNotifications = true;
  bool _darkMode = false;
  double _fontSize = 14.0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          '설정',
          style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        elevation: 1,
        iconTheme: const IconThemeData(color: Colors.black87),
      ),
      body: ListView(
        children: [
          _buildSectionHeader('회의 설정'),
          SwitchListTile(
            title: const Text('회의 입장 시 내 비디오 끄기'),
            subtitle: const Text('회의에 참여할 때 항상 비디오를 끈 상태로 시작합니다.'),
            value: !_videoOnEntry, // '끄기' 옵션이므로 반대로 표현하거나 변수명에 맞게 조정
            onChanged: (bool value) {
              setState(() {
                _videoOnEntry = !value;
              });
            },
            secondary: const Icon(Icons.videocam_off),
          ),
          SwitchListTile(
            title: const Text('회의 입장 시 내 마이크 끄기'),
            subtitle: const Text('회의에 참여할 때 항상 마이크를 끈 상태로 시작합니다.'),
            value: !_audioOnEntry,
            onChanged: (bool value) {
              setState(() {
                _audioOnEntry = !value;
              });
            },
            secondary: const Icon(Icons.mic_off),
          ),
           SwitchListTile(
            title: const Text('오디오 자동 연결'),
            subtitle: const Text('인터넷 오디오를 사용하여 자동으로 연결합니다.'),
            value: _autoConnectAudio,
            onChanged: (bool value) {
              setState(() {
                _autoConnectAudio = value;
              });
            },
            secondary: const Icon(Icons.headset),
          ),

          _buildDivider(),

          _buildSectionHeader('일반'),
          SwitchListTile(
            title: const Text('다크 모드'),
            value: _darkMode,
            onChanged: (bool value) {
              setState(() {
                _darkMode = value;
              });
              // 실제 테마 변경 로직은 여기에 추가
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('테마 설정은 준비 중입니다.')),
              );
            },
            secondary: const Icon(Icons.dark_mode),
          ),
          ListTile(
            title: const Text('언어'),
            subtitle: const Text('한국어'),
            leading: const Icon(Icons.language),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () {
               ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('언어 변경 기능은 준비 중입니다.')),
              );
            },
          ),

          _buildDivider(),
          
          _buildSectionHeader('알림'),
          SwitchListTile(
            title: const Text('푸시 알림 받기'),
            value: _pushNotifications,
            onChanged: (bool value) {
              setState(() {
                _pushNotifications = value;
              });
            },
            secondary: const Icon(Icons.notifications),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: Colors.blue[700],
        ),
      ),
    );
  }

  Widget _buildDivider() {
    return const Divider(thickness: 8, color: Color(0xFFF5F5F5));
  }
}
