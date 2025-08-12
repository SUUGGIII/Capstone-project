// signaling_service.dart
import 'dart:convert';
import 'package:web_socket_channel/web_socket_channel.dart';

class SignalingService {
  WebSocketChannel? _channel;
  Function(String type, dynamic data)? onMessage;

  // 서버 연결
  void connect(String url, {required Function(String type, dynamic data) onMessageCallback}) {
    onMessage = onMessageCallback;
    try {
      _channel = WebSocketChannel.connect(Uri.parse(url));
      _channel!.stream.listen((message) {
        try {
          final decodedMessage = jsonDecode(message);
          final type = decodedMessage['type'];
          // 핸들러에게 전체 메시지 맵을 전달하여 sender, receiver 등의 정보에 접근할 수 있게 함
          onMessage?.call(type, decodedMessage);
        } catch (e) {
          print('Failed to decode message: $message');
          print('Error: $e');
        }
      }, onError: (error) {
        print('WebSocket Error: $error');
        onMessage?.call('error', {'message': error.toString()});
      }, onDone: () {
        print('WebSocket connection closed');
        onMessage?.call('close', {});
      });
    } catch (e) {
      print('Failed to connect to WebSocket: $e');
    }
  }

  // 메시지 전송
  void send(Map<String, dynamic> message) {
    if (_channel != null) {
      _channel!.sink.add(jsonEncode(message));
    }
  }

  // 연결 종료
  void dispose() {
    _channel?.sink.close();
  }
}