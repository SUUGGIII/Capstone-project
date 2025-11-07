// 기능: WebRTC 시그널링을 위한 WebSocket 연결을 설정하고 관리하는 서비스 클래스를 구현함. 시그널링 서버와 메시지를 주고받는 기능을 담당하며, 수신된 메시지를 파싱하여 콜백 함수를 통해 처리함.
// 호출: web_socket_channel 라이브러리의 WebSocketChannel.connect를 사용하여 WebSocket 연결을 수립하고, stream.listen을 통해 서버로부터의 메시지를 수신함. jsonDecode 및 jsonEncode를 사용하여 메시지를 직렬화/역직렬화함.
// 호출됨: room_screen.dart 파일에서 SignalingService 인스턴스를 생성하고 connect, send, dispose 메소드를 호출하여 시그널링 통신을 관리함.
import 'dart:convert';
import 'package:web_socket_channel/web_socket_channel.dart';

class SignalingService {
  WebSocketChannel? _channel;
  Function(String type, dynamic data)? onMessage;

  void connect(String url, {required Function(String type, dynamic data) onMessageCallback}) {
    onMessage = onMessageCallback;
    try {
      _channel = WebSocketChannel.connect(Uri.parse(url));
      _channel!.stream.listen((message) {
        try {
          final decodedMessage = jsonDecode(message);
          final type = decodedMessage['type'];
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

  void send(Map<String, dynamic> message) {
    if (_channel != null) {
      _channel!.sink.add(jsonEncode(message));
    }
  }

  void dispose() {
    _channel?.sink.close();
  }
}
