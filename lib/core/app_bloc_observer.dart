import 'dart:developer';

import 'package:flutter_bloc/flutter_bloc.dart';

class AppBlocObserver implements BlocObserver {
  @override
  void onChange(BlocBase bloc, Change change) {
    log('$bloc => $change');
  }

  @override
  void onClose(BlocBase bloc) {
    log('$bloc closed');
  }

  @override
  void onCreate(BlocBase bloc) {
    log('$bloc created');
  }

  @override
  void onError(BlocBase bloc, Object error, StackTrace stackTrace) {
    log('$bloc => ${error.toString()} => ${stackTrace.toString()}');
  }

  @override
  void onEvent(Bloc bloc, Object? event) {
    // TODO: implement onEvent
  }

  @override
  void onTransition(Bloc bloc, Transition transition) {
    // TODO: implement onTransition
  }

  @override
  void onDone(
    Bloc<dynamic, dynamic> bloc,
    Object? error, [
    Object? errorStackTrace,
    StackTrace? stackTrace,
  ]) {
    log('$bloc done');
  }
}
