// 기능: LiveKit 화상 회의 참가자의 실시간 WebRTC 통계(오디오/비디오 비트레이트, 코덱, 프레임률, 패킷 손실 등)를 표시하는 디버깅 및 모니터링용 위젯을 구현함.
// 호출: livekit_client 패키지의 Participant, Track, EventsListener, VideoSenderStatsEvent, AudioSenderStatsEvent 등 다양한 클래스와 이벤트를 사용하여 참가자의 미디어 트랙 통계 정보를 수집하고 처리함. flutter/material.dart의 Column, Text 등 기본 위젯을 사용하여 통계 정보를 UI에 표시함.
// 호출됨: participant.dart 파일에서 ParticipantWidget 내부에서 showStatsLayer가 활성화될 경우 ParticipantStatsWidget 형태로 호출되어 사용됨.
import 'package:flutter/material.dart';
import 'package:livekit_client/livekit_client.dart';

enum StatsType {
  kUnknown,
  kLocalAudioSender,
  kLocalVideoSender,
  kRemoteAudioReceiver,
  kRemoteVideoReceiver,
}

class ParticipantStatsWidget extends StatefulWidget {
  const ParticipantStatsWidget({super.key, required this.participant});
  final Participant participant;
  @override
  State<StatefulWidget> createState() => _ParticipantStatsWidgetState();
}

class _ParticipantStatsWidgetState extends State<ParticipantStatsWidget> {
  List<EventsListener<TrackEvent>> listeners = [];
  StatsType statsType = StatsType.kUnknown;
  Map<String, Map<String, String>> stats = {'audio': {}, 'video': {}};

  void _setUpListener(Track track) {
    var listener = track.createListener();
    listeners.add(listener);
    if (track is LocalVideoTrack) {
      statsType = StatsType.kLocalVideoSender;
      listener.on<VideoSenderStatsEvent>((event) {
        Map<String, String> stats = {};
        setState(() {
          stats['tx'] = 'total sent ${event.currentBitrate.toInt()} kpbs';
          event.stats.forEach((key, value) {
            stats['layer-$key'] =
                '${value.frameWidth ?? 0}x${value.frameHeight ?? 0} ${value.framesPerSecond?.toDouble() ?? 0} fps, ${event.bitrateForLayers[key] ?? 0} kbps';
          });
          var firstStats =
              event.stats['f'] ?? event.stats['h'] ?? event.stats['q'];
          if (firstStats != null) {
            stats['encoder'] = firstStats.encoderImplementation ?? '';
            if (firstStats.mimeType != null) {
              stats['codec'] =
                  '${firstStats.mimeType!.split('/')[1]}/${firstStats.clockRate}';
            }
            stats['payload'] = '${firstStats.payloadType}';
            stats['qualityLimitationReason'] =
                firstStats.qualityLimitationReason ?? '';
          }

          this.stats['video']!.addEntries(stats.entries);
        });
      });
    } else if (track is RemoteVideoTrack) {
      statsType = StatsType.kRemoteVideoReceiver;
      listener.on<VideoReceiverStatsEvent>((event) {
        Map<String, String> stats = {};
        setState(() {
          if (!event.currentBitrate.isNaN) {
            stats['rx'] = '${event.currentBitrate.toInt()} kpbs';
          }
          if (event.stats.mimeType != null) {
            stats['codec'] =
                '${event.stats.mimeType!.split('/')[1]}/${event.stats.clockRate}';
          }
          stats['payload'] = '${event.stats.payloadType}';
          stats['size/fps'] =
              '${event.stats.frameWidth}x${event.stats.frameHeight} ${event.stats.framesPerSecond?.toDouble()}fps';
          stats['jitter'] = '${event.stats.jitter} s';
          stats['decoder'] = '${event.stats.decoderImplementation}';
          //stats['video packets lost'] = '${event.stats.packetsLost}';
          //stats['video packets received'] = '${event.stats.packetsReceived}';
          stats['frames received'] = '${event.stats.framesReceived}';
          stats['frames decoded'] = '${event.stats.framesDecoded}';
          stats['frames dropped'] = '${event.stats.framesDropped}';

          this.stats['video']!.addEntries(stats.entries);
        });
      });
    } else if (track is LocalAudioTrack) {
      statsType = StatsType.kLocalAudioSender;
      listener.on<AudioSenderStatsEvent>((event) {
        Map<String, String> stats = {};
        setState(() {
          stats['tx'] = '${event.currentBitrate.toInt()} kpbs';
          if (event.stats.mimeType != null) {
            stats['codec'] =
                '${event.stats.mimeType!.split('/')[1]}/${event.stats.clockRate}/${event.stats.channels}';
          }
          stats['payload'] = '${event.stats.payloadType}';
          this.stats['audio']!.addEntries(stats.entries);
        });
      });
    } else if (track is RemoteAudioTrack) {
      statsType = StatsType.kRemoteAudioReceiver;
      listener.on<AudioReceiverStatsEvent>((event) {
        Map<String, String> stats = {};
        setState(() {
          stats['rx'] = '${event.currentBitrate.toInt()} kpbs';
          if (event.stats.mimeType != null) {
            stats['codec'] =
                '${event.stats.mimeType!.split('/')[1]}/${event.stats.clockRate}/${event.stats.channels}';
          }
          stats['payload'] = '${event.stats.payloadType}';
          stats['jitter'] = '${event.stats.jitter} s';
          //stats['concealed samples'] =
          //    '${event.stats.concealedSamples} / ${event.stats.concealmentEvents}';
          stats['packets lost'] = '${event.stats.packetsLost}';
          stats['packets received'] = '${event.stats.packetsReceived}';

          this.stats['audio']!.addEntries(stats.entries);
        });
      });
    }
  }

  _onParticipantChanged() {
    for (var element in listeners) {
      element.dispose();
    }
    listeners.clear();
    for (var track in [
      ...widget.participant.videoTrackPublications,
      ...widget.participant.audioTrackPublications
    ]) {
      if (track.track != null) {
        _setUpListener(track.track!);
      }
    }
  }

  @override
  void initState() {
    super.initState();
    widget.participant.addListener(_onParticipantChanged);
    // trigger initial change
    _onParticipantChanged();
  }

  @override
  void deactivate() {
    for (var element in listeners) {
      element.dispose();
    }
    widget.participant.removeListener(_onParticipantChanged);
    super.deactivate();
  }

  num sendBitrate = 0;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black.withValues(alpha: 0.3),
      padding: const EdgeInsets.symmetric(
        vertical: 8,
        horizontal: 8,
      ),
      child: Column(children: [
        const Text('audio stats',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        ...stats['audio']!.entries.map((e) => Text('${e.key}: ${e.value}')),
        const Text('video stats',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        ...stats['video']!.entries.map((e) => Text('${e.key}: ${e.value}')),
      ]),
    );
  }
}
