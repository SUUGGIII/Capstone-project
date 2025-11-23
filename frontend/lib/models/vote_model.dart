class VoteEvent {
  final String topic;
  final List<String> options;
  final String proposer;
  final String createdAt;

  VoteEvent({required this.topic, required this.options, required this.proposer, required this.createdAt});

  factory VoteEvent.fromJson(Map<String, dynamic> json) {
    var optionsList = List<String>.from(json['data']['options']);
    return VoteEvent(
      topic: json['data']['topic'] ?? '알 수 없는 주제',
      options: optionsList,
      proposer: json['data']['proposer'] ?? 'Unknown',
      createdAt: json['data']['created_at'] ?? '',
    );
  }
}
