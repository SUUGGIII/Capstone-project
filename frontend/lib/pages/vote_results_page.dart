import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/vote_result_model.dart';

class VoteResultsPage extends StatefulWidget {
  final String sessionName;

  const VoteResultsPage({super.key, required this.sessionName});

  @override
  State<VoteResultsPage> createState() => _VoteResultsPageState();
}

class _VoteResultsPageState extends State<VoteResultsPage> {
  late Future<List<VoteResultModel>> _voteResultsFuture;

  @override
  void initState() {
    super.initState();
    _voteResultsFuture = _fetchVoteResults();
  }

  Future<List<VoteResultModel>> _fetchVoteResults() async {
    final prefs = await SharedPreferences.getInstance();
    final accessToken = prefs.getString('accessToken');

    if (accessToken == null) {
      throw Exception("로그인이 필요합니다.");
    }

    // API 호출. 로컬호스트 가정.
    final url = Uri.parse('http://localhost:8080/api/votes/room/${widget.sessionName}');
    
    try {
      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $accessToken',
        },
      );

      if (response.statusCode == 200) {
        // UTF-8 디코딩을 명시적으로 처리 (한글 깨짐 방지)
        final List<dynamic> body = jsonDecode(utf8.decode(response.bodyBytes));
        return body.map((e) => VoteResultModel.fromJson(e)).toList();
      } else {
        throw Exception("Failed to load vote results: ${response.statusCode}");
      }
    } catch (e) {
      throw Exception("Error fetching vote results: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("${widget.sessionName} 투표 결과"),
        centerTitle: true,
      ),
      body: FutureBuilder<List<VoteResultModel>>(
        future: _voteResultsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 48, color: Colors.red),
                  const SizedBox(height: 16),
                  Text("오류 발생: ${snapshot.error}"),
                ],
              ),
            );
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(
              child: Text("진행된 투표가 없습니다.", style: TextStyle(fontSize: 16, color: Colors.grey)),
            );
          }

          final votes = snapshot.data!;

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: votes.length,
            itemBuilder: (context, index) {
              final vote = votes[index];
              return _buildVoteCard(vote);
            },
          );
        },
      ),
    );
  }

  Widget _buildVoteCard(VoteResultModel vote) {
    int totalVotes = vote.results.values.fold(0, (sum, count) => sum + count);

    return Card(
      elevation: 3,
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    vote.topic,
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: vote.status == 'CLOSED' ? Colors.grey[200] : Colors.green[50],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    vote.status == 'CLOSED' ? "종료됨" : "진행중",
                    style: TextStyle(
                      fontSize: 12,
                      color: vote.status == 'CLOSED' ? Colors.grey : Colors.green,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text("총 참여: $totalVotes명", style: TextStyle(color: Colors.grey[600], fontSize: 12)),
            const SizedBox(height: 16),
            ...vote.results.entries.map((entry) {
              final option = entry.key;
              final count = entry.value;
              final percentage = totalVotes > 0 ? count / totalVotes : 0.0;

              return Padding(
                padding: const EdgeInsets.only(bottom: 12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(option, style: const TextStyle(fontSize: 14)),
                        Text("$count표 (${(percentage * 100).toStringAsFixed(1)}%)",
                            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                      ],
                    ),
                    const SizedBox(height: 4),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: percentage,
                        backgroundColor: Colors.grey[200],
                        valueColor: const AlwaysStoppedAnimation<Color>(Colors.blueAccent),
                        minHeight: 8,
                      ),
                    ),
                  ],
                ),
              );
            }), // .toList() removed as spread operator supports Iterable
          ],
        ),
      ),
    );
  }
}
