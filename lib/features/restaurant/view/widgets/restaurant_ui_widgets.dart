import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:iconsax/iconsax.dart';

import '../../../../core/ navigation/navigation.dart';
import '../../../../core/styles/themes.dart';
import '../../../../core/widgets/user_nav_header.dart'
    show PinnedAppHeaderSliver;
import '../../cubit/restaurant_cubit.dart';
import '../../cubit/restaurant_states.dart';
import '../restaurant_notifications_page.dart';

class RestaurantHeader extends StatefulWidget {
  const RestaurantHeader({super.key, required this.title});

  final String title;

  @override
  State<RestaurantHeader> createState() => _RestaurantHeaderState();
}

class _RestaurantHeaderState extends State<RestaurantHeader> {
  bool requestedNotifications = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _requestNotifications();
  }

  @override
  Widget build(BuildContext context) {
    RestaurantCubit? cubit;
    try {
      cubit = context.read<RestaurantCubit>();
    } catch (_) {
      cubit = null;
    }

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 0),
      child: SizedBox(
        height: 58,
        child: Stack(
          alignment: Alignment.center,
          children: [
            Align(
              alignment: Alignment.center,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Image.asset('assets/images/logo.png', height: 44),
                  Text(
                    widget.title,
                    style: const TextStyle(
                      color: secondaryColor,
                      fontSize: 7,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
            Align(
              alignment: Alignment.centerLeft,
              child:
                  cubit == null
                      ? const Icon(Iconsax.notification, size: 22)
                      : BlocBuilder<RestaurantCubit, RestaurantState>(
                        bloc: cubit,
                        builder: (context, state) {
                          final unread =
                              cubit?.notificationsData?.unreadCount ?? 0;
                          return _RestaurantNotificationButton(
                            count: unread,
                            onTap:
                                () => navigateTo(
                                  context,
                                  BlocProvider.value(
                                    value: cubit!,
                                    child:
                                        const RestaurantNotificationsPage(),
                                  ),
                                ),
                          );
                        },
                      ),
            ),
          ],
        ),
      ),
    );
  }

  void _requestNotifications() {
    if (requestedNotifications) return;
    requestedNotifications = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      try {
        final cubit = context.read<RestaurantCubit>();
        if (cubit.notificationsData == null) {
          cubit.getNotificationsData();
        }
      } catch (_) {}
    });
  }
}

class _RestaurantNotificationButton extends StatelessWidget {
  const _RestaurantNotificationButton({
    required this.count,
    required this.onTap,
  });

  final int count;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          const Icon(Iconsax.notification, size: 22),
          if (count > 0)
            Positioned(
              right: -2,
              top: -5,
              child: Container(
                width: 14,
                height: 14,
                decoration: const BoxDecoration(
                  color: secondaryColor,
                  shape: BoxShape.circle,
                ),
                alignment: Alignment.center,
                child: Text(
                  count > 99 ? '99+' : '$count',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 9,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class RestaurantHeaderSliver extends StatelessWidget {
  const RestaurantHeaderSliver({super.key, required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return PinnedAppHeaderSliver(
      height: 72,
      child: RestaurantHeader(title: title),
    );
  }
}

class RestaurantSectionHeader extends StatelessWidget {
  const RestaurantSectionHeader({
    super.key,
    required this.title,
    required this.icon,
    required this.count,
  });

  final String title;
  final IconData icon;
  final int count;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14),
      child: Row(
        children: [
          Icon(icon, color: primaryColor, size: 16),
          const SizedBox(width: 6),
          Text(
            title,
            style: const TextStyle(
              color: Color(0xFF151B18),
              fontSize: 13,
              fontWeight: FontWeight.w900,
            ),
          ),
          const Spacer(),
          Container(
            height: 18,
            padding: const EdgeInsets.symmetric(horizontal: 8),
            decoration: BoxDecoration(
              color: const Color(0xFFF2FAF4),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              count.toString(),
              style: const TextStyle(
                color: primaryColor,
                fontSize: 9,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class RestaurantStatusPill extends StatelessWidget {
  const RestaurantStatusPill({
    super.key,
    required this.text,
    required this.color,
  });

  final String text;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 20,
      padding: const EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: .10),
        borderRadius: BorderRadius.circular(12),
      ),
      alignment: Alignment.center,
      child: Text(
        text,
        style: TextStyle(
          color: color,
          fontSize: 8,
          fontWeight: FontWeight.w900,
        ),
      ),
    );
  }
}

class RestaurantIconAction extends StatelessWidget {
  const RestaurantIconAction({
    super.key,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      customBorder: const CircleBorder(),
      child: Container(
        width: 26,
        height: 26,
        decoration: BoxDecoration(
          color: color.withValues(alpha: .09),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: color, size: 13),
      ),
    );
  }
}

class RestaurantSheetTextField extends StatelessWidget {
  const RestaurantSheetTextField({
    super.key,
    required this.controller,
    required this.label,
    required this.icon,
    this.keyboardType,
    this.height = 44,
    this.maxLines = 1,
  });

  final TextEditingController controller;
  final String label;
  final IconData icon;
  final TextInputType? keyboardType;
  final double height;
  final int maxLines;

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
        maxLines: maxLines,
        textAlign: TextAlign.right,
        decoration: InputDecoration(
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 14,
            vertical: 15,
          ),
          hintText: label,
          hintStyle: const TextStyle(
            color: Color(0xFF8E9295),
            fontSize: 11,
            fontWeight: FontWeight.w700,
          ),
          suffixIcon: Icon(icon, color: primaryColor, size: 19),
        ),
      ),
    );
  }
}

class RestaurantImagePickerField extends StatefulWidget {
  const RestaurantImagePickerField({
    super.key,
    required this.label,
    required this.onChanged,
  });

  final String label;
  final ValueChanged<String?> onChanged;

  @override
  State<RestaurantImagePickerField> createState() =>
      _RestaurantImagePickerFieldState();
}

class _RestaurantImagePickerFieldState
    extends State<RestaurantImagePickerField> {
  String? imageName;

  Future<void> _pickImage() async {
    final image = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (image == null) return;

    setState(() => imageName = image.name);
    widget.onChanged(image.path);
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: _pickImage,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        height: 44,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: const Color(0xFFE3E5E6)),
        ),
        child: Row(
          children: [
            const Icon(Iconsax.gallery_add, color: primaryColor, size: 19),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                imageName ?? widget.label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color:
                      imageName == null
                          ? const Color(0xFF8E9295)
                          : const Color(0xFF151B18),
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
            const Icon(
              Icons.keyboard_arrow_down_rounded,
              color: Color(0xFF8E9295),
              size: 18,
            ),
          ],
        ),
      ),
    );
  }
}

