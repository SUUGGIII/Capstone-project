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
