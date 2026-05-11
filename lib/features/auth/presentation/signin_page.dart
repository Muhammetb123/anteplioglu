import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/foundation.dart';

import '../../../core/widgets/general_button.dart';
import '../../../core/widgets/general_text_form_field.dart';
import '../../../core/network/api_error.dart';
import '../../../core/routing/admin_initial_route.dart';
import '../../../core/routing/app_router.dart';
import '../logic/auth_cubit.dart';
import 'auth_theme.dart';

@RoutePage()
class SignInPage extends StatefulWidget {
  const SignInPage({super.key, this.infoMessage});

  final String? infoMessage;

  @override
  State<SignInPage> createState() => _SignInPageState();
}

class _SignInPageState extends State<SignInPage> {
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();

  bool _obscure = true;
  bool _loading = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    if (widget.infoMessage != null && widget.infoMessage!.isNotEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(widget.infoMessage!)));
      });
    }
  }

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    FocusScope.of(context).unfocus();
    setState(() {
      _error = null;
      _loading = true;
    });

    try {
      final user = await context.read<AuthCubit>().signIn(
        email: _emailCtrl.text.trim(),
        password: _passCtrl.text,
      );
      if (!mounted) return;

      final roleCode = user.role?.code;
      if (roleCode == 'admin') {
        context.router.replaceAll([adminInitialRouteForUser(user)]);
      } else {
        context.router.replaceAll([const MainHomeRoute()]);
      }
    } catch (e) {
      final msg = e is ApiError ? e.message : 'Giriş yapılamadı';
      if (kDebugMode) {
        if (e is ApiError) {
          debugPrint(
            'SignIn error => status: ${e.statusCode}, message: ${e.message}',
          );
        } else {
          debugPrint('SignIn error => $e');
        }
      }
      setState(() => _error = msg);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final topPadding = MediaQuery.paddingOf(context).top;
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.fromLTRB(24, 24 + topPadding * 0.0, 24, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 24),
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
                  'Log In',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                ),
              ),
              const SizedBox(height: 28),
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
                hintText: 'ornek@anteplioglu.com',
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      'Şifre',
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                  ),
                  TextButton(
                    onPressed: () =>
                        context.router.push(const ForgotPasswordRoute()),
                    style: TextButton.styleFrom(
                      minimumSize: Size.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 4,
                        vertical: 2,
                      ),
                    ),
                    child: const Text(
                      'Şifreni mi unuttun?',
                      style: TextStyle(color: Colors.black54, fontSize: 12),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              GeneralTextFormField(
                controller: _passCtrl,
                obscureText: _obscure,
                textInputAction: TextInputAction.done,
                onSubmitted: (_) => _submit(),
                prefixIcon: Icons.lock_outline,
                hintText: '********',
                suffixIcon: IconButton(
                  onPressed: () => setState(() => _obscure = !_obscure),
                  icon: Icon(
                    _obscure ? Icons.visibility_off : Icons.visibility,
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
              const SizedBox(height: 22),
              const Divider(height: 1),
              const SizedBox(height: 14),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    'Hesabın yok mu?  ',
                    style: TextStyle(color: Colors.black54),
                  ),
                  GestureDetector(
                    onTap: () => context.router.push(const SignUpRoute()),
                    child: const Text(
                      'Hesap Oluştur',
                      style: TextStyle(fontWeight: FontWeight.w700),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 26),
              GeneralButton(
                text: 'Giriş Yap',
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
