// 기능: 화상 회의 참여 전 사용자가 오디오/비디오 장치를 선택하고 자신의 모습을 미리 볼 수 있는 대기 화면을 제공함. LiveKit 서버에 연결하여 회의에 참여하는 기능을 수행함.
// 호출: room.dart의 RoomPage를 호출하여 실제 회의 화면으로 전환함. livekit_client 패키지의 Hardware, LocalAudioTrack, LocalVideoTrack, Room 등의 클래스와 메소드를 사용하여 장치 관리 및 룸 연결을 처리함. utils/exts.dart의 확장 함수들을 사용하여 다이얼로그를 표시함.
// 호출됨: MeetingPage 또는 다른 회의 시작 지점에서 PreJoinPage 위젯 형태로 호출될 것으로 추정됨.
import 'dart:async';
import 'dart:math' as math;

import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:livekit_client/livekit_client.dart';
import 'package:meeting_app/utils/exts.dart';

import 'room.dart';
import 'package:meeting_app/widgets/Rooms/no_video.dart';

class JoinArgs {
  JoinArgs({
    required this.url,
    required this.token,
    this.e2ee = false,
    this.e2eeKey,
    this.simulcast = true,
    this.adaptiveStream = true,
    this.dynacast = true,
    this.preferredCodec = 'VP8',
    this.enableBackupVideoCodec = true,
  });
  final String url;
  final String token;
  final bool e2ee;
  final String? e2eeKey;
  final bool simulcast;
  final bool adaptiveStream;
  final bool dynacast;
  final String preferredCodec;
  final bool enableBackupVideoCodec;
}

class PreJoinPage extends StatefulWidget {
  const PreJoinPage({
    required this.args,
    super.key,
  });
  final JoinArgs args;
  @override
  State<StatefulWidget> createState() => _PreJoinPageState();
}

class _PreJoinPageState extends State<PreJoinPage> {
  List<MediaDevice> _audioInputs = [];
  List<MediaDevice> _videoInputs = [];
  StreamSubscription? _subscription;

  bool _busy = false;
  bool _enableVideo = true;
  bool _enableAudio = true;
  LocalAudioTrack? _audioTrack;
  LocalVideoTrack? _videoTrack;

  MediaDevice? _selectedVideoDevice;
  MediaDevice? _selectedAudioDevice;
  VideoParameters _selectedVideoParameters = VideoParametersPresets.h720_169;

  @override
  void initState() {
    super.initState();
    _subscription =
        Hardware.instance.onDeviceChange.stream.listen(_loadDevices);
    _initialize();
  }

  Future<void> _initialize() async {
    await _loadDevices();
    await _setEnableVideo(_enableVideo);
    await _setEnableAudio(_enableAudio);
  }

  @override
  void deactivate() {
    _subscription?.cancel();
    super.deactivate();
  }

  @override
  void dispose() {
    _subscription?.cancel();
    _audioTrack?.stop();
    _videoTrack?.stop();
    super.dispose();
  }

  Future<void> _loadDevices([List<MediaDevice>? devices]) async {
    devices ??= await Hardware.instance.enumerateDevices();
    _audioInputs = devices.where((d) => d.kind == 'audioinput').toList();
    _videoInputs = devices.where((d) => d.kind == 'videoinput').toList();

    if (_audioInputs.isNotEmpty && _selectedAudioDevice == null) {
      _selectedAudioDevice = _audioInputs.first;
    }

    if (_videoInputs.isNotEmpty && _selectedVideoDevice == null) {
      _selectedVideoDevice = _videoInputs.first;
    }
    setState(() {});
  }

  Future<void> _setEnableVideo(bool value) async {
    _enableVideo = value;
    if (_enableVideo) {
      await _changeLocalVideoTrack();
    } else {
      await _videoTrack?.stop();
      _videoTrack = null;
    }
    setState(() {});
  }

  Future<void> _setEnableAudio(bool value) async {
    _enableAudio = value;
    if (_enableAudio) {
      await _changeLocalAudioTrack();
    } else {
      await _audioTrack?.stop();
      _audioTrack = null;
    }
    setState(() {});
  }

