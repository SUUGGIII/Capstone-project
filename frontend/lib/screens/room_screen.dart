// room_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:uuid/uuid.dart';
import 'package:asdf/services/signaling_service.dart';
import 'package:asdf/services/webrtc_manager.dart';


class RoomScreen extends StatefulWidget {
  final String roomId;
  const RoomScreen({Key? key, required this.roomId}) : super(key: key);

  @override
  _RoomScreenState createState() => _RoomScreenState();
}

class _RoomScreenState extends State<RoomScreen> {
  final SignalingService _signaling = SignalingService();
  late final WebRTCManager _webRTCManager;
  final String _selfId = Uuid().v4();
  final List<String> _participants = [];
  // {peerId: remoteStream}
  final Map<String, MediaStream> _remoteStreams = {};
  // {peerId: audioPlayer} 오디오 재생을 위한 플레이어
  final Map<String, RTCVideoRenderer> _audioRenderers = {};

  @override
  void initState() {
    super.initState();
    _webRTCManager = WebRTCManager(
      _selfId,
      sendSignal: (message) => _signaling.send(message),
      onAddRemoteStream: (peerId, stream) async {
        final audioRenderer = RTCVideoRenderer();
        await audioRenderer.initialize();
        audioRenderer.srcObject = stream;
        setState(() {
          _remoteStreams[peerId] = stream;
          _audioRenderers[peerId] = audioRenderer;
        });
      },
      onRemoveRemoteStream: (peerId) async {
        await _audioRenderers[peerId]?.dispose();
        setState(() {
          _remoteStreams.remove(peerId);
          _audioRenderers.remove(peerId);
        });
      },
    );
    _connect();
  }

  Future<void> _connect() async {
    await _webRTCManager.initializeLocalStream();
    // "localhost" 또는 실제 서버 IP/도메인으로 변경하세요.
    _signaling.connect('ws://localhost:8080/signal', onMessageCallback: _handleMessage);

    _signaling.send({
      'type': 'join',
      'sender': _selfId,
      'room': widget.roomId,
    });
  }

  void _handleMessage(String type, dynamic data) {
    final String senderId = data['sender'] ?? '';
    final String roomId = data['room'] ?? widget.roomId;

    switch (type) {
      case 'all-users':
        final List<String> users = List<String>.from(data['data']);
        print('Existing users: $users');
        setState(() => _participants.addAll(users));
        for (final user in users) {
          _webRTCManager.createOffer(user, roomId);
        }
        break;
      case 'new-user':
        print('New user joined: $senderId');
        setState(() => _participants.add(senderId));
        // 이 클라이언트는 offer를 기다립니다.
        break;
      case 'offer':
        _webRTCManager.handleOffer(senderId, roomId, data['data']);
        break;
      case 'answer':
        _webRTCManager.handleAnswer(senderId, data['data']);
        break;
      case 'ice-candidate':
        _webRTCManager.handleIceCandidate(senderId, data['data']);
        break;
      case 'user-left':
        print('User left: $senderId');
        setState(() => _participants.remove(senderId));
        _webRTCManager.closePeerConnection(senderId);
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Room: ${widget.roomId} (ID: $_selfId)')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text('참가자 (${_participants.length + 1})', style: Theme.of(context).textTheme.headlineSmall),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: _participants.length,
              itemBuilder: (context, index) {
                final peerId = _participants[index];
                return ListTile(
                  title: Text(peerId),
                  trailing: _remoteStreams.containsKey(peerId)
                      ? Icon(Icons.mic, color: Colors.green)
                      : Icon(Icons.mic_off, color: Colors.grey),
                );
              },
            ),
          ),
          // 오디오 렌더러들을 위젯 트리에 추가하여 실제로 소리가 나게 함 (UI에 보이지 않음)
          if (_audioRenderers.isNotEmpty)
            SizedBox(
              width: 0,
              height: 0,
              child: Column(children: _audioRenderers.values.map((renderer) => RTCVideoView(renderer)).toList()),
            )
        ],
      ),
    );
  }

  @override
  void dispose() {
    _signaling.dispose();
    _webRTCManager.dispose();
    _audioRenderers.forEach((key, value) => value.dispose());
    super.dispose();
  }
}