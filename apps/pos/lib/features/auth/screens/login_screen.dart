import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/login_request.dart';
import '../providers/auth_provider.dart';
import '../widgets/pin_pad.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _storeCodeController = TextEditingController();
  final _phoneController = TextEditingController();
  String _pin = '';

  @override
  void dispose() {
    _storeCodeController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  void _onLogin() {
    if (_storeCodeController.text.isEmpty ||
        _phoneController.text.isEmpty ||
        _pin.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('모든 항목을 입력해주세요.')),
      );
      return;
    }

    ref.read(authProvider.notifier).login(
          LoginRequest(
            storeCode: _storeCodeController.text.trim(),
            phone: _phoneController.text.trim(),
            pin: _pin,
          ),
        );
  }

  @override
  Widget build(BuildContext context) {
    final auth = ref.watch(authProvider);
    final theme = Theme.of(context);

    ref.listen<AuthState>(authProvider, (prev, next) {
      if (next.status == AuthStatus.error && next.error != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(next.error!),
            backgroundColor: theme.colorScheme.error,
          ),
        );
      }
    });

    return Scaffold(
      backgroundColor: theme.colorScheme.surfaceContainerLowest,
      body: Center(
        child: SingleChildScrollView(
          child: Card(
            elevation: 4,
            margin: const EdgeInsets.all(32),
            child: Container(
              width: 400,
              padding: const EdgeInsets.all(32),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.point_of_sale,
                    size: 64,
                    color: theme.colorScheme.primary,
                  ),
                  const SizedBox(height: 16),
                  Text('POS 로그인', style: theme.textTheme.headlineMedium),
                  const SizedBox(height: 32),

                  // Store code
                  TextField(
                    controller: _storeCodeController,
                    decoration: const InputDecoration(
                      labelText: '매장 코드',
                      prefixIcon: Icon(Icons.store),
                    ),
                    textInputAction: TextInputAction.next,
                  ),
                  const SizedBox(height: 16),

                  // Phone
                  TextField(
                    controller: _phoneController,
                    decoration: const InputDecoration(
                      labelText: '전화번호',
                      prefixIcon: Icon(Icons.phone),
                      hintText: '010-0000-0000',
                    ),
                    keyboardType: TextInputType.phone,
                    textInputAction: TextInputAction.done,
                  ),
                  const SizedBox(height: 24),

                  // PIN display
                  Text('PIN', style: theme.textTheme.titleMedium),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(6, (i) {
                      return Container(
                        width: 40,
                        height: 40,
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: i < _pin.length
                                ? theme.colorScheme.primary
                                : theme.colorScheme.outlineVariant,
                            width: 2,
                          ),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Center(
                          child: i < _pin.length
                              ? Container(
                                  width: 14,
                                  height: 14,
                                  decoration: BoxDecoration(
                                    color: theme.colorScheme.primary,
                                    shape: BoxShape.circle,
                                  ),
                                )
                              : null,
                        ),
                      );
                    }),
                  ),
                  const SizedBox(height: 16),

                  // PIN pad
                  PinPad(
                    onDigit: (digit) {
                      if (_pin.length < 6) {
                        setState(() => _pin += digit);
                      }
                    },
                    onDelete: () {
                      if (_pin.isNotEmpty) {
                        setState(
                            () => _pin = _pin.substring(0, _pin.length - 1));
                      }
                    },
                    onClear: () => setState(() => _pin = ''),
                  ),
                  const SizedBox(height: 24),

                  // Login button
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton(
                      onPressed:
                          auth.status == AuthStatus.loading ? null : _onLogin,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: theme.colorScheme.primary,
                        foregroundColor: theme.colorScheme.onPrimary,
                      ),
                      child: auth.status == AuthStatus.loading
                          ? const SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Text('로그인',
                              style: TextStyle(fontSize: 18)),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
