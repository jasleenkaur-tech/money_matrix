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
  double lockedBalance = 0.0;
  Bet? lastBet;
  Map<String, dynamic>? lastBetResult;
  String? error;
  
  // Notification system
  String? lastNotification;

  bool get isBettingOpen => roundStatus == 'running' && remainingMs > 5000; // Allow until last 5s

  void initialize(AuthService auth) {
    if (auth.token == null) return;

    _socketService.connect(auth.token!, {
      // 🏦 Initial Wallet Sync (Backend spelling: curret-wallet)
      'curret-wallet': (data) {
        userBalance = (data['balance'] ?? 0).toDouble();
        lockedBalance = (data['lockedBalance'] ?? 0).toDouble();
        notifyListeners();
      },

      // 🔄 Live Wallet Update (Win/Loss/Refund)
      'wallet-update': (data) {
        userBalance = (data['balance'] ?? 0).toDouble();
        lockedBalance = (data['lockedBalance'] ?? 0).toDouble();
        notifyListeners();
      },
      
      'current-round': (data) {
        currentRound = GameRound.fromJson(data);
        roundStatus = currentRound?.status ?? 'waiting';
        notifyListeners();
      },
      
      'new-round': (data) {
        currentRound = GameRound.fromJson(data);
        roundStatus = 'running';
        lastBet = null;
        lastBetResult = null;
        lastNotification = "New Round Started! 🚀";
        notifyListeners();
      },
      
      'timer': (data) {
        remainingMs = data['remaining'] ?? 0;
        roundStatus = data['status'] ?? 'running';
        notifyListeners();
      },
      
      'bet-placed': (data) {
        lastBet = Bet.fromJson(data['bet']);
        userBalance = (data['balance'] ?? 0).toDouble();
        lockedBalance = (data['lockedBalance'] ?? 0).toDouble();
        lastNotification = "Bet of ₹${lastBet?.amount} placed on ${lastBet?.color.toUpperCase()} ✅";
        error = null;
        notifyListeners();
      },
      
      'bet-result': (data) {
        final result = Bet.fromJson(data);
        lastBetResult = data;
        bool isWin = result.status == 'won';
        lastNotification = isWin 
            ? "Congratulations! You won ₹${result.winAmount} 🎉" 
            : "Round Ended. Better luck next time! 🍀";
        notifyListeners();
      },
      
      'round-ended': (data) {
        roundStatus = data['status'] ?? 'waiting';
        if (data['currentRound'] != null) {
          currentRound = GameRound.fromJson(data['currentRound']);
        }
        notifyListeners();
      },
      
      'error': (data) {
        error = data['message'];
        lastNotification = "⚠️ $error";
        notifyListeners();
      }
    });
  }

  void placeBet(String color, double amount) {
    if (!isBettingOpen) {
      error = "Betting is currently closed";
      notifyListeners();
      return;
    }
    _socketService.emit('place-bet', {
      'color': color.toLowerCase(), // backend expects lowercase
      'amount': amount,
    });
  }

  void clearNotification() {
    lastNotification = null;
  }

  @override
  void dispose() {
    _socketService.dispose();
    super.dispose();
  }
}
