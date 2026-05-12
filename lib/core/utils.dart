import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

class Utils {
  Utils._();

  static final GlobalKey<ScaffoldMessengerState> messengerKey =
      GlobalKey<ScaffoldMessengerState>();

  static void showSnackBar(String? text, [Color? color]) {
    if (text == null) return;
    final snackBar = SnackBar(
      content: Text(
        text,
        style: const TextStyle(color: Colors.white,),
      ),
      backgroundColor: color,
    );
    messengerKey.currentState!
      ..removeCurrentSnackBar()
      ..showSnackBar(snackBar);
  }
}

Widget buildSvg({
  required String? path,
  double? height,
  double? width,
  Color? color,
  BoxFit? fit,
}) {
  if (path == null || path.isEmpty) {
    return const SizedBox.shrink();
  }
  return SvgPicture.asset(
    path,
    height: height,
    width: width,
    colorFilter:
        color != null ? ColorFilter.mode(color, BlendMode.srcIn) : null,
    fit: fit ?? BoxFit.contain,
  );
}
