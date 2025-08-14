import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:meeting_app/providers/navigation_provider.dart';
import 'package:meeting_app/pages/home_tab_page.dart';
import 'package:meeting_app/pages/meeting_page.dart';
import 'package:meeting_app/pages/team_chat_page.dart';
import 'package:meeting_app/pages/scheduler_page.dart';
import 'package:meeting_app/pages/documents_page.dart';
import 'package:meeting_app/pages/friends_page.dart';
import 'package:meeting_app/pages/more_page.dart';


class HomePage extends StatelessWidget {
  const HomePage({super.key});

  static final Map<String, Widget> _pages = {
    '홈': const HomeTabPage(),
    '회의': const MeetingPage(),
    '팀 채팅': const TeamChatPage(),
    '스케줄러': const SchedulerPage(),
    '문서': const DocumentsPage(),
    '친구': const FriendsPage(),
    '더보기': const MorePage(),
  };

  @override
  Widget build(BuildContext context) {
    return Consumer<NavigationProvider>(
      builder: (context, navProvider, child) {
        return Scaffold(
          appBar: AppBar(
            backgroundColor: Colors.white,
            elevation: 0.5,
            title: Row(
              children: [
                Image.asset('assets/zoom_logo.png', height: 24),
                const SizedBox(width: 8),
                const Text(
                  'Workplace',
                  style: TextStyle(
                    color: Colors.black87,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.search, color: Colors.grey),
                onPressed: () {},
                tooltip: '검색',
              ),
              const SizedBox(width: 16),
              ..._pages.entries.toList().asMap().entries.map((entry) {
                int index = entry.key;
                String label = entry.value.key;
                return _buildNavigationItem(label, index, navProvider);
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
                onPressed: () {},
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
          body: Row(
            children: [
              Container(
                width: 200,
                color: Colors.grey[50],
                padding: const EdgeInsets.symmetric(vertical: 24.0, horizontal: 16.0),
                child: Column(
                  children: [
                    _buildSidebarButton(
                      icon: Icons.videocam,
                      label: '새 회의',
                      iconColor: Colors.orange,
                      backgroundColor: Colors.orange[100],
                      onPressed: () => navProvider.setSelectedIndex(1),
                    ),
                    const SizedBox(height: 16),
                    _buildSidebarButton(
                      icon: Icons.add_box,
                      label: '참가',
                      iconColor: Colors.blue,
                      backgroundColor: Colors.blue[100],
                      onPressed: () => navProvider.setSelectedIndex(1),
                    ),
                    const SizedBox(height: 16),
                    _buildSidebarButton(
                      icon: Icons.calendar_today,
                      label: '예약',
                      iconColor: Colors.blue,
                      backgroundColor: Colors.blue[100],
                      onPressed: () => navProvider.setSelectedIndex(3),
                    ),
                    const SizedBox(height: 16),
                    _buildSidebarButton(
                      icon: Icons.arrow_upward,
                      label: '화면 공유',
                      iconColor: Colors.blue,
                      backgroundColor: Colors.blue[100],
                      onPressed: () {},
                    ),
                    const Spacer(),
                  ],
                ),
              ),
              Expanded(
                child: IndexedStack(
                  index: navProvider.selectedIndex,
                  children: _pages.values.toList(),
                ),
              ),
            ],
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

  Widget _buildSidebarButton({
    required IconData icon,
    required String label,
    required Color iconColor,
    required Color? backgroundColor,
    required VoidCallback onPressed,
  }) {
    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 16.0),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: iconColor, size: 36),
            const SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(color: iconColor, fontSize: 16, fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ),
    );
  }
}
