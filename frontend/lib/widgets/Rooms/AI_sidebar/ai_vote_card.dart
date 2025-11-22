import 'package:flutter/material.dart';
import 'package:meeting_app/models/vote/vote_session.dart';
import 'package:meeting_app/services/api_service.dart';

class AiVoteCard extends StatefulWidget {
  final VoteSession voteSession;
  final String voterId;
  final bool isProposer;
  final VoidCallback? onRemove;

  const AiVoteCard({
    super.key,
    required this.voteSession,
    required this.voterId,
    required this.isProposer,
    this.onRemove,
  });

  @override
  State<AiVoteCard> createState() => _AiVoteCardState();
}

class _AiVoteCardState extends State<AiVoteCard> {
  bool _isLoading = false;
  bool _hasVoted = false;
  String? _myVote;

  void _handleVote(String selectedOption) async {
    if (_isLoading || _hasVoted) return;

    setState(() {
      _isLoading = true;
    });

    final success = await ApiService.castVote(
      voteId: widget.voteSession.voteId,
      voterId: widget.voterId,
      selectedOption: selectedOption,
    );

    if (!mounted) return;

    setState(() {
      _isLoading = false;
      if (success) {
        _hasVoted = true;
        _myVote = selectedOption;
      }
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(success ? '투표가 제출되었습니다.' : '투표 제출에 실패했습니다.'),
      ),
    );
  }

  void _handleCloseVote() async {
    final success = await ApiService.closeVote(voteId: widget.voteSession.voteId);
     if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(success ? '투표가 마감되었습니다.' : '투표 마감에 실패했습니다.'),
      ),
    );
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
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                widget.voteSession.topic,
                style: const TextStyle(
                  color: Colors.black,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Divider(),
              if (_isLoading)
                const Center(
                  child: Padding(
                    padding: EdgeInsets.all(8.0),
                    child: CircularProgressIndicator(),
                  ),
                )
              else
                ...widget.voteSession.options.map((option) {
                  final isSelected = _myVote == option;
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4.0),
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: isSelected ? Colors.blue.shade100 : null
                      ),
                      onPressed: _hasVoted ? null : () => _handleVote(option),
                      child: Text(option),
                    ),
                  );
                }).toList(),
              
              if (_hasVoted)
                Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: Text('내 선택: $_myVote', textAlign: TextAlign.center, style: TextStyle(color: Colors.blue, fontWeight: FontWeight.bold)),
                ),

              if (widget.isProposer) ...[
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: _handleCloseVote,
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.red.shade400),
                  child: const Text('투표 마감'),
                )
              ]
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
