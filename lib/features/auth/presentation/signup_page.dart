import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';

import '../../../core/di/di.dart';
import '../../../core/network/api_error.dart';
import '../../../core/routing/app_router.dart';
import '../../../core/widgets/general_button.dart';
import '../../../core/widgets/general_text_form_field.dart';
import '../data/auth_repository.dart';
import 'auth_theme.dart';

@RoutePage()
class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  final _pass2Ctrl = TextEditingController();

  bool _obscure1 = true;
  bool _obscure2 = true;
  bool _loading = false;
  String? _error;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _passCtrl.dispose();
    _pass2Ctrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    FocusScope.of(context).unfocus();
    final pass = _passCtrl.text;
    if (pass != _pass2Ctrl.text) {
      setState(() => _error = 'Şifreler eşleşmiyor');
      return;
    }

    setState(() {
      _error = null;
      _loading = true;
    });

    try {
      final repo = getIt<AuthRepository>();
      final fullName = _nameCtrl.text.trim();
      final parts = fullName
          .split(RegExp(r'\s+'))
          .where((e) => e.isNotEmpty)
          .toList();
      final firstName = parts.isEmpty ? '' : parts.first;
      final lastName = parts.length <= 1 ? '' : parts.sublist(1).join(' ');

      await repo.signUp(
        email: _emailCtrl.text.trim(),
        password: pass,
        firstName: firstName,
        lastName: lastName,
      );
      if (!mounted) return;

      context.router.push(
        VerifyEmailRoute(email: _emailCtrl.text.trim(), password: pass),
      );
    } catch (e) {
      final msg = e is ApiError ? e.message : 'Kayıt olunamadı';
      setState(() => _error = msg);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 24, 24, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 10),
              Center(
                child: Container(
                  width: 74,
                  height: 74,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: AuthTheme.primaryGreen,
                      width: 1.2,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 18),
              const Center(
                child: Text(
                  'Kayıt Ol',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
                ),
              ),
              const SizedBox(height: 28),
              const Text(
                'Ad Soyad',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),
              GeneralTextFormField(
                controller: _nameCtrl,
                textInputAction: TextInputAction.next,
                prefixIcon: Icons.person_outline,
                hintText: 'Adınız Soyadınız',
              ),
              const SizedBox(height: 16),
              const Text(
                'E-Posta',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),
              GeneralTextFormField(
                controller: _emailCtrl,
                keyboardType: TextInputType.emailAddress,
                textInputAction: TextInputAction.next,
                prefixIcon: Icons.mail_outline,
                hintText: 'Email giriniz',
              ),
              const SizedBox(height: 16),
              const Text(
                'Şifre',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),
              GeneralTextFormField(
                controller: _passCtrl,
                obscureText: _obscure1,
                textInputAction: TextInputAction.next,
                prefixIcon: Icons.lock_outline,
                hintText: 'Minimum 8 haneli şifre oluştur',
                suffixIcon: IconButton(
                  onPressed: () => setState(() => _obscure1 = !_obscure1),
                  icon: Icon(
                    _obscure1 ? Icons.visibility_off : Icons.visibility,
                    color: const Color(0xff8a9aa5),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Şifre',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),
              GeneralTextFormField(
                controller: _pass2Ctrl,
                obscureText: _obscure2,
                textInputAction: TextInputAction.done,
                onSubmitted: (_) => _submit(),
                prefixIcon: Icons.lock_outline,
                hintText: 'Minimum 8 haneli şifre oluştur',
                suffixIcon: IconButton(
                  onPressed: () => setState(() => _obscure2 = !_obscure2),
                  icon: Icon(
                    _obscure2 ? Icons.visibility_off : Icons.visibility,
                    color: const Color(0xff8a9aa5),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              if (_error != null)
                Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Text(
                    _error!,
                    style: const TextStyle(color: Colors.red),
                  ),
                ),
              const SizedBox(height: 26),
              GeneralButton(
                text: 'İlerle',
                onPressed: _submit,
                isLoading: _loading,
                variant: GeneralButtonVariant.green,
                height: 54,
              ),
              const SizedBox(height: 12),
              TextButton(
                onPressed: () => context.router.pop(),
                child: const Text('Girişe dön'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
