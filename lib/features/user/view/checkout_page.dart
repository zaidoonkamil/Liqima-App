import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:iconsax/iconsax.dart';

import '../../../core/ navigation/navigation.dart';
import '../../../core/navigation_bar/navigation_bar.dart';
import '../../../core/styles/themes.dart';
import '../../../core/widgets/show_toast.dart';
import '../../../core/widgets/user_nav_header.dart';
import '../cubit/cubit.dart';
import '../cubit/states.dart';
import '../data/cart_page_data.dart';
import '../data/user_profile_api_data.dart';
import 'address_picker_page.dart';
import 'coupons_page.dart';
import 'widgets/user_page_shimmers.dart';

class CheckoutPage extends StatefulWidget {
  const CheckoutPage({super.key});

  @override
  State<CheckoutPage> createState() => _CheckoutPageState();
}

class _CheckoutPageState extends State<CheckoutPage> {
  bool acceptedTerms = true;
  int? selectedAddressId;
  bool requestedInitialData = false;

  @override
  Widget build(BuildContext context) {
    try {
      context.read<UserCubit>();
      return _buildWithCubit(context);
    } catch (_) {
      return BlocProvider(
        create: (_) => UserCubit(),
        child: Builder(builder: _buildWithCubit),
      );
    }
  }

