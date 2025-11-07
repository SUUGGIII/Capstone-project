// 기능: WebRTC 통신을 위한 핵심 로직을 관리하는 클래스를 구현함. PeerConnection 생성 및 관리, Offer/Answer/ICE Candidate 교환, 로컬/원격 미디어 스트림 및 화면 공유 스트림 처리, 마이크 및 원격 오디오 제어 등의 복잡한 WebRTC 동작을 캡슐화함.
// 호출: flutter_webrtc 라이브러리의 navigator.mediaDevices, createPeerConnection, RTCSessionDescription, RTCIceCandidate 등 다양한 WebRTC API를 직접 호출하여 미디어 장치 접근, PeerConnection 설정, SDP 및 ICE Candidate 처리를 수행함. sendSignal 콜백을 통해 SignalingService로 시그널링 메시지를 전송함.
// 호출됨: room_screen.dart 파일에서 WebRTCManager 인스턴스를 생성하고 initializeLocalStream, shareScreen, stopShareScreen, createOffer, handleOffer, handleAnswer, handleIceCandidate, closePeerConnection, toggleMicrophone, toggleRemoteAudio, dispose 등의 메소드를 호출하여 WebRTC 통신을 총괄함.
import 'dart:async';
import 'package:flutter_webrtc/flutter_webrtc.dart';

class WebRTCManager {
  final Map<String, RTCPeerConnection> _peerConnections = {};
  MediaStream? _localStream;
  MediaStream? _screenStream;
  final String _selfId;
  final Function(Map<String, dynamic> message) sendSignal;

  final Function(String peerId, MediaStream stream) onAddRemoteStream;
  final Function(String peerId) onRemoveRemoteStream;
  final Function(MediaStream stream) onAddLocalScreenStream;
  final Function() onRemoveLocalScreenStream;
  final Function(String peerId, MediaStream stream) onAddRemoteScreenStream;
  final Function(String peerId) onRemoveRemoteScreenStream;


  WebRTCManager(this._selfId, {
    required this.sendSignal,
    required this.onAddRemoteStream,
    required this.onRemoveRemoteStream,
    required this.onAddLocalScreenStream,
    required this.onRemoveLocalScreenStream,
    required this.onAddRemoteScreenStream,
    required this.onRemoveRemoteScreenStream,
  });

  Future<void> initializeLocalStream() async {
    _localStream = await navigator.mediaDevices.getUserMedia({'audio': true, 'video': false});
  }

  Future<void> shareScreen(DesktopCapturerSource source) async {
    if (_screenStream != null) {
      print("Screen is already being shared.");
      return;
    }
    try {
      _screenStream = await navigator.mediaDevices.getDisplayMedia({
        'video': {
          'deviceId': {'exact': source.id},
          'mandatory': {
            'minFrameRate': '30',
          }
        }
      });

      onAddLocalScreenStream(_screenStream!);

      for (var peerId in _peerConnections.keys) {
        var pc = _peerConnections[peerId]!;
        _screenStream!.getTracks().forEach((track) {
          pc.addTrack(track, _screenStream!);
        });
        await _renegotiate(pc, peerId);
      }
    } catch (e) {
      print('Error sharing screen: $e');
    }
  }

  Future<void> stopShareScreen() async {
    if (_screenStream == null) return;

    try {
      for (var track in _screenStream!.getTracks()) {
        await track.stop();
      }
      await _screenStream!.dispose();
      _screenStream = null;
      onRemoveLocalScreenStream();

      for (var peerId in _peerConnections.keys) {
        var pc = _peerConnections[peerId]!;
        var senders = await pc.getSenders();
        for (var sender in senders) {
          if (sender.track?.kind == 'video') {
            await pc.removeTrack(sender);
          }
        }
        await _renegotiate(pc, peerId);
      }
    } catch (e) {
      print('Error stopping screen share: $e');
    }
  }

  Future<void> _renegotiate(RTCPeerConnection pc, String peerId) async {
    try {
      final offer = await pc.createOffer();
      await pc.setLocalDescription(offer);

      sendSignal({
        'type': 'offer',
        'sender': _selfId,
        'receiver': peerId,
        'room': 'some_room_id',
        'data': offer.toMap()
      });
    } catch (e) {
      print("Renegotiation failed for $peerId: $e");
    }
  }

  Future<void> createOffer(String peerId, String roomId) async {
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

  Future<void> handleOffer(String peerId, String roomId, dynamic sdp) async {
    final pc = _peerConnections[peerId] ?? await _createPeerConnection(peerId, roomId);
    if (!_peerConnections.containsKey(peerId)) {
      _peerConnections[peerId] = pc;
    }

    pc.onRenegotiationNeeded = () async {
      print("Renegotiation needed for $peerId");
      await _renegotiate(pc, peerId);
    };

    await pc.setRemoteDescription(RTCSessionDescription(sdp['sdp'], sdp['type']));

    final senders = await pc.getSenders();
    _localStream?.getTracks().forEach((track) {
      if (!senders.any((sender) => sender.track?.id == track.id)) {
        pc.addTrack(track, _localStream!);
      }
    });

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

  Future<void> handleAnswer(String peerId, dynamic sdp) async {
    final pc = _peerConnections[peerId];
    await pc?.setRemoteDescription(RTCSessionDescription(sdp['sdp'], sdp['type']));
  }

  Future<void> handleIceCandidate(String peerId, dynamic candidateData) async {
    final pc = _peerConnections[peerId];
    final candidate = RTCIceCandidate(
      candidateData['candidate'],
      candidateData['sdpMid'],
      candidateData['sdpMLineIndex'],
    );
    await pc?.addCandidate(candidate);
  }

  void closePeerConnection(String peerId) {
    print('Closing connection for $peerId');
    _peerConnections[peerId]?.dispose();
    _peerConnections.remove(peerId);
    onRemoveRemoteStream(peerId);
    onRemoveRemoteScreenStream(peerId);
  }

  void dispose() {
    _localStream?.getTracks().forEach((track) => track.stop());
    _localStream?.dispose();
    _screenStream?.getTracks().forEach((track) => track.stop());
    _screenStream?.dispose();
    _peerConnections.forEach((key, value) => value.dispose());
    _peerConnections.clear();
  }

  void toggleMicrophone(bool enabled) {
    _localStream?.getAudioTracks().forEach((track) {
      track.enabled = enabled;
    });
  }

  void toggleRemoteAudio(bool enabled) {
    _peerConnections.forEach((key, pc) async {
      var receivers = await pc.getReceivers();
      receivers.forEach((receiver) {
        if (receiver.track?.kind == 'audio') {
          receiver.track?.enabled = enabled;
        }
      });
    });
  }

  Future<RTCPeerConnection> _createPeerConnection(String peerId, String roomId) async {
    final pc = await createPeerConnection({
      'iceServers': [{'urls': 'stun:stun.l.google.com:19302'}]
    });

    pc.onIceCandidate = (candidate) {
      sendSignal({
        'type': 'ice-candidate',
        'sender': _selfId,
        'receiver': peerId,
        'room': roomId,
        'data': candidate.toMap(),
      });
    };

    final Set<String> receivedStreamIds = {};
    pc.onTrack = (event) {
      if (event.streams.isEmpty) return;
      final stream = event.streams[0];

      if (receivedStreamIds.contains(stream.id)) return;
      receivedStreamIds.add(stream.id);

      if (event.track.kind == 'audio') {
        onAddRemoteStream(peerId, stream);
      } else if (event.track.kind == 'video') {
        onAddRemoteScreenStream(peerId, stream);
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
