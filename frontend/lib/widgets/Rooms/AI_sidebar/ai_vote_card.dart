import 'package:flutter/material.dart';
import 'package:meeting_app/models/vote_model.dart';
import 'package:meeting_app/services/api_service.dart';

class AiVoteCard extends StatefulWidget {
  final VoteEvent voteEvent;
  final String roomName;
  final String voterId;
  final VoidCallback? onRemove;

  const AiVoteCard({
    super.key,
    required this.voteEvent,
    required this.roomName,
    required this.voterId,
    this.onRemove,
  });

  @override
  State<AiVoteCard> createState() => _AiVoteCardState();
}

class _AiVoteCardState extends State<AiVoteCard> {
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

    // Show SnackBar and then remove the card
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(success ? '투표가 완료되었습니다.' : '투표 제출에 실패했습니다.'),
      ),
    );

    // After showing feedback, trigger the removal/clearing of the card
    if (widget.onRemove != null) {
      widget.onRemove!();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8.0),
      ),
      child: Stack(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.voteEvent.topic,
                style: const TextStyle(
                  color: Colors.black,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text("제안자: ${widget.voteEvent.proposer}"),
              const Divider(),
              if (_isLoading)
                const Center(
                  child: Padding(
                    padding: EdgeInsets.all(8.0),
                    child: CircularProgressIndicator(),
                  ),
                )
              else
                ...widget.voteEvent.options.map((option) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4.0),
                    child: ElevatedButton(
                      onPressed: () => _handleVote(option),
                      child: Text(option),
                    ),
                  );
                }).toList(),
            ],
          ),
          Positioned(
            top: -10,
            right: -10,
            child: IconButton(
              icon: const Icon(Icons.close, size: 16, color: Colors.grey),
              onPressed: widget.onRemove,
            ),
          ),
        ],
      ),
    );
  }
}
