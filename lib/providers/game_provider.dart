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
  
  String? lastNotification;
  AuthService? _auth;

  bool get isBettingOpen => roundStatus == 'running' && remainingMs > 5000; 

  void initialize(AuthService auth) {
    _auth = auth;
    if (auth.token == null) return;

    _socketService.connect(auth.token!, {
      'curret-wallet': (data) {
        userBalance = (data['balance'] ?? 0).toDouble();
        lockedBalance = (data['lockedBalance'] ?? 0).toDouble();
        _auth?.updateBalance(userBalance);
        notifyListeners();
      },

      'wallet-update': (data) {
        userBalance = (data['balance'] ?? 0).toDouble();
        lockedBalance = (data['lockedBalance'] ?? 0).toDouble();
        _auth?.updateBalance(userBalance);
        _auth?.getBetInfo(); // ✅ Sync stats in real-time on wallet update
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
        _auth?.getBetInfo(); // ✅ Refresh stats at start of round
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
        _auth?.updateBalance(userBalance);
        _auth?.getBetInfo(); // ✅ Sync stats immediately after bet is placed
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
        
        // ✅ CRITICAL: Fetch latest stats from API when bet is settled
        _auth?.getBetInfo(); 
        notifyListeners();
      },
      
      'round-ended': (data) {
        roundStatus = data['status'] ?? 'waiting';
        if (data['currentRound'] != null) {
          currentRound = GameRound.fromJson(data['currentRound']);
        }
        _auth?.getBetInfo(); // ✅ Refresh stats when round finishes
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
      'color': color.toLowerCase(),
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
