// 기능: LiveKit 화상 회의에 참여하기 위한 방 생성 및 설정 페이지를 제공함. 서버 URL, 토큰, 사용자 정보, 방 이름, E2EE, Simulcast, Adaptive Stream, Dynacast, 코덱 등 다양한 회의 관련 옵션을 설정하고 관리함. 백엔드 서버로부터 LiveKit 토큰을 요청하는 기능을 포함함.
// 호출: prejoin.dart의 PreJoinPage를 호출하여 설정된 값으로 회의 대기 화면으로 이동함. LKTextField 위젯을 사용하여 사용자 입력을 받음. permission_handler를 사용하여 카메라 및 마이크 권한을 요청하고, shared_preferences를 사용하여 설정값을 저장하고 불러옴. http 패키지를 사용하여 백엔드 서버와 통신하여 LiveKit 토큰을 가져옴.
// 호출됨: home_page.dart 또는 meeting_page.dart와 같은 메인 화면에서 "새 회의" 또는 "방 생성" 기능으로 CreateRoomPage 위젯 형태로 호출될 것으로 추정됨.
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:livekit_client/livekit_client.dart';
import 'package:meeting_app/utils/exts.dart';
import 'package:meeting_app/pages/Rooms/prejoin.dart';
import 'package:meeting_app/widgets/text_field.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:meeting_app/services/api_service.dart';
import 'dart:convert';

class CreateRoomPage extends StatefulWidget {
  const CreateRoomPage({super.key});

  @override
  State<StatefulWidget> createState() => _CreateRoomPageState();
}

class _CreateRoomPageState extends State<CreateRoomPage> {
  static const _liveKitServerBaseUrl = 'http://127.0.0.1:8080';
  static const _tokenEndpoint = '/api/livekit/token';

  static const _storeKeyUri = 'uri';
  static const _storeKeyToken = 'token';
  static const _storeKeySimulcast = 'simulcast';
  static const _storeKeyAdaptiveStream = 'adaptive-stream';
  static const _storeKeyDynacast = 'dynacast';
  static const _storeKeyE2EE = 'e2ee';
  static const _storeKeySharedKey = 'shared-key';
  static const _storeKeyMultiCodec = 'multi-codec';

  final _uriCtrl = TextEditingController();
  final _tokenCtrl = TextEditingController();
  final _sharedKeyCtrl = TextEditingController();
  final _nameCtrl = TextEditingController();
  final _identityCtrl = TextEditingController();
  final _metadataCtrl = TextEditingController();
  final _roomNameCtrl = TextEditingController();

  bool _simulcast = true;
  bool _adaptiveStream = true;
  bool _dynacast = true;
  bool _busy = false;
  bool _e2ee = false;
  bool _multiCodec = false;
  String _preferredCodec = 'VP8';

  @override
  void initState() {
    super.initState();
    _readPrefs();
    if (lkPlatformIs(PlatformType.android)) {
      _checkPermissions();
    }
    _nameCtrl.text = 'user';
    _identityCtrl.text = 'user-${DateTime.now().millisecondsSinceEpoch % 1000}';
    _metadataCtrl.text = 'MeetingParticipant';
    _roomNameCtrl.text = 'my-team-meeting';
  }

  @override
  void dispose() {
    _uriCtrl.dispose();
    _tokenCtrl.dispose();
    _sharedKeyCtrl.dispose();
    _nameCtrl.dispose();
    _identityCtrl.dispose();
    _metadataCtrl.dispose();
    _roomNameCtrl.dispose();
    super.dispose();
  }

  Future<void> _checkPermissions() async {
    var status = await Permission.bluetooth.request();
    if (status.isPermanentlyDenied) {
      print('Bluetooth Permission disabled');
    }
    status = await Permission.bluetoothConnect.request();
    if (status.isPermanentlyDenied) {
      print('Bluetooth Connect Permission disabled');
    }
    status = await Permission.camera.request();
    if (status.isPermanentlyDenied) {
      print('Camera Permission disabled');
    }
    status = await Permission.microphone.request();
    if (status.isPermanentlyDenied) {
      print('Microphone Permission disabled');
    }
  }

