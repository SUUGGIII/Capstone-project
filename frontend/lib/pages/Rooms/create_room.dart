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
import 'package:http/http.dart' as http;
import 'dart:convert';

import '../../services/user_store.dart';

class CreateRoomPage extends StatefulWidget {
  const CreateRoomPage({super.key});

  @override
  State<StatefulWidget> createState() => _CreateRoomPageState();
}

class _CreateRoomPageState extends State<CreateRoomPage> {
  static const _liveKitServerBaseUrl = 'http://127.0.0.1:8080';
  static const _tokenEndpoint = '/livekit/token';

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
  bool _isEmptyWindowMode = false;

  @override
  void initState() {
    super.initState();
    _readPrefs();
    if (lkPlatformIs(PlatformType.android)) {
      _checkPermissions();
    }
    _uriCtrl.text = 'ws://59.187.251.201:7880';
    final user = UserStore().user;
    _nameCtrl.text = user?.nickname ?? 'user';
    _identityCtrl.text = user?.userId.toString() ?? '';
    
    if (user != null) {
      final metadataMap = {
        'age': user.age,
        'sex': user.sex,
        'occupation': user.occupation,
      };
      _metadataCtrl.text = jsonEncode(metadataMap);
    } else {
      _metadataCtrl.text = '{}';
    }
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
    await prefs.setString(_storeKeySharedKey, _sharedKeyCtrl.text);
    await prefs.setBool(_storeKeySimulcast, _simulcast);
    await prefs.setBool(_storeKeyAdaptiveStream, _adaptiveStream);
    await prefs.setBool(_storeKeyDynacast, _dynacast);
    await prefs.setBool(_storeKeyE2EE, _e2ee);
    await prefs.setBool(_storeKeyMultiCodec, _multiCodec);
  }

  Future<void> _fetchLiveKitToken(BuildContext ctx) async {
    final prefs = await SharedPreferences.getInstance();
    final userAuthToken = prefs.getString('accessToken');
    final name = _nameCtrl.text.trim();
    final identity = _identityCtrl.text.trim();
    final metadata = _metadataCtrl.text.trim();
    final roomName = _roomNameCtrl.text.trim();
    final url = Uri.parse(_liveKitServerBaseUrl + _tokenEndpoint);
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
          'Authorization': 'Bearer $userAuthToken',
        },
        body: jsonEncode({
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
          _tokenCtrl.text = livekitToken;
        } else {
          await ctx.showErrorDialog('응답에서 LiveKit 토큰(token)을 찾을 수 없습니다.');
        }
      } else {
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
    try {
      setState(() {
        _busy = true;
      });
      
      // 토큰 생성 (Connect 버튼 누를 때 작동)
      await _fetchLiveKitToken(ctx);
      
      if (_tokenCtrl.text.isEmpty) {
        // 토큰 발급 실패 시 중단 (에러 메시지는 _fetchLiveKitToken에서 처리됨)
        return;
      }

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
        actions: [
          IconButton(
            icon: Icon(
              _isEmptyWindowMode ? Icons.visibility_off : Icons.visibility,
              color: Colors.blue,
            ),
            onPressed: () {
              setState(() {
                _isEmptyWindowMode = !_isEmptyWindowMode;
              });
            },
          ),
        ],
      ),
    body: _isEmptyWindowMode
        ? Container(color: Colors.white)
        : Container(
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
              Center(
                child: Card(
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(32.0),
                    child: Column(
                      children: [
                        const Text(
                          'Join Meeting',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 32),
                        LKTextField(
                          label: 'Name',
                          ctrl: _nameCtrl,
                        ),
                        const SizedBox(height: 24),
                        LKTextField(
                          label: 'RoomName',
                          ctrl: _roomNameCtrl,
                        ),
                        const SizedBox(height: 32),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: _busy ? null : () => _connect(context),
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                if (_busy)
                                  const Padding(
                                    padding: EdgeInsets.only(right: 12),
                                    child: SizedBox(
                                      height: 16,
                                      width: 16,
                                      child: CircularProgressIndicator(
                                        color: Colors.white,
                                        strokeWidth: 2,
                                      ),
                                    ),
                                  ),
                                const Text(
                                  'CONNECT',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}
