import 'package:flutter/material.dart';
import 'package:meeting_app/services/api_service.dart';
import '../models/vote_model.dart';

class VoteDialog extends StatefulWidget {
  final VoteEvent voteEvent;
  final String roomName;
  final String voterId;

  const VoteDialog({
    Key? key,
    required this.voteEvent,
    required this.roomName,
    required this.voterId,
  }) : super(key: key);

  @override
  State<VoteDialog> createState() => _VoteDialogState();
}

class _VoteDialogState extends State<VoteDialog> {
  bool _isLoading = false;

  void _handleVote(String selectedOption) async {
    if (_isLoading) return;

    setState(() {
      _isLoading = true;
    });

    final success = await ApiService.submitVote(
      roomName: widget.roomName,
      topic: widget.voteEvent.topic,
      voterId: widget.voterId,
      selectedOption: selectedOption,
    );

    if (!mounted) return;

    setState(() {
      _isLoading = false;
    });

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('투표가 완료되었습니다.')),
      );
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('투표 제출에 실패했습니다.')),
      );
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Container(
        width: 400,
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(widget.voteEvent.topic,
                style:
                    const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            Text("제안자: ${widget.voteEvent.proposer}"),
            const Divider(),
            if (_isLoading)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 20.0),
                child: CircularProgressIndicator(),
              )
            else
              ...widget.voteEvent.options
                  .map((option) => ElevatedButton(
                        onPressed: () => _handleVote(option),
                        child: Text(option),
                      ))
                  .toList(),
          ],
        ),
      ),
    );
  }
}