  Future<void> _readPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    _uriCtrl.text = const bool.hasEnvironment('URL')
        ? const String.fromEnvironment('URL')
        : prefs.getString(_storeKeyUri) ?? '';
    _tokenCtrl.text = const bool.hasEnvironment('TOKEN')
        ? const String.fromEnvironment('TOKEN')
        : prefs.getString(_storeKeyToken) ?? '';
    _sharedKeyCtrl.text = const bool.hasEnvironment('E2EEKEY')
        ? const String.fromEnvironment('E2EEKEY')
        : prefs.getString(_storeKeySharedKey) ?? '';
    setState(() {
      _simulcast = prefs.getBool(_storeKeySimulcast) ?? true;
      _adaptiveStream = prefs.getBool(_storeKeyAdaptiveStream) ?? true;
      _dynacast = prefs.getBool(_storeKeyDynacast) ?? true;
      _e2ee = prefs.getBool(_storeKeyE2EE) ?? false;
      _multiCodec = prefs.getBool(_storeKeyMultiCodec) ?? false;
    });
  }

  Future<void> _writePrefs() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_storeKeyUri, _uriCtrl.text);
    await prefs.setString(_storeKeyToken, _tokenCtrl.text);
    await prefs.setString(_storeKeySharedKey, _sharedKeyCtrl.text);
    await prefs.setBool(_storeKeySimulcast, _simulcast);
    await prefs.setBool(_storeKeyAdaptiveStream, _adaptiveStream);
    await prefs.setBool(_storeKeyDynacast, _dynacast);
    await prefs.setBool(_storeKeyE2EE, _e2ee);
    await prefs.setBool(_storeKeyMultiCodec, _multiCodec);
  }

  Future<void> _fetchLiveKitToken(BuildContext ctx) async {
    final name = _nameCtrl.text.trim();
    final identity = _identityCtrl.text.trim();
    final metadata = _metadataCtrl.text.trim();
    final roomName = _roomNameCtrl.text.trim();

    try {
      setState(() {
        _busy = true;
      });

      final response = await ApiService.post(
        _tokenEndpoint,
        body: {
          'name': name,
          'identity': identity,
          'metadata': metadata,
          'roomName': roomName,
        },
        context: ctx,
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        final livekitToken = data['token'];
        final livekitUrl = data['url'];

        if (livekitToken != null) {
          _tokenCtrl.text = livekitToken;
        } else {
          await ctx.showErrorDialog('응답에서 LiveKit 토큰(token)을 찾을 수 없습니다.');
        }

        if (livekitUrl != null) {
          _uriCtrl.text = livekitUrl;
        }
      } else {
        await ctx.showErrorDialog(
          '토큰 요청 실패: HTTP ${response.statusCode}\n서버 응답: ${response.body}',
        );
      }
    } catch (e) {
      await ctx.showErrorDialog('토큰 요청 중 오류 발생: $e');
    } finally {
      setState(() {
        _busy = false;
      });
    }
  }

  Future<void> _connect(BuildContext ctx) async {
    try {
      setState(() {
        _busy = true;
      });
      await _writePrefs();
      print('Connecting with url: ${_uriCtrl.text}, '
          'token: ${_tokenCtrl.text}...');
      var url = _uriCtrl.text;
      var token = _tokenCtrl.text;
      var e2eeKey = _sharedKeyCtrl.text;
      await Navigator.push<void>(
        ctx,
        MaterialPageRoute(
            builder: (_) => PreJoinPage(
              args: JoinArgs(
                url: url,
                token: token,
                e2ee: _e2ee,
                e2eeKey: e2eeKey,
                simulcast: _simulcast,
                adaptiveStream: _adaptiveStream,
                dynacast: _dynacast,
                preferredCodec: _preferredCodec,
                enableBackupVideoCodec:
                ['VP9', 'AV1'].contains(_preferredCodec),
              ),
            )),
      );
    } catch (error) {
      print('Could not connect $error');
      await ctx.showErrorDialog(error);
    } finally {
      setState(() {
        _busy = false;
      });
    }
  }

  void _setSimulcast(bool? value) async {
    if (value == null || _simulcast == value) return;
    setState(() {
      _simulcast = value;
    });
  }

  void _setE2EE(bool? value) async {
    if (value == null || _e2ee == value) return;
    setState(() {
      _e2ee = value;
    });
  }

  void _setAdaptiveStream(bool? value) async {
    if (value == null || _adaptiveStream == value) return;
    setState(() {
      _adaptiveStream = value;
    });
  }

  void _setDynacast(bool? value) async {
    if (value == null || _dynacast == value) return;
    setState(() {
      _dynacast = value;
    });
  }

  void _setMultiCodec(bool? value) async {
    if (value == null || _multiCodec == value) return;
    setState(() {
      _multiCodec = value;
    });
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
        title: const Text('New Meeting Settings'),
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
                padding: const EdgeInsets.only(bottom: 50),
                child: Image.asset(
                  'assets/zoom_logo.png',
                  height: 100,
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(bottom: 25),
                child: LKTextField(
                  label: 'Name(회원정보, DB꺼(자동 입력 -> 추후 칸 삭제))',
                  ctrl: _nameCtrl,
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(bottom: 25),
                child: LKTextField(
                  label: 'Identity(회원정보, DB꺼(자동입력 -> 추후 칸 삭제))',
                  ctrl: _identityCtrl,
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(bottom: 25),
                child: LKTextField(
                  label: 'metadata(직책, 뭐 방장 이런거?, DB꺼?)',
                  ctrl: _metadataCtrl,
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(bottom: 25),
                child: LKTextField(
                  label: 'RoomName(생성할때 입력하는거)(회의실별 고유값)',
                  ctrl: _roomNameCtrl,
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(bottom: 25),
                child: ElevatedButton(
                  onPressed: _busy ? null : () => _fetchLiveKitToken(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blueGrey,
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
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
                      const Text(
                        'GET LIVEKIT TOKEN',
                        style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(bottom: 25),
                child: LKTextField(
                  label: 'LiveKit Server URL (ws://...)(모든 회의실, 참가자 고정값 -> 추후 삭제)',
                  ctrl: _uriCtrl,
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(bottom: 25),
                child: LKTextField(
                  label: 'Access Token (JWT)(Name, Identity, Metadata ,RoomName으로 생성)',
                  ctrl: _tokenCtrl,
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(bottom: 25),
                child: LKTextField(
                  label: 'Shared Key (for E2EE)(전송 내용 암호화용 비밀번호)(사용자가 지정 및 회의 참자가와 직접 공유해서 입력해야함)',
                  ctrl: _sharedKeyCtrl,
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(bottom: 5),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('E2EE'),
                    Switch(
                      value: _e2ee,
                      onChanged: (value) => _setE2EE(value),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(bottom: 5),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Simulcast'),
                    Switch(
                      value: _simulcast,
                      onChanged: (value) => _setSimulcast(value),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(bottom: 5),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Adaptive Stream'),
                    Switch(
                      value: _adaptiveStream,
                      onChanged: (value) => _setAdaptiveStream(value),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(bottom: 5),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Dynacast'),
                    Switch(
                      value: _dynacast,
                      onChanged: (value) => _setDynacast(value),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: EdgeInsets.only(bottom: _multiCodec ? 5 : 25),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Multi Codec'),
                    Switch(
                      value: _multiCodec,
                      onChanged: (value) => _setMultiCodec(value),
                    ),
                  ],
                ),
              ),
              if (_multiCodec)
                Padding(
                    padding: const EdgeInsets.only(bottom: 5),
                    child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Preferred Codec:'),
                          DropdownButton<String>(
                            value: _preferredCodec,
                            icon: const Icon(
                              Icons.arrow_drop_down,
                              color: Colors.blue,
                            ),
                            elevation: 16,
                            style: const TextStyle(color: Colors.blue),
                            underline: Container(
                              height: 2,
                              color: Colors.blueAccent,
                            ),
                            onChanged: (String? value) {
                              setState(() {
                                _preferredCodec = value!;
                              });
                            },
                            items: [
                              'Preferred Codec',
                              'AV1',
                              'VP9',
                              'VP8',
                              'H264',
                              'H265'
                            ].map<DropdownMenuItem<String>>((String value) {
                              return DropdownMenuItem<String>(
                                value: value,
                                child: Text(value),
                              );
                            }).toList(),
                          )
                        ])),
              ElevatedButton(
                onPressed: _busy ? null : () => _connect(context),
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
                    const Text('CONNECT'),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}
