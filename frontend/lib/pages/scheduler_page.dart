// 기능: "Zoom Scheduler" 기능의 주요 장점을 사용자에게 홍보하고, 14일 무료 체험, 구매, 자세히 알아보기 등의 액션을 유도하는 마케팅 페이지를 구현함.
// 호출: flutter/material.dart의 다양한 기본 위젯(ElevatedButton, TextButton 등)을 사용하여 UI를 구성함. 현재는 다른 커스텀 위젯이나 파일을 직접 호출하지 않음.
// 호출됨: home_page.dart 파일에서 SchedulerPage 위젯 형태로 호출되어 메인 화면의 탭 중 하나로 사용되거나, meeting_page.dart에서 "예약" 버튼 클릭 시 NavigationProvider를 통해 전환될 것으로 추정됨.
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class SchedulerPage extends StatefulWidget {
  const SchedulerPage({super.key});

  @override
  State<SchedulerPage> createState() => _SchedulerPageState();
}

class _SchedulerPageState extends State<SchedulerPage> {
  DateTime _selectedDate = DateTime.now();
  
  // 더미 일정 데이터
  final Map<String, List<Map<String, String>>> _events = {
    '2025-11-30': [
      {'time': '10:00 AM', 'title': '팀 주간 회의', 'duration': '1시간'},
      {'time': '01:00 PM', 'title': '디자인 리뷰', 'duration': '45분'},
      {'time': '03:30 PM', 'title': '프로젝트 킥오프', 'duration': '1시간 30분'},
    ],
    '2025-12-01': [
      {'time': '09:30 AM', 'title': '일일 스탠드업', 'duration': '15분'},
      {'time': '02:00 PM', 'title': '클라이언트 미팅', 'duration': '1시간'},
    ],
    '2025-12-02': [
      {'time': '11:00 AM', 'title': '기술 인터뷰', 'duration': '1시간'},
    ],
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('새 일정 추가 기능은 준비 중입니다.')),
          );
        },
        backgroundColor: Colors.blue[600],
        child: const Icon(Icons.add, color: Colors.white),
      ),
      body: Column(
        children: [
          _buildHeader(),
          _buildDateSelector(),
          const Divider(height: 1, thickness: 1),
          Expanded(
            child: _buildEventList(),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 20.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                DateFormat('yyyy년 M월').format(_selectedDate),
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '오늘의 일정',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
          IconButton(
            icon: const Icon(Icons.calendar_today, color: Colors.black54),
            onPressed: () async {
              final DateTime? picked = await showDatePicker(
                context: context,
                initialDate: _selectedDate,
                firstDate: DateTime(2020),
                lastDate: DateTime(2030),
                builder: (context, child) {
                  return Theme(
                    data: Theme.of(context).copyWith(
                      colorScheme: ColorScheme.light(
                        primary: Colors.blue[600]!, // 헤더 배경색
                        onPrimary: Colors.white, // 헤더 텍스트 색상
                        onSurface: Colors.black, // 달력 텍스트 색상
                      ),
                    ),
                    child: child!,
                  );
                },
              );
              if (picked != null && picked != _selectedDate) {
                setState(() {
                  _selectedDate = picked;
                });
              }
            },
          ),
        ],
      ),
    );
  }

  Widget _buildDateSelector() {
    return SizedBox(
      height: 90,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: 14, // 2주치 표시
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemBuilder: (context, index) {
          // 오늘 날짜 기준으로 날짜 생성
          final date = DateTime.now().add(Duration(days: index));
          final isSelected = DateUtils.isSameDay(date, _selectedDate);
          
          return GestureDetector(
            onTap: () {
              setState(() {
                _selectedDate = date;
              });
            },
            child: Container(
              width: 60,
              margin: const EdgeInsets.only(right: 12, bottom: 16),
              decoration: BoxDecoration(
                color: isSelected ? Colors.blue[600] : Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isSelected ? Colors.blue[600]! : Colors.grey[300]!,
                  width: 1,
                ),
                boxShadow: isSelected
                    ? [
                        BoxShadow(
                          color: Colors.blue.withOpacity(0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        )
                      ]
                    : [],
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    DateFormat('E', 'ko_KR').format(date), // 요일 (월, 화...)
                    style: TextStyle(
                      fontSize: 14,
                      color: isSelected ? Colors.white70 : Colors.grey[600],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    date.day.toString(),
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: isSelected ? Colors.white : Colors.black87,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildEventList() {
    final dateKey = DateFormat('yyyy-MM-dd').format(_selectedDate);
    final events = _events[dateKey] ?? [];

    if (events.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.event_busy, size: 64, color: Colors.grey[300]),
            const SizedBox(height: 16),
            Text(
              '예정된 일정이 없습니다.',
              style: TextStyle(fontSize: 16, color: Colors.grey[500]),
            ),
            const SizedBox(height: 8),
            TextButton(
              onPressed: () {},
              child: const Text('일정 추가하기'),
            )
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(20),
      itemCount: events.length,
      itemBuilder: (context, index) {
        final event = events[index];
        return Container(
          margin: const EdgeInsets.only(bottom: 16),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.grey[200]!),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.03),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 4,
                height: 50,
                decoration: BoxDecoration(
                  color: _getEventColor(index),
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      event['time']!,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey[500],
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      event['title']!,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(Icons.access_time, size: 12, color: Colors.grey[400]),
                        const SizedBox(width: 4),
                        Text(
                          event['duration']!,
                          style: TextStyle(fontSize: 12, color: Colors.grey[400]),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: Icon(Icons.more_vert, color: Colors.grey[400]),
                onPressed: () {},
              ),
            ],
          ),
        );
      },
    );
  }

  Color _getEventColor(int index) {
    const colors = [Colors.blue, Colors.orange, Colors.purple, Colors.green];
    return colors[index % colors.length];
  }
}
