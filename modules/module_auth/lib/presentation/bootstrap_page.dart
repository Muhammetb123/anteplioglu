import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:core/core.dart';
import '../routing/auth_navigator.dart';
import '../logic/auth_cubit.dart';
import '../logic/auth_state.dart';

@RoutePage()
class BootstrapPage extends StatefulWidget {
  const BootstrapPage({super.key});

  @override
  State<BootstrapPage> createState() => _BootstrapPageState();
}

class _BootstrapPageState extends State<BootstrapPage> {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthCubit, AuthState>(
      builder: (context, state) {
        if (state case AuthAuthenticated(:final user)) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            getIt<AuthNavigator>().navigateOnAuthenticated(context, user);
          });
        } else if (state is AuthUnauthenticated) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            getIt<AuthNavigator>().navigateOnUnauthenticated(context);
          });
        }

        return const Scaffold(
          body: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  width: 28,
                  height: 28,
                  child: CircularProgressIndicator(),
                ),
                SizedBox(height: 12),
                Text('Yükleniyor...'),
              ],
            ),
          ),
        );
      },
    );
  }
}

