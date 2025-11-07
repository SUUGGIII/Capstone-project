// 기능: 화면 공유 기능을 위해 사용자가 공유할 스크린 또는 특정 애플리케이션 윈도우를 선택할 수 있도록 목록을 제공하는 다이얼로그 위젯을 구현함.
// 호출: flutter_webrtc 패키지의 desktopCapturer.getSources 메소드를 호출하여 시스템에서 사용 가능한 화면 공유 소스(스크린, 윈도우) 목록을 비동기적으로 가져옴. flutter/material.dart의 AlertDialog, ListView.builder, ListTile, Radio 등 기본 위젯을 사용하여 선택 UI를 구성함.
// 호출됨: controls.dart 파일의 _enableScreenShare 메소드 또는 room_screen.dart 파일의 _toggleScreenShare 메소드에서 showDialog를 통해 다이얼로그 형태로 호출되어 사용됨.
// screen_select_dialog.dart
import 'package:flutter/material.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';

class ScreenSelectDialog extends StatefulWidget {
  const ScreenSelectDialog({super.key});

  @override
  State<ScreenSelectDialog> createState() => _ScreenSelectDialogState();
}

class _ScreenSelectDialogState extends State<ScreenSelectDialog> {
  List<DesktopCapturerSource> _sources = [];
  DesktopCapturerSource? _selectedSource;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadSources();
  }

  Future<void> _loadSources() async {
    try {
      final sources = await desktopCapturer.getSources(types: [SourceType.Screen, SourceType.Window]);
      setState(() {
        _sources = sources;
        _isLoading = false;
      });
    } catch (e) {
      print('Error loading screen sources: $e');
      // Handle error appropriately
      Navigator.of(context).pop(); // Close dialog on error
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Select Screen to Share'),
      content: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SizedBox(
        width: double.maxFinite,
        child: ListView.builder(
          itemCount: _sources.length,
          itemBuilder: (context, index) {
            final source = _sources[index];
            return ListTile(
              title: Text(source.name),
              leading: Radio<DesktopCapturerSource>(
                value: source,
                groupValue: _selectedSource,
                onChanged: (DesktopCapturerSource? value) {
                  setState(() {
                    _selectedSource = value;
                  });
                },
              ),
              onTap: () {
                setState(() {
                  _selectedSource = source;
                });
              },
            );
          },
        ),
      ),
      actions: <Widget>[
        TextButton(
          child: const Text('Cancel'),
          onPressed: () => Navigator.of(context).pop(),
        ),
        TextButton(
          child: const Text('Share'),
          onPressed: _selectedSource == null
              ? null
              : () => Navigator.of(context).pop(_selectedSource),
        ),
      ],
    );
  }
}