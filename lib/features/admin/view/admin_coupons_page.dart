import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:iconsax/iconsax.dart';

import '../../../core/ navigation/navigation.dart';
import '../../../core/styles/themes.dart';
import '../../../core/widgets/show_toast.dart';
import '../../restaurant/view/widgets/restaurant_ui_widgets.dart';
import '../cubit/admin_cubit.dart';
import '../cubit/admin_states.dart';
import '../model/admin_coupon_model.dart';
import '../model/admin_restaurant_model.dart';

class AdminCouponsPage extends StatefulWidget {
  const AdminCouponsPage({super.key});

  @override
  State<AdminCouponsPage> createState() => _AdminCouponsPageState();
}

class _AdminCouponsPageState extends State<AdminCouponsPage> {
  bool loaded = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!loaded) {
      loaded = true;
      context.read<AdminCubit>().loadCoupons();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
          bottom: false,
          child: BlocConsumer<AdminCubit, AdminState>(
            listener: (context, state) {
              if (state is AdminCouponsErrorState) {
                showToastError(text: state.message, context: context);
              }
            },
            builder: (context, state) {
              final cubit = context.read<AdminCubit>();
              final loading = state is AdminCouponsLoadingState;
              return CustomScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                slivers: [
                  const RestaurantHeaderSliver(title: 'إدارة الكوبونات'),
                  const SliverToBoxAdapter(child: SizedBox(height: 14)),
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 14),
                      child: Row(
                        children: [
                          Expanded(
                            child: _ActionButton(
                              text: 'إضافة كوبون',
                              icon: Iconsax.ticket_discount,
                              onTap: () => _showCouponSheet(context),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: _ActionButton(
                              text: 'إضافة قسم',
                              icon: Iconsax.category,
                              onTap: () => _showCouponCategorySheet(context),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SliverToBoxAdapter(child: SizedBox(height: 12)),
                  SliverToBoxAdapter(
                    child: RestaurantSectionHeader(
                      title: 'الكوبونات',
                      icon: Iconsax.ticket_discount,
                      count: cubit.coupons.length,
                    ),
                  ),
                  const SliverToBoxAdapter(child: SizedBox(height: 8)),
                  if (loading && cubit.coupons.isEmpty)
                    const SliverFillRemaining(
                      hasScrollBody: false,
                      child: Center(
                        child: CircularProgressIndicator(color: primaryColor),
                      ),
                    )
                  else if (cubit.coupons.isEmpty)
                    const SliverFillRemaining(
                      hasScrollBody: false,
                      child: Center(
                        child: Text(
                          'لا توجد كوبونات حالياً',
                          style: TextStyle(
                            color: Color(0xFF747D79),
                            fontSize: 12,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                    )
                  else
                    SliverList.separated(
                      itemBuilder: (context, index) {
                        final coupon = cubit.coupons[index];
                        return Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 14),
                          child: _CouponAdminCard(coupon: coupon),
                        );
                      },
                      separatorBuilder: (_, __) => const SizedBox(height: 8),
                      itemCount: cubit.coupons.length,
                    ),
                  const SliverToBoxAdapter(child: SizedBox(height: 94)),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

class _CouponAdminCard extends StatelessWidget {
  const _CouponAdminCard({required this.coupon});

  final AdminCouponModel coupon;

  @override
  Widget build(BuildContext context) {
    final color = coupon.isActive ? primaryColor : const Color(0xFF8A8F8D);
    return Container(
      height: 94,
      padding: const EdgeInsets.all(10),
      decoration: restaurantSoftDecoration(radius: 18),
      child: Row(
        children: [
          Container(
            width: 54,
            height: 54,
            decoration: BoxDecoration(
              color: color.withValues(alpha: .10),
              borderRadius: BorderRadius.circular(15),
            ),
            child: Icon(Iconsax.ticket_discount, color: color, size: 24),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  '${coupon.title}  ·  ${coupon.code}',
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
                  '${coupon.typeLabel} ${coupon.valueText} · ${coupon.targetLabel}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Color(0xFF747D79),
                    fontSize: 8,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 7),
                Wrap(
                  spacing: 6,
                  runSpacing: 4,
                  children: [
                    RestaurantStatusPill(
                      text: coupon.isActive ? 'فعال' : 'متوقف',
                      color: color,
                    ),
                    RestaurantStatusPill(
                      text: 'استخدم ${coupon.usedCount}',
                      color: secondaryColor,
                    ),
                    RestaurantStatusPill(
                      text: coupon.categoryName,
                      color: primaryColor,
                    ),
                  ],
                ),
              ],
            ),
          ),
          RestaurantIconAction(
            icon: Iconsax.refresh,
            color: primaryColor,
            onTap:
                () => context.read<AdminCubit>().updateCoupon(
                  couponId: coupon.id,
                  fields: {'isActive': !coupon.isActive},
                ),
          ),
          RestaurantIconAction(
            icon: Iconsax.edit_2,
            color: secondaryColor,
            onTap: () => _showCouponSheet(context, coupon: coupon),
          ),
          RestaurantIconAction(
            icon: Iconsax.trash,
            color: const Color(0xFFE34B4B),
            onTap:
                () => showRestaurantDeleteDialog(
                  context: context,
                  title: 'حذف الكوبون؟',
                  message: 'راح ينحذف الكوبون نهائياً من التطبيق.',
                  onConfirm:
                      () => context.read<AdminCubit>().deleteCoupon(coupon.id),
                ),
          ),
        ],
      ),
    );
  }
}

Future<void> _showCouponCategorySheet(BuildContext context) {
  final name = TextEditingController();
  return showRestaurantSheet(
    context: context,
    title: 'إضافة قسم كوبونات',
    icon: Iconsax.category,
    children: [
      RestaurantSheetTextField(
        controller: name,
        label: 'اسم القسم',
        icon: Iconsax.category,
      ),
    ],
    buttonText: 'إضافة',
    onSubmit: () {
      context.read<AdminCubit>().createCouponCategory(name: name.text);
      navigateBack(context);
    },
  );
}

Future<void> _showCouponSheet(
  BuildContext context, {
  AdminCouponModel? coupon,
}) {
  final cubit = context.read<AdminCubit>();
  final code = TextEditingController(text: coupon?.code ?? '');
  final title = TextEditingController(text: coupon?.title ?? '');
  final description = TextEditingController(text: coupon?.description ?? '');
  final value = TextEditingController(text: coupon?.value.toString() ?? '0');
  final minimumOrder = TextEditingController(
    text: coupon?.minimumOrder.toString() ?? '0',
  );
  final maxDiscount = TextEditingController(
    text: coupon?.maxDiscount?.toString() ?? '',
  );
  final totalUsageLimit = TextEditingController(
    text: coupon?.totalUsageLimit?.toString() ?? '',
  );
  final perUserLimit = TextEditingController(
    text: coupon?.perUserLimit.toString() ?? '1',
  );
  final startsAt = TextEditingController(text: coupon?.startsAt ?? '');
  final expiresAt = TextEditingController(text: coupon?.expiresAt ?? '');

  var type = coupon?.type ?? 'free_delivery';
  var target = coupon?.target ?? 'all';
  var isActive = coupon?.isActive ?? true;
  int? categoryId =
      coupon?.categoryId ??
      (cubit.couponCategories.isEmpty ? null : cubit.couponCategories.first.id);
  int? restaurantId = coupon?.restaurantId;

  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (sheetContext) {
      return Directionality(
        textDirection: TextDirection.rtl,
        child: StatefulBuilder(
          builder: (context, setSheetState) {
            return Padding(
              padding: EdgeInsets.only(
                left: 14,
                right: 14,
                bottom: MediaQuery.of(context).viewInsets.bottom + 14,
              ),
              child: Container(
                constraints: BoxConstraints(
                  maxHeight: MediaQuery.of(context).size.height * .88,
                ),
                padding: const EdgeInsets.fromLTRB(14, 14, 14, 16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(22),
                ),
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _SheetTitle(
                        title: coupon == null ? 'إضافة كوبون' : 'تعديل كوبون',
                        icon: Iconsax.ticket_discount,
                      ),
                      const SizedBox(height: 14),
                      RestaurantSheetTextField(
                        controller: title,
                        label: 'عنوان الكوبون',
                        icon: Iconsax.edit_2,
                      ),
                      const SizedBox(height: 8),
                      RestaurantSheetTextField(
                        controller: code,
                        label: 'الكود',
                        icon: Iconsax.copy,
                      ),
                      const SizedBox(height: 8),
                      _DropdownField(
                        icon: Iconsax.ticket_discount,
                        value: type,
                        items: const {
                          'free_delivery': 'توصيل مجاني',
                          'percentage': 'خصم نسبة',
                          'fixed': 'خصم ثابت',
                        },
                        onChanged: (value) {
                          if (value != null) setSheetState(() => type = value);
                        },
                      ),
                      const SizedBox(height: 8),
                      if (type != 'free_delivery')
                        RestaurantSheetTextField(
                          controller: value,
                          label: type == 'percentage' ? 'النسبة' : 'قيمة الخصم',
                          icon: Iconsax.discount_shape,
                          keyboardType: TextInputType.number,
                        ),
                      if (type != 'free_delivery') const SizedBox(height: 8),
                      _DropdownField(
                        icon: Iconsax.global,
                        value: target,
                        items: const {
                          'all': 'كل المطاعم',
                          'restaurant': 'مطعم معين',
                        },
                        onChanged: (value) {
                          if (value == null) return;
                          setSheetState(() {
                            target = value;
                            if (target == 'all') restaurantId = null;
                          });
                        },
                      ),
                      if (target == 'restaurant') ...[
                        const SizedBox(height: 8),
                        _RestaurantDropdown(
                          restaurants: cubit.restaurants,
                          value: restaurantId,
                          onChanged:
                              (value) =>
                                  setSheetState(() => restaurantId = value),
                        ),
                      ],
                      const SizedBox(height: 8),
                      _CategoryDropdown(
                        categories: cubit.couponCategories,
                        value: categoryId,
                        onChanged:
                            (value) => setSheetState(() => categoryId = value),
                      ),
                      const SizedBox(height: 8),
                      RestaurantSheetTextField(
                        controller: minimumOrder,
                        label: 'الحد الأدنى للطلب',
                        icon: Iconsax.receipt,
                        keyboardType: TextInputType.number,
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Expanded(
                            child: RestaurantSheetTextField(
                              controller: maxDiscount,
                              label: 'أعلى خصم',
                              icon: Iconsax.money_4,
                              keyboardType: TextInputType.number,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: RestaurantSheetTextField(
                              controller: perUserLimit,
                              label: 'لكل مستخدم',
                              icon: Iconsax.user,
                              keyboardType: TextInputType.number,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      RestaurantSheetTextField(
                        controller: totalUsageLimit,
                        label: 'عدد الاستخدامات الكلي',
                        icon: Iconsax.chart,
                        keyboardType: TextInputType.number,
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Expanded(
                            child: RestaurantSheetTextField(
                              controller: startsAt,
                              label: 'يبدأ yyyy-mm-dd',
                              icon: Iconsax.calendar,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: RestaurantSheetTextField(
                              controller: expiresAt,
                              label: 'ينتهي yyyy-mm-dd',
                              icon: Iconsax.calendar,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      RestaurantSheetTextField(
                        controller: description,
                        label: 'الوصف',
                        icon: Iconsax.note,
                        height: 76,
                        maxLines: 3,
                      ),
                      const SizedBox(height: 8),
                      SwitchListTile(
                        value: isActive,
                        activeColor: primaryColor,
                        contentPadding: EdgeInsets.zero,
                        title: const Text(
                          'الكوبون فعال',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        onChanged:
                            (value) => setSheetState(() => isActive = value),
                      ),
                      const SizedBox(height: 12),
                      _ActionButton(
                        text: coupon == null ? 'إضافة الكوبون' : 'حفظ التعديل',
                        icon: Iconsax.tick_circle,
                        onTap: () {
                          if (title.text.trim().isEmpty ||
                              code.text.trim().isEmpty ||
                              (target == 'restaurant' &&
                                  restaurantId == null)) {
                            showToastInfo(
                              text: 'أكمل بيانات الكوبون المطلوبة',
                              context: context,
                            );
                            return;
                          }

                          final fields = _couponFields(
                            code: code.text,
                            title: title.text,
                            description: description.text,
                            type: type,
                            value: value.text,
                            minimumOrder: minimumOrder.text,
                            maxDiscount: maxDiscount.text,
                            totalUsageLimit: totalUsageLimit.text,
                            perUserLimit: perUserLimit.text,
                            startsAt: startsAt.text,
                            expiresAt: expiresAt.text,
                            target: target,
                            restaurantId: restaurantId,
                            categoryId: categoryId,
                            isActive: isActive,
                          );

                          if (coupon == null) {
                            cubit.createCoupon(fields);
                          } else {
                            cubit.updateCoupon(
                              couponId: coupon.id,
                              fields: fields,
                            );
                          }
                          navigateBack(context);
                        },
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      );
    },
  );
}

class _DropdownField extends StatelessWidget {
  const _DropdownField({
    required this.icon,
    required this.value,
    required this.items,
    required this.onChanged,
  });

  final IconData icon;
  final String value;
  final Map<String, String> items;
  final ValueChanged<String?> onChanged;

  @override
  Widget build(BuildContext context) {
    return _BaseDropdown(
      icon: icon,
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          isExpanded: true,
          items:
              items.entries
                  .map(
                    (entry) => DropdownMenuItem(
                      value: entry.key,
                      child: Text(entry.value),
                    ),
                  )
                  .toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }
}

class _RestaurantDropdown extends StatelessWidget {
  const _RestaurantDropdown({
    required this.restaurants,
    required this.value,
    required this.onChanged,
  });

  final List<AdminRestaurantModel> restaurants;
  final int? value;
  final ValueChanged<int?> onChanged;

  @override
  Widget build(BuildContext context) {
    return _BaseDropdown(
      icon: Iconsax.shop,
      child: DropdownButtonHideUnderline(
        child: DropdownButton<int?>(
          value: value,
          isExpanded: true,
          hint: const Text('اختر المطعم'),
          items:
              restaurants
                  .map(
                    (restaurant) => DropdownMenuItem<int?>(
                      value: restaurant.id,
                      child: Text(restaurant.name),
                    ),
                  )
                  .toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }
}

class _CategoryDropdown extends StatelessWidget {
  const _CategoryDropdown({
    required this.categories,
    required this.value,
    required this.onChanged,
  });

  final List<AdminCouponCategoryModel> categories;
  final int? value;
  final ValueChanged<int?> onChanged;

  @override
  Widget build(BuildContext context) {
    return _BaseDropdown(
      icon: Iconsax.category,
      child: DropdownButtonHideUnderline(
        child: DropdownButton<int?>(
          value: value,
          isExpanded: true,
          hint: const Text('قسم الكوبون'),
          items:
              categories
                  .map(
                    (category) => DropdownMenuItem<int?>(
                      value: category.id,
                      child: Text(category.name),
                    ),
                  )
                  .toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }
}

class _BaseDropdown extends StatelessWidget {
  const _BaseDropdown({required this.icon, required this.child});

  final IconData icon;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 44,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFE3E5E6)),
      ),
      child: Row(
        children: [
          Icon(icon, color: primaryColor, size: 19),
          const SizedBox(width: 8),
          Expanded(child: child),
        ],
      ),
    );
  }
}

class _SheetTitle extends StatelessWidget {
  const _SheetTitle({required this.title, required this.icon});

  final String title;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Row(
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
    );
  }
}

class _ActionButton extends StatelessWidget {
  const _ActionButton({
    required this.text,
    required this.icon,
    required this.onTap,
  });

  final String text;
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        height: 42,
        decoration: BoxDecoration(
          color: primaryColor,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: Colors.white, size: 18),
            const SizedBox(width: 8),
            Text(
              text,
              style: const TextStyle(
                color: Colors.white,
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

Map<String, dynamic> _couponFields({
  required String code,
  required String title,
  required String description,
  required String type,
  required String value,
  required String minimumOrder,
  required String maxDiscount,
  required String totalUsageLimit,
  required String perUserLimit,
  required String startsAt,
  required String expiresAt,
  required String target,
  required int? restaurantId,
  required int? categoryId,
  required bool isActive,
}) {
  return {
    'code': code.trim().toUpperCase(),
    'title': title.trim(),
    'description': description.trim(),
    'type': type,
    'value': type == 'free_delivery' ? 0 : _asNumber(value),
    'minimumOrder': _asNumber(minimumOrder),
    'maxDiscount': maxDiscount.trim().isEmpty ? null : _asNumber(maxDiscount),
    'totalUsageLimit':
        totalUsageLimit.trim().isEmpty ? null : _asNumber(totalUsageLimit),
    'perUserLimit': _asNumber(perUserLimit, fallback: 1),
    'startsAt': startsAt.trim().isEmpty ? null : startsAt.trim(),
    'expiresAt': expiresAt.trim().isEmpty ? null : expiresAt.trim(),
    'target': target,
    'restaurantId': target == 'restaurant' ? restaurantId : null,
    'couponCategoryId': categoryId,
    'isActive': isActive,
  };
}

num _asNumber(String value, {num fallback = 0}) {
  return num.tryParse(value.trim().replaceAll(',', '.')) ?? fallback;
}
