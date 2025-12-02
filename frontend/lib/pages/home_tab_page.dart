// 기능: 앱의 기본 홈 탭 페이지를 구성함. 현재 시간 정보를 표시하고, 캘린더 연결 안내 메시지를 제공하며, 예정된 회의 목록을 보여주는 기능을 담당함.
// 호출: CurrentTimeCard 위젯을 호출하여 현재 시간을 표시함. flutter/material.dart의 다양한 기본 위젯들을 사용하여 UI를 구성함. 현재는 다른 커스텀 페이지를 직접 호출하지 않음. (향후 '회의 예약' 시 SchedulerPage 호출 예상).
// 호출됨: home_page.dart 파일에서 HomeTabPage 위젯 형태로 호출되어 메인 화면의 탭 중 하나로 사용됨.
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/navigation_provider.dart';
import 'Rooms/create_room.dart';

class HomeTabPage extends StatelessWidget {
  const HomeTabPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.all(32.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 왼쪽: 액션 버튼 그리드
          Expanded(
            flex: 3,
            child: Row(
              children: [
                _buildActionButton(
                  context,
                  icon: Icons.videocam,
                  label: '새 회의',
                  color: const Color(0xFFFF742E),
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const CreateRoomPage()),
                  ),
                ),
                const SizedBox(width: 16),
                _buildActionButton(
                  context,
                  icon: Icons.add_box,
                  label: '참가',
                  color: const Color(0xFF0E71EB),
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const CreateRoomPage()),
                  ),
                ),
                const SizedBox(width: 16),
                _buildActionButton(
                  context,
                  icon: Icons.calendar_today,
                  label: '예약',
                  color: const Color(0xFF0E71EB),
                  onPressed: () => Provider.of<NavigationProvider>(context, listen: false).setSelectedIndex(3),
                ),
              ],
            ),
          ),
          const SizedBox(width: 32),
          // 오른쪽: 시계 및 일정 리스트
          Expanded(
            flex: 2,
            child: Column(
              children: [
                // 시계 카드
                Container(
                  width: double.infinity,
                  height: 150,
                  decoration: BoxDecoration(
                    image: const DecorationImage(
                      image: AssetImage('assets/scheduler_preview.png'), // 배경 이미지 재사용 또는 대체
                      fit: BoxFit.cover,
                      colorFilter: ColorFilter.mode(Colors.black45, BlendMode.darken),
                    ),
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          DateFormat('h:mm a').format(DateTime.now()),
                          style: const TextStyle(
                            fontSize: 36,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          DateFormat('yyyy년 M월 d일 EEEE', 'ko_KR').format(DateTime.now()),
                          style: const TextStyle(
                            fontSize: 16,
                            color: Colors.white70,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                // 일정 리스트 헤더
                const Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    '오늘의 회의',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                // 일정 리스트 (비어있음)
                Expanded(
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.event_available, size: 48, color: Colors.grey[300]),
                        const SizedBox(height: 12),
                        Text(
                          '예정된 회의가 없습니다.',
                          style: TextStyle(color: Colors.grey[500]),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton(BuildContext context,
      {required IconData icon,
      required String label,
      required Color color,
      required VoidCallback onPressed}) {
    return Expanded(
      child: GestureDetector(
        onTap: onPressed,
        child: Container(
          height: 120, // 고정 높이 추가
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: color.withOpacity(0.3),
                blurRadius: 12,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(12), // 이전 16
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Icon(icon, size: 32, color: Colors.white), // 이전 40
              ),
              const SizedBox(height: 12), // 이전 16
              Text(
                label,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16, // 이전 18
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
