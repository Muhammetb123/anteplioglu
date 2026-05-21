import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';

import 'package:core/core.dart';
import 'package:shared_ui/shared_ui.dart';
import '../routing/module_router.dart';
import '../data/auth_repository.dart';

@RoutePage()
class ForgotPasswordPage extends StatefulWidget {
  const ForgotPasswordPage({super.key});

  @override
  State<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  final _emailCtrl = TextEditingController();

  bool _loading = false;
  String? _error;

  @override
  void dispose() {
    _emailCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    FocusScope.of(context).unfocus();
    final email = _emailCtrl.text.trim();
    if (email.isEmpty) {
      setState(() => _error = 'Lütfen e-posta adresinizi girin');
      return;
    }

    setState(() {
      _error = null;
      _loading = true;
    });

    try {
      final repo = getIt<AuthRepository>();
      final message = await repo.forgetPassword(email: email);
      if (!mounted) return;
      context.router.replace(SignInRoute(infoMessage: message));
    } catch (e) {
      final msg = e is ApiError ? e.message : 'İstek gönderilemedi';
      setState(() => _error = msg);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Şifremi Unuttum')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 48, 24, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'Email Address',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),
              GeneralTextFormField(
                controller: _emailCtrl,
                keyboardType: TextInputType.emailAddress,
                textInputAction: TextInputAction.done,
                onSubmitted: (_) => _submit(),
                prefixIcon: Icons.mail_outline,
                hintText: 'ornek@anteplioglu.com',
              ),
              const SizedBox(height: 12),
              if (_error != null)
                Text(_error!, style: const TextStyle(color: Colors.red)),
              const SizedBox(height: 24),
              GeneralButton(
                text: 'Gönder',
                onPressed: _submit,
                isLoading: _loading,
                variant: GeneralButtonVariant.green,
                height: 54,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
