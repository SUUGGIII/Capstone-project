// 기능: 앱의 추가 기능 및 설정에 접근할 수 있는 "더보기" 페이지를 구현함. 설정, 도움말, 정보, 로그아웃과 같은 메뉴 항목을 리스트 형태로 제공함.
// 호출: flutter/material.dart의 기본 위젯(Card, ListTile 등)을 사용하여 UI를 구성함. 현재는 다른 커스텀 페이지를 직접 호출하지 않음. (향후 각 메뉴에 해당하는 페이지 또는 로그아웃 시 LoginPage 호출 예상).
// 호출됨: home_page.dart 파일에서 MorePage 위젯 형태로 호출되어 메인 화면의 탭 중 하나로 사용됨.
import 'package:flutter/material.dart';

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
                _buildMoreOption(Icons.settings, '설정'),
                _buildMoreOption(Icons.help_outline, '도움말'),
                _buildMoreOption(Icons.info_outline, '정보'),
                _buildMoreOption(Icons.logout, '로그아웃'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMoreOption(IconData icon, String title) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12.0),
      elevation: 0.5,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        leading: Icon(icon, color: Colors.blue),
        title: Text(
          title,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
        ),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
        onTap: () {},
      ),
    );
  }
}
