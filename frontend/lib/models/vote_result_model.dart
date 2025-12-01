class VoteResultModel {
  final int id;
  final String roomName;
  final String topic;
  final Map<String, List<String>> results;
  final String status;

  VoteResultModel({
    required this.id,
    required this.roomName,
    required this.topic,
    required this.results,
    required this.status,
  });

  factory VoteResultModel.fromJson(Map<String, dynamic> json) {
    return VoteResultModel(
      id: json['id'],
      roomName: json['roomName'],
      topic: json['topic'],
      results: Map<String, List<String>>.from(
        (json['results'] as Map<String, dynamic>).map(
          (key, value) => MapEntry(key, List<String>.from(value)),
        ),
      ),
      status: json['status'],
    );
  }
}
