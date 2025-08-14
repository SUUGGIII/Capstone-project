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
