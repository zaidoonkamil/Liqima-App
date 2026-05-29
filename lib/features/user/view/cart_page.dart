import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:iconsax/iconsax.dart';

import '../../../core/ navigation/navigation.dart';
import '../../../core/styles/themes.dart';
import '../../../core/widgets/show_toast.dart';
import '../../../core/widgets/user_nav_header.dart' show UserAppBarSliver;
import '../cubit/cubit.dart';
import '../cubit/states.dart';
import '../data/cart_page_data.dart';
import 'checkout_page.dart';
import 'coupons_page.dart';
import 'widgets/user_page_shimmers.dart';

class CartPage extends StatefulWidget {
  const CartPage({super.key});

  @override
  State<CartPage> createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  bool initialLoadFinished = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      UserCubit.get(context).getCartData(refresh: true);
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
              if (state is UserCartErrorState) {
                initialLoadFinished = true;
                showToastError(text: state.message, context: context);
              }
              if (state is UserCartSuccessState) {
                initialLoadFinished = true;
              }
              if (state is UserCartCouponAppliedState) {
                showToastSuccess(text: 'تم تطبيق الكوبون', context: context);
              }
            },
            builder: (context, state) {
              final cubit = UserCubit.get(context);
              final cart = cubit.cartData;
              final loading =
                  cart == null &&
                  (!initialLoadFinished || state is UserCartLoadingState);

              return CustomScrollView(
                physics: const AlwaysScrollableScrollPhysics(
                  parent: BouncingScrollPhysics(),
                ),
                slivers: [
                  const UserAppBarSliver(),
                  const SliverToBoxAdapter(child: SizedBox(height: 6)),
                  if (loading)
                    const CartPageShimmerSlivers()
                  else if (cart == null || cart.isEmpty)
                    const SliverFillRemaining(
                      hasScrollBody: false,
                      child: _EmptyCart(),
                    )
                  else ...[
                    SliverToBoxAdapter(
                      child: _FreeDeliveryProgress(summary: cart.summary),
                    ),
                    const SliverToBoxAdapter(child: SizedBox(height: 12)),
                    SliverToBoxAdapter(child: _CartItemsCard(cart: cart)),
                    const SliverToBoxAdapter(child: SizedBox(height: 12)),
                    SliverToBoxAdapter(child: _CouponBox(cart: cart)),
                    const SliverToBoxAdapter(child: SizedBox(height: 12)),
                    SliverToBoxAdapter(child: _OrderSummaryCard(cart: cart)),
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

class _FreeDeliveryProgress extends StatelessWidget {
  const _FreeDeliveryProgress({required this.summary});

  final CartSummaryData summary;

  @override
  Widget build(BuildContext context) {
    final title =
        summary.deliveryFee <= 0
            ? 'التوصيل مجاني لهذا الطلب'
            : 'رسوم التوصيل د.ع ${_formatPrice(summary.deliveryFee)}';
    final progressValue =
        summary.freeDeliveryDistanceKm <= 0
            ? 1.0
            : (summary.deliveryDistanceKm == null
                ? 0.0
                : (summary.deliveryDistanceKm! / summary.freeDeliveryDistanceKm)
                    .clamp(0, 1)
                    .toDouble());

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        height: 56,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: const Color(0xFFF3FAF2),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            Image.asset(
              'assets/images/deliverylokma.png',
              width: 42,
              height: 42,
            ),
            const SizedBox(width: 6),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: primaryColor,
                            fontSize: 8,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ),
                      Text(
                        summary.deliveryDistanceKm == null
                            ? 'قريب'
                            : '${summary.deliveryDistanceKm!.toStringAsFixed(1)} كم',
                        style: const TextStyle(
                          color: primaryColor,
                          fontSize: 8,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: LinearProgressIndicator(
                      minHeight: 6,
                      value: progressValue,
                      backgroundColor: Colors.orange,
                      valueColor: const AlwaysStoppedAnimation(primaryColor),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      const Text(
                        'حد المجاني',
                        style: TextStyle(
                          color: Color(0xFF747D79),
                          fontSize: 8,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${summary.freeDeliveryDistanceKm.toStringAsFixed(1)} كم',
                        style: const TextStyle(
                          color: Color(0xFF747D79),
                          fontSize: 8,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ],
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

class _CartItemsCard extends StatelessWidget {
  const _CartItemsCard({required this.cart});

  final CartApiData cart;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        decoration: _softDecoration(radius: 18),
        clipBehavior: Clip.antiAlias,
        child: Column(
          children: [
            _RestaurantHeader(cart: cart),
            AnimatedSize(
              duration: const Duration(milliseconds: 220),
              curve: Curves.easeOutCubic,
              alignment: Alignment.topCenter,
              child: Column(
                children: [
                  for (final item in cart.items) ...[
                    const Divider(height: 1, color: Color(0xFFF0F1EF)),
                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 180),
                      switchInCurve: Curves.easeOutCubic,
                      switchOutCurve: Curves.easeInCubic,
                      transitionBuilder:
                          (child, animation) => SizeTransition(
                            sizeFactor: animation,
                            axisAlignment: -1,
                            child: FadeTransition(
                              opacity: animation,
                              child: child,
                            ),
                          ),
                      child: _CartItemTile(
                        key: ValueKey('${item.id}-${item.quantity}'),
                        item: item,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _RestaurantHeader extends StatelessWidget {
  const _RestaurantHeader({required this.cart});

  final CartApiData cart;

  @override
  Widget build(BuildContext context) {
    final restaurant = cart.restaurant;
    final summary = cart.summary;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child:
                restaurant == null
                    ? Container(
                      width: 40,
                      height: 40,
                      color: primaryColor.withValues(alpha: .08),
                      child: const Icon(Iconsax.shop, color: primaryColor),
                    )
                    : Image.network(
                      restaurant.logoUrl,
                      width: 40,
                      height: 40,
                      fit: BoxFit.cover,
                    ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        restaurant?.name ?? 'المطعم',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Color(0xFF151B18),
                          fontSize: 11,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                    const SizedBox(width: 6),
                    const Icon(Iconsax.arrow_left_2, size: 14),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Text(
                      restaurant?.deliveryTime ?? '25-35 دقيقة',
                      style: const TextStyle(
                        color: Color(0xFF555D59),
                        fontSize: 8,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(width: 4),
                    const Icon(Iconsax.timer, color: primaryColor, size: 12),
                    const SizedBox(width: 4),
                    Text(
                      summary.deliveryDistanceKm == null
                          ? restaurant?.distance ?? 'قريب'
                          : '${summary.deliveryDistanceKm!.toStringAsFixed(1)} كم',
                      style: const TextStyle(
                        color: Color(0xFF555D59),
                        fontSize: 8,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(width: 4),
                    const Icon(Iconsax.location, color: primaryColor, size: 12),
                  ],
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Row(
                children: [
                  Text(
                    summary.deliveryFee <= 0
                        ? 'توصيل مجاني'
                        : 'د.ع ${_formatPrice(summary.deliveryFee)}',
                    style: const TextStyle(
                      color: primaryColor,
                      fontSize: 8,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(width: 4),
                  const Icon(
                    Icons.delivery_dining_rounded,
                    color: primaryColor,
                    size: 13,
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                '${cart.items.length} أصناف بالسلة',
                style: const TextStyle(
                  color: Color(0xFF747D79),
                  fontSize: 8,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _CartItemTile extends StatelessWidget {
  const _CartItemTile({super.key, required this.item});

  final CartItemData item;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.network(
              item.imageUrl,
              width: 72,
              height: 68,
              fit: BoxFit.cover,
            ),
          ),
          const SizedBox(width: 6),
          Expanded(
            child: SizedBox(
              height: 66,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Color(0xFF151B18),
                      fontSize: 11,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    _itemDescription(item),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Color(0xFF747D79),
                      fontSize: 8,
                      height: 1.25,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const Spacer(),
                  Row(
                    children: [
                      Text(
                        'د.ع ${_formatPrice(item.lineTotal)}',
                        style: const TextStyle(
                          color: primaryColor,
                          fontSize: 10,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      if (item.oldPrice != null) ...[
                        const SizedBox(width: 6),
                        Text(
                          _formatPrice(item.oldPrice!),
                          style: const TextStyle(
                            color: Color(0xFF9AA09D),
                            fontSize: 8,
                            fontWeight: FontWeight.w700,
                            decoration: TextDecoration.lineThrough,
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 10),
          SizedBox(
            width: 64,
            height: 66,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                _DeleteButton(itemId: item.id),
                const Spacer(),
                _QuantityStepper(item: item),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _itemDescription(CartItemData item) {
    final parts = <String>[
      if (item.selectedSize != null) item.selectedSize!,
      if (item.addonsTotal > 0) 'إضافات د.ع ${_formatPrice(item.addonsTotal)}',
      if (item.description.isNotEmpty) item.description,
    ];
    return parts.join(' · ');
  }
}

class _DeleteButton extends StatelessWidget {
  const _DeleteButton({required this.itemId});

  final int itemId;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => UserCubit.get(context).removeCartItem(itemId),
      customBorder: const CircleBorder(),
      child: Container(
        width: 30,
        height: 30,
        decoration: BoxDecoration(
          color: const Color(0xFFFFF4F2),
          shape: BoxShape.circle,
          border: Border.all(color: const Color(0xFFFFE2DD)),
        ),
        child: const Icon(Iconsax.trash, color: Color(0xFFE6554B), size: 15),
      ),
    );
  }
}

class _QuantityStepper extends StatelessWidget {
  const _QuantityStepper({required this.item});

  final CartItemData item;

  @override
  Widget build(BuildContext context) {
    final cubit = UserCubit.get(context);
    return Container(
      width: 64,
      height: 30,
      decoration: _softDecoration(radius: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          InkWell(
            onTap:
                item.quantity <= 1
                    ? null
                    : () => cubit.changeCartItemQuantity(
                      itemId: item.id,
                      quantity: item.quantity - 1,
                    ),
            child: const Icon(
              Icons.remove_rounded,
              color: primaryColor,
              size: 16,
            ),
          ),
          Text(
            '${item.quantity}',
            style: const TextStyle(
              color: Color(0xFF151B18),
              fontSize: 12,
              fontWeight: FontWeight.w900,
            ),
          ),
          InkWell(
            onTap:
                () => cubit.changeCartItemQuantity(
                  itemId: item.id,
                  quantity: item.quantity + 1,
                ),
            child: const Icon(Icons.add_rounded, color: primaryColor, size: 16),
          ),
        ],
      ),
    );
  }
}

class _CouponBox extends StatelessWidget {
  const _CouponBox({required this.cart});

  final CartApiData cart;

  @override
  Widget build(BuildContext context) {
    final applied = cart.summary.couponCode;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: InkWell(
        onTap: () => _showCouponDialog(context),
        borderRadius: BorderRadius.circular(12),
        child: Container(
          height: 44,
          padding: const EdgeInsets.symmetric(horizontal: 14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFFFFD9AE), width: 1.1),
          ),
          child: Row(
            children: [
              const Icon(
                Icons.local_offer_rounded,
                color: secondaryColor,
                size: 22,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      applied == null ? 'لديك كوبون خصم؟' : 'الكوبون مطبق',
                      style: const TextStyle(
                        color: Color(0xFF151B18),
                        fontSize: 10,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      applied ?? 'ادخل الكود هنا',
                      style: const TextStyle(
                        color: Color(0xFF747D79),
                        fontSize: 8,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                height: 25,
                padding: const EdgeInsets.symmetric(horizontal: 14),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: const Color(0xFFFFB45D)),
                ),
                alignment: Alignment.center,
                child: const Text(
                  'إضافة كوبون',
                  style: TextStyle(
                    color: secondaryColor,
                    fontSize: 9,
                    fontWeight: FontWeight.w900,
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

class _OrderSummaryCard extends StatelessWidget {
  const _OrderSummaryCard({required this.cart});

  final CartApiData cart;

  @override
  Widget build(BuildContext context) {
    final summary = cart.summary;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        padding: const EdgeInsets.fromLTRB(14, 14, 14, 14),
        decoration: _softDecoration(radius: 18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'ملخص الطلب',
              style: TextStyle(
                color: Color(0xFF151B18),
                fontSize: 12,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 6),
            _SummaryRow(
              title: 'المجموع الفرعي (${summary.itemsCount} أصناف)',
              value: 'د.ع ${_formatPrice(summary.subtotal)}',
            ),
            const SizedBox(height: 6),
            _SummaryRow(
              title: 'رسوم التوصيل',
              value:
                  summary.deliveryFee <= 0
                      ? 'توصيل مجاني'
                      : 'د.ع ${_formatPrice(summary.deliveryFee)}',
              greenValue: summary.deliveryFee <= 0,
              oldValue:
                  summary.deliveryFeeBeforeDiscount > summary.deliveryFee
                      ? 'د.ع ${_formatPrice(summary.deliveryFeeBeforeDiscount)}'
                      : null,
            ),
            if (summary.appDeliveryFee > 0) ...[
              const SizedBox(height: 6),
              _SummaryRow(
                title: 'رسوم التطبيق',
                value: 'د.ع ${_formatPrice(summary.appDeliveryFee)}',
              ),
            ],
            const SizedBox(height: 6),
            _SummaryRow(
              title: 'خصم',
              value: 'د.ع ${_formatPrice(summary.discountAmount)}',
              greenValue: summary.discountAmount > 0,
            ),
            const SizedBox(height: 6),
            const Divider(height: 1, color: Color(0xFFF0F1EF)),
            const SizedBox(height: 6),
            _SummaryRow(
              title: 'الإجمالي',
              value: 'د.ع ${_formatPrice(summary.total)}',
              bold: true,
            ),
            const SizedBox(height: 4),
            const Text(
              'شامل ضريبة القيمة المضافة',
              style: TextStyle(
                color: Color(0xFF9AA09D),
                fontSize: 8,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: Container(
                    height: 38,
                    padding: const EdgeInsets.symmetric(horizontal: 7),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF3FAF2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Iconsax.location, color: primaryColor, size: 17),
                        SizedBox(width: 6),
                        Flexible(
                          child: Text(
                            'العنوان',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
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
                ),
                const SizedBox(width: 4),
                Expanded(
                  flex: 2,
                  child: InkWell(
                    onTap:
                        summary.canCheckout
                            ? () {
                              final cubit = UserCubit.get(context);
                              navigateTo(
                                context,
                                BlocProvider.value(
                                  value: cubit,
                                  child: const CheckoutPage(),
                                ),
                              );
                            }
                            : null,
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      height: 38,
                      decoration: BoxDecoration(
                        color:
                            summary.canCheckout
                                ? primaryColor
                                : const Color(0xFFB8C2BD),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          const SizedBox(width: 14),
                          Text(
                            'د.ع ${_formatPrice(summary.total)}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 9,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                          const Spacer(),
                          const Text(
                            'إتمام الطلب',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 11,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                          const Spacer(),
                          const Icon(
                            Icons.arrow_forward_ios,
                            color: Colors.white,
                            size: 16,
                          ),
                          const SizedBox(width: 14),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  const _SummaryRow({
    required this.title,
    required this.value,
    this.greenValue = false,
    this.oldValue,
    this.bold = false,
  });

  final String title;
  final String value;
  final bool greenValue;
  final String? oldValue;
  final bool bold;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          title,
          style: TextStyle(
            color: bold ? const Color(0xFF151B18) : const Color(0xFF555D59),
            fontSize: bold ? 12 : 9,
            fontWeight: bold ? FontWeight.w900 : FontWeight.w700,
          ),
        ),
        const Spacer(),
        if (oldValue != null) ...[
          Text(
            oldValue!,
            style: const TextStyle(
              color: Color(0xFF9AA09D),
              fontSize: 8,
              fontWeight: FontWeight.w700,
              decoration: TextDecoration.lineThrough,
            ),
          ),
          const SizedBox(width: 8),
        ],
        Text(
          value,
          style: TextStyle(
            color: greenValue || bold ? primaryColor : const Color(0xFF151B18),
            fontSize: bold ? 12 : 9,
            fontWeight: FontWeight.w900,
          ),
        ),
      ],
    );
  }
}

class _EmptyCart extends StatelessWidget {
  const _EmptyCart();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 28),
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
              Iconsax.shopping_cart,
              color: primaryColor,
              size: 34,
            ),
          ),
          const SizedBox(height: 14),
          const Text(
            'السلة فارغة',
            style: TextStyle(
              color: Color(0xFF151B18),
              fontSize: 15,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'من تضيف وجبات راح تظهر هنا مباشرة',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Color(0xFF747D79),
              fontSize: 9,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

Future<void> _showCouponDialog(BuildContext context) async {
  final cubit = UserCubit.get(context);
  final code = await navigateToWithResult<String>(
    context,
    BlocProvider.value(
      value: cubit,
      child: const CouponsPage(selectionMode: true),
    ),
  );
  if (code == null || code.trim().isEmpty) return;
  await cubit.applyCartCoupon(code);
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
