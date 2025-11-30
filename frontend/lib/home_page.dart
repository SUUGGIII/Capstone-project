// 기능: 앱의 메인 화면을 구성하며, 로그인 후 사용자에게 다양한 기능(회의, 팀 채팅, 일정, 문서, 친구, 더보기)에 접근할 수 있는 UI를 제공함. 상단 내비게이션 바와 좌측 사이드바를 통해 페이지 전환 및 새 회의 생성 기능을 제공함.
// 호출: HomeTabPage, MeetingPage, TeamChatPage, SchedulerPage, DocumentsPage, FriendsPage, MorePage 등 여러 페이지 위젯을 IndexedStack 내에서 관리하며 표시함. CreateRoomPage를 호출하여 새 회의 생성 화면으로 이동함. NavigationProvider를 사용하여 내비게이션 상태를 관리함.
// 호출됨: main.dart 파일에서 LoginPage를 통해 로그인 성공 시 HomePage 위젯 형태로 호출되어 앱의 초기 화면으로 사용됨.
import 'package:flutter/material.dart';
import 'package:meeting_app/pages/session_list_page.dart';
import 'package:provider/provider.dart';
import 'package:meeting_app/providers/navigation_provider.dart';
import 'package:meeting_app/pages/home_tab_page.dart';
import 'package:meeting_app/pages/meeting_page.dart';
import 'package:meeting_app/pages/scheduler_page.dart';
import 'package:meeting_app/pages/documents_page.dart';
import 'package:meeting_app/pages/friends_page.dart';
import 'package:meeting_app/pages/more_page.dart';
import 'package:meeting_app/pages/Rooms/create_room.dart';
import 'package:meeting_app/pages/profile_page.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  // IndexedStack에서 네비게이션에 사용할 모든 뷰
  static final List<Widget> _allViews = [
    const HomeTabPage(),      // index 0
    const MeetingPage(),      // index 1
    const SessionListPage(),     // index 2
    const SchedulerPage(),    // index 3
    const DocumentsPage(),    // index 4
    const FriendsPage(),      // index 5
    const MorePage(),         // index 6
  ];

  // 상단 네비게이션 바에 표시될 페이지, 레이블을 _allViews의 인덱스에 매핑
  static final Map<String, int> _navItems = {
    '홈': 0,
    '회의록': 2,
    '일정': 3,
    '문서': 4,
    '친구': 5,
    '더보기': 6,
  };

  @override
  Widget build(BuildContext context) {
    return Consumer<NavigationProvider>(
      builder: (context, navProvider, child) {
        return Scaffold(
          appBar: AppBar(
            backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
            elevation: 0.5,
            title: GestureDetector(
              onTap: () => navProvider.setSelectedIndex(0), // HomeTabPage로 네비게이션
              child: Row(
                children: [
                  Image.asset('assets/zoom_logo.png', height: 24),
                  const SizedBox(width: 8),
                  Text(
                    'MeetingApp',
                    style: TextStyle(
                      color: Theme.of(context).textTheme.titleLarge?.color,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.search, color: Colors.grey),
                onPressed: () {},
                tooltip: '검색',
              ),
              const SizedBox(width: 16),
              ..._navItems.entries.map((entry) {
                return _buildNavigationItem(entry.key, entry.value, navProvider);
              }).toList(),
              const SizedBox(width: 16),
              Stack(
                children: [
                  IconButton(
                    icon: const Icon(Icons.notifications_none, color: Colors.grey),
                    onPressed: () {},
                    tooltip: '알림',
                  ),
                  Positioned(
                    right: 0,
                    top: 0,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.red,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: const Text(
                        'NEW',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 8,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 16),
              IconButton(
                icon: const Icon(Icons.person_outline, color: Colors.grey),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const ProfilePage()),
                  );
                },
                tooltip: '내 프로필',
              ),
              const SizedBox(width: 8),
              IconButton(
                icon: const Icon(Icons.settings, color: Colors.grey),
                onPressed: () {},
                tooltip: '설정',
              ),
              const SizedBox(width: 8),
            ],
          ),
          body: IndexedStack(
            index: navProvider.selectedIndex,
            children: _allViews,
          ),
        );
      },
    );
  }

  Widget _buildNavigationItem(String label, int index, NavigationProvider navProvider) {
    return TextButton(
      onPressed: () => navProvider.setSelectedIndex(index),
      child: Text(
        label,
        style: TextStyle(
          color: navProvider.selectedIndex == index ? Colors.blue[700] : Colors.black87,
          fontSize: 16,
          fontWeight: navProvider.selectedIndex == index ? FontWeight.bold : FontWeight.w500,
        ),
      ),
    );
  }
}