Future<void> showRestaurantSheet({
  required BuildContext context,
  required String title,
  required IconData icon,
  required List<Widget> children,
  required String buttonText,
  required VoidCallback onSubmit,
}) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) {
      return Directionality(
        textDirection: TextDirection.rtl,
        child: Padding(
          padding: EdgeInsets.only(
            left: 14,
            right: 14,
            bottom: MediaQuery.of(context).viewInsets.bottom + 14,
          ),
          child: Container(
            padding: const EdgeInsets.fromLTRB(14, 14, 14, 16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(22),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: .10),
                  blurRadius: 24,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 42,
                  height: 4,
                  decoration: BoxDecoration(
                    color: const Color(0xFFE2E6E3),
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                const SizedBox(height: 14),
                Row(
                  children: [
                    Container(
                      width: 34,
                      height: 34,
                      decoration: BoxDecoration(
                        color: primaryColor.withValues(alpha: .10),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(icon, color: primaryColor, size: 18),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      title,
                      style: const TextStyle(
                        color: Color(0xFF151B18),
                        fontSize: 14,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                ...children,
                const SizedBox(height: 14),
                InkWell(
                  onTap: onSubmit,
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    height: 40,
                    decoration: BoxDecoration(
                      color: primaryColor,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      buttonText,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
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
    },
  );
}

Future<void> showRestaurantDeleteDialog({
  required BuildContext context,
  required String title,
  required String message,
  required VoidCallback onConfirm,
}) {
  return showDialog<void>(
    context: context,
    builder: (dialogContext) {
      return Directionality(
        textDirection: TextDirection.rtl,
        child: Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: const EdgeInsets.symmetric(horizontal: 28),
          child: Container(
            padding: const EdgeInsets.fromLTRB(14, 16, 14, 14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: .10),
                  blurRadius: 24,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    color: const Color(0xFFE34B4B).withValues(alpha: .10),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.delete_outline_rounded,
                    color: Color(0xFFE34B4B),
                    size: 22,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  title,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Color(0xFF151B18),
                    fontSize: 14,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  message,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Color(0xFF747D79),
                    fontSize: 9,
                    fontWeight: FontWeight.w700,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 14),
                Row(
                  children: [
                    Expanded(
                      child: InkWell(
                        onTap: () => navigateBack(dialogContext),
                        borderRadius: BorderRadius.circular(12),
                        child: Container(
                          height: 38,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: const Color(0xFFF4F6F5),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Text(
                            'إلغاء',
                            style: TextStyle(
                              color: Color(0xFF151B18),
                              fontSize: 11,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: InkWell(
                        onTap: () {
                          navigateBack(dialogContext);
                          onConfirm();
                        },
                        borderRadius: BorderRadius.circular(12),
                        child: Container(
                          height: 38,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: const Color(0xFFE34B4B),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Text(
                            'حذف',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 11,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      );
    },
  );
}

BoxDecoration restaurantSoftDecoration({required double radius}) {
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

String formatRestaurantPrice(int price) {
  final value = price.toString();
  return value.replaceAllMapped(RegExp(r'\B(?=(\d{3})+(?!\d))'), (_) => ',');
}
