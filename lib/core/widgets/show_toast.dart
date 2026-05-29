import 'package:flutter/material.dart';

import '../styles/themes.dart';

enum AppSnackBarType { success, error, info }

void showToastSuccess({required String text, required BuildContext context}) {
  showAppSnackBar(
    context: context,
    message: text,
    type: AppSnackBarType.success,
  );
}

void showToastError({required String text, required BuildContext context}) {
  showAppSnackBar(context: context, message: text, type: AppSnackBarType.error);
}

void showToastInfo({required String text, required BuildContext context}) {
  showAppSnackBar(context: context, message: text, type: AppSnackBarType.info);
}

void showAppSnackBar({
  required BuildContext context,
  required String message,
  AppSnackBarType type = AppSnackBarType.info,
}) {
  final messenger = ScaffoldMessenger.maybeOf(context);
  if (messenger == null) return;

  final color = switch (type) {
    AppSnackBarType.success => primaryColor,
    AppSnackBarType.error => const Color(0xFFE34B4B),
    AppSnackBarType.info => const Color(0xFFF0A12A),
  };
  final icon = switch (type) {
    AppSnackBarType.success => Icons.check_circle_rounded,
    AppSnackBarType.error => Icons.error_rounded,
    AppSnackBarType.info => Icons.info_rounded,
  };

  messenger
    ..hideCurrentSnackBar()
    ..showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        backgroundColor: const Color(0xFF111827),
        elevation: 8,
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
          side: BorderSide(color: color.withValues(alpha: .4)),
        ),
        content: Row(
          children: [
            Expanded(
              child: Text(
                message,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  height: 1.4,
                ),
                textAlign: TextAlign.end,
              ),
            ),
            const SizedBox(width: 12),
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: color.withValues(alpha: .15),
              ),
              child: Icon(icon, color: color, size: 22),
            ),
          ],
        ),
        duration: const Duration(seconds: 3),
      ),
    );
}
