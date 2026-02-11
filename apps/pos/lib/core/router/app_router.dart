import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../features/auth/providers/auth_provider.dart';
import '../../features/auth/screens/login_screen.dart';
import '../../features/devices/screens/device_list_screen.dart';
import '../../features/pos/screens/pos_screen.dart';
import '../../features/payment/screens/payment_screen.dart';
import '../../features/order_complete/screens/order_complete_screen.dart';

final routerProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authProvider);

  return GoRouter(
    initialLocation: '/login',
    redirect: (context, state) {
      final isAuth = authState.isAuthenticated;
      final isLoggingIn = state.matchedLocation == '/login';
      final isLoading = authState.status == AuthStatus.initial ||
          authState.status == AuthStatus.loading;

      if (isLoading) return null;

      if (!isAuth && !isLoggingIn) return '/login';
      if (isAuth && isLoggingIn) return '/pos';

      return null;
    },
    routes: [
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/pos',
        builder: (context, state) => const PosScreen(),
      ),
      GoRoute(
        path: '/payment',
        builder: (context, state) {
          final extra = state.extra as Map<String, dynamic>?;
          return PaymentScreen(
            orderId: extra?['orderId'] as int? ?? 0,
            totalAmount: extra?['totalAmount'] as int? ?? 0,
          );
        },
      ),
      GoRoute(
        path: '/devices',
        builder: (context, state) => const DeviceListScreen(),
      ),
      GoRoute(
        path: '/order-complete',
        builder: (context, state) {
          final extra = state.extra as Map<String, dynamic>?;
          return OrderCompleteScreen(
            orderNumber: extra?['orderNumber'] as String? ?? '',
            totalAmount: extra?['totalAmount'] as int? ?? 0,
            paymentMethod: extra?['paymentMethod'] as String? ?? '',
            changeAmount: extra?['changeAmount'] as int? ?? 0,
          );
        },
      ),
    ],
    errorBuilder: (context, state) => Scaffold(
      body: Center(
        child: Text('페이지를 찾을 수 없습니다: ${state.error}'),
      ),
    ),
  );
});
