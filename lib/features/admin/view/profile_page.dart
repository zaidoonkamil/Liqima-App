import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:iconsax/iconsax.dart';
import 'package:liqima/features/user/view/favorites_page.dart';

import '../../../core/ navigation/navigation.dart';
import '../../../core/widgets/constant.dart';
import '../../../core/widgets/user_nav_header.dart';
import '../../../core/styles/themes.dart';
import '../../user/data/profile_page_data.dart';
import '../../user/view/contact_page.dart';
import '../cubit/admin_cubit.dart';
import 'admin_coupons_page.dart';

class ProfilePageAdmin extends StatelessWidget {
  const ProfilePageAdmin({super.key});

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
          bottom: false,
          child: CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            slivers: const [
              UserNavHeaderSliver(),
              SliverToBoxAdapter(child: SizedBox(height: 14)),
              SliverToBoxAdapter(child: _UserCard()),
              SliverToBoxAdapter(child: SizedBox(height: 12)),
              SliverToBoxAdapter(child: _WalletCard()),
              SliverToBoxAdapter(child: SizedBox(height: 12)),
              SliverToBoxAdapter(child: _AddressesSection()),
              SliverToBoxAdapter(child: SizedBox(height: 12)),
              SliverToBoxAdapter(child: _OptionsSection()),
              SliverToBoxAdapter(child: SizedBox(height: 12)),
              SliverToBoxAdapter(child: _AccountActions()),
              SliverToBoxAdapter(child: SizedBox(height: 92)),
            ],
          ),
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
        height: 44,
        padding: const EdgeInsets.symmetric(horizontal: 14),
        decoration: BoxDecoration(
          color: color.withValues(alpha: .09),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: color.withValues(alpha: .35)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 18),
            const SizedBox(width: 8),
            Text(
              text,
              style: TextStyle(
                color: color,
                fontSize: 12,
                fontWeight: FontWeight.w900,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _UserCard extends StatelessWidget {
  const _UserCard();

  @override
  Widget build(BuildContext context) {
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
                  child: ClipOval(
                    child: Image.network(
                      ProfilePageData.avatarUrl,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        ProfilePageData.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: Color(0xFF151B18),
                          fontSize: 12,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const Text(
                        ProfilePageData.phone,
                        textDirection: TextDirection.ltr,
                        style: TextStyle(
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
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              ProfilePageData.memberSince,
                              style: TextStyle(
                                color: primaryColor,
                                fontSize: 9,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                            SizedBox(width: 5),
                            Icon(
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
                for (var i = 0; i < ProfilePageData.stats.length; i++) ...[
                  Expanded(child: _StatItem(stat: ProfilePageData.stats[i])),
                  if (i != ProfilePageData.stats.length - 1)
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
  const _WalletCard();

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
                    'د.ع ${_formatPrice(ProfilePageData.walletBalance)}',
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
  const _AddressesSection();

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
            for (final address in ProfilePageData.addresses) ...[
              _AddressTile(address: address),
              if (address != ProfilePageData.addresses.last)
                const SizedBox(height: 8),
            ],
            const SizedBox(height: 8),
            Container(
              height: 32,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: const Color(0xFFE5E8E5),
                  style: BorderStyle.solid,
                ),
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Iconsax.add_circle, color: primaryColor, size: 16),
                  SizedBox(width: 8),
                  Text(
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

class _AddressTile extends StatelessWidget {
  const _AddressTile({required this.address});

  final ProfileAddressData address;

  @override
  Widget build(BuildContext context) {
    return Container(
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
                  address.title,
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
                  address.details,
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
              address.badge,
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
    );
  }
}

class _OptionsSection extends StatelessWidget {
  const _OptionsSection();

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
              _OptionTile(option: option),
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
  const _OptionTile({required this.option});

  final ProfileOptionData option;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        if (option.title == 'كوبوناتي') {
          navigateTo(
            context,
            BlocProvider.value(
              value: AdminCubit.get(context),
              child: const AdminCouponsPage(),
            ),
          );
        } else if (option.title == 'المفضلة') {
          navigateTo(context, const FavoritesPage());
        } else if (option.title == 'تواصل معنا') {
          navigateTo(context, const ContactPage());
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