  Widget _buildWithCubit(BuildContext context) {
    _requestInitialData(context);
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
          bottom: false,
          child: BlocConsumer<UserCubit, UserStates>(
            listener: (context, state) {
              if (state is UserCheckoutSuccessState) {
                _showOrderDoneDialog(context);
              } else if (state is UserCheckoutErrorState) {
                showToastError(text: state.message, context: context);
              } else if (state is UserCartErrorState) {
                showToastError(text: state.message, context: context);
              }
            },
            builder: (context, state) {
              final cubit = UserCubit.get(context);
              final cart = cubit.cartData;
              final profile = cubit.profileData;
              final addresses = profile?.addresses ?? const <UserAddressData>[];
              final selectedAddress = _selectedAddress(addresses);
              final loading =
                  (cart == null && state is UserCartLoadingState) ||
                  (profile == null && state is UserProfileLoadingState);
              final canConfirm =
                  acceptedTerms &&
                  selectedAddress != null &&
                  cart != null &&
                  !cart.isEmpty &&
                  state is! UserCheckoutLoadingState;

              return CustomScrollView(
                physics: const BouncingScrollPhysics(),
                slivers: [
                  const UserAppBarSliver(),
                  const SliverToBoxAdapter(child: SizedBox(height: 14)),
                  SliverToBoxAdapter(
                    child: _CheckoutStepper(
                      hasAddress: selectedAddress != null,
                    ),
                  ),
                  const SliverToBoxAdapter(child: SizedBox(height: 12)),
                  if (loading)
                    const CartPageShimmerSlivers()
                  else ...[
                    SliverToBoxAdapter(
                      child: _AddressCard(
                        address: selectedAddress,
                        hasAddresses: addresses.isNotEmpty,
                        onTap:
                            () => _showAddressSheet(
                              context: context,
                              addresses: addresses,
                            ),
                      ),
                    ),
                    const SliverToBoxAdapter(child: SizedBox(height: 12)),
                    const SliverToBoxAdapter(child: _PaymentCard()),
                    const SliverToBoxAdapter(child: SizedBox(height: 12)),
                    SliverToBoxAdapter(
                      child: _SummaryCard(
                        cart: cart,
                        onCouponTap: () => _pickCoupon(context),
                      ),
                    ),
                    // const SliverToBoxAdapter(child: SizedBox(height: 10)),
                    // SliverToBoxAdapter(
                    //   child: _TermsRow(
                    //     value: acceptedTerms,
                    //     onChanged:
                    //         (value) =>
                    //             setState(() => acceptedTerms = value ?? false),
                    //   ),
                    // ),
                    const SliverToBoxAdapter(child: SizedBox(height: 12)),
                    SliverToBoxAdapter(
                      child: _ConfirmButton(
                        total: cart?.summary.total ?? 0,
                        enabled: canConfirm,
                        loading: state is UserCheckoutLoadingState,
                        onTap: () {
                          final address = selectedAddress;
                          if (address == null) {
                            _showAddressSheet(
                              context: context,
                              addresses: addresses,
                            );
                            return;
                          }
                          cubit.confirmCheckout(addressId: address.id);
                        },
                      ),
                    ),
                    const SliverToBoxAdapter(child: SizedBox(height: 8)),
                    const SliverToBoxAdapter(child: _SecureNote()),
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

  void _requestInitialData(BuildContext context) {
    if (requestedInitialData) return;
    requestedInitialData = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final cubit = UserCubit.get(context);
      cubit.getCartData(refresh: true);
      cubit.getProfileData(refresh: true);
    });
  }

  UserAddressData? _selectedAddress(List<UserAddressData> addresses) {
    if (addresses.isEmpty) return null;
    for (final address in addresses) {
      if (address.id == selectedAddressId) return address;
    }
    for (final address in addresses) {
      if (address.isDefault) return address;
    }
    return addresses.first;
  }

  Future<void> _pickCoupon(BuildContext context) async {
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

  Future<void> _showAddressSheet({
    required BuildContext context,
    required List<UserAddressData> addresses,
  }) async {
    if (addresses.isEmpty) {
      await _openAddressPicker(context);
      return;
    }

    await showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
      ),
      builder:
          (sheetContext) => Directionality(
            textDirection: TextDirection.rtl,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'اختر عنوان التوصيل',
                    style: TextStyle(
                      color: Color(0xFF151B18),
                      fontSize: 14,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 10),
                  for (final address in addresses)
                    InkWell(
                      onTap: () {
                        setState(() => selectedAddressId = address.id);
                        navigateBack(sheetContext);
                      },
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 8),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 10,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF8FAF8),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: const Color(0xFFE8EAE8)),
                        ),
                        child: Row(
                          children: [
                            Icon(address.icon, color: address.color, size: 18),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Column(
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
                                  const SizedBox(height: 3),
                                  Text(
                                    address.details.isEmpty
                                        ? address.typeLabel
                                        : '${address.typeLabel} - ${address.details}',
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
                            if (_selectedAddress(addresses)?.id == address.id)
                              const Icon(
                                Icons.check_circle_rounded,
                                color: primaryColor,
                                size: 18,
                              ),
                          ],
                        ),
                      ),
                    ),
                  InkWell(
                    onTap: () async {
                      navigateBack(sheetContext);
                      await _openAddressPicker(context);
                    },
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      height: 42,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: primaryColor),
                      ),
                      child: const Text(
                        'إضافة عنوان جديد',
                        style: TextStyle(
                          color: primaryColor,
                          fontSize: 10,
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

  Future<void> _openAddressPicker(BuildContext context) async {
    final cubit = UserCubit.get(context);
    final result = await navigateToWithResult<UserAddressPickerResult>(
      context,
      const UserAddressPickerPage(),
    );
    if (result == null) return;
    await cubit.saveUserAddress(
      addressId: result.addressId,
      type: result.type,
      title: result.title,
      addressText: result.addressText,
      details: result.details,
      latitude: result.latitude,
      longitude: result.longitude,
    );
  }
}

class _CheckoutStepper extends StatelessWidget {
  const _CheckoutStepper({required this.hasAddress});

  final bool hasAddress;

  @override
  Widget build(BuildContext context) {
    final steps = [
      _StepData('العنوان', hasAddress, hasAddress ? '✓' : '1'),
      const _StepData('مراجعة الطلب', true, '✓'),
      const _StepData('الدفع', true, '✓'),
      const _StepData('تأكيد الطلب', false, '4'),
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 28),
      child: Row(
        children: [
          for (var i = 0; i < steps.length; i++) ...[
            Expanded(child: _StepItem(step: steps[i])),
            if (i != steps.length - 1)
              Expanded(
                child: Container(
                  height: 1,
                  margin: const EdgeInsets.only(bottom: 25),
                  color: const Color(0xFFE5E8E5),
                ),
              ),
          ],
        ],
      ),
    );
  }
}

class _StepData {
  const _StepData(this.title, this.done, this.value);

  final String title;
  final bool done;
  final String value;
}

class _StepItem extends StatelessWidget {
  const _StepItem({required this.step});

  final _StepData step;

  @override
  Widget build(BuildContext context) {
    final color = step.done ? primaryColor : secondaryColor;
    return Column(
      children: [
        Container(
          width: 24,
          height: 24,
          alignment: Alignment.center,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          child: Text(
            step.value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 10,
              fontWeight: FontWeight.w900,
            ),
          ),
        ),
        const SizedBox(height: 5),
        Text(
          step.title,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            color: Color(0xFF151B18),
            fontSize: 6,
            fontWeight: FontWeight.w900,
          ),
        ),
      ],
    );
  }
}

class _AddressCard extends StatelessWidget {
  const _AddressCard({
    required this.address,
    required this.hasAddresses,
    required this.onTap,
  });