  Future<void> _changeLocalAudioTrack() async {
    if (_audioTrack != null) {
      await _audioTrack!.stop();
      _audioTrack = null;
    }

    if (_selectedAudioDevice != null && _enableAudio) {
      try {
        _audioTrack = await LocalAudioTrack.create(
          AudioCaptureOptions(
            deviceId: _selectedAudioDevice!.deviceId,
          ),
        );
        await _audioTrack!.start();
      } catch (e) {
        print('Could not create audio track: $e');
        if (mounted) {
          context.showErrorDialog(e);
        }
        _enableAudio = false;
      }
    }
  }

  Future<void> _changeLocalVideoTrack() async {
    if (_videoTrack != null) {
      await _videoTrack!.stop();
      _videoTrack = null;
    }

    if (_selectedVideoDevice != null && _enableVideo) {
      try {
        _videoTrack =
            await LocalVideoTrack.createCameraTrack(CameraCaptureOptions(
          deviceId: _selectedVideoDevice!.deviceId,
          params: _selectedVideoParameters,
        ));
        await _videoTrack!.start();
      } catch (e) {
        print('Could not create video track: $e');
        if (mounted) {
          context.showErrorDialog(e);
        }
        _enableVideo = false;
      }
    }
  }

  _join(BuildContext context) async {
    _busy = true;

    setState(() {});

    var args = widget.args;

    try {
      //create new room
      var cameraEncoding = const VideoEncoding(
        maxBitrate: 5 * 1000 * 1000,
        maxFramerate: 30,
      );

      var screenEncoding = const VideoEncoding(
        maxBitrate: 3 * 1000 * 1000,
        maxFramerate: 15,
      );

      E2EEOptions? e2eeOptions;
      if (args.e2ee && args.e2eeKey != null) {
        final keyProvider = await BaseKeyProvider.create();
        e2eeOptions = E2EEOptions(keyProvider: keyProvider);
        await keyProvider.setKey(args.e2eeKey!);
      }

      final room = Room(
        roomOptions: RoomOptions(
          adaptiveStream: args.adaptiveStream,
          dynacast: args.dynacast,
          defaultAudioPublishOptions: const AudioPublishOptions(
            name: 'custom_audio_track_name',
          ),
          defaultCameraCaptureOptions: const CameraCaptureOptions(
              maxFrameRate: 30,
              params: VideoParameters(
                dimensions: VideoDimensions(1280, 720),
              )),
          defaultScreenShareCaptureOptions: const ScreenShareCaptureOptions(
              useiOSBroadcastExtension: true,
              params: VideoParameters(
                dimensions: VideoDimensionsPresets.h1080_169,
              )),
          defaultVideoPublishOptions: VideoPublishOptions(
            simulcast: args.simulcast,
            videoCodec: args.preferredCodec,
            backupVideoCodec: BackupVideoCodec(
              enabled: args.enableBackupVideoCodec,
            ),
            videoEncoding: cameraEncoding,
            screenShareEncoding: screenEncoding,
          ),
          e2eeOptions: e2eeOptions,
        ),
      );
      // Create a Listener before connecting
      final listener = room.createListener();

      await room.prepareConnection(args.url, args.token);

      // Try to connect to the room
      // This will throw an Exception if it fails for any reason.
      await room.connect(
        args.url,
        args.token,
        fastConnectOptions: FastConnectOptions(
          microphone: TrackOption(track: _audioTrack),
          camera: TrackOption(track: _videoTrack),
        ),
      );

      await Navigator.push<void>(
        context,
        MaterialPageRoute(builder: (_) => RoomPage(room, listener)),
      );
    } catch (error) {
      print('Could not connect $error');
      await context.showErrorDialog(error);
    } finally {
      setState(() {
        _busy = false;
      });
    }
  }

