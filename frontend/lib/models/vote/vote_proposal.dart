class VoteProposal {
  final String topic;
  final List<String> options;
  final String proposerId;

  VoteProposal({
    required this.topic,
    required this.options,
    required this.proposerId,
  });

  factory VoteProposal.fromJson(Map<String, dynamic> json) {
    var data = json['data'];
    return VoteProposal(
      topic: data['topic'] ?? '알 수 없는 주제',
      options: List<String>.from(data['options'] ?? []),
      proposerId: data['proposer'] ?? '', // Assuming the backend sends 'proposer' as the ID
    );
  }
}
