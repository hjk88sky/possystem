import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';
import 'features/auth/providers/auth_provider.dart';
import 'features/devices/providers/device_provider.dart';

class PosApp extends ConsumerWidget {
  const PosApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);

    // 로그인 성공 시 디바이스 자동등록 + 하트비트 시작
    // 로그아웃 시 하트비트 중지
    ref.listen<AuthState>(authProvider, (prev, next) {
      if (prev?.status != AuthStatus.authenticated &&
          next.status == AuthStatus.authenticated) {
        ref.read(deviceRegistrationProvider.notifier).registerDevice();
      }
      if (prev?.status == AuthStatus.authenticated &&
          next.status != AuthStatus.authenticated) {
        ref.read(deviceRegistrationProvider.notifier).stopHeartbeat();
      }
    });

    return MaterialApp.router(
      title: 'POS System',
      theme: AppTheme.lightTheme,
      routerConfig: router,
      debugShowCheckedModeBanner: false,
    );
  }
}
