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
