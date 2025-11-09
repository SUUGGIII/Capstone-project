import 'package:flutter/material.dart';
import 'package:livekit_client/livekit_client.dart' as lk;

class RoomScreen extends StatefulWidget {
  final String roomId;
  final String token; // You need to generate this token on your backend
  final String livekitUrl;

  const RoomScreen({
    super.key,
    required this.roomId,
    required this.token,
    required this.livekitUrl,
  });

  @override
  State<RoomScreen> createState() => _RoomScreenState();
}

class _RoomScreenState extends State<RoomScreen> {
  late final lk.Room _room;
  lk.EventsListener<lk.RoomEvent>? _listener;
  List<lk.Participant> _participants = [];
  bool _isMicEnabled = true;
  bool _isCameraEnabled = false;
  bool _isScreenSharing = false;

  // LiveKit server URL
  final String _liveKitUrl = 'ws://localhost:7880';

  @override
  void initState() {
    super.initState();
    _room = lk.Room();
    _connectToRoom();
  }

  Future<void> _connectToRoom() async {
    try {
      _listener = _room.createListener();
      _listener!
        ..on<lk.RoomDisconnectedEvent>((event) async {
          if (mounted) {
            // Handle disconnection
            Navigator.pop(context);
          }
        })
        ..on<lk.ParticipantEvent>((event) => _sortParticipants())
        ..on<lk.TrackSubscribedEvent>((event) => _sortParticipants())
        ..on<lk.TrackUnsubscribedEvent>((event) => _sortParticipants());

      await _room.connect(
        widget.livekitUrl,
        widget.token,
        roomOptions: const lk.RoomOptions(
          adaptiveStream: true,
          dynacast: true,
          defaultVideoPublishOptions: lk.VideoPublishOptions(
            simulcast: true,
          ),
        ),
      );

      // Initially publish audio
      await _room.localParticipant?.setMicrophoneEnabled(true);
      _sortParticipants();

    } catch (e) {
      print('Could not connect to the room: $e');
      // Handle connection error
      if (mounted) {
        Navigator.pop(context);
      }
    }
  }

  void _sortParticipants() {
    List<lk.Participant> participants = [];
    if (_room.remoteParticipants.isNotEmpty) {
      participants.addAll(_room.remoteParticipants.values);
    }
    // sort speakers for the grid
    participants.sort((a, b) {
      // loudest speaker first
      if (a.isSpeaking && b.isSpeaking) {
        return b.audioLevel.compareTo(a.audioLevel);
      }

      // speaker goes first
      if (a.isSpeaking != b.isSpeaking) {
        return a.isSpeaking ? -1 : 1;
      }

      // last spoken at
      final aSpokeAt = a.lastSpokeAt?.millisecondsSinceEpoch ?? 0;
      final bSpokeAt = b.lastSpokeAt?.millisecondsSinceEpoch ?? 0;

      if (aSpokeAt != bSpokeAt) {
        return bSpokeAt.compareTo(aSpokeAt);
      }

      // video on
      if (a.hasVideo != b.hasVideo) {
        return a.hasVideo ? -1 : 1;
      }

      // joined at
      return a.joinedAt.compareTo(b.joinedAt);
    });

    final localParticipant = _room.localParticipant;
    if (localParticipant != null) {
      participants.insert(0, localParticipant);
    }

    setState(() {
      _participants = participants;
    });
  }

  void _toggleMic() async {
    setState(() {
      _isMicEnabled = !_isMicEnabled;
    });
    await _room.localParticipant?.setMicrophoneEnabled(_isMicEnabled);
  }

  void _toggleCamera() async {
    setState(() {
      _isCameraEnabled = !_isCameraEnabled;
    });
    await _room.localParticipant?.setCameraEnabled(_isCameraEnabled);
  }

  void _toggleScreenShare() async {
    setState(() {
      _isScreenSharing = !_isScreenSharing;
    });
    await _room.localParticipant?.setScreenShareEnabled(_isScreenSharing);
  }

  @override
  void dispose() {
    _listener?.dispose();
    _room.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Room: ${widget.roomId}'),
      ),
      body: _room.connectionState == lk.ConnectionState.connected
          ? GridView.builder(
              gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                maxCrossAxisExtent: 200,
                childAspectRatio: 1,
              ),
              itemCount: _participants.length,
              itemBuilder: (context, index) {
                final participant = _participants[index];
                return ParticipantTile(participant: participant);
              },
            )
          : const Center(child: CircularProgressIndicator()),
      bottomNavigationBar: BottomAppBar(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            IconButton(
              icon: Icon(_isMicEnabled ? Icons.mic : Icons.mic_off),
              onPressed: _toggleMic,
            ),
            IconButton(
              icon: Icon(_isCameraEnabled ? Icons.videocam : Icons.videocam_off),
              onPressed: _toggleCamera,
            ),
            IconButton(
              icon: Icon(
                _isScreenSharing ? Icons.stop_screen_share : Icons.screen_share,
                color: _isScreenSharing ? Colors.blue : Colors.grey,
              ),
              onPressed: _toggleScreenShare,
            ),
            IconButton(
              icon: const Icon(Icons.call_end, color: Colors.red),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ],
        ),
      ),
    );
  }
}

class ParticipantTile extends StatefulWidget {
  final lk.Participant participant;

  const ParticipantTile({super.key, required this.participant});

  @override
  State<ParticipantTile> createState() => _ParticipantTileState();
}

class _ParticipantTileState extends State<ParticipantTile> {
  lk.TrackPublication? get _videoTrack => widget.participant.videoTrackPublications.firstOrNull;

  bool get isScreenSharing => _videoTrack?.source == lk.TrackSource.screenShareVideo;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(
          color: widget.participant.isSpeaking ? Colors.blue : Colors.grey,
          width: widget.participant.isSpeaking ? 3 : 1,
        ),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Stack(
        children: [
          if (_videoTrack != null && _videoTrack!.subscribed)
            lk.VideoTrackRenderer(
              _videoTrack!.track as lk.VideoTrack,
              fit: lk.VideoViewFit.cover,
            ),
          if (_videoTrack == null || !_videoTrack!.subscribed)
            const Center(child: Icon(Icons.person, size: 50)),
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              width: double.infinity,
              color: Colors.black.withOpacity(0.5),
              padding: const EdgeInsets.all(4),
              child: Text(
                widget.participant.identity,
                style: const TextStyle(color: Colors.white),
                textAlign: TextAlign.center,
              ),
            ),
          ),
          Align(
            alignment: Alignment.topRight,
            child: Padding(
              padding: const EdgeInsets.all(4.0),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (widget.participant.isMuted)
                    const Icon(Icons.mic_off, color: Colors.white, size: 18),
                  if (!widget.participant.isMuted)
                    const Icon(Icons.mic, color: Colors.white, size: 18),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}