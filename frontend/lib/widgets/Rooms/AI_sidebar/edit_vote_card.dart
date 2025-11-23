import 'package:flutter/material.dart';
import 'package:meeting_app/models/vote/vote_proposal.dart';

class EditVoteCard extends StatefulWidget {
  final VoteProposal proposal;
  final Function(String topic, List<String> options) onStart;
  final VoidCallback onCancel;

  const EditVoteCard({
    super.key,
    required this.proposal,
    required this.onStart,
    required this.onCancel,
  });

  @override
  State<EditVoteCard> createState() => _EditVoteCardState();
}

class _EditVoteCardState extends State<EditVoteCard> {
  late TextEditingController _topicController;
  late List<TextEditingController> _optionControllers;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _topicController = TextEditingController(text: widget.proposal.topic);
    _optionControllers = widget.proposal.options
        .map((opt) => TextEditingController(text: opt))
        .toList();
  }

  void _addOption() {
    setState(() {
      _optionControllers.add(TextEditingController());
    });
  }

  void _removeOption(int index) {
    setState(() {
      _optionControllers.removeAt(index);
    });
  }

  void _handleStart() {
    if (_isLoading) return;

    setState(() {
      _isLoading = true;
    });

    final topic = _topicController.text;
    final options =
        _optionControllers.map((c) => c.text).where((t) => t.isNotEmpty).toList();

    if (topic.isNotEmpty && options.length >= 2) {
      widget.onStart(topic, options);
    } else {
      // Show an error if topic is empty or less than 2 options
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('주제와 2개 이상의 선택지를 입력해주세요.')),
      );
      setState(() {
        _isLoading = false;
      });
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text('투표 수정 및 확정', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 8),
          TextField(
            controller: _topicController,
            decoration: const InputDecoration(labelText: '투표 주제'),
          ),
          const SizedBox(height: 8),
          ..._optionControllers.asMap().entries.map((entry) {
            int idx = entry.key;
            TextEditingController controller = entry.value;
            return Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: controller,
                    decoration: InputDecoration(labelText: '선택지 ${idx + 1}'),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.remove_circle_outline),
                  onPressed: () => _removeOption(idx),
                ),
              ],
            );
          }).toList(),
          TextButton.icon(
            icon: const Icon(Icons.add),
            label: const Text('선택지 추가'),
            onPressed: _addOption,
          ),
          const SizedBox(height: 16),
          if (_isLoading)
            const Center(child: CircularProgressIndicator())
          else
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: widget.onCancel,
                  child: const Text('취소'),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: _handleStart,
                  child: const Text('공유 및 시작'),
                ),
              ],
            ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _topicController.dispose();
    for (var controller in _optionControllers) {
      controller.dispose();
    }
    super.dispose();
  }
}
