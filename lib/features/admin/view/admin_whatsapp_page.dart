import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:iconsax/iconsax.dart';

import '../../../core/styles/themes.dart';
import '../../../core/widgets/show_toast.dart';
import '../../../core/widgets/user_nav_header.dart' show PinnedAppHeaderSliver;
import '../cubit/admin_cubit.dart';
import '../cubit/admin_states.dart';

class AdminWhatsAppPage extends StatefulWidget {
  const AdminWhatsAppPage({super.key});

  @override
  State<AdminWhatsAppPage> createState() => _AdminWhatsAppPageState();
}

class _AdminWhatsAppPageState extends State<AdminWhatsAppPage> {
  final formKey = GlobalKey<FormState>();
  final phoneController = TextEditingController();
  final messageController = TextEditingController(
    text: 'رسالة تجربة من لوحة أدمن لقيمة',
  );
  Timer? statusTimer;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      AdminCubit.get(context).getWhatsAppStatus();
    });
  }

  @override
  void dispose() {
    statusTimer?.cancel();
    phoneController.dispose();
    messageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AdminCubit, AdminState>(
      listener: (context, state) {
        final cubit = AdminCubit.get(context);
        _syncStatusPolling(cubit);

        if (state is AdminWhatsAppInitSuccessState) {
          showToastSuccess(text: 'تم تشغيل جلسة واتساب', context: context);
          cubit.getWhatsAppQr();
        } else if (state is AdminWhatsAppLogoutSuccessState) {
          showToastSuccess(text: 'تم تسجيل خروج واتساب', context: context);
          cubit.getWhatsAppStatus();
        } else if (state is AdminWhatsAppSendSuccessState) {
          showToastSuccess(text: 'تم إرسال الرسالة بنجاح', context: context);
          cubit.getWhatsAppStatus();
        } else if (state is AdminWhatsAppErrorState) {
          showToastError(text: state.message, context: context);
        }
      },
      builder: (context, state) {
        final cubit = AdminCubit.get(context);
        final status = cubit.whatsAppStatus ?? {};
        final statusText = status['status']?.toString() ?? 'idle';
        final connectedNumber = status['connectedNumber']?.toString();
        final lastError = status['lastError']?.toString();
        final qrBytes = _decodeQr(
          cubit.whatsAppQrImage ?? status['qrImage']?.toString(),
        );
        final isLoading = state is AdminWhatsAppLoadingState;

        return Directionality(
          textDirection: TextDirection.rtl,
          child: Scaffold(
            backgroundColor: Colors.white,
            body: SafeArea(
              bottom: false,
              child: CustomScrollView(
                physics: const AlwaysScrollableScrollPhysics(
                  parent: BouncingScrollPhysics(),
                ),
                slivers: [
                  const _AdminHeaderSliver(),
                  const SliverToBoxAdapter(child: SizedBox(height: 14)),
                  SliverToBoxAdapter(
                    child: _StatusCard(
                      status: statusText,
                      connectedNumber: connectedNumber,
                      lastError: lastError,
                    ),
                  ),
                  const SliverToBoxAdapter(child: SizedBox(height: 12)),
                  SliverToBoxAdapter(
                    child: _ActionsCard(
                      isLoading: isLoading,
                      onInit: cubit.initWhatsApp,
                      onQr: cubit.getWhatsAppQr,
                      onRefresh: cubit.getWhatsAppStatus,
                      onLogout: cubit.logoutWhatsApp,
                    ),
                  ),
                  const SliverToBoxAdapter(child: SizedBox(height: 12)),
                  SliverToBoxAdapter(
                    child: _QrCard(qrBytes: qrBytes, status: statusText),
                  ),
                  const SliverToBoxAdapter(child: SizedBox(height: 12)),
                  SliverToBoxAdapter(
                    child: _TestMessageCard(
                      formKey: formKey,
                      isLoading: isLoading,
                      canSend: cubit.isWhatsAppReady && !isLoading,
                      phoneController: phoneController,
                      messageController: messageController,
                      onSend: () {
                        if (!formKey.currentState!.validate()) return;
                        if (!cubit.isWhatsAppReady) {
                          showToastInfo(
                            text: 'واتساب بعده مو جاهز للإرسال',
                            context: context,
                          );
                          cubit.getWhatsAppStatus();
                          return;
                        }
                        cubit.sendWhatsAppTest(
                          phone: phoneController.text,
                          message: messageController.text,
                        );
                      },
                    ),
                  ),
                  const SliverToBoxAdapter(child: SizedBox(height: 94)),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void _syncStatusPolling(AdminCubit cubit) {
    if (cubit.isWhatsAppTransitioning) {
      statusTimer ??= Timer.periodic(const Duration(seconds: 3), (_) {
        if (!mounted) return;
        final currentCubit = AdminCubit.get(context);
        if (currentCubit.isWhatsAppTransitioning) {
          currentCubit.getWhatsAppStatus();
        }
      });
    } else {
      statusTimer?.cancel();
      statusTimer = null;
    }
  }
}

class _AdminHeader extends StatelessWidget {
  const _AdminHeader();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 0),
      child: SizedBox(
        height: 58,
        child: Stack(
          alignment: Alignment.center,
          children: [
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Image.asset('assets/images/logo.png', height: 44),
                const Text(
                  'إدارة التطبيق',
                  style: TextStyle(
                    color: secondaryColor,
                    fontSize: 7,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
            const Align(
              alignment: Alignment.centerRight,
              child: Icon(Iconsax.setting_2, color: primaryColor, size: 22),
            ),
          ],
        ),
      ),
    );
  }
}

class _AdminHeaderSliver extends StatelessWidget {
  const _AdminHeaderSliver();

  @override
  Widget build(BuildContext context) {
    return const PinnedAppHeaderSliver(height: 72, child: _AdminHeader());
  }
}

class _StatusCard extends StatelessWidget {
  const _StatusCard({
    required this.status,
    required this.connectedNumber,
    required this.lastError,
  });

  final String status;
  final String? connectedNumber;
  final String? lastError;

  @override
  Widget build(BuildContext context) {
    final color = _statusColor(status);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: _softDecoration(radius: 18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: .10),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Iconsax.message, color: color, size: 21),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _statusLabel(status),
                        style: const TextStyle(
                          color: Color(0xFF151B18),
                          fontSize: 13,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      Text(
                        _statusDescription(status),
                        style: const TextStyle(
                          color: Color(0xFF747D79),
                          fontSize: 8,
                          fontWeight: FontWeight.w700,
                          height: 1.4,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            if (connectedNumber != null &&
                connectedNumber!.trim().isNotEmpty) ...[
              const SizedBox(height: 10),
              _InfoPill(label: 'الرقم المرتبط', value: connectedNumber!),
            ],
            if (lastError != null && lastError!.trim().isNotEmpty) ...[
              const SizedBox(height: 10),
              Text(
                lastError!,
                style: const TextStyle(
                  color: Color(0xFFE34B4B),
                  fontSize: 8,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _ActionsCard extends StatelessWidget {
  const _ActionsCard({
    required this.isLoading,
    required this.onInit,
    required this.onQr,
    required this.onRefresh,
    required this.onLogout,
  });

  final bool isLoading;
  final Future<void> Function() onInit;
  final Future<void> Function() onQr;
  final Future<void> Function() onRefresh;
  final Future<void> Function() onLogout;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: _softDecoration(radius: 18),
        child: Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            _ActionButton(
              title: 'تشغيل الخدمة',
              icon: Icons.power_settings_new_rounded,
              color: primaryColor,
              onTap: isLoading ? null : onInit,
            ),
            _ActionButton(
              title: 'جلب QR',
              icon: Icons.qr_code_2_rounded,
              color: secondaryColor,
              onTap: isLoading ? null : onQr,
            ),
            _ActionButton(
              title: 'تحديث الحالة',
              icon: Icons.refresh_rounded,
              color: const Color(0xFF2D8AC8),
              onTap: isLoading ? null : onRefresh,
            ),
            _ActionButton(
              title: 'تسجيل خروج',
              icon: Icons.logout_rounded,
              color: const Color(0xFFE34B4B),
              onTap: isLoading ? null : onLogout,
            ),
          ],
        ),
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  const _ActionButton({
    required this.title,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  final String title;
  final IconData icon;
  final Color color;
  final Future<void> Function()? onTap;

  @override
  Widget build(BuildContext context) {
    final width = (MediaQuery.of(context).size.width - 52) / 2;
    return InkWell(
      onTap: onTap == null ? null : () => onTap!(),
      borderRadius: BorderRadius.circular(14),
      child: Container(
        width: width,
        height: 42,
        padding: const EdgeInsets.symmetric(horizontal: 10),
        decoration: BoxDecoration(
          color: color.withValues(alpha: .10),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: color.withValues(alpha: .28)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 16),
            const SizedBox(width: 6),
            Flexible(
              child: Text(
                title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: color,
                  fontSize: 10,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _QrCard extends StatelessWidget {
  const _QrCard({required this.qrBytes, required this.status});

  final Uint8List? qrBytes;
  final String status;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: _softDecoration(radius: 18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'رمز الربط',
              style: TextStyle(
                color: Color(0xFF151B18),
                fontSize: 13,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 4),
            const Text(
              'شغّل الخدمة وبعدها امسح QR من واتساب ضمن الأجهزة المرتبطة.',
              style: TextStyle(
                color: Color(0xFF747D79),
                fontSize: 8,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 12),
            Center(
              child: Container(
                width: 220,
                height: 220,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFF8FAF8),
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: const Color(0xFFE8ECE8)),
                ),
                child:
                    qrBytes != null
                        ? Image.memory(qrBytes!, fit: BoxFit.contain)
                        : Center(
                          child: Text(
                            status == 'ready'
                                ? 'الحساب مرتبط بالفعل'
                                : 'اضغط تشغيل ثم جلب QR',
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              color: Color(0xFF747D79),
                              fontSize: 10,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TestMessageCard extends StatelessWidget {
  const _TestMessageCard({
    required this.formKey,
    required this.isLoading,
    required this.canSend,
    required this.phoneController,
    required this.messageController,
    required this.onSend,
  });

  final GlobalKey<FormState> formKey;
  final bool isLoading;
  final bool canSend;
  final TextEditingController phoneController;
  final TextEditingController messageController;
  final VoidCallback onSend;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: _softDecoration(radius: 18),
        child: Form(
          key: formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'إضافة رقم موبايل',
                style: TextStyle(
                  color: Color(0xFF151B18),
                  fontSize: 13,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                'اكتب رقم حتى ترسل رسالة تجربة وتتأكد الخدمة شغالة.',
                style: TextStyle(
                  color: Color(0xFF747D79),
                  fontSize: 8,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 12),
              _AdminTextField(
                controller: phoneController,
                hint: 'رقم الهاتف',
                icon: Iconsax.call,
                keyboardType: TextInputType.phone,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'رجاءً ادخل رقم الهاتف';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 8),
              _AdminTextField(
                controller: messageController,
                hint: 'نص الرسالة',
                icon: Iconsax.message_text,
                maxLines: 3,
                height: 82,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'رجاءً ادخل الرسالة';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12),
              InkWell(
                onTap: isLoading || !canSend ? null : onSend,
                borderRadius: BorderRadius.circular(14),
                child: Container(
                  height: 42,
                  decoration: BoxDecoration(
                    color: canSend ? primaryColor : const Color(0xFFE9ECEA),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  alignment: Alignment.center,
                  child:
                      isLoading
                          ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                          : Text(
                            canSend
                                ? 'إرسال رسالة تجريبية'
                                : 'بانتظار جاهزية واتساب',
                            style: TextStyle(
                              color:
                                  canSend
                                      ? Colors.white
                                      : const Color(0xFF747D79),
                              fontSize: 11,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AdminTextField extends StatelessWidget {
  const _AdminTextField({
    required this.controller,
    required this.hint,
    required this.icon,
    this.keyboardType,
    this.validator,
    this.maxLines = 1,
    this.height = 44,
  });

  final TextEditingController controller;
  final String hint;
  final IconData icon;
  final TextInputType? keyboardType;
  final String? Function(String?)? validator;
  final int maxLines;
  final double height;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFE3E5E6)),
      ),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        validator: validator,
        maxLines: maxLines,
        textAlign: TextAlign.right,
        decoration: InputDecoration(
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 14,
            vertical: 14,
          ),
          hintText: hint,
          hintStyle: const TextStyle(
            color: Color(0xFF8E9295),
            fontSize: 11,
            fontWeight: FontWeight.w700,
          ),
          suffixIcon: Icon(icon, color: primaryColor, size: 18),
        ),
      ),
    );
  }
}

class _InfoPill extends StatelessWidget {
  const _InfoPill({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 30,
      padding: const EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
        color: const Color(0xFFF2FAF4),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Text(
            label,
            style: const TextStyle(
              color: primaryColor,
              fontSize: 9,
              fontWeight: FontWeight.w900,
            ),
          ),
          const Spacer(),
          Text(
            value,
            textDirection: TextDirection.ltr,
            style: const TextStyle(
              color: Color(0xFF151B18),
              fontSize: 10,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }
}

Uint8List? _decodeQr(String? value) {
  if (value == null || value.trim().isEmpty) return null;
  final payload =
      value.contains(',') ? value.substring(value.indexOf(',') + 1) : value;
  try {
    return base64Decode(payload);
  } catch (_) {
    return null;
  }
}

Color _statusColor(String status) {
  switch (status) {
    case 'ready':
      return primaryColor;
    case 'qr_ready':
    case 'authenticated':
    case 'initializing':
    case 'reconnecting':
    case 'connecting':
      return secondaryColor;
    case 'auth_failure':
    case 'failed':
    case 'disconnected':
    case 'logged_out':
      return const Color(0xFFE34B4B);
    default:
      return const Color(0xFF8A8F8D);
  }
}

String _statusLabel(String status) {
  switch (status) {
    case 'ready':
      return 'واتساب جاهز للإرسال';
    case 'qr_ready':
      return 'رمز الربط جاهز';
    case 'authenticated':
      return 'تمت المصادقة';
    case 'initializing':
      return 'جاري التشغيل';
    case 'connecting':
      return 'جاري الاتصال';
    case 'reconnecting':
      return 'جاري إعادة الاتصال';
    case 'disconnected':
      return 'الاتصال مفصول';
    case 'logged_out':
      return 'تم تسجيل الخروج';
    case 'failed':
      return 'فشل تشغيل الجلسة';
    case 'auth_failure':
      return 'فشل التحقق';
    default:
      return 'غير مرتبط';
  }
}

String _statusDescription(String status) {
  switch (status) {
    case 'ready':
      return 'الحساب مرتبط وتكدر تستخدمه للإرسال والـ OTP.';
    case 'qr_ready':
      return 'افتح واتساب من الموبايل وامسح رمز الربط.';
    case 'authenticated':
      return 'تم التحقق من الجلسة وباقي لحظات حتى تصير جاهزة.';
    case 'initializing':
    case 'connecting':
      return 'جاري تهيئة جلسة واتساب على السيرفر.';
    case 'reconnecting':
      return 'السيرفر يحاول يرجع الجلسة السابقة تلقائياً.';
    case 'disconnected':
      return 'انقطع الاتصال، شغل الخدمة أو جيب QR جديد.';
    case 'logged_out':
      return 'ماكو جلسة نشطة حالياً.';
    case 'failed':
      return 'صار خطأ أثناء تشغيل واتساب.';
    case 'auth_failure':
      return 'المصادقة فشلت ويحتاج ربط جديد.';
    default:
      return 'ابدأ تشغيل الخدمة حتى يظهر QR.';
  }
}

BoxDecoration _softDecoration({required double radius}) {
  return BoxDecoration(
    color: Colors.white,
    borderRadius: BorderRadius.circular(radius),
    border: Border.all(color: const Color(0xFFF0F1EF)),
    boxShadow: [
      BoxShadow(
        color: Colors.black.withValues(alpha: .06),
        blurRadius: 16,
        offset: const Offset(0, 7),
      ),
    ],
  );
}
