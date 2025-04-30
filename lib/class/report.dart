class Report {
  final int? id;
  final int userId;
  final int score;
  final String resultMessage;
  final String timestamp;

  Report({
    this.id,
    required this.userId,
    required this.score,
    required this.resultMessage,
    required this.timestamp,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'user_id': userId,
      'score': score,
      'result_message': resultMessage,
      'timestamp': timestamp,
    };
  }

  factory Report.fromMap(Map<String, dynamic> map) {
    return Report(
      id: map['id'],
      userId: map['user_id'],
      score: map['score'],
      resultMessage: map['result_message'],
      timestamp: map['timestamp'],
    );
  }
}