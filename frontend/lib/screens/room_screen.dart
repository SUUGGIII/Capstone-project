// 기능: WebRTC 기술을 사용하여 오디오/비디오 채팅 및 화면 공유 기능을 제공하는 화상 회의 방 화면을 구현함. 참가자 관리, 로컬/원격 스트림 처리, 마이크/화면 공유 제어 등의 기능을 포함함. (LiveKit SDK를 사용하는 room.dart와는 다른, 수동 시그널링 기반의 구현 방식임.)
// 호출: SignalingService를 사용하여 시그널링 서버와 통신하고, WebRTCManager를 사용하여 WebRTC 연결 및 미디어 스트림을 관리함. ScreenSelectDialog를 호출하여 화면 공유 소스를 선택함. flutter_webrtc 패키지의 RTCVideoRenderer 및 MediaStream 관련 클래스를 사용하여 비디오 렌더링 및 스트림 처리를 담당함.
// 호출됨: home_screen.dart 파일에서 Room ID와 함께 RoomScreen 위젯 형태로 호출되어 사용됨.
import 'package:flutter/material.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:uuid/uuid.dart';
import '../services/signaling_service.dart';
import '../services/webrtc_manager.dart';
import 'package:meeting_app/widgets/Rooms/screen_select_dialog.dart';

class RoomScreen extends StatefulWidget {
  final String roomId;
  const RoomScreen({super.key, required this.roomId});

  @override
  _RoomScreenState createState() => _RoomScreenState();
}

class _RoomScreenState extends State<RoomScreen> {
  final SignalingService _signaling = SignalingService();
  late final WebRTCManager _webRTCManager;
  final String _selfId = const Uuid().v4();

  final List<String> _participants = [];
  final Map<String, MediaStream> _remoteStreams = {};
  final Map<String, RTCVideoRenderer> _audioRenderers = {};

  bool _isScreenSharing = false;
  MediaStream? _localScreenStream;
  final RTCVideoRenderer _localScreenRenderer = RTCVideoRenderer();
  final Map<String, MediaStream> _remoteScreenStreams = {};
  final Map<String, RTCVideoRenderer> _remoteScreenRenderers = {};

  bool _isMicEnabled = true;
  bool _isRemoteAudioEnabled = true;

  @override
  void initState() {
    super.initState();
    _initializeRenderers();

    _webRTCManager = WebRTCManager(
      _selfId,
      sendSignal: (message) => _signaling.send(message),
      onAddRemoteStream: (peerId, stream) => _addRemoteStream(peerId, stream),
      onRemoveRemoteStream: (peerId) => _removeRemoteStream(peerId),
      onAddLocalScreenStream: (stream) {
        setState(() {
          _localScreenStream = stream;
          _localScreenRenderer.srcObject = stream;
          _isScreenSharing = true;
        });
      },
      onRemoveLocalScreenStream: () {
        setState(() {
          _localScreenRenderer.srcObject = null;
          _localScreenStream?.getTracks().forEach((track) => track.stop());
          _localScreenStream = null;
          _isScreenSharing = false;
        });
      },
      onAddRemoteScreenStream: (peerId, stream) => _addRemoteScreenStream(peerId, stream),
      onRemoveRemoteScreenStream: (peerId) => _removeRemoteScreenStream(peerId),
    );
    _connect();
  }

  Future<void> _initializeRenderers() async {
    await _localScreenRenderer.initialize();
  }

  void _addRemoteStream(String peerId, MediaStream stream) async {
    final audioRenderer = RTCVideoRenderer();
    await audioRenderer.initialize();
    audioRenderer.srcObject = stream;
    setState(() {
      _remoteStreams[peerId] = stream;
      _audioRenderers[peerId] = audioRenderer;
    });
  }

  void _removeRemoteStream(String peerId) async {
    await _audioRenderers[peerId]?.dispose();
    setState(() {
      _remoteStreams.remove(peerId);
      _audioRenderers.remove(peerId);
    });
  }

  void _addRemoteScreenStream(String peerId, MediaStream stream) async {
    final renderer = RTCVideoRenderer();
    await renderer.initialize();
    renderer.srcObject = stream;
    setState(() {
      _remoteScreenStreams[peerId] = stream;
      _remoteScreenRenderers[peerId] = renderer;
    });
  }

  void _removeRemoteScreenStream(String peerId) async {
    await _remoteScreenRenderers[peerId]?.dispose();
    setState(() {
      _remoteScreenStreams.remove(peerId);
      _remoteScreenRenderers.remove(peerId);
    });
  }

