import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:core/core.dart';
import 'package:shared_ui/shared_ui.dart';
import '../routing/auth_navigator.dart';
import '../data/auth_repository.dart';
import '../logic/auth_cubit.dart';
import 'auth_theme.dart';

@RoutePage()
class VerifyEmailPage extends StatefulWidget {
  final String email;
  final String password;

  const VerifyEmailPage({
    super.key,
    required this.email,
    required this.password,
  });

  @override
  State<VerifyEmailPage> createState() => _VerifyEmailPageState();
}

class _VerifyEmailPageState extends State<VerifyEmailPage> {
  final _ctrls = List.generate(6, (_) => TextEditingController());
  final _nodes = List.generate(6, (_) => FocusNode());

  bool _loading = false;
  String? _error;

  @override
  void dispose() {
    for (final c in _ctrls) {
      c.dispose();
    }
    for (final n in _nodes) {
      n.dispose();
    }
    super.dispose();
  }

  String get _code => _ctrls.map((e) => e.text.trim()).join();

  Future<void> _submit() async {
    FocusScope.of(context).unfocus();
    if (_code.length != 6) {
      setState(() => _error = 'Lütfen 6 haneli kodu girin');
      return;
    }

    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final repo = getIt<AuthRepository>();
      await repo.verifyEmail(code: _code);
      if (!mounted) return;

      final user = await context.read<AuthCubit>().signIn(
        email: widget.email,
        password: widget.password,
      );
      if (!mounted) return;
      getIt<AuthNavigator>().navigateOnAuthenticated(context, user);
    } catch (e) {
      final msg = e is ApiError ? e.message : 'Doğrulama başarısız';
      setState(() => _error = msg);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Widget _otpBox(int i) {
    return SizedBox(
      width: 48,
      child: TextField(
        controller: _ctrls[i],
        focusNode: _nodes[i],
        keyboardType: TextInputType.number,
        textAlign: TextAlign.center,
        maxLength: 1,
        decoration: InputDecoration(
          counterText: '',
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFFE2E6EA)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: AuthTheme.primaryGreen, width: 1.5),
          ),
        ),
        onChanged: (v) {
          if (v.isNotEmpty) {
            if (i < _nodes.length - 1) {
              _nodes[i + 1].requestFocus();
            } else {
              _submit();
            }
          } else {
            if (i > 0) _nodes[i - 1].requestFocus();
          }
        },
      ),
    );
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
                  'Email Doğrulama',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
                ),
              ),
              const SizedBox(height: 10),
              Center(
                child: Text(
                  'Merak etmeyin! Lütfen ${widget.email}\nadresine gönderilen kodu girin.',
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.black54),
                ),
              ),
              const SizedBox(height: 26),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: List.generate(6, _otpBox),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('Kodu alamadınız mı?  '),
                  GestureDetector(
                    onTap: _loading ? null : () {},
                    child: const Text(
                      'Tekrar Gönder!',
                      style: TextStyle(fontWeight: FontWeight.w700),
                    ),
                  ),
                ],
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
            ],
          ),
        ),
      ),
    );
  }
}
