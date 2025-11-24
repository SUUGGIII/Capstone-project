class VoteResults {
  final int voteId;
  final String topic;
  final Map<String, int> results;

  VoteResults({
    required this.voteId,
    required this.topic,
    required this.results,
  });

  factory VoteResults.fromJson(Map<String, dynamic> json) {
    var data = json['data'];
    // The 'results' map from backend has String keys and Long values (from collectors.counting).
    // We need to cast them correctly.
    final Map<String, int> parsedResults = (data['results'] as Map<String, dynamic>).map(
          (key, value) => MapEntry(key, (value as num).toInt()),
    );

    return VoteResults(
      voteId: data['voteId'] ?? 0,
      topic: data['topic'] ?? '알 수 없는 주제',
      results: parsedResults,
    );
  }
}
