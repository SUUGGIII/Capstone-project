// 기능: 현재 시간과 날짜를 실시간으로 업데이트하여 표시하는 카드 형태의 위젯을 구현함. Timer를 사용하여 1초마다 시간을 갱신하고 intl 패키지를 사용하여 날짜 및 시간 형식을 지정함.
// 호출: dart:async의 Timer를 사용하여 주기적인 업데이트를 스케줄링하고, intl 패키지의 DateFormat을 사용하여 날짜/시간을 포맷팅함. flutter/material.dart의 기본 위젯들을 사용하여 UI를 구성함.
// 호출됨: home_tab_page.dart 파일에서 CurrentTimeCard 위젯 형태로 호출되어 홈 탭 페이지에 현재 시간 정보를 표시함.
import 'package:flutter/material.dart';
import 'dart:async';
import 'package:intl/intl.dart';

class CurrentTimeCard extends StatefulWidget {
  const CurrentTimeCard({super.key});

  @override
  State<CurrentTimeCard> createState() => _CurrentTimeCardState();
}

class _CurrentTimeCardState extends State<CurrentTimeCard> {
  late String _timeString;
  late String _dateString;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _updateTime();
    _timer = Timer.periodic(const Duration(seconds: 1), (Timer t) => _updateTime());
  }

  void _updateTime() {
    final DateTime now = DateTime.now();
    final DateFormat timeFormatter = DateFormat('h:mm a');
    final DateFormat dateFormatter = DateFormat('EEEE, MMMM d');

    setState(() {
      _timeString = timeFormatter.format(now);
      _dateString = dateFormatter.format(now);
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Row(
          children: [
            Icon(Icons.cloud, size: 48, color: Colors.green[400]),
            const SizedBox(width: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _timeString,
                  style: const TextStyle(
                    fontSize: 36,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                Text(
                  _dateString,
                  style: const TextStyle(
                    fontSize: 16,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
            const Spacer(),
            IconButton(
              icon: const Icon(Icons.more_horiz, color: Colors.grey),
              onPressed: () {},
            ),
          ],
        ),
      ),
    );
  }
}
