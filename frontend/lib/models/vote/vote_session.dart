class VoteSession {
  final int voteId;
  final String topic;
  final List<String> options;
  final String proposerId;

  VoteSession({
    required this.voteId,
    required this.topic,
    required this.options,
    required this.proposerId,
  });

  factory VoteSession.fromJson(Map<String, dynamic> json) {
    var data = json['data'];
    return VoteSession(
      voteId: data['voteId'] ?? 0,
      topic: data['topic'] ?? '알 수 없는 주제',
      options: List<String>.from(data['options'] ?? []),
      proposerId: data['proposerId'] ?? '',
    );
  }
}