  void _toggleMic() {
    setState(() => _isMicEnabled = !_isMicEnabled);
    _webRTCManager.toggleMicrophone(_isMicEnabled);
  }

  void _toggleRemoteAudio() {
    setState(() => _isRemoteAudioEnabled = !_isRemoteAudioEnabled);
    _webRTCManager.toggleRemoteAudio(_isRemoteAudioEnabled);
  }

  Future<void> _toggleScreenShare() async {
    if (_isScreenSharing) {
      await _webRTCManager.stopShareScreen();
      return;
    }

    final source = await showDialog<DesktopCapturerSource>(
      context: context,
      builder: (context) => const ScreenSelectDialog(),
    );

    if (source != null) {
      await _webRTCManager.shareScreen(source);
    }
  }

  Future<void> _connect() async {
    await _webRTCManager.initializeLocalStream();
    _signaling.connect('ws://localhost:8080/signal', onMessageCallback: _handleMessage);
    _signaling.send({'type': 'join', 'sender': _selfId, 'room': widget.roomId});
  }

  void _handleMessage(String type, dynamic data) {
    final String senderId = data['sender'] ?? '';
    final String roomId = data['room'] ?? widget.roomId;

    switch (type) {
      case 'all-users':
        final List<String> users = List<String>.from(data['data']);
        setState(() => _participants.addAll(users));
        for (final user in users) {
          _webRTCManager.createOffer(user, roomId);
        }
        break;
      case 'new-user':
        setState(() => _participants.add(senderId));
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
        setState(() => _participants.remove(senderId));
        _webRTCManager.closePeerConnection(senderId);
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Room: ${widget.roomId}')),
      body: Column(
        children: [
          if (_isScreenSharing || _remoteScreenRenderers.isNotEmpty)
            SizedBox(
              height: 200,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: [
                  if (_isScreenSharing && _localScreenStream != null)
                    _buildScreenShareView("My Screen", _localScreenRenderer),
                  ..._remoteScreenRenderers.entries.map((entry) {
                    return _buildScreenShareView(entry.key, entry.value);
                  }).toList(),
                ],
              ),
            ),
          const Divider(),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text('Participants (${_participants.length + 1})', style: Theme.of(context).textTheme.titleMedium),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: _participants.length,
              itemBuilder: (context, index) {
                final peerId = _participants[index];
                return ListTile(
                  title: Text(peerId),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (_remoteStreams.containsKey(peerId))
                        const Icon(Icons.mic, color: Colors.green),
                      if (_remoteScreenStreams.containsKey(peerId))
                        const Icon(Icons.screen_share, color: Colors.blue),
                    ],
                  ),
                );
              },
            ),
          ),
          SizedBox(
            width: 0,
            height: 0,
            child: Column(
              children: _audioRenderers.values.map((r) => RTCVideoView(r, objectFit: RTCVideoViewObjectFit.RTCVideoViewObjectFitContain)).toList(),
            ),
          ),
        ],
      ),
      bottomNavigationBar: BottomAppBar(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            IconButton(
              icon: Icon(_isMicEnabled ? Icons.mic : Icons.mic_off),
              onPressed: _toggleMic,
            ),
            IconButton(
              icon: Icon(Icons.call_end, color: Colors.red),
              onPressed: () => Navigator.of(context).pop(),
            ),
            IconButton(
              icon: Icon(
                _isScreenSharing ? Icons.stop_screen_share : Icons.screen_share,
                color: _isScreenSharing ? Colors.blue : Colors.grey,
              ),
              onPressed: _toggleScreenShare,
            ),
            IconButton(
              icon: Icon(_isRemoteAudioEnabled ? Icons.headset : Icons.headset_off),
              onPressed: _toggleRemoteAudio,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildScreenShareView(String peerId, RTCVideoRenderer renderer) {
    return Container(
      width: 200,
      height: 150,
      margin: const EdgeInsets.all(4.0),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey),
        borderRadius: BorderRadius.circular(8.0),
        color: Colors.black87,
      ),
      child: Column(
        children: [
          Expanded(
            child: RTCVideoView(renderer, objectFit: RTCVideoViewObjectFit.RTCVideoViewObjectFitContain),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 4.0),
            child: Text(peerId, style: const TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _signaling.dispose();
    _webRTCManager.dispose();
    _localScreenRenderer.dispose();
    _audioRenderers.forEach((_, r) => r.dispose());
    _remoteScreenRenderers.forEach((_, r) => r.dispose());
    super.dispose();
  }
}
