import 'package:socket_io_client/socket_io_client.dart' as io;

import '../network/remote/dio_helper.dart';
import '../widgets/constant.dart';

class OrdersSocketService {
  OrdersSocketService._();

  static final OrdersSocketService instance = OrdersSocketService._();

  io.Socket? _socket;

  bool get isConnected => _socket?.connected == true;

  void connect({required String role, required VoidCallback onOrdersChanged}) {
    final userId = int.tryParse(id) ?? 0;
    if (role.isEmpty || userId == 0) return;

    disconnect();

    _socket = io.io(
      url,
      io.OptionBuilder()
          .setTransports(['websocket'])
          .disableAutoConnect()
          .setAuth({'token': token})
          .setQuery({'role': role, 'userId': userId})
          .build(),
    );

    _socket!
      ..onConnect((_) {
        _socket?.emit('join_orders', {'role': role, 'userId': userId});
      })
      ..on('orders_changed', (_) => onOrdersChanged())
      ..connect();
  }

  void disconnect() {
    final userId = int.tryParse(id) ?? 0;
    final role = adminOrUser;
    if (_socket != null && userId != 0 && role.isNotEmpty) {
      _socket?.emit('leave_orders', {'role': role, 'userId': userId});
    }
    _socket?.off('orders_changed');
    _socket?.disconnect();
    _socket?.dispose();
    _socket = null;
  }
}

typedef VoidCallback = void Function();
