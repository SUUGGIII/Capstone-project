// webrtc_manager.dart
import 'package:flutter_webrtc/flutter_webrtc.dart';

class WebRTCManager {
  // {peerId: peerConnection}
  final Map<String, RTCPeerConnection> _peerConnections = {};
  MediaStream? _localStream;
  final String _selfId;
  final Function(String peerId, MediaStream stream) onAddRemoteStream;
  final Function(String peerId) onRemoveRemoteStream;
  final Function(Map<String, dynamic> message) sendSignal;

  WebRTCManager(this._selfId, {
    required this.onAddRemoteStream,
    required this.onRemoveRemoteStream,
    required this.sendSignal
  });

  // 로컬 오디오 스트림 초기화
  Future<void> initializeLocalStream() async {
    _localStream = await navigator.mediaDevices.getUserMedia({'audio': true, 'video': false});
  }

  // 새로운 피어를 위한 PeerConnection 생성 및 Offer 전송
  Future<void> createOffer(String peerId, String roomId) async {
    print('Creating offer for $peerId');
    final pc = await _createPeerConnection(peerId, roomId);
    _peerConnections[peerId] = pc;

    _localStream?.getTracks().forEach((track) {
      pc.addTrack(track, _localStream!);
    });

    final offer = await pc.createOffer();
    await pc.setLocalDescription(offer);

    sendSignal({
      'type': 'offer',
      'sender': _selfId,
      'receiver': peerId,
      'room': roomId,
      'data': offer.toMap()
    });
  }

  // Offer 수신 및 Answer 생성
  Future<void> handleOffer(String peerId, String roomId, dynamic sdp) async {
    print('Handling offer from $peerId');
    final pc = await _createPeerConnection(peerId, roomId);
    _peerConnections[peerId] = pc;

    _localStream?.getTracks().forEach((track) {
      pc.addTrack(track, _localStream!);
    });

    await pc.setRemoteDescription(RTCSessionDescription(sdp['sdp'], sdp['type']));

    final answer = await pc.createAnswer();
    await pc.setLocalDescription(answer);

    sendSignal({
      'type': 'answer',
      'sender': _selfId,
      'receiver': peerId,
      'room': roomId,
      'data': answer.toMap()
    });
  }

  // Answer 수신
  Future<void> handleAnswer(String peerId, dynamic sdp) async {
    print('Handling answer from $peerId');
    final pc = _peerConnections[peerId];
    if (pc != null) {
      await pc.setRemoteDescription(RTCSessionDescription(sdp['sdp'], sdp['type']));
    }
  }

  // ICE Candidate 수신
  Future<void> handleIceCandidate(String peerId, dynamic candidateData) async {
    final pc = _peerConnections[peerId];
    if (pc != null) {
      final candidate = RTCIceCandidate(
        candidateData['candidate'],
        candidateData['sdpMid'],
        candidateData['sdpMLineIndex'],
      );
      await pc.addCandidate(candidate);
    }
  }

  // 피어 연결 종료 및 리소스 정리
  void closePeerConnection(String peerId) {
    print('Closing connection for $peerId');
    _peerConnections[peerId]?.close();
    _peerConnections.remove(peerId);
    onRemoveRemoteStream(peerId);
  }

  void dispose() {
    _localStream?.getTracks().forEach((track) => track.stop());
    _localStream?.dispose();
    _peerConnections.forEach((key, value) => value.dispose());
    _peerConnections.clear();
  }

  // 공통 PeerConnection 생성 로직
  Future<RTCPeerConnection> _createPeerConnection(String peerId, String roomId) async {
    final Map<String, dynamic> configuration = {
      'iceServers': [
        {'urls': 'stun:stun.l.google.com:19302'}, // Google STUN 서버 예시
        // 필요시 TURN 서버 추가
      ]
    };

    final pc = await createPeerConnection(configuration);

    pc.onIceCandidate = (candidate) {
      if (candidate != null) {
        sendSignal({
          'type': 'ice-candidate',
          'sender': _selfId,
          'receiver': peerId,
          'room': roomId,
          'data': candidate.toMap(),
        });
      }
    };

    pc.onTrack = (event) {
      if (event.streams.isNotEmpty) {
        onAddRemoteStream(peerId, event.streams[0]);
      }
    };

    pc.onConnectionState = (state) {
      print('Connection state for $peerId: $state');
      if (state == RTCPeerConnectionState.RTCPeerConnectionStateDisconnected ||
          state == RTCPeerConnectionState.RTCPeerConnectionStateFailed ||
          state == RTCPeerConnectionState.RTCPeerConnectionStateClosed) {
        closePeerConnection(peerId);
      }
    };

    return pc;
  }
}