// 기능: 등록된 친구 목록을 표시하고 관리하는 페이지를 구현함. 친구 검색, 온라인/회의 중/자리 비움/오프라인 등 상태 확인, 그리고 각 친구에 대한 채팅, 통화, 화상 회의 시작 기능을 제공함.
// 호출: flutter/material.dart의 다양한 기본 위젯(TextField, ListView, Card, ListTile 등)을 사용하여 UI를 구성함. 현재는 다른 커스텀 위젯이나 파일을 직접 호출하지 않음. (향후 채팅, 통화 화면 등 호출 예정).
// 호출됨: home_page.dart 파일에서 FriendsPage 위젯 형태로 호출되어 메인 화면의 탭 중 하나로 사용됨.
import 'package:flutter/material.dart';

class FriendsPage extends StatelessWidget {
  const FriendsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(32.0),
      alignment: Alignment.topLeft,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '친구',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 24),
          TextField(
            decoration: InputDecoration(
              hintText: '친구 검색 또는 추가',
              prefixIcon: const Icon(Icons.search),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12.0),
                borderSide: BorderSide.none,
              ),
              filled: true,
              fillColor: Colors.grey[50],
              contentPadding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
            ),
          ),
          const SizedBox(height: 24),
          Expanded(
            child: ListView(
              children: [
                _buildFriendItem(name: '김철수', status: '온라인', avatarColor: Colors.green),
                _buildFriendItem(name: '이영희', status: '회의 중', avatarColor: Colors.red),
                _buildFriendItem(name: '박민수', status: '자리 비움', avatarColor: Colors.orange),
                _buildFriendItem(name: '최지영', status: '오프라인', avatarColor: Colors.grey),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFriendItem({required String name, required String status, required Color avatarColor}) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12.0),
      elevation: 0.5,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: avatarColor,
          child: Text(
            name[0],
            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
        ),
        title: Text(
          name,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(status),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(icon: const Icon(Icons.message), onPressed: () {}),
            IconButton(icon: const Icon(Icons.call), onPressed: () {}),
            IconButton(icon: const Icon(Icons.videocam), onPressed: () {}),
          ],
        ),
        onTap: () {},
      ),
    );
  }
}
