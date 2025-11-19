// 기능: 화상 회의 참가자의 이름, 마이크 상태, 연결 품질, 화면 공유 여부, E2EE(종단 간 암호화) 활성화 여부 등 핵심 정보를 표시하는 위젯을 구현함.
// 호출: flutter/material.dart의 Row, Text, Icon 등 기본 위젯을 사용하여 정보를 시각적으로 구성함. livekit_client 패키지의 ConnectionQuality enum을 사용하여 연결 품질에 따른 아이콘을 표시함.
// 호출됨: participant.dart 파일에서 ParticipantInfoWidget 형태로 호출되어 각 참가자 비디오 화면 하단에 정보 오버레이로 사용됨.
import 'package:flutter/material.dart';
import 'package:livekit_client/livekit_client.dart';

enum ParticipantTrackType {
  kUserMedia,
  kScreenShare,
}

extension ParticipantTrackTypeExt on ParticipantTrackType {
  TrackSource get lkVideoSourceType => {
        ParticipantTrackType.kUserMedia: TrackSource.camera,
        ParticipantTrackType.kScreenShare: TrackSource.screenShareVideo,
      }[this]!;

  TrackSource get lkAudioSourceType => {
        ParticipantTrackType.kUserMedia: TrackSource.microphone,
        ParticipantTrackType.kScreenShare: TrackSource.screenShareAudio,
      }[this]!;
}

class ParticipantTrack {
  ParticipantTrack(
      {required this.participant, this.type = ParticipantTrackType.kUserMedia});
  Participant participant;
  final ParticipantTrackType type;
}

class ParticipantInfoWidget extends StatelessWidget {
  final String? title;
  final bool audioAvailable;
  final ConnectionQuality connectionQuality;
  final bool isScreenShare;
  final bool enabledE2EE;

  const ParticipantInfoWidget({
    this.title,
    this.audioAvailable = true,
    this.connectionQuality = ConnectionQuality.unknown,
    this.isScreenShare = false,
    this.enabledE2EE = false,
    super.key,
  });

  @override
  Widget build(BuildContext context) => Container(
        color: Colors.black.withValues(alpha: 0.3),
        padding: const EdgeInsets.symmetric(
          vertical: 7,
          horizontal: 10,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            if (title != null)
              Flexible(
                child: Text(
                  title!,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            isScreenShare
                ? const Padding(
                    padding: EdgeInsets.only(left: 5),
                    child: Icon(
                      Icons.monitor,
                      color: Colors.white,
                      size: 16,
                    ),
                  )
                : Padding(
                    padding: const EdgeInsets.only(left: 5),
                    child: Icon(
                      audioAvailable ? Icons.mic : Icons.mic_off,
                      color: audioAvailable ? Colors.white : Colors.red,
                      size: 16,
                    ),
                  ),
            if (connectionQuality != ConnectionQuality.unknown)
              Padding(
                padding: const EdgeInsets.only(left: 5),
                child: Icon(
                  connectionQuality == ConnectionQuality.poor
                      ? Icons.wifi_off_outlined
                      : Icons.wifi,
                  color: {
                    ConnectionQuality.excellent: Colors.green,
                    ConnectionQuality.good: Colors.orange,
                    ConnectionQuality.poor: Colors.red,
                  }[connectionQuality],
                  size: 16,
                ),
              ),
            Padding(
              padding: const EdgeInsets.only(left: 5),
              child: Icon(
                enabledE2EE ? Icons.lock : Icons.lock_open,
                color: enabledE2EE ? Colors.green : Colors.red,
                size: 16,
              ),
            ),
          ],
        ),
      );
}
