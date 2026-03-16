class RoomModel {
  final String id;
  final String title;
  final String gameType;
  final double betAmount;
  final String creatorId;
  final int playersCount;
  RoomModel({
    required this.id,
    required this.title,
    required this.gameType,
    required this.betAmount,
    required this.creatorId,
    required this.playersCount,
  });
}
