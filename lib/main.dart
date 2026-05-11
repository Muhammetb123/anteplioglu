import 'package:antepli/core/app_bloc_observer.dart';
import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'core/di/di.dart';
import 'core/routing/app_router.dart';
import 'features/auth/logic/auth_cubit.dart';
import 'features/auth/logic/auth_state.dart';

Future<void> main() async {
  Bloc.observer = AppBlocObserver();
  WidgetsFlutterBinding.ensureInitialized();
  await EasyLocalization.ensureInitialized();
  await Hive.initFlutter();
  await SharedPreferences.getInstance();
  await dotenv.load(fileName: '.env');
  await configureDependencies();

  runApp(
    EasyLocalization(
      supportedLocales: const [Locale('tr'), Locale('en')],
      path: 'assets/translations',
      fallbackLocale: const Locale('tr'),
      child: const AntepliApp(),
    ),
  );
}

class AntepliApp extends StatelessWidget {
  const AntepliApp({super.key});

  @override
  Widget build(BuildContext context) {
    final appRouter = getIt<AppRouter>();
    return BlocProvider(
      create: (_) => getIt<AuthCubit>()..bootstrap(),
      child: BlocListener<AuthCubit, AuthState>(
        listenWhen: (prev, curr) => curr is AuthUnauthenticated,
        listener: (context, state) {
          if (state is AuthUnauthenticated) {
            appRouter.replaceAll([SignInRoute()]);
          }
        },
        child: MaterialApp.router(
          debugShowCheckedModeBanner: false,
          title: 'Anteplioglu ERP',
          locale: context.locale,
          supportedLocales: context.supportedLocales,
          localizationsDelegates: context.localizationDelegates,
          theme: ThemeData(
            colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepOrange),
            useMaterial3: true,
          ),
          routerConfig: appRouter.config(),
        ),
      ),
    );
  }
}
