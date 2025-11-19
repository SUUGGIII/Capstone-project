// 기능: 화상 회의 참가자의 비디오가 비활성화되었거나 존재하지 않을 때, 이를 시각적으로 나타내는 "비디오 없음" 아이콘 위젯을 구현함.
// 호출: flutter/material.dart의 Icon 및 Container 등 기본 위젯을 사용하여 UI를 구성함. dart:math의 min 함수를 사용하여 아이콘 크기를 동적으로 조절함.
// 호출됨: participant.dart 파일에서 ParticipantWidget 내부에서 참가자의 비디오 트랙이 없을 경우 NoVideoWidget 형태로 호출되어 사용됨.
import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'package:meeting_app/theme/theme.dart';

class NoVideoWidget extends StatelessWidget {
  //
  const NoVideoWidget({super.key});

  @override
  Widget build(BuildContext context) => Container(
        alignment: Alignment.center,
        child: LayoutBuilder(
          builder: (ctx, constraints) => Icon(
            Icons.videocam_off_outlined,
            color: LKColors.lkBlue,
            size: math.min(constraints.maxHeight, constraints.maxWidth) * 0.3,
          ),
        ),
      );
}