  final UserAddressData? address;
  final bool hasAddresses;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final hasAddress = address != null;
    return _SectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _SectionTitle(
            title: 'عنوان التوصيل',
            icon: Icons.location_on_rounded,
            iconColor: secondaryColor,
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      hasAddress ? address!.addressText : 'ضع عنوانك',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Color(0xFF151B18),
                        fontSize: 12,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      hasAddress
                          ? address!.details
                          : 'حتى نعرف نوصل طلبك للمكان الصحيح',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Color(0xFF747D79),
                        fontSize: 8,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Text(
                      hasAddress ? address!.typeLabel : 'اختر موقعك من الخريطة',
                      style: const TextStyle(
                        color: Color(0xFF747D79),
                        fontSize: 9,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
              InkWell(
                onTap: onTap,
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  height: 36,
                  padding: const EdgeInsets.symmetric(horizontal: 14),
                  decoration: _outlineDecoration(const Color(0xFFE5E8E5)),
                  child: Row(
                    children: [
                      Text(
                        hasAddresses ? 'تغيير' : 'إضافة',
                        style: const TextStyle(
                          color: primaryColor,
                          fontSize: 9,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const SizedBox(width: 6),
                      const Icon(Iconsax.edit_2, color: primaryColor, size: 14),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Container(
            height: 30,
            decoration: BoxDecoration(
              color: const Color(0xFFF5F6F4),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.delivery_dining_rounded,
                  color: primaryColor,
                  size: 18,
                ),
                SizedBox(width: 8),
                Text(
                  'وقت التوصيل المتوقع:',
                  style: TextStyle(
                    color: Color(0xFF151B18),
                    fontSize: 9,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                SizedBox(width: 4),
                Text(
                  '25-35 دقيقة',
                  style: TextStyle(
                    color: secondaryColor,
                    fontSize: 9,
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

class _PaymentCard extends StatelessWidget {
  const _PaymentCard();

  @override
  Widget build(BuildContext context) {
    return const _SectionCard(
      child: Column(
        children: [
          _SectionTitle(
            title: 'طريقة الدفع',
            icon: Iconsax.wallet_3,
            iconColor: Color(0xFFF0A12A),
          ),
          SizedBox(height: 8),
          _PaymentOption(
            title: 'الدفع عند الاستلام',
            subtitle: 'ادفع كاش عند استلام الطلب',
            icon: Icons.payments_outlined,
            selected: true,
          ),
        ],
      ),
    );
  }
}

class _PaymentOption extends StatelessWidget {
  const _PaymentOption({
    required this.title,
    required this.subtitle,
    required this.icon,
    this.selected = false,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 50,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: selected ? const Color(0xFFF7FCF8) : Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: selected ? primaryColor : const Color(0xFFE8EAE8),
        ),
      ),
      child: Row(
        children: [
          Icon(
            icon,
            color: selected ? primaryColor : const Color(0xFF747D79),
            size: 22,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Color(0xFF151B18),
                    fontSize: 10,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  subtitle,
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
            width: 16,
            height: 16,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: selected ? primaryColor : const Color(0xFFD7DBD7),
              ),
            ),
            child:
                selected
                    ? Center(
                      child: Container(
                        width: 7,
                        height: 7,
                        decoration: const BoxDecoration(
                          color: primaryColor,
                          shape: BoxShape.circle,
                        ),
                      ),
                    )
                    : null,
          ),
        ],
      ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({required this.cart, required this.onCouponTap});

  final CartApiData? cart;
  final VoidCallback onCouponTap;

  @override
  Widget build(BuildContext context) {
    final summary = cart?.summary;
    final hasCoupon = (summary?.couponCode ?? '').isNotEmpty;
    return _SectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _SectionTitle(
            title: 'ملخص الطلب',
            icon: Iconsax.receipt_text,
            iconColor: Color(0xFFF0A12A),
          ),
          const SizedBox(height: 8),
          _SummaryRow(
            title: 'المجموع الفرعي (${summary?.itemsCount ?? 0} أصناف)',
            value: 'د.ع ${_formatPrice(summary?.subtotal ?? 0)}',
          ),
          const SizedBox(height: 4),
          _SummaryRow(
            title: 'رسوم التوصيل',
            value:
                (summary?.deliveryFee ?? 0) == 0
                    ? 'توصيل مجاني'
                    : 'د.ع ${_formatPrice(summary?.deliveryFee ?? 0)}',
            green: (summary?.deliveryFee ?? 0) == 0,
          ),
          const SizedBox(height: 4),
          _SummaryRow(
            title: 'خصم',
            value: 'د.ع -${_formatPrice(summary?.discountAmount ?? 0)}',
            orange: true,
          ),
          const SizedBox(height: 12),
          const Divider(height: 1, color: Color(0xFFF0F1EF)),
          const SizedBox(height: 8),
          _SummaryRow(
            title: 'الإجمالي',
            value: 'د.ع ${_formatPrice(summary?.total ?? 0)}',
            total: true,
          ),
          const Text(
            'شامل كل شيء',
            style: TextStyle(
              color: Color(0xFF9AA09D),
              fontSize: 8,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 14),
          InkWell(
            onTap: onCouponTap,
            borderRadius: BorderRadius.circular(12),
            child: Container(
              height: 44,
              padding: const EdgeInsets.symmetric(horizontal: 14),
              decoration: BoxDecoration(
                color: const Color(0xFFFFFCF8),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFFFD9AE)),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.local_offer_rounded,
                    color: secondaryColor,
                    size: 22,
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          hasCoupon ? 'الكوبون المطبق' : 'كود خصم',
                          style: const TextStyle(
                            color: Color(0xFF151B18),
                            fontSize: 10,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          hasCoupon ? summary!.couponCode! : 'اختر كوبون الخصم',
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
                    height: 32,
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    decoration: _outlineDecoration(const Color(0xFFE5E8E5)),
                    child: Center(
                      child: Text(
                        hasCoupon ? 'تغيير' : 'إضافة',
                        style: const TextStyle(
                          color: primaryColor,
                          fontSize: 9,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
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

class _TermsRow extends StatelessWidget {
  const _TermsRow({required this.value, required this.onChanged});

  final bool value;
  final ValueChanged<bool?> onChanged;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 28),
      child: InkWell(
        onTap: () => onChanged(!value),
        borderRadius: BorderRadius.circular(8),
        child: Row(
          children: [
            SizedBox(
              width: 18,
              height: 18,
              child: Checkbox(
                value: value,
                onChanged: onChanged,
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                visualDensity: VisualDensity.compact,
                side: const BorderSide(color: primaryColor, width: 1.2),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(5),
                ),
                activeColor: primaryColor,
                checkColor: Colors.white,
              ),
            ),
            const SizedBox(width: 8),
            const Expanded(
              child: Text(
                'أوافق على الشروط والأحكام وسياسة الخصوصية',
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

class _ConfirmButton extends StatelessWidget {
  const _ConfirmButton({
    required this.total,
    required this.enabled,
    required this.loading,
    required this.onTap,
  });

  final int total;
  final bool enabled;
  final bool loading;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 28),
      child: InkWell(
        onTap: enabled ? onTap : null,
        borderRadius: BorderRadius.circular(14),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          height: 44,
          decoration: BoxDecoration(
            color: enabled ? primaryColor : const Color(0xFFB8C0BB),
            borderRadius: BorderRadius.circular(14),
            boxShadow: [
              BoxShadow(
                color: primaryColor.withValues(alpha: enabled ? .18 : 0),
                blurRadius: 18,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child:
              loading
                  ? const Center(
                    child: SizedBox(
                      width: 19,
                      height: 19,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    ),
                  )
                  : Row(
                    children: [
                      const SizedBox(width: 18),
                      Text(
                        'د.ع ${_formatPrice(total)}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const Spacer(),
                      const Text(
                        'تأكيد الطلب',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const Spacer(),
                      const Icon(
                        Icons.arrow_forward_ios,
                        color: Colors.white,
                        size: 16,
                      ),
                      const SizedBox(width: 18),
                    ],
                  ),
        ),
      ),
    );
  }
}

class _SecureNote extends StatelessWidget {
  const _SecureNote();

  @override
  Widget build(BuildContext context) {
    return const Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.verified_user_rounded, color: primaryColor, size: 14),
        SizedBox(width: 5),
        Text(
          'طلبك آمن وموثوق 100%',
          style: TextStyle(
            color: primaryColor,
            fontSize: 8,
            fontWeight: FontWeight.w900,
          ),
        ),
      ],
    );
  }
}

class _SectionCard extends StatelessWidget {
  const _SectionCard({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.fromLTRB(14, 14, 14, 14),
        decoration: _softDecoration(radius: 18),
        child: child,
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({
    required this.title,
    required this.icon,
    required this.iconColor,
  });

  final String title;
  final IconData icon;
  final Color iconColor;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 26,
          height: 26,
          decoration: BoxDecoration(
            color: iconColor.withValues(alpha: .10),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: iconColor, size: 16),
        ),
        const SizedBox(width: 4),
        Text(
          title,
          style: const TextStyle(
            color: primaryColor,
            fontSize: 12,
            fontWeight: FontWeight.w900,
          ),
        ),
      ],
    );
  }
}

class _SummaryRow extends StatelessWidget {
  const _SummaryRow({
    required this.title,
    required this.value,
    this.green = false,
    this.orange = false,
    this.total = false,
  });

  final String title;
  final String value;
  final bool green;
  final bool orange;
  final bool total;

  @override
  Widget build(BuildContext context) {
    final valueColor =
        total || green
            ? primaryColor
            : orange
            ? secondaryColor
            : const Color(0xFF151B18);
    return Row(
      children: [
        Text(
          title,
          style: TextStyle(
            color: total ? const Color(0xFF151B18) : const Color(0xFF555D59),
            fontSize: total ? 13 : 10,
            fontWeight: total ? FontWeight.w900 : FontWeight.w700,
          ),
        ),
        const Spacer(),
        Text(
          value,
          style: TextStyle(
            color: valueColor,
            fontSize: total ? 16 : 10,
            fontWeight: FontWeight.w900,
          ),
        ),
      ],
    );
  }
}

Future<void> _showOrderDoneDialog(BuildContext context) async {
  await showDialog<void>(
    context: context,
    barrierDismissible: false,
    builder:
        (dialogContext) => Directionality(
          textDirection: TextDirection.rtl,
          child: AlertDialog(
            backgroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            contentPadding: const EdgeInsets.fromLTRB(22, 24, 22, 18),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TweenAnimationBuilder<double>(
                  tween: Tween(begin: .55, end: 1),
                  duration: const Duration(milliseconds: 420),
                  curve: Curves.elasticOut,
                  builder:
                      (_, value, child) =>
                          Transform.scale(scale: value, child: child),
                  child: Container(
                    width: 72,
                    height: 72,
                    decoration: BoxDecoration(
                      color: primaryColor.withValues(alpha: .10),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.check_circle_rounded,
                      color: primaryColor,
                      size: 54,
                    ),
                  ),
                ),
                const SizedBox(height: 14),
                const Text(
                  'تم تأكيد طلبك',
                  style: TextStyle(
                    color: Color(0xFF151B18),
                    fontSize: 16,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 6),
                const Text(
                  'نرسل طلبك للمطعم الآن، وتكدر تتابع حالته من صفحة طلباتي.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Color(0xFF747D79),
                    fontSize: 9,
                    fontWeight: FontWeight.w700,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 18),
                Row(
                  children: [
                    Expanded(
                      child: _DoneActionButton(
                        title: 'تتبع الطلب',
                        filled: true,
                        onTap: () {
                          navigateAndRemoveUntil(
                            dialogContext,
                            const BottomNavBar(initialIndex: 3),
                          );
                        },
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _DoneActionButton(
                        title: 'الرئيسية',
                        filled: false,
                        onTap: () {
                          navigateAndRemoveUntil(
                            dialogContext,
                            const BottomNavBar(initialIndex: 2),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
  );
}

class _DoneActionButton extends StatelessWidget {
  const _DoneActionButton({
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
      borderRadius: BorderRadius.circular(12),
      child: Container(
        height: 40,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: filled ? primaryColor : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: primaryColor),
        ),
        child: Text(
          title,
          style: TextStyle(
            color: filled ? Colors.white : primaryColor,
            fontSize: 10,
            fontWeight: FontWeight.w900,
          ),
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
        color: Colors.black.withValues(alpha: .06),
        blurRadius: 14,
        offset: const Offset(0, 7),
      ),
    ],
  );
}

BoxDecoration _outlineDecoration(Color color) {
  return BoxDecoration(
    color: Colors.white,
    borderRadius: BorderRadius.circular(12),
    border: Border.all(color: color),
  );
}

String _formatPrice(int price) {
  final value = price.toString();
  return value.replaceAllMapped(RegExp(r'\B(?=(\d{3})+(?!\d))'), (_) => ',');
}
