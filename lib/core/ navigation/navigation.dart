import 'package:flutter/cupertino.dart';

void navigateTo(BuildContext context, Widget nextPage) {
  _dismissKeyboard();
  Navigator.of(
    context,
  ).push(_appRoute(nextPage)).whenComplete(_dismissKeyboard);
}

Future<T?> navigateToWithResult<T>(BuildContext context, Widget nextPage) {
  _dismissKeyboard();
  return Navigator.of(
    context,
  ).push<T>(_appRoute<T>(nextPage)).whenComplete(_dismissKeyboard);
}

void navigateBack<T extends Object?>(BuildContext context, [T? result]) {
  _dismissKeyboard();
  Navigator.of(context).pop<T>(result);
}

void navigateAndFinish(BuildContext context, Widget widget) {
  _dismissKeyboard();
  Navigator.of(context).pushAndRemoveUntil(_appRoute(widget), (route) => false);
}

void navigateAndRemoveUntil(BuildContext context, Widget widget) {
  _dismissKeyboard();
  Navigator.of(context).pushAndRemoveUntil(_appRoute(widget), (route) => false);
}

PageRoute<T> _appRoute<T>(Widget page) {
  return CupertinoPageRoute<T>(builder: (_) => page);
}

void _dismissKeyboard() {
  FocusManager.instance.primaryFocus?.unfocus();
}
