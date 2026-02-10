import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../auth/providers/auth_provider.dart';
import '../widgets/category_tab_bar.dart';
import '../widgets/menu_grid.dart';
import '../widgets/cart_panel.dart';

class PosScreen extends ConsumerWidget {
  const PosScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
              ref.read(authProvider.notifier).logout();
            },
            child: const Text('로그아웃'),
          ),
        ],
      ),
    );
  }
}
