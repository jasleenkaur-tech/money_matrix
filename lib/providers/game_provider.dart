import 'package:flutter/material.dart';
import '../models/game_models.dart';
import '../services/socket_service.dart';
import '../services/auth_service.dart';

class GameProvider extends ChangeNotifier {
  final SocketService _socketService = SocketService();
  
  GameRound? currentRound;
  int remainingMs = 0;
  String roundStatus = 'waiting';
  
  double userBalance = 0.0;
  Bet? lastBet;
  String? error;

  bool get isBettingOpen => roundStatus == 'running' && remainingMs > 10000; // Close last 10s

  void initialize(AuthService auth) {
    if (auth.token == null) return;

    _socketService.connect(auth.token!, {
      'current-round': (data) {
        currentRound = GameRound.fromJson(data);
        roundStatus = currentRound?.status ?? 'waiting';
        notifyListeners();
      },
      'new-round': (data) {
        currentRound = GameRound.fromJson(data);
        roundStatus = 'running';
        lastBet = null;
        notifyListeners();
      },
      'timer': (data) {
        remainingMs = data['remaining'] ?? 0;
        roundStatus = data['status'] ?? 'waiting';
        notifyListeners();
      },
      'bet-placed': (data) {
        lastBet = Bet.fromJson(data['bet']);
        userBalance = (data['balance'] ?? 0).toDouble();
        notifyListeners();
      },
      'bet-result': (data) {
        final resultBet = Bet.fromJson(data);
        // Show result logic
        notifyListeners();
      },
      'round-ended': (data) {
        roundStatus = 'waiting';
        if (data['currentRound'] != null) {
          currentRound = GameRound.fromJson(data['currentRound']);
        }
        notifyListeners();
      },
      'error': (data) {
        error = data['message'];
        notifyListeners();
      }
    });
  }

  void placeBet(String color, double amount) {
    if (!isBettingOpen) {
      error = "Betting is closed for this round";
      notifyListeners();
      return;
    }
    _socketService.emit('place-bet', {
      'color': color,
      'amount': amount,
    });
  }

  @override
  void dispose() {
    _socketService.dispose();
    super.dispose();
  }
}
