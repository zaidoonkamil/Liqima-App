import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:iconsax/iconsax.dart';

import '../../../core/ navigation/navigation.dart';
import '../../../core/styles/themes.dart';
import '../../../core/widgets/show_toast.dart';
import '../../../core/widgets/constant.dart';
import '../../../core/widgets/user_nav_header.dart';
import '../../restaurant/view/widgets/restaurant_ui_widgets.dart';
import '../cubit/cubit.dart';
import '../cubit/states.dart';
import '../data/profile_page_data.dart';
import '../data/user_profile_api_data.dart';
import 'account_info_page.dart';
import 'address_picker_page.dart';
import 'contact_page.dart';
import 'coupons_page.dart';
import 'widgets/user_page_shimmers.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key, this.onFavoritesTap});

  final VoidCallback? onFavoritesTap;

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  bool initialLoadFinished = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      UserCubit.get(context).getProfileData();
    });
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
              if (state is UserProfileSuccessState ||
                  state is UserProfileErrorState) {
                initialLoadFinished = true;
              }
              if (state is UserAddressErrorState) {
                showToastError(text: state.message, context: context);
              }
            },
            builder: (context, state) {
              final profile = UserCubit.get(context).profileData;
              if (profile == null &&
                  (!initialLoadFinished || state is UserProfileLoadingState)) {
                return const ProfilePageShimmer();
              }

              return CustomScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                slivers: [
                  const UserNavHeaderSliver(),
                  const SliverToBoxAdapter(child: SizedBox(height: 14)),
                  SliverToBoxAdapter(child: _UserCard(profile: profile)),
                  const SliverToBoxAdapter(child: SizedBox(height: 12)),
                  SliverToBoxAdapter(child: _WalletCard(profile: profile)),
                  const SliverToBoxAdapter(child: SizedBox(height: 12)),
                  SliverToBoxAdapter(
                    child: _AddressesSection(
                      addresses: profile?.addresses ?? const [],
                      saving: state is UserAddressSavingState,
                    ),
                  ),
                  const SliverToBoxAdapter(child: SizedBox(height: 12)),
                  SliverToBoxAdapter(
                    child: _OptionsSection(
                      onFavoritesTap: widget.onFavoritesTap,
                    ),
                  ),
                  const SliverToBoxAdapter(child: _AccountActions()),
                  const SliverToBoxAdapter(child: SizedBox(height: 92)),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

class _UserCard extends StatelessWidget {
  const _UserCard({required this.profile});

  final UserProfileData? profile;

  @override
  Widget build(BuildContext context) {
    final stats = _profileStats(profile);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14),
      child: Container(
        decoration: _softDecoration(radius: 18),
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
        child: Column(
          children: [
            Row(
              children: [
                Container(
                  width: 56,
                  height: 56,
                  padding: const EdgeInsets.all(6),
                  decoration: const BoxDecoration(
                    color: Color(0xFFEAF5EE),
                    shape: BoxShape.circle,
                  ),
                  child: ClipOval(child: _ProfileAvatar(profile: profile)),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        profile?.name ?? ProfilePageData.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Color(0xFF151B18),
                          fontSize: 12,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      Text(
                        profile?.phone ?? ProfilePageData.phone,
                        textDirection: TextDirection.ltr,
                        style: const TextStyle(
                          color: Color(0xFF1D2320),
                          fontSize: 9,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 9,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF0F8F1),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              profile?.memberSince ??
                                  ProfilePageData.memberSince,
                              style: const TextStyle(
                                color: primaryColor,
                                fontSize: 9,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                            const SizedBox(width: 5),
                            const Icon(
                              Iconsax.calendar,
                              color: primaryColor,
                              size: 12,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Container(height: 1, color: const Color(0xFFF0F1EF)),
            const SizedBox(height: 4),
            Row(
              children: [
                for (var i = 0; i < stats.length; i++) ...[
                  Expanded(child: _StatItem(stat: stats[i])),
                  if (i != stats.length - 1)
                    Container(
                      width: 1,
                      height: 26,
                      color: const Color(0xFFE7EAE7),
                    ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _ProfileAvatar extends StatelessWidget {
  const _ProfileAvatar({required this.profile});

  final UserProfileData? profile;

  @override
  Widget build(BuildContext context) {
    final avatarUrl = profile?.avatarUrl;
    if (avatarUrl != null && avatarUrl.isNotEmpty) {
      return Image.network(avatarUrl, fit: BoxFit.cover);
    }

    return Padding(
      padding: const EdgeInsets.all(6),
      child: Image.asset('assets/images/logo.png', fit: BoxFit.contain),
    );
  }
}

class _StatItem extends StatelessWidget {
  const _StatItem({required this.stat});

  final ProfileStatData stat;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(stat.icon, color: stat.color, size: 16),
        const SizedBox(width: 8),
        Column(
          children: [
            Text(
              stat.value,
              style: const TextStyle(
                color: Color(0xFF151B18),
                fontSize: 14,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              stat.title,
              style: const TextStyle(
                color: Color(0xFF555D59),
                fontSize: 8,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _WalletCard extends StatelessWidget {
  const _WalletCard({required this.profile});

  final UserProfileData? profile;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14),
      child: Container(
        height: 68,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(
          color: primaryColor,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: primaryColor.withValues(alpha: .18),
              blurRadius: 18,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Row(
          children: [
            const Icon(Iconsax.wallet_3, color: Color(0xFFFFDE73), size: 30),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    'المحفظة',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'د.ع ${_formatPrice(profile?.walletBalance ?? ProfilePageData.walletBalance)}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AddressesSection extends StatelessWidget {
  const _AddressesSection({required this.addresses, required this.saving});

  final List<UserAddressData> addresses;
  final bool saving;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14),
      child: Container(
        decoration: _softDecoration(radius: 18),
        padding: const EdgeInsets.fromLTRB(12, 14, 12, 14),
        child: Column(
          children: [
            const _SectionHeader(title: 'عناويني', action: 'عرض الكل'),
            const SizedBox(height: 8),
            if (addresses.isEmpty)
              const _AddressPlaceholder()
            else
              for (final address in addresses) ...[
                _AddressTile(address: address),
                if (address != addresses.last) const SizedBox(height: 8),
              ],
            const SizedBox(height: 8),
            InkWell(
              onTap: saving ? null : () => _openAddressPicker(context),
              borderRadius: BorderRadius.circular(8),
              child: Container(
                height: 32,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: const Color(0xFFE5E8E5)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (saving)
                      const SizedBox(
                        width: 14,
                        height: 14,
                        child: CircularProgressIndicator(
                          color: primaryColor,
                          strokeWidth: 2,
                        ),
                      )
                    else
                      const Icon(
                        Iconsax.add_circle,
                        color: primaryColor,
                        size: 16,
                      ),
                    const SizedBox(width: 8),
                    const Text(
                      'إضافة عنوان جديد',
                      style: TextStyle(
                        color: primaryColor,
                        fontSize: 10,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AddressPlaceholder extends StatelessWidget {
  const _AddressPlaceholder();

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => _openAddressPicker(context),
      borderRadius: BorderRadius.circular(13),
      child: Container(
        height: 48,
        padding: const EdgeInsets.symmetric(horizontal: 10),
        decoration: BoxDecoration(
          color: const Color(0xFFF8FBF8),
          borderRadius: BorderRadius.circular(13),
          border: Border.all(color: const Color(0xFFE5E8E5)),
        ),
        child: const Row(
          children: [
            Icon(Iconsax.location_add, color: primaryColor, size: 18),
            SizedBox(width: 8),
            Expanded(
              child: Text(
                'ضع عنوانك حتى نقدر نوصلك أسرع',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: Color(0xFF151B18),
                  fontSize: 10,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
            Icon(Iconsax.arrow_left_2, color: primaryColor, size: 16),
          ],
        ),
      ),
    );
  }
}

class _AddressTile extends StatelessWidget {
  const _AddressTile({required this.address});

  final UserAddressData address;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => _openAddressPicker(context, address: address),
      borderRadius: BorderRadius.circular(13),
      child: Container(
        height: 44,
        padding: const EdgeInsets.symmetric(horizontal: 10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(13),
          border: Border.all(color: const Color(0xFFF0F1EF)),
        ),
        child: Row(
          children: [
            Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                color: address.color.withValues(alpha: .10),
                shape: BoxShape.circle,
              ),
              child: Icon(address.icon, color: address.color, size: 14),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    address.addressText,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Color(0xFF151B18),
                      fontSize: 10,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    address.details.isEmpty
                        ? 'اضغط لتعديل العنوان'
                        : address.details,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Color(0xFF747D79),
                      fontSize: 8,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 10),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: address.color.withValues(alpha: .10),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Text(
                address.typeLabel,
                style: TextStyle(
                  color: address.color,
                  fontSize: 8,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
            const SizedBox(width: 4),
            const Icon(Iconsax.arrow_left_2, color: primaryColor, size: 16),
          ],
        ),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title, this.action});

  final String title;
  final String? action;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          title,
          style: const TextStyle(
            color: Color(0xFF151B18),
            fontSize: 12,
            fontWeight: FontWeight.w900,
          ),
        ),
        const Spacer(),
        if (action != null)
          Text(
            action!,
            style: const TextStyle(
              color: primaryColor,
              fontSize: 9,
              fontWeight: FontWeight.w900,
            ),
          ),
      ],
    );
  }
}

class _OptionsSection extends StatelessWidget {
  const _OptionsSection({this.onFavoritesTap});

  final VoidCallback? onFavoritesTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14),
      child: Container(
        decoration: _softDecoration(radius: 18),
        padding: const EdgeInsets.fromLTRB(12, 14, 12, 12),
        child: Column(
          children: [
            const _SectionHeader(title: 'المزيد من الخيارات'),
            const SizedBox(height: 12),
            for (final option in ProfilePageData.options) ...[
              _OptionTile(option: option, onFavoritesTap: onFavoritesTap),
              if (option != ProfilePageData.options.last)
                const Divider(height: 1, color: Color(0xFFF0F1EF)),
            ],
          ],
        ),
      ),
    );
  }
}

class _OptionTile extends StatelessWidget {
  const _OptionTile({required this.option, this.onFavoritesTap});

  final ProfileOptionData option;
  final VoidCallback? onFavoritesTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        if (option.title == 'كوبوناتي') {
          navigateTo(
            context,
            BlocProvider.value(
              value: UserCubit.get(context),
              child: const CouponsPage(),
            ),
          );
        } else if (option.title == 'معلومات الحساب') {
          navigateTo(
            context,
            BlocProvider.value(
              value: UserCubit.get(context),
              child: const AccountInfoPage(),
            ),
          );
        } else if (option.title == 'المفضلة') {
          onFavoritesTap?.call();
        } else if (option.title == 'تواصل معنا') {
          navigateTo(context, const ContactPage());
        } else if (option.title == 'طرق الدفع') {
          showToastInfo(text: 'قادمة قريبا', context: context);
        }
      },
      borderRadius: BorderRadius.circular(12),
      child: SizedBox(
        height: 42,
        child: Row(
          children: [
            Icon(option.icon, color: primaryColor, size: 18),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                option.title,
                style: const TextStyle(
                  color: Color(0xFF363C39),
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            const Icon(
              Iconsax.arrow_left_2,
              color: Color(0xFF555D59),
              size: 16,
            ),
          ],
        ),
      ),
    );
  }
}

class _AccountActions extends StatelessWidget {
  const _AccountActions();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(14, 16, 14, 94),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          _AccountButton(
            text: 'تسجيل الخروج',
            icon: Iconsax.logout,
            color: primaryColor,
            onTap: () => signOut(context),
          ),
          const SizedBox(height: 10),
          _AccountButton(
            text: 'حذف الحساب',
            icon: Iconsax.trash,
            color: const Color(0xFFE34B4B),
            onTap:
                () => showRestaurantDeleteDialog(
                  context: context,
                  title: 'حذف الحساب؟',
                  message: 'راح يتم حذف حسابك نهائياً بعد تأكيد العملية.',
                  onConfirm: () {},
                ),
          ),
        ],
      ),
    );
  }
}

class _AccountButton extends StatelessWidget {
  const _AccountButton({
    required this.text,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  final String text;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        height: 32,
        padding: const EdgeInsets.symmetric(horizontal: 14),
        decoration: BoxDecoration(
          color: color.withValues(alpha: .09),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: color.withValues(alpha: .35)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 16),
            const SizedBox(width: 8),
            Text(
              text,
              style: TextStyle(
                color: color,
                fontSize: 11,
                fontWeight: FontWeight.w900,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

Future<void> _openAddressPicker(
  BuildContext context, {
  UserAddressData? address,
}) async {
  final result = await navigateToWithResult<dynamic>(
    context,
    UserAddressPickerPage(address: address),
  );
  if (result is! UserAddressPickerResult || !context.mounted) return;

  await UserCubit.get(context).saveUserAddress(
    addressId: result.addressId,
    type: result.type,
    title: result.title,
    addressText: result.addressText,
    details: result.details,
    latitude: result.latitude,
    longitude: result.longitude,
  );
}

List<ProfileStatData> _profileStats(UserProfileData? profile) {
  if (profile == null) return ProfilePageData.stats;
  return [
    ProfileStatData(
      title: 'تقييمي',
      value: profile.rating.toStringAsFixed(1),
      icon: Iconsax.star1,
      color: const Color(0xFFFF9517),
    ),
    ProfileStatData(
      title: 'كوبونات',
      value: profile.couponsCount.toString(),
      icon: Icons.confirmation_number_outlined,
      color: secondaryColor,
    ),
  ];
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

String _formatPrice(int price) {
  final value = price.toString();
  return value.replaceAllMapped(RegExp(r'\B(?=(\d{3})+(?!\d))'), (_) => ',');
}
