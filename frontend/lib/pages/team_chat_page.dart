import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:livekit_client/livekit_client.dart';
import 'package:meeting_app/pages/exts.dart';
import 'package:meeting_app/pages/prejoin.dart';
import 'package:meeting_app/pages/text_field.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http; // HTTP 통신을 위한 라이브러리 추가
import 'dart:convert'; // JSON 처리를 위한 라이브러리 추가

class TeamChatPage extends StatefulWidget {
  const TeamChatPage({super.key});

  @override
  State<StatefulWidget> createState() => _TeamChatPageState();
}

class _TeamChatPageState extends State<TeamChatPage> {
  // LiveKit 토큰을 요청할 백엔드 서버의 기본 URL을 정적 상수로 정의합니다.
  // **주의: 실제 백엔드 서버 주소로 변경해야 합니다.**
  static const _liveKitServerBaseUrl = 'http://127.0.0.1:8080';
  static const _tokenEndpoint = '/livekit/token';
  // 이전의 _userAuthToken 상수는 제거하고 SharedPreferences에서 액세스 토큰을 가져옵니다.

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
    _uriCtrl.text = 'wss://stt-bu5ksfvb.livekit.cloud';
    // 기본값 설정
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
    // ... (기존 권한 체크 로직)
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

  // Read saved URL and Token
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

  // Save URL and Token
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

  /**
   * 백엔드 서버에 요청하여 LiveKit 액세스 토큰을 가져오는 함수
   */
  Future<void> _fetchLiveKitToken(BuildContext ctx) async {
    // SharedPreferences에서 저장된 accessToken을 가져옵니다.
    final prefs = await SharedPreferences.getInstance();
    final userAuthToken = prefs.getString('accessToken');

    final name = _nameCtrl.text.trim();
    final identity = _identityCtrl.text.trim();
    final metadata = _metadataCtrl.text.trim();
    final roomName = _roomNameCtrl.text.trim();

    final url = Uri.parse(_liveKitServerBaseUrl + _tokenEndpoint);


    // accessToken이 없으면 오류 메시지를 표시하고 반환합니다.
    if (userAuthToken == null || userAuthToken.isEmpty) {
      await ctx.showErrorDialog('토큰 요청 실패: SharedPreferences에 저장된 사용자 accessToken이 없습니다. 먼저 로그인/인증을 통해 토큰을 저장해야 합니다.');
      return;
    }

    try {
      setState(() {
        _busy = true;
      });

      print('Requesting token from $url...');

      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          // SharedPreferences에서 가져온 사용자 인증 토큰을 헤더에 포함합니다.
          'Authorization': 'Bearer $userAuthToken',
        },
        body: jsonEncode({
          // 서버의 LiveKitRequestDTO에 맞게 인자들을 전송합니다.
          'name': name,
          'identity': identity,
          'metadata': metadata,
          'roomName': roomName,
        }),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        final livekitToken = data['token'];

        if (livekitToken != null) {
          // 성공적으로 LiveKit 토큰을 받아와 Token 필드에 채웁니다.
          _tokenCtrl.text = livekitToken;
        } else {
          await ctx.showErrorDialog('응답에서 LiveKit 토큰(token)을 찾을 수 없습니다.');
        }
      } else {
        // HTTP 오류 처리
        await ctx.showErrorDialog(
            '토큰 요청 실패: HTTP ${response.statusCode}\n서버 응답: ${response.body}');
      }
    } catch (e) {
      print('Token fetching error: $e');
      await ctx.showErrorDialog('토큰 요청 중 오류 발생: $e');
    } finally {
      setState(() {
        _busy = false;
      });
    }
  }

  Future<void> _connect(BuildContext ctx) async {
    //
    try {
      setState(() {
        _busy = true;
      });

      // Save URL and Token for convenience
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
                child: SvgPicture.asset(
                  'images/logo-dark.svg',
                  height: 100,
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(bottom: 25),
                child: LKTextField(
                  label: 'Name',
                  ctrl: _nameCtrl,
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(bottom: 25),
                child: LKTextField(
                  label: 'Identity',
                  ctrl: _identityCtrl,
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(bottom: 25),
                child: LKTextField(
                  label: 'metadata',
                  ctrl: _metadataCtrl,
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(bottom: 25),
                child: LKTextField(
                  label: 'RoomName',
                  ctrl: _roomNameCtrl,
                ),
              ),
              // 토큰 요청 버튼
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
              // Server URL, Token, Shared Key는 기존대로 유지
              Padding(
                padding: const EdgeInsets.only(bottom: 25),
                child: LKTextField(
                  label: 'LiveKit Server URL (ws://...)',
                  ctrl: _uriCtrl,
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(bottom: 25),
                child: LKTextField(
                  label: 'Access Token (JWT)',
                  ctrl: _tokenCtrl,
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(bottom: 25),
                child: LKTextField(
                  label: 'Shared Key (for E2EE)',
                  ctrl: _sharedKeyCtrl,
                ),
              ),
              // ... (이하 스위치 설정 및 CONNECT 버튼은 기존대로 유지)
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
                              // This is called when the user selects an item.
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
