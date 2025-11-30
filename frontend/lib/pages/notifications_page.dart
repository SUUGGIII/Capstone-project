import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class NotificationsPage extends StatelessWidget {
  const NotificationsPage({super.key});

  @override
  Widget build(BuildContext context) {
    // 더미 알림 데이터
    final List<Map<String, dynamic>> notifications = [
      {
        'type': 'meeting',
        'title': '회의 시작 알림',
        'content': "'팀 주간 회의'가 시작되었습니다. 지금 참여하세요!",
        'time': DateTime.now().subtract(const Duration(minutes: 5)),
        'isRead': false,
      },
      {
        'type': 'document',
        'title': '문서 공유됨',
        'content': "'철희'님이 '2025 기획안.pdf'를 공유했습니다.",
        'time': DateTime.now().subtract(const Duration(hours: 2)),
        'isRead': true,
      },
      {
        'type': 'system',
        'title': '업데이트 안내',
        'content': "새로운 버전(1.1.0)이 출시되었습니다. 업데이트 내용을 확인해보세요.",
        'time': DateTime.now().subtract(const Duration(days: 1)),
        'isRead': true,
      },
      {
        'type': 'friend',
        'title': '친구 요청',
        'content': "'민수'님이 친구 요청을 보냈습니다.",
        'time': DateTime.now().subtract(const Duration(days: 3)),
        'isRead': true,
      },
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          '알림',
          style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        elevation: 1,
        iconTheme: const IconThemeData(color: Colors.black87),
        actions: [
          TextButton(
            onPressed: () {},
            child: const Text('모두 읽음'),
          )
        ],
      ),
      body: ListView.separated(
        itemCount: notifications.length,
        separatorBuilder: (context, index) => const Divider(height: 1),
        itemBuilder: (context, index) {
          final noti = notifications[index];
          return Container(
            color: noti['isRead'] ? Colors.white : Colors.blue[50],
            child: ListTile(
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              leading: _buildIcon(noti['type']),
              title: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    noti['title'],
                    style: TextStyle(
                      fontWeight: noti['isRead'] ? FontWeight.normal : FontWeight.bold,
                      fontSize: 15,
                    ),
                  ),
                  Text(
                    _formatTime(noti['time']),
                    style: TextStyle(
                      color: Colors.grey[500],
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
              subtitle: Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text(
                  noti['content'],
                  style: TextStyle(
                    color: Colors.grey[800],
                    fontSize: 14,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              onTap: () {
                // 알림 클릭 처리 로직
              },
            ),
          );
        },
      ),
    );
  }

  Widget _buildIcon(String type) {
    IconData iconData;
    Color color;

    switch (type) {
      case 'meeting':
        iconData = Icons.videocam;
        color = Colors.orange;
        break;
      case 'document':
        iconData = Icons.description;
        color = Colors.blue;
        break;
      case 'friend':
        iconData = Icons.person_add;
        color = Colors.green;
        break;
      case 'system':
      default:
        iconData = Icons.info;
        color = Colors.grey;
        break;
    }

    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        shape: BoxShape.circle,
      ),
      child: Icon(iconData, color: color, size: 20),
    );
  }

  String _formatTime(DateTime time) {
    final now = DateTime.now();
    final diff = now.difference(time);

    if (diff.inMinutes < 60) {
      return '${diff.inMinutes}분 전';
    } else if (diff.inHours < 24) {
      return '${diff.inHours}시간 전';
    } else {
      return DateFormat('MM/dd').format(time);
    }
  }
}
