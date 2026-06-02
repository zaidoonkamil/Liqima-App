import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';

import '../../features/auth/view/login.dart';
import '../ navigation/navigation.dart';
import '../styles/themes.dart';
import 'constant.dart';

bool get isUserLoggedIn => token.trim().isNotEmpty && id.trim().isNotEmpty;

Future<bool> requireLogin(
  BuildContext context, {
  required String featureName,
}) async {
  if (isUserLoggedIn) return true;

  final shouldLogin = await showDialog<bool>(
    context: context,
    barrierDismissible: true,
    builder:
        (dialogContext) => Directionality(
          textDirection: TextDirection.rtl,
          child: Dialog(
            backgroundColor: Colors.transparent,
            insetPadding: const EdgeInsets.symmetric(horizontal: 28),
            child: Container(
              padding: const EdgeInsets.fromLTRB(18, 20, 18, 16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(22),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: .16),
                    blurRadius: 30,
                    offset: const Offset(0, 14),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 58,
                    height: 58,
                    decoration: BoxDecoration(
                      color: primaryColor.withValues(alpha: .10),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Iconsax.lock_1,
                      color: primaryColor,
                      size: 28,
                    ),
                  ),
                  const SizedBox(height: 14),
                  const Text(
                    'تسجيل الدخول مطلوب',
                    style: TextStyle(
                      color: Color(0xFF151B18),
                      fontSize: 16,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'سجل الدخول بالتطبيق لفتح ميزة $featureName.',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Color(0xFF747D79),
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 18),
                  Row(
                    children: [
                      Expanded(
                        child: _AuthDialogButton(
                          title: 'ابقاء',
                          filled: false,
                          onTap: () => Navigator.of(dialogContext).pop(false),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _AuthDialogButton(
                          title: 'تسجيل الدخول',
                          filled: true,
                          onTap: () => Navigator.of(dialogContext).pop(true),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
  );

  if (shouldLogin == true && context.mounted) {
    navigateTo(context, const Login());
  }
  return false;
}

Future<void> runWithLogin(
  BuildContext context, {
  required String featureName,
  required VoidCallback action,
}) async {
  final allowed = await requireLogin(context, featureName: featureName);
  if (allowed && context.mounted) action();
}

class _AuthDialogButton extends StatelessWidget {
  const _AuthDialogButton({
    required this.title,
    required this.filled,
    required this.onTap,
  });

  final String title;
  final bool filled;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        height: 42,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: filled ? primaryColor : const Color(0xFFF3FAF2),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: filled ? primaryColor : primaryColor.withValues(alpha: .24),
          ),
        ),
        child: Text(
          title,
          style: TextStyle(
            color: filled ? Colors.white : primaryColor,
            fontSize: 12,
            fontWeight: FontWeight.w900,
          ),
        ),
      ),
    );
  }
}
