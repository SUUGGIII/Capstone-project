import 'package:flutter/material.dart';

class SummarizePage extends StatelessWidget {
  final String sessionName;
  final String content;

  const SummarizePage({
    super.key,
    required this.sessionName,
    required this.content,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("$sessionName 회의록"),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0.5,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Text(
          content,
          style: const TextStyle(fontSize: 16, height: 1.5),
        ),
      ),
    );
  }
}
