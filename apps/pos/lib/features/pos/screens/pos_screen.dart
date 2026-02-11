import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../auth/providers/auth_provider.dart';
import '../../devices/providers/device_provider.dart';
import '../widgets/category_tab_bar.dart';
import '../widgets/menu_grid.dart';
import '../widgets/cart_panel.dart';

class PosScreen extends ConsumerStatefulWidget {
  const PosScreen({super.key});

  @override
  ConsumerState<PosScreen> createState() => _PosScreenState();
}

class _PosScreenState extends ConsumerState<PosScreen> {
  @override
  void initState() {
    super.initState();
    // 로그인 성공 후 디바이스 자동 등록 + 하트비트 시작
    Future.microtask(() {
      ref.read(deviceRegistrationProvider.notifier).registerDevice();
    });
  }

  @override
  Widget build(BuildContext context) {
    final auth = ref.watch(authProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('POS'),
        actions: [
          if (auth.user != null)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Center(
                child: Text(
                  auth.user!.name,
                  style: const TextStyle(fontSize: 14),
                ),
              ),
            ),
          IconButton(
            icon: const Icon(Icons.devices),
            tooltip: '디바이스 관리',
            onPressed: () => context.push('/devices'),
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: '로그아웃',
            onPressed: () => _showLogoutDialog(context, ref),
          ),
        ],
      ),
      body: const Row(
        children: [
          // Left: Menu area
          Expanded(
            flex: 3,
            child: Column(
              children: [
                CategoryTabBar(),
                Expanded(child: MenuGrid()),
              ],
            ),
          ),
          // Right: Cart panel
          CartPanel(),
        ],
      ),
    );
  }

  void _showLogoutDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('로그아웃'),
        content: const Text('로그아웃 하시겠습니까?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('취소'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              // 하트비트 중지 후 로그아웃
              ref.read(deviceRegistrationProvider.notifier).stopHeartbeat();
              ref.read(authProvider.notifier).logout();
            },
            child: const Text('로그아웃'),
          ),
        ],
      ),
    );
  }
}
