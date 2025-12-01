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
    // 1. 최다 득표 수 찾기
    int maxVotes = 0;
    if (results.results.isNotEmpty) {
      maxVotes = results.results.values.reduce((curr, next) => curr > next ? curr : next);
    }

    // 2. 최다 득표 항목들 찾기 (동점자 처리)
    List<String> winners = [];
    if (maxVotes > 0) {
      results.results.forEach((option, votes) {
        if (votes == maxVotes) {
          winners.add(option);
        }
      });
    }

    // 3. 단독 1등 여부 확인
    String? singleWinner;
    if (winners.length == 1) {
      singleWinner = winners.first;
    }

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

              // 모든 항목과 득표 수 표시
              ...results.results.entries.map((entry) {
                // 단독 1등인 경우에만 파란색/볼드체 강조
                bool isWinner = singleWinner != null && entry.key == singleWinner;

                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          entry.key,
                          style: TextStyle(
                            fontWeight: isWinner ? FontWeight.bold : FontWeight.normal,
                            color: isWinner ? Colors.blue : Colors.black87,
                          ),
                        ),
                      ),
                      Text(
                        '${entry.value}표',
                        style: TextStyle(
                          fontWeight: isWinner ? FontWeight.bold : FontWeight.normal,
                          color: isWinner ? Colors.blue : Colors.black87,
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),

              const SizedBox(height: 16),

              // 최다 득표 표시 (단독 1등일 때만, 동점이면 생략)
              if (singleWinner != null)
                Center(
                  child: Text(
                    '최다 득표: $singleWinner',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.blue,
                      fontSize: 15,
                    ),
                  ),
                )
              else if (maxVotes > 0 && winners.length > 1)
              // (선택사항) 동점자가 있을 때 메시지를 보여주고 싶다면 아래 주석 해제
              /*
                 const Center(
                   child: Text(
                     '동점 항목이 있습니다.',
                     style: TextStyle(color: Colors.grey, fontSize: 13),
                   ),
                 )
                 */
                const SizedBox.shrink(), // 동점이면 아무것도 표시 안 함
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