  void _actionBack(BuildContext context) async {
    await _setEnableVideo(false);
    await _setEnableAudio(false);
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text(
            'Select Devices',
            style: TextStyle(
              color: Colors.white,
            ),
          ),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => _actionBack(context),
          ),
        ),
        body: Container(
            alignment: Alignment.center,
            child: SingleChildScrollView(
                child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 20,
                vertical: 20,
              ),
              constraints: const BoxConstraints(maxWidth: 400),
              child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: SizedBox(
                            width: 320,
                            height: 240,
                            child: Container(
                              alignment: Alignment.center,
                              color: Colors.black54,
                              child: _videoTrack != null
                                  ? VideoTrackRenderer(
                                      _videoTrack!,
                                      mirrorMode: VideoViewMirrorMode.mirror,
                                    )
                                  : const NoVideoWidget(),
                            ))),
                    Padding(
                      padding: const EdgeInsets.only(bottom: 5),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Camera:'),
                          Switch(
                            value: _enableVideo,
                            onChanged: (value) => _setEnableVideo(value),
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(bottom: 25),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton2<MediaDevice>(
                          isExpanded: true,
                          disabledHint: const Text('Disable Camera'),
                          hint: const Text(
                            'Select Camera',
                          ),
                          items: _enableVideo
                              ? _videoInputs
                                  .map((MediaDevice item) =>
                                      DropdownMenuItem<MediaDevice>(
                                        value: item,
                                        child: Text(
                                          item.label,
                                          style: const TextStyle(
                                            fontSize: 14,
                                          ),
                                        ),
                                      ))
                                  .toList()
                              : [],
                          value: _selectedVideoDevice,
                          onChanged: (MediaDevice? value) async {
                            if (value != null) {
                              _selectedVideoDevice = value;
                              await _changeLocalVideoTrack();
                              setState(() {});
                            }
                          },
                          buttonStyleData: const ButtonStyleData(
                            padding: EdgeInsets.symmetric(horizontal: 16),
                            height: 40,
                            width: 140,
                          ),
                          menuItemStyleData: const MenuItemStyleData(
                            height: 40,
                          ),
                        ),
                      ),
                    ),
                    if (_enableVideo)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 25),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton2<VideoParameters>(
                            isExpanded: true,
                            hint: const Text(
                              'Select Video Dimensions',
                            ),
                            items: [
                              VideoParametersPresets.h480_43,
                              VideoParametersPresets.h540_169,
                              VideoParametersPresets.h720_169,
                              VideoParametersPresets.h1080_169,
                            ]
                                .map((VideoParameters item) =>
                                    DropdownMenuItem<VideoParameters>(
                                      value: item,
                                      child: Text(
                                        '${item.dimensions.width}x${item.dimensions.height}',
                                        style: const TextStyle(
                                          fontSize: 14,
                                        ),
                                      ),
                                    ))
                                .toList(),
                            value: _selectedVideoParameters,
                            onChanged: (VideoParameters? value) async {
                              if (value != null) {
                                _selectedVideoParameters = value;
                                await _changeLocalVideoTrack();
                                setState(() {});
                              }
                            },
                            buttonStyleData: const ButtonStyleData(
                              padding: EdgeInsets.symmetric(horizontal: 16),
                              height: 40,
                              width: 140,
                            ),
                            menuItemStyleData: const MenuItemStyleData(
                              height: 40,
                            ),
                          ),
                        ),
                      ),
                    Padding(
                      padding: const EdgeInsets.only(bottom: 5),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Micriphone:'),
                          Switch(
                            value: _enableAudio,
                            onChanged: (value) => _setEnableAudio(value),
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(bottom: 25),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton2<MediaDevice>(
                          isExpanded: true,
                          disabledHint: const Text('Disable Microphone'),
                          hint: const Text(
                            'Select Micriphone',
                          ),
                          items: _enableAudio
                              ? _audioInputs
                                  .map((MediaDevice item) =>
                                      DropdownMenuItem<MediaDevice>(
                                        value: item,
                                        child: Text(
                                          item.label,
                                          style: const TextStyle(
                                            fontSize: 14,
                                          ),
                                        ),
                                      ))
                                  .toList()
                              : [],
                          value: _selectedAudioDevice,
                          onChanged: (MediaDevice? value) async {
                            if (value != null) {
                              _selectedAudioDevice = value;
                              await _changeLocalAudioTrack();
                              setState(() {});
                            }
                          },
                          buttonStyleData: const ButtonStyleData(
                            padding: EdgeInsets.symmetric(horizontal: 16),
                            height: 40,
                            width: 140,
                          ),
                          menuItemStyleData: const MenuItemStyleData(
                            height: 40,
                          ),
                        ),
                      ),
                    ),
                    ElevatedButton(
                      onPressed: _busy ? null : () => _join(context),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (_busy)
                            const Padding(
                              padding: EdgeInsets.only(right: 10),
                              child: SizedBox(
                                height: 15,
                                width: 15,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2,
                                ),
                              ),
                            ),
                          const Text('JOIN'),
                        ],
                      ),
                    ),
                  ]),
            ))));
  }
}