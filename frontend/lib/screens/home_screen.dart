import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:meeting_app/screens/room_screen.dart';
import 'package:uuid/uuid.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

// TODO: Replace with a proper token generation from your backend.
// This is a placeholder for demonstration purposes.
const String livekitUrl = 'ws://59.187.251.201:7880';
const String token = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJleHAiOjE3MzU2ODk2MDAsImlzcyI6IkFQSVRzVjQ3MTRoTDRzQSIsIm5iZiI6MTcwNDU4NTYwMCwic3ViIjoidXNlci1pZCIsInZpZGVvIjp7InJvb20iOiJ0ZXN0LXJvb20iLCJyb29tSm9pbiI6dHJ1ZSwiY2FuUHVibGlzaCI6dHJ1ZSwiY2FuUHVibGlzaERhdGEiOnRydWUsImNhblN1YnNjcmliZSI6dHJ1ZX19.O5h_3h3v5h3j3h3v5h3j3h3v5h3j3h3v5h3j3h3v5h3';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _roomIdController = TextEditingController();
  bool _busy = false;

  @override
  void dispose() {
    _roomIdController.dispose();
    super.dispose();
  }

  Future<void> _showErrorDialog(String message) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Error'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text(message),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('확인'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void _joinRoom() async {
    if (_roomIdController.text.isEmpty) {
      await _showErrorDialog('방 ID를 입력해주세요.');
      return;
    }

    setState(() {
      _busy = true;
    });

    try {
      final prefs = await SharedPreferences.getInstance();
      final accessToken = prefs.getString('accessToken');

      if (accessToken == null) {
        await _showErrorDialog('로그인이 필요합니다.');
        // Optionally, navigate to the login page.
        return;
      }

      print('Using accessToken: $accessToken'); // Debug print

      final userId = const Uuid().v4();
      final response = await http.post(
        Uri.parse('http://localhost:8080/token'), // Using the backend URL from login_page.dart
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          'Authorization': 'Bearer $accessToken',
        },
        body: jsonEncode(<String, String>{
          'roomName': _roomIdController.text,
          'identity': userId,
        }),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        final livekitToken = data['token'];
        final livekitUrl = data['url'];

        if (livekitToken != null && livekitUrl != null) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => RoomScreen(
                roomId: _roomIdController.text,
                token: livekitToken,
                livekitUrl: livekitUrl,
              ),
            ),
          );
        } else {
          await _showErrorDialog('응답에서 LiveKit 토큰(token) 또는 URL(url)을 찾을 수 없습니다.');
        }
      } else {
        await _showErrorDialog(
          '토큰 요청 실패: HTTP ${response.statusCode}\n서버 응답: ${response.body}',
        );
      }
    } catch (e) {
      await _showErrorDialog('토큰 요청 중 오류 발생: $e');
    } finally {
      setState(() {
        _busy = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('LiveKit Room'),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextField(
                controller: _roomIdController,
                decoration: const InputDecoration(
                  labelText: 'Enter Room ID',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 20),
              _busy
                  ? const CircularProgressIndicator()
                  : ElevatedButton(
                      onPressed: _joinRoom,
                      child: const Text('Join Room'),
                    ),
            ],
          ),
        ),
      ),
    );
  }
}
