import 'dart:async';
import 'package:socket_io_client/socket_io_client.dart' as io;
import '../storage/app_storage.dart';
import '../constants/app_constants.dart';

class SocketService {
  io.Socket? _socket;
  final _messageController = StreamController<Map<String, dynamic>>.broadcast();

  Stream<Map<String, dynamic>> get messageStream => _messageController.stream;

  void connect() async {
    final token = await AppStorage.getAccessToken();
    if (token == null) return;

    _socket = io.io(AppConstants.baseUrl.replaceAll('/api/v1', ''), {
      'transports': ['websocket'],
      'autoConnect': true,
      'auth': {'token': token},
    });

    _socket?.onConnect((_) {
      print('📡 Socket Connected');
    });

    _socket?.onDisconnect((_) {
      print('📡 Socket Disconnected');
    });

    _socket?.on('new_message', (data) {
      _messageController.add(Map<String, dynamic>.from(data));
    });
  }

  void disconnect() {
    _socket?.disconnect();
    _socket = null;
  }

  void dispose() {
    _messageController.close();
    disconnect();
  }
}
