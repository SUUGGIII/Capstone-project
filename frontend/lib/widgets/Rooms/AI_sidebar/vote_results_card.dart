import 'package:flutter/material.dart';
import 'package:meeting_app/models/vote/vote_results.dart';

class VoteResultsCard extends StatelessWidget {
  final VoteResults results;
  final VoidCallback onDismiss;

  const VoteResultsCard({
    super.key,
    required this.results,
    required this.onDismiss,
  });

  @override
  Widget build(BuildContext context) {
    // Find the winning option
    String winningOption = '';
    int maxVotes = 0;
    results.results.forEach((option, votes) {
      if (votes > maxVotes) {
        maxVotes = votes;
        winningOption = option;
      }
    });

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
                '투표 결과: ${results.topic}',
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              const Divider(),
              ...results.results.entries.map((entry) {
                bool isWinner = entry.key == winningOption;
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        entry.key,
                        style: TextStyle(
                          fontWeight: isWinner ? FontWeight.bold : FontWeight.normal,
                          color: isWinner ? Colors.blue : Colors.black,
                        ),
                      ),
                      Text(
                        '${entry.value}표',
                        style: TextStyle(
                          fontWeight: isWinner ? FontWeight.bold : FontWeight.normal,
                          color: isWinner ? Colors.blue : Colors.black,
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
              const SizedBox(height: 16),
              Center(
                child: Text(
                  '최다 득표: $winningOption',
                  style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.blue),
                ),
              ),
            ],
          ),
          Positioned(
            top: -10,
            right: -10,
            child: IconButton(
              icon: const Icon(Icons.close, size: 16, color: Colors.grey),
              onPressed: onDismiss,
            ),
          ),
        ],
      ),
    );
  }
}
