import 'package:socket_io_client/socket_io_client.dart' as io;
import 'dart:developer';

class SocketService {
  late io.Socket socket;
  final String _baseUrl = "https://delphia-synostotic-fletcher.ngrok-free.dev"; // Use your backend URL

  void connect(String token, Map<String, Function> listeners) {
    socket = io.io(_baseUrl, io.OptionBuilder()
      .setTransports(['websocket'])
      .setAuth({'token': token})
      .enableAutoConnect()
      .build());

    socket.onConnect((_) {
      log('✅ Socket connected: ${socket.id}');
    });

    socket.onDisconnect((_) {
      log('❌ Socket disconnected');
    });

    socket.onConnectError((err) {
      log('⚠️ Socket connect error: $err');
    });

    // Register dynamic listeners
    listeners.forEach((event, callback) {
      socket.on(event, (data) => callback(data));
    });
  }

  void emit(String event, dynamic data) {
    if (socket.connected) {
      socket.emit(event, data);
    }
  }

  void dispose() {
    socket.dispose();
  }
}
