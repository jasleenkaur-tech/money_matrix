class GameRound {
  final String id;
  final String roundId;
  final String status; // running, waiting, ended
  final DateTime? startTime;
  final DateTime? endTime;
  final double totalBetAmount;
  final double totalRed;
  final double totalBlue;
  final double totalViolet;
  final String? result;

  GameRound({
    required this.id,
    required this.roundId,
    required this.status,
    this.startTime,
    this.endTime,
    this.totalBetAmount = 0,
    this.totalRed = 0,
    this.totalBlue = 0,
    this.totalViolet = 0,
    this.result,
  });

  factory GameRound.fromJson(Map<String, dynamic> json) {
    return GameRound(
      id: json['_id'] ?? '',
      roundId: json['roundId'] ?? '',
      status: json['status'] ?? 'waiting',
      startTime: json['startTime'] != null ? DateTime.parse(json['startTime']) : null,
      endTime: json['endTime'] != null ? DateTime.parse(json['endTime']) : null,
      totalBetAmount: (json['totalBetAmount'] ?? 0).toDouble(),
      totalRed: (json['totalRed'] ?? 0).toDouble(),
      totalBlue: (json['totalBlue'] ?? 0).toDouble(),
      totalViolet: (json['totalViolet'] ?? 0).toDouble(),
      result: json['result'],
    );
  }
}

class Bet {
  final String id;
  final String userId;
  final String roundId;
  final String color;
  final double amount;
  final String status;
  final double winAmount;
  final bool isSettled;

  Bet({
    required this.id,
    required this.userId,
    required this.roundId,
    required this.color,
    required this.amount,
    required this.status,
    this.winAmount = 0,
    this.isSettled = false,
  });

  factory Bet.fromJson(Map<String, dynamic> json) {
    return Bet(
      id: json['_id'] ?? '',
      userId: json['user'] ?? '',
      roundId: json['round'] ?? '',
      color: json['color'] ?? '',
      amount: (json['amount'] ?? 0).toDouble(),
      status: json['status'] ?? 'pending',
      winAmount: (json['winAmount'] ?? 0).toDouble(),
      isSettled: json['isSettled'] ?? false,
    );
  }
}
