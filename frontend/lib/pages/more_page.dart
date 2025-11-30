// 기능: 앱의 추가 기능 및 설정에 접근할 수 있는 "더보기" 페이지를 구현함. 설정, 도움말, 정보, 로그아웃과 같은 메뉴 항목을 리스트 형태로 제공함.
// 호출: flutter/material.dart의 기본 위젯(Card, ListTile 등)을 사용하여 UI를 구성함. 현재는 다른 커스텀 페이지를 직접 호출하지 않음. (향후 각 메뉴에 해당하는 페이지 또는 로그아웃 시 LoginPage 호출 예상).
// 호출됨: home_page.dart 파일에서 MorePage 위젯 형태로 호출되어 메인 화면의 탭 중 하나로 사용됨.
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:meeting_app/services/user_store.dart';
import 'package:meeting_app/pages/login_page.dart';

class MorePage extends StatelessWidget {
  const MorePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(32.0),
      alignment: Alignment.topLeft,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '더보기',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 24),
          Expanded(
            child: ListView(
              children: [
                _buildMoreOption(
                  context,
                  Icons.help_outline,
                  '도움말',
                  onTap: () => _showHelpDialog(context),
                ),
                _buildMoreOption(
                  context,
                  Icons.info_outline,
                  '정보',
                  onTap: () => _showAboutDialog(context),
                ),
                _buildMoreOption(
                  context,
                  Icons.logout,
                  '로그아웃',
                  onTap: () => _handleLogout(context),
                  textColor: Colors.red,
                  iconColor: Colors.red,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMoreOption(
    BuildContext context,
    IconData icon,
    String title, {
    required VoidCallback onTap,
    Color? textColor,
    Color? iconColor,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12.0),
      elevation: 0.5,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        leading: Icon(icon, color: iconColor ?? Colors.blue),
        title: Text(
          title,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: textColor ?? Colors.black87,
          ),
        ),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
        onTap: onTap,
      ),
    );
  }

  void _showHelpDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('도움말'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('• 회의 참가: 코드를 입력하여 입장하세요.'),
            SizedBox(height: 8),
            Text('• 새 회의: 새로운 회의 방을 만드세요.'),
            SizedBox(height: 8),
            Text('• 고객 센터: support@meetingapp.com'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('닫기'),
          ),
        ],
      ),
    );
  }

  void _showAboutDialog(BuildContext context) {
    showAboutDialog(
      context: context,
      applicationName: 'MeetingApp',
      applicationVersion: '1.0.0',
      applicationIcon: const Icon(Icons.videocam, size: 40, color: Colors.blue),
      children: [
        const SizedBox(height: 16),
        const Text('이 앱은 캡스톤 디자인 프로젝트의 일환으로 개발되었습니다.'),
        const SizedBox(height: 8),
        const Text('© 2025 MeetingApp Team. All rights reserved.'),
      ],
    );
  }

  Future<void> _handleLogout(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('로그아웃'),
        content: const Text('정말 로그아웃 하시겠습니까?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('취소'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('로그아웃'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      // 1. 로컬 저장소 초기화
      final prefs = await SharedPreferences.getInstance();
      await prefs.clear();

      // 2. 전역 상태 초기화
      UserStore().clear();

      if (context.mounted) {
        // 3. 로그인 화면으로 이동 (이전 스택 모두 제거)
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const LoginPage()),
          (route) => false,
        );
      }
    }
  }
}
