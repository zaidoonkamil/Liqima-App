import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:iconsax/iconsax.dart';

import '../../../core/ navigation/navigation.dart';
import '../../../core/widgets/user_nav_header.dart';
import '../cubit/cubit.dart';
import '../cubit/states.dart';
import '../data/coupons_page_data.dart';
import '../../../core/styles/themes.dart';
import '../../../core/widgets/show_toast.dart';
import 'widgets/user_page_shimmers.dart';

class CouponsPage extends StatefulWidget {
  const CouponsPage({super.key, this.selectionMode = false});

  final bool selectionMode;

  @override
  State<CouponsPage> createState() => _CouponsPageState();
}

class _CouponsPageState extends State<CouponsPage> {
  bool initialLoadFinished = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      UserCubit.get(context).getCouponsData();
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
              if (state is UserCouponsErrorState) {
                initialLoadFinished = true;
                showToastError(text: state.message, context: context);
              }
              if (state is UserCouponsSuccessState) {
                initialLoadFinished = true;
              }
            },
            builder: (context, state) {
              final cubit = UserCubit.get(context);
              final coupons = cubit.couponsData;
              final loading =
                  coupons == null &&
                  (!initialLoadFinished || state is UserCouponsLoadingState);
              final isEmpty =
                  !loading &&
                  (coupons?.availableCoupons.isEmpty ?? true) &&
                  (coupons?.expiredCoupons.isEmpty ?? true);
              return CustomScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                slivers: [
                  UserAppBarSliver(),
                  const SliverToBoxAdapter(child: SizedBox(height: 12)),
                  SliverToBoxAdapter(child: _SavingsCard(data: coupons)),
                  const SliverToBoxAdapter(child: SizedBox(height: 12)),
                  if (loading)
                    const CouponsPageShimmerSlivers()
                  else if (isEmpty)
                    const SliverFillRemaining(
                      hasScrollBody: false,
                      child: _EmptyCoupons(),
                    )
                  else ...[
                    SliverToBoxAdapter(
                      child: _CouponsSection(
                        title: 'الكوبونات المتاحة',
                        count: coupons?.availableCount ?? 0,
                        coupons: coupons?.availableCoupons ?? const [],
                        selectionMode: widget.selectionMode,
                      ),
                    ),
                    const SliverToBoxAdapter(child: SizedBox(height: 10)),
                    SliverToBoxAdapter(
                      child: _CouponsSection(
                        title: 'الكوبونات المنتهية',
                        count: coupons?.expiredCount ?? 0,
                        coupons: coupons?.expiredCoupons ?? const [],
                        selectionMode: false,
                      ),
                    ),
                    const SliverToBoxAdapter(child: SizedBox(height: 10)),
                    const SliverToBoxAdapter(child: _InfoBar()),
                    const SliverToBoxAdapter(child: SizedBox(height: 92)),
                  ],
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

class _EmptyCoupons extends StatelessWidget {
  const _EmptyCoupons();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 78,
            height: 78,
            decoration: BoxDecoration(
              color: primaryColor.withValues(alpha: .08),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Iconsax.ticket_discount,
              color: primaryColor,
              size: 34,
            ),
          ),
          const SizedBox(height: 14),
          const Text(
            'ماكو كوبونات حالياً',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Color(0xFF151B18),
              fontSize: 15,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'من تتوفر كوبونات جديدة راح تظهر هنا',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Color(0xFF747D79),
              fontSize: 9,
              fontWeight: FontWeight.w700,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 16),
          InkWell(
            onTap: () => UserCubit.get(context).getCouponsData(refresh: true),
            borderRadius: BorderRadius.circular(18),
            child: Container(
              height: 36,
              padding: const EdgeInsets.symmetric(horizontal: 18),
              decoration: BoxDecoration(
                color: primaryColor,
                borderRadius: BorderRadius.circular(18),
                boxShadow: [
                  BoxShadow(
                    color: primaryColor.withValues(alpha: .14),
                    blurRadius: 14,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Iconsax.refresh, color: Colors.white, size: 15),
                  SizedBox(width: 7),
                  Text(
                    'تحديث',
                    style: TextStyle(
                      color: Colors.white,
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
    );
  }
}

// ignore: unused_element
class _CouponsHeader extends StatelessWidget {
  const _CouponsHeader();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(18, 8, 18, 0),
      child: SizedBox(
        height: 116,
        child: Stack(
          alignment: Alignment.topCenter,
          children: [
            Column(
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Image.asset('assets/images/logo.png', height: 58),
                    const SizedBox(width: 8),
                    Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: const Color(0xFFF1FAF3),
                        shape: BoxShape.circle,
                        border: Border.all(color: const Color(0xFFE2EFE7)),
                      ),
                      child: const Icon(
                        Iconsax.shopping_bag,
                        color: primaryColor,
                        size: 17,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                const Text(
                  'الكوبونات',
                  style: TextStyle(
                    color: Color(0xFF151B18),
                    fontSize: 16,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 5),
                const Text(
                  'استخدم الكوبونات واستمتع بتوفير أكثر',
                  style: TextStyle(
                    color: Color(0xFF747D79),
                    fontSize: 8,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
            Align(
              alignment: Alignment.topRight,
              child: InkWell(
                onTap: () => navigateBack(context),
                customBorder: const CircleBorder(),
                child: Container(
                  width: 38,
                  height: 38,
                  decoration: _softDecoration(radius: 19),
                  child: const Icon(Iconsax.arrow_right_3, size: 18),
                ),
              ),
            ),
            Align(
              alignment: Alignment.topLeft,
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  const Padding(
                    padding: EdgeInsets.all(8),
                    child: Icon(Iconsax.notification, size: 22),
                  ),
                  Positioned(
                    right: 2,
                    top: 0,
                    child: Container(
                      width: 17,
                      height: 17,
                      alignment: Alignment.center,
                      decoration: const BoxDecoration(
                        color: secondaryColor,
                        shape: BoxShape.circle,
                      ),
                      child: const Text(
                        '3',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 9,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
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

class _SavingsCard extends StatelessWidget {
  const _SavingsCard({required this.data});

  final UserCouponsData? data;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        height: 74,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          color: primaryColor,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: primaryColor.withValues(alpha: .16),
              blurRadius: 18,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Row(
          children: [
            Image.asset('assets/images/copon.png', width: 50),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'لديك ${data?.total ?? 0} كوبونات',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    '${data?.availableCount ?? 0} صالحة  ·  ${data?.expiredCount ?? 0} منتهية',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 8,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              width: 106,
              height: 52,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: .08),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.white30),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    'إجمالي التوفير',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 7,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    ' د.ع ${_formatPrice(data?.totalSavings ?? 0)}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  SizedBox(height: 2),
                  Text(
                    'من جميع الطلبات',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 7,
                      fontWeight: FontWeight.w700,
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

class _CouponsSection extends StatelessWidget {
  const _CouponsSection({
    required this.title,
    required this.count,
    required this.coupons,
    required this.selectionMode,
  });

  final String title;
  final int count;
  final List<CouponCardData> coupons;
  final bool selectionMode;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          Row(
            children: [
              Text(
                title,
                style: const TextStyle(
                  color: Color(0xFF151B18),
                  fontSize: 12,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(width: 7),
              Container(
                width: 20,
                height: 20,
                alignment: Alignment.center,
                decoration: const BoxDecoration(
                  color: Color(0xFFEFF8F1),
                  shape: BoxShape.circle,
                ),
                child: Text(
                  '$count',
                  style: const TextStyle(
                    color: primaryColor,
                    fontSize: 10,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          for (final coupon in coupons) ...[
            _CouponCard(coupon: coupon, selectionMode: selectionMode),
            if (coupon != coupons.last) const SizedBox(height: 8),
          ],
        ],
      ),
    );
  }
}

class _CouponCard extends StatelessWidget {
  const _CouponCard({required this.coupon, required this.selectionMode});

  final CouponCardData coupon;
  final bool selectionMode;

  bool get isExpired => coupon.status == CouponStatus.expired;

  @override
  Widget build(BuildContext context) {
    final color = isExpired ? const Color(0xFF8E908F) : coupon.color;
    final textColor = isExpired ? const Color(0xFF8E908F) : primaryColor;
    final backgroundColor =
        isExpired
            ? const Color(0xFFFAFAFA)
            : coupon.color == secondaryColor
            ? const Color(0xFFFFFBF7)
            : Colors.white;

    final card = Container(
      height: 85,
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFF0F1EF)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: .055),
            blurRadius: 14,
            offset: const Offset(0, 7),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Row(
        children: [
          ClipPath(
            clipper: const _CouponCodeClipper(),
            child: Container(
              width: 100,
              color: color,
              padding: const EdgeInsets.fromLTRB(13, 12, 17, 12),
              child: Column(
                children: [
                  const Text(
                    'الكود',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 8,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    coupon.code,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Container(
                    height: 20,
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: .08),
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: Colors.white38),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          selectionMode
                              ? Icons.check_rounded
                              : Icons.copy_rounded,
                          color: Colors.white,
                          size: 10,
                        ),
                        const SizedBox(width: 2),
                        Text(
                          selectionMode ? 'تطبيق' : 'انسخ الكود',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 8,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(12, 10, 14, 8),
              child: Row(
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Text(
                        coupon.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.right,
                        style: TextStyle(
                          color:
                              isExpired
                                  ? const Color(0xFF888C89)
                                  : const Color(0xFF151B18),
                          fontSize: 12,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        coupon.subtitle,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.right,
                        style: const TextStyle(
                          color: Color(0xFF747D79),
                          fontSize: 8,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        'الأدنى للطلب ${_formatPrice(coupon.minimumOrder)} د.ع',
                        textAlign: TextAlign.right,
                        style: const TextStyle(
                          color: Color(0xFF747D79),
                          fontSize: 8,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                  Spacer(),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Row(
                        textDirection: TextDirection.ltr,
                        children: [
                          Icon(Iconsax.calendar, color: textColor, size: 12),
                          const SizedBox(width: 4),
                          Text(
                            coupon.validUntil,
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

                      _CouponBadge(text: coupon.badge, color: color),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );

    if (!selectionMode || isExpired) return card;

    return InkWell(
      onTap: () => navigateBack(context, coupon.code),
      borderRadius: BorderRadius.circular(12),
      child: card,
    );
  }
}

class _CouponBadge extends StatelessWidget {
  const _CouponBadge({required this.text, required this.color});

  final String text;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: .10),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            text,
            style: TextStyle(
              color: color,
              fontSize: 8,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(width: 4),
          Icon(_badgeIcon(text), color: color, size: 11),
        ],
      ),
    );
  }
}

IconData _badgeIcon(String text) {
  if (text == 'منتهي') return Icons.cancel_rounded;
  if (text == 'خصم على الطلب') return Icons.local_offer_outlined;
  if (text == 'خصم ثابت') return Icons.monetization_on_outlined;
  return Icons.delivery_dining_rounded;
}

class _InfoBar extends StatelessWidget {
  const _InfoBar();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        height: 36,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(
          color: const Color(0xFFF1FAF3),
          borderRadius: BorderRadius.circular(10),
        ),
        child: const Row(
          children: [
            Icon(Iconsax.info_circle, color: primaryColor, size: 15),
            SizedBox(width: 8),
            Expanded(
              child: Text(
                'يمكنك استخدام كوبون واحد فقط في كل طلب',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: primaryColor,
                  fontSize: 9,
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

class _CouponCodeClipper extends CustomClipper<Path> {
  const _CouponCodeClipper();

  @override
  Path getClip(Size size) {
    const notchRadius = 7.0;
    const zigzagStep = 7.0;
    const zigzagDepth = 5.0;
    final path = Path()..moveTo(size.width, 0);

    path.lineTo(size.width, 24 - notchRadius);
    path.arcToPoint(
      Offset(size.width, 24 + notchRadius),
      radius: const Radius.circular(notchRadius),
      clockwise: false,
    );
    path.lineTo(size.width, size.height - 24 - notchRadius);
    path.arcToPoint(
      Offset(size.width, size.height - 24 + notchRadius),
      radius: const Radius.circular(notchRadius),
      clockwise: false,
    );
    path.lineTo(size.width, size.height);
    path.lineTo(0, size.height);

    var y = size.height;
    var pullIn = true;
    while (y > 0) {
      y = (y - zigzagStep).clamp(0, size.height);
      path.lineTo(pullIn ? zigzagDepth : 0, y);
      pullIn = !pullIn;
    }

    path.close();
    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => false;
}

BoxDecoration _softDecoration({required double radius}) {
  return BoxDecoration(
    color: Colors.white,
    borderRadius: BorderRadius.circular(radius),
    border: Border.all(color: const Color(0xFFF0F1EF)),
    boxShadow: [
      BoxShadow(
        color: Colors.black.withValues(alpha: .06),
        blurRadius: 14,
        offset: const Offset(0, 7),
      ),
    ],
  );
}

String _formatPrice(int price) {
  final value = price.toString();
  return value.replaceAllMapped(RegExp(r'\B(?=(\d{3})+(?!\d))'), (_) => ',');
}
