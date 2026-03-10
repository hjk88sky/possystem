import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:socket_io_client/socket_io_client.dart' as io;
import '../config/api_config.dart';

class RealtimeEvent {
  final String event;
  final String? storeId;
  final String timestamp;
  final Map<String, dynamic> payload;

  const RealtimeEvent({
    required this.event,
    required this.timestamp,
    required this.payload,
    this.storeId,
  });

  factory RealtimeEvent.fromJson(Map<String, dynamic> json) {
    return RealtimeEvent(
      event: json['event'] as String? ?? 'store.event',
      storeId: json['storeId'] as String?,
      timestamp: json['timestamp'] as String? ?? DateTime.now().toIso8601String(),
      payload: json,
    );
  }
}

class RealtimeState {
  final bool isConnected;
  final String? storeId;
  final RealtimeEvent? lastEvent;

  const RealtimeState({
    this.isConnected = false,
    this.storeId,
    this.lastEvent,
  });

  RealtimeState copyWith({
    bool? isConnected,
    String? storeId,
    RealtimeEvent? lastEvent,
  }) {
    return RealtimeState(
      isConnected: isConnected ?? this.isConnected,
      storeId: storeId ?? this.storeId,
      lastEvent: lastEvent ?? this.lastEvent,
    );
  }
}

class RealtimeNotifier extends StateNotifier<RealtimeState> {
  RealtimeNotifier() : super(const RealtimeState());

  io.Socket? _socket;

  void connect({required String storeId}) {
    if (state.storeId == storeId && _socket?.connected == true) {
      return;
    }

    disconnect();

    final socket = io.io(
      ApiConfig.realtimeUrl,
      io.OptionBuilder()
          .setTransports(['websocket'])
          .disableAutoConnect()
          .setAuth({'storeId': storeId})
          .build(),
    );

    socket.onConnect((_) {
      state = state.copyWith(isConnected: true, storeId: storeId);
      socket.emit('store.subscribe', {'storeId': storeId});
    });

    socket.onDisconnect((_) {
      state = state.copyWith(isConnected: false);
    });

    socket.on('store.event', (data) {
      if (data is Map) {
        state = state.copyWith(
          lastEvent: RealtimeEvent.fromJson(Map<String, dynamic>.from(data)),
        );
      }
    });

    _socket = socket;
    socket.connect();
  }

  void disconnect() {
    _socket?.dispose();
    _socket = null;
    state = const RealtimeState();
  }

  @override
  void dispose() {
    disconnect();
    super.dispose();
  }
}

final realtimeProvider =
    StateNotifierProvider<RealtimeNotifier, RealtimeState>((ref) {
  return RealtimeNotifier();
});
