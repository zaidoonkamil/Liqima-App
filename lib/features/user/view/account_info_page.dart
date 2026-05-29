import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:iconsax/iconsax.dart';

import '../../../core/ navigation/navigation.dart';
import '../../../core/styles/themes.dart';
import '../../../core/widgets/show_toast.dart';
import '../../../core/widgets/user_nav_header.dart';
import '../cubit/cubit.dart';
import '../cubit/states.dart';
import '../data/user_profile_api_data.dart';

class AccountInfoPage extends StatefulWidget {
  const AccountInfoPage({super.key});

  @override
  State<AccountInfoPage> createState() => _AccountInfoPageState();
}

class _AccountInfoPageState extends State<AccountInfoPage> {
  String? _imagePath;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final cubit = UserCubit.get(context);
      if (cubit.profileData == null) cubit.getProfileData();
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<void> _pickImage() async {
    final image = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (image == null) return;
    setState(() => _imagePath = image.path);
  }

  Future<void> _save(UserProfileData? profile) async {
    if (profile == null || _imagePath == null) return;
    await UserCubit.get(context).updateProfile(
      name: profile.name,
      phone: profile.phone,
      imagePath: _imagePath,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
          bottom: false,
          child: BlocConsumer<UserCubit, UserStates>(
            listener: (context, state) {
              if (state is UserProfileUpdatedState) {
                setState(() => _imagePath = null);
                showToastSuccess(
                  text: 'تم تحديث صورة الحساب',
                  context: context,
                );
              }
              if (state is UserProfileUpdateErrorState) {
                showToastError(text: state.message, context: context);
              }
            },
            builder: (context, state) {
              final profile = UserCubit.get(context).profileData;

              final loading =
                  state is UserProfileLoadingState ||
                  state is UserProfileUpdatingState;

              return CustomScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                slivers: [
                  const UserAppBarSliver(),
                  const SliverToBoxAdapter(child: SizedBox(height: 16)),
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 14),
                      child: Container(
                        padding: const EdgeInsets.fromLTRB(14, 16, 14, 16),
                        decoration: _softDecoration(radius: 18),
                        child: Column(
                          children: [
                            _AvatarPicker(
                              profile: profile,
                              imagePath: _imagePath,
                              onTap: _pickImage,
                            ),
                            const SizedBox(height: 18),
                            _AccountInfoTile(
                              label: 'الاسم الكامل',
                              value: profile?.name ?? 'مستخدم',
                              icon: Iconsax.user,
                            ),
                            const SizedBox(height: 10),
                            _AccountInfoTile(
                              label: 'رقم الهاتف',
                              value: profile?.phone ?? '',
                              icon: Iconsax.call,
                              textDirection: TextDirection.ltr,
                            ),
                            const SizedBox(height: 10),
                            _AccountInfoTile(
                              label: 'تاريخ الانضمام',
                              value: profile?.memberSince ?? 'عضو جديد',
                              icon: Iconsax.calendar,
                            ),
                            const SizedBox(height: 10),
                            Row(
                              children: [
                                Expanded(
                                  child: _SmallInfoTile(
                                    label: 'التقييم',
                                    value:
                                        profile?.rating.toStringAsFixed(1) ??
                                        '0.0',
                                    icon: Iconsax.star1,
                                    color: const Color(0xFFFF9517),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: _SmallInfoTile(
                                    label: 'الكوبونات',
                                    value:
                                        (profile?.couponsCount ?? 0).toString(),
                                    icon: Icons.confirmation_number_outlined,
                                    color: secondaryColor,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 10),
                            Row(
                              children: [
                                Expanded(
                                  child: _SmallInfoTile(
                                    label: 'النقاط',
                                    value: (profile?.points ?? 0).toString(),
                                    icon: Iconsax.bag_tick,
                                    color: primaryColor,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: _SmallInfoTile(
                                    label: 'المحفظة',
                                    value:
                                        '${_formatPrice(profile?.walletBalance ?? 0)} د.ع',
                                    icon: Iconsax.wallet_3,
                                    color: primaryColor,
                                  ),
                                ),
                              ],
                            ),
                            if (_imagePath != null) ...[
                              const SizedBox(height: 16),
                              InkWell(
                                onTap: loading ? null : () => _save(profile),
                                borderRadius: BorderRadius.circular(13),
                                child: Container(
                                  height: 42,
                                  decoration: BoxDecoration(
                                    color: primaryColor,
                                    borderRadius: BorderRadius.circular(13),
                                  ),
                                  alignment: Alignment.center,
                                  child:
                                      loading
                                          ? const SizedBox(
                                            width: 18,
                                            height: 18,
                                            child: CircularProgressIndicator(
                                              color: Colors.white,
                                              strokeWidth: 2,
                                            ),
                                          )
                                          : const Text(
                                            'حفظ الصورة',
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 12,
                                              fontWeight: FontWeight.w900,
                                            ),
                                          ),
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SliverToBoxAdapter(child: SizedBox(height: 110)),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

// ignore: unused_element
class _AccountHeader extends StatelessWidget {
  const _AccountHeader();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 0),
      child: SizedBox(
        height: 70,
        child: Stack(
          alignment: Alignment.center,
          children: [
            Align(
              alignment: Alignment.center,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Image.asset('assets/images/logo.png', height: 44),
                  const SizedBox(height: 2),
                  const Text(
                    'معلومات الحساب',
                    style: TextStyle(
                      color: Color(0xFF151B18),
                      fontSize: 13,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ],
              ),
            ),
            Align(
              alignment: Alignment.centerLeft,
              child: InkWell(
                onTap: () => navigateBack(context),
                customBorder: const CircleBorder(),
                child: Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: .08),
                        blurRadius: 12,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Iconsax.arrow_left_2,
                    color: Color(0xFF151B18),
                    size: 18,
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

class _AvatarPicker extends StatelessWidget {
  const _AvatarPicker({
    required this.profile,
    required this.imagePath,
    required this.onTap,
  });

  final UserProfileData? profile;
  final String? imagePath;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        InkWell(
          onTap: onTap,
          customBorder: const CircleBorder(),
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              Container(
                width: 82,
                height: 82,
                padding: const EdgeInsets.all(7),
                decoration: const BoxDecoration(
                  color: Color(0xFFEAF5EE),
                  shape: BoxShape.circle,
                ),
                child: ClipOval(
                  child: _AvatarImage(profile: profile, path: imagePath),
                ),
              ),
              Positioned(
                right: -2,
                bottom: 2,
                child: Container(
                  width: 26,
                  height: 26,
                  decoration: const BoxDecoration(
                    color: primaryColor,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Iconsax.camera,
                    color: Colors.white,
                    size: 14,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          'تغيير صورة الملف الشخصي',
          style: TextStyle(
            color: primaryColor,
            fontSize: 10,
            fontWeight: FontWeight.w900,
          ),
        ),
      ],
    );
  }
}

class _AvatarImage extends StatelessWidget {
  const _AvatarImage({required this.profile, required this.path});

  final UserProfileData? profile;
  final String? path;

  @override
  Widget build(BuildContext context) {
    if (path != null) {
      return Image.file(File(path!), fit: BoxFit.cover);
    }

    final avatarUrl = profile?.avatarUrl;
    if (avatarUrl != null && avatarUrl.isNotEmpty) {
      return Image.network(avatarUrl, fit: BoxFit.cover);
    }

    return Padding(
      padding: const EdgeInsets.all(8),
      child: Image.asset('assets/images/logo.png', fit: BoxFit.contain),
    );
  }
}

class _AccountInfoTile extends StatelessWidget {
  const _AccountInfoTile({
    required this.label,
    required this.value,
    required this.icon,
    this.textDirection,
  });

  final String label;
  final String value;
  final IconData icon;
  final TextDirection? textDirection;

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(minHeight: 48),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFFFBFCFB),
        borderRadius: BorderRadius.circular(11),
        border: Border.all(color: const Color(0xFFE3E5E6)),
      ),
      child: Row(
        children: [
          Icon(icon, color: primaryColor, size: 19),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    color: Color(0xFF555D59),
                    fontSize: 9,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  value,
                  textDirection: textDirection,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Color(0xFF151B18),
                    fontSize: 11,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SmallInfoTile extends StatelessWidget {
  const _SmallInfoTile({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  final String label;
  final String value;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 54,
      padding: const EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
        color: color.withValues(alpha: .07),
        borderRadius: BorderRadius.circular(11),
        border: Border.all(color: color.withValues(alpha: .16)),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 17),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Color(0xFF555D59),
                    fontSize: 8,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  value,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Color(0xFF151B18),
                    fontSize: 12,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

String _formatPrice(int price) {
  final value = price.toString();
  return value.replaceAllMapped(RegExp(r'\B(?=(\d{3})+(?!\d))'), (_) => ',');
}

BoxDecoration _softDecoration({required double radius}) {
  return BoxDecoration(
    color: Colors.white,
    borderRadius: BorderRadius.circular(radius),
    border: Border.all(color: const Color(0xFFF0F1EF)),
    boxShadow: [
      BoxShadow(
        color: Colors.black.withValues(alpha: .07),
        blurRadius: 18,
        offset: const Offset(0, 8),
      ),
    ],
  );
}
