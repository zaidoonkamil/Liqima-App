import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:iconsax/iconsax.dart';

import '../../../core/ navigation/navigation.dart';
import '../../../core/styles/themes.dart';
import '../../../core/widgets/show_toast.dart';
import '../../restaurant/view/widgets/restaurant_ui_widgets.dart';
import '../cubit/admin_cubit.dart';
import '../cubit/admin_states.dart';
import '../model/admin_restaurant_model.dart';
import 'admin_location_picker_page.dart';

class AdminRestaurantsPage extends StatefulWidget {
  const AdminRestaurantsPage({super.key});

  @override
  State<AdminRestaurantsPage> createState() => _AdminRestaurantsPageState();
}

class _AdminRestaurantsPageState extends State<AdminRestaurantsPage> {
  bool _loaded = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_loaded) {
      _loaded = true;
      context.read<AdminCubit>().loadRestaurants();
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
              if (state is AdminRestaurantsErrorState) {
                showToastError(text: state.message, context: context);
              }
            },
            builder: (context, state) {
              final cubit = context.read<AdminCubit>();
              final isLoading = state is AdminRestaurantsLoadingState;

              return CustomScrollView(
                physics: const BouncingScrollPhysics(
                  parent: AlwaysScrollableScrollPhysics(),
                ),
                slivers: [
                  const RestaurantHeaderSliver(title: 'إدارة المطاعم'),
                  const SliverToBoxAdapter(child: SizedBox(height: 14)),
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 14),
                      child: _PrimaryActionButton(
                        text: 'إضافة مطعم',
                        icon: Iconsax.shop_add,
                        onTap: () => _showRestaurantForm(context),
                      ),
                    ),
                  ),
                  const SliverToBoxAdapter(child: SizedBox(height: 12)),
                  SliverToBoxAdapter(
                    child: RestaurantSectionHeader(
                      title: 'المطاعم المضافة',
                      icon: Iconsax.shop,
                      count: cubit.restaurants.length,
                    ),
                  ),
                  const SliverToBoxAdapter(child: SizedBox(height: 8)),
                  if (isLoading && cubit.restaurants.isEmpty)
                    const SliverFillRemaining(
                      hasScrollBody: false,
                      child: Center(
                        child: CircularProgressIndicator(color: primaryColor),
                      ),
                    )
                  else if (cubit.restaurants.isEmpty)
                    const SliverFillRemaining(
                      hasScrollBody: false,
                      child: Center(
                        child: Text(
                          'لا توجد مطاعم حالياً',
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
                        final restaurant = cubit.restaurants[index];
                        return Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 14),
                          child: _RestaurantAdminCard(restaurant: restaurant),
                        );
                      },
                      separatorBuilder: (_, __) => const SizedBox(height: 8),
                      itemCount: cubit.restaurants.length,
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

class _RestaurantAdminCard extends StatelessWidget {
  const _RestaurantAdminCard({required this.restaurant});

  final AdminRestaurantModel restaurant;

  @override
  Widget build(BuildContext context) {
    final image = restaurant.coverImage ?? restaurant.logo;
    return Container(
      height: 122,
      decoration: restaurantSoftDecoration(radius: 18),
      padding: const EdgeInsets.all(10),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(14),
            child:
                image == null
                    ? Container(
                      width: 94,
                      height: 82,
                      color: primaryColor.withValues(alpha: .10),
                      child: const Icon(Iconsax.shop, color: primaryColor),
                    )
                    : Image.network(
                      image,
                      width: 94,
                      height: 82,
                      fit: BoxFit.cover,
                    ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  restaurant.name,
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
                  restaurant.cuisineText.isEmpty
                      ? restaurant.description
                      : restaurant.cuisineText,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Color(0xFF747D79),
                    fontSize: 8,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 6),
                Wrap(
                  spacing: 6,
                  runSpacing: 4,
                  children: [
                    RestaurantStatusPill(
                      text: _statusLabel(restaurant.status),
                      color:
                          restaurant.status == 'active'
                              ? primaryColor
                              : const Color(0xFFFF9517),
                    ),
                    RestaurantStatusPill(
                      text: restaurant.freeDelivery ? 'توصيل مجاني' : 'مدفوع',
                      color: secondaryColor,
                    ),
                  ],
                ),
                const SizedBox(height: 5),
                Text(
                  restaurant.phone,
                  textDirection: TextDirection.ltr,
                  style: const TextStyle(
                    color: Color(0xFF555D59),
                    fontSize: 9,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
          ),
          RestaurantIconAction(
            icon: Iconsax.edit_2,
            color: secondaryColor,
            onTap: () => _showRestaurantForm(context, restaurant: restaurant),
          ),
        ],
      ),
    );
  }
}

class _PrimaryActionButton extends StatelessWidget {
  const _PrimaryActionButton({
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

Future<void> _showRestaurantForm(
  BuildContext context, {
  AdminRestaurantModel? restaurant,
}) {
  final adminCubit = context.read<AdminCubit>();
  final isEdit = restaurant != null;
  final name = TextEditingController(text: restaurant?.name ?? '');
  final phone = TextEditingController(text: restaurant?.phone ?? '');
  final password = TextEditingController();
  final description = TextEditingController(
    text: restaurant?.description ?? '',
  );
  final address = TextEditingController(text: restaurant?.address ?? '');
  final area = TextEditingController(text: restaurant?.area ?? '');
  final latitude = TextEditingController(text: restaurant?.latitude ?? '');
  final longitude = TextEditingController(text: restaurant?.longitude ?? '');
  final cuisines = TextEditingController(
    text: restaurant?.cuisineTypes.join(', ') ?? '',
  );
  final deliveryMin = TextEditingController(
    text: isEdit ? restaurant.deliveryTimeMin.toString() : '25',
  );
  final deliveryMax = TextEditingController(
    text: isEdit ? restaurant.deliveryTimeMax.toString() : '35',
  );
  final freeDeliveryDistanceKm = TextEditingController(
    text: isEdit ? restaurant.freeDeliveryDistanceKm.toStringAsFixed(1) : '5',
  );
  final deliveryPricePerKm = TextEditingController(
    text: isEdit ? restaurant.deliveryPricePerKm.toString() : '0',
  );
  final appDeliveryFee = TextEditingController(
    text: isEdit ? restaurant.appDeliveryFee.toString() : '0',
  );
  final minimumOrder = TextEditingController(
    text: isEdit ? restaurant.minimumOrder.toString() : '15000',
  );
  final discountPercent = TextEditingController(
    text: isEdit ? restaurant.discountPercent.toString() : '0',
  );
  final discountMinOrder = TextEditingController(
    text: isEdit ? restaurant.discountMinOrder.toString() : '0',
  );
  final rating = TextEditingController(
    text: isEdit ? restaurant.rating.toStringAsFixed(1) : '0',
  );
  final ratingsCount = TextEditingController(
    text: isEdit ? restaurant.ratingsCount.toString() : '0',
  );
  final openingTime = TextEditingController(
    text: restaurant?.openingTime ?? '',
  );
  final closingTime = TextEditingController(
    text: restaurant?.closingTime ?? '',
  );

  String? logoPath;
  String? coverPath;
  var status = restaurant?.status ?? 'active';
  var isOpen = restaurant?.isOpen ?? true;
  var freeDelivery = restaurant?.freeDelivery ?? false;
  var isFeatured = restaurant?.isFeatured ?? false;

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
                        title: isEdit ? 'تعديل مطعم' : 'إضافة مطعم',
                        icon: Iconsax.shop,
                      ),
                      const SizedBox(height: 14),
                      RestaurantSheetTextField(
                        controller: name,
                        label: 'اسم المطعم',
                        icon: Iconsax.shop,
                      ),
                      const SizedBox(height: 8),
                      RestaurantSheetTextField(
                        controller: phone,
                        label: 'رقم الهاتف',
                        icon: Iconsax.call,
                        keyboardType: TextInputType.phone,
                      ),
                      const SizedBox(height: 8),
                      RestaurantSheetTextField(
                        controller: password,
                        label:
                            isEdit
                                ? 'كلمة مرور جديدة (اختياري)'
                                : 'كلمة المرور',
                        icon: Iconsax.lock,
                      ),
                      const SizedBox(height: 8),
                      RestaurantImagePickerField(
                        label: isEdit ? 'تغيير شعار المطعم' : 'شعار المطعم',
                        onChanged: (path) => logoPath = path,
                      ),
                      const SizedBox(height: 8),
                      RestaurantImagePickerField(
                        label: isEdit ? 'تغيير صورة الغلاف' : 'صورة الغلاف',
                        onChanged: (path) => coverPath = path,
                      ),
                      const SizedBox(height: 8),
                      RestaurantSheetTextField(
                        controller: description,
                        label: 'وصف المطعم',
                        icon: Iconsax.note,
                        height: 76,
                        maxLines: 3,
                      ),
                      const SizedBox(height: 8),
                      RestaurantSheetTextField(
                        controller: cuisines,
                        label: 'أنواع الأكل، مثال: شاورما، عربي',
                        icon: Iconsax.reserve,
                      ),
                      const SizedBox(height: 8),
                      RestaurantSheetTextField(
                        controller: address,
                        label: 'العنوان',
                        icon: Iconsax.location,
                      ),
                      const SizedBox(height: 8),
                      RestaurantSheetTextField(
                        controller: area,
                        label: 'المنطقة',
                        icon: Iconsax.map,
                      ),
                      const SizedBox(height: 8),
                      _LocationPickerField(
                        latitude: latitude.text,
                        longitude: longitude.text,
                        onTap: () async {
                          final result =
                              await navigateToWithResult<AdminLocationResult>(
                                context,
                                AdminLocationPickerPage(
                                  initialLatitude: double.tryParse(
                                    latitude.text.trim(),
                                  ),
                                  initialLongitude: double.tryParse(
                                    longitude.text.trim(),
                                  ),
                                ),
                              );
                          if (result == null) return;
                          setSheetState(() {
                            latitude.text = result.latitude.toStringAsFixed(7);
                            longitude.text = result.longitude.toStringAsFixed(
                              7,
                            );
                          });
                        },
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Expanded(
                            child: RestaurantSheetTextField(
                              controller: deliveryMin,
                              label: 'أقل وقت',
                              icon: Iconsax.timer,
                              keyboardType: TextInputType.number,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: RestaurantSheetTextField(
                              controller: deliveryMax,
                              label: 'أعلى وقت',
                              icon: Iconsax.timer,
                              keyboardType: TextInputType.number,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Expanded(
                            child: RestaurantSheetTextField(
                              controller: freeDeliveryDistanceKm,
                              label: 'حد التوصيل المجاني كم',
                              icon: Iconsax.routing,
                              keyboardType: TextInputType.number,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: RestaurantSheetTextField(
                              controller: deliveryPricePerKm,
                              label: 'سعر الكيلومتر',
                              icon: Iconsax.money_4,
                              keyboardType: TextInputType.number,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Expanded(
                            child: RestaurantSheetTextField(
                              controller: appDeliveryFee,
                              label: 'رسوم التطبيق للتوصيل',
                              icon: Iconsax.money_4,
                              keyboardType: TextInputType.number,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: RestaurantSheetTextField(
                              controller: minimumOrder,
                              label: 'الحد الأدنى',
                              icon: Iconsax.receipt,
                              keyboardType: TextInputType.number,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Expanded(
                            child: RestaurantSheetTextField(
                              controller: discountPercent,
                              label: 'نسبة الخصم',
                              icon: Iconsax.discount_shape,
                              keyboardType: TextInputType.number,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: RestaurantSheetTextField(
                              controller: discountMinOrder,
                              label: 'حد الخصم',
                              icon: Iconsax.discount_circle,
                              keyboardType: TextInputType.number,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Expanded(
                            child: RestaurantSheetTextField(
                              controller: rating,
                              label: 'تقييم المطعم',
                              icon: Iconsax.star1,
                              keyboardType: TextInputType.number,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: RestaurantSheetTextField(
                              controller: ratingsCount,
                              label: 'عدد التقييمات',
                              icon: Iconsax.message_question,
                              keyboardType: TextInputType.number,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Expanded(
                            child: RestaurantSheetTextField(
                              controller: openingTime,
                              label: 'يفتح',
                              icon: Iconsax.clock,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: RestaurantSheetTextField(
                              controller: closingTime,
                              label: 'يغلق',
                              icon: Iconsax.clock,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      _StatusDropdown(
                        value: status,
                        onChanged: (value) {
                          if (value != null) {
                            setSheetState(() => status = value);
                          }
                        },
                      ),
                      const SizedBox(height: 8),
                      _SwitchRow(
                        title: 'المطعم مفتوح',
                        value: isOpen,
                        onChanged:
                            (value) => setSheetState(() => isOpen = value),
                      ),
                      _SwitchRow(
                        title: 'توصيل مجاني',
                        value: freeDelivery,
                        onChanged:
                            (value) =>
                                setSheetState(() => freeDelivery = value),
                      ),
                      _SwitchRow(
                        title: 'مطعم مميز',
                        value: isFeatured,
                        onChanged:
                            (value) => setSheetState(() => isFeatured = value),
                      ),
                      const SizedBox(height: 12),
                      _PrimaryActionButton(
                        text: isEdit ? 'حفظ التعديل' : 'إضافة المطعم',
                        icon: Iconsax.tick_circle,
                        onTap: () {
                          if (name.text.trim().isEmpty ||
                              phone.text.trim().isEmpty ||
                              (!isEdit && password.text.trim().isEmpty) ||
                              (!isEdit && logoPath == null)) {
                            showToastInfo(
                              text:
                                  'أكمل اسم المطعم، الهاتف، كلمة المرور والشعار',
                              context: context,
                            );
                            return;
                          }

                          final fields = _restaurantFields(
                            name: name.text,
                            phone: phone.text,
                            password: password.text,
                            description: description.text,
                            address: address.text,
                            area: area.text,
                            latitude: latitude.text,
                            longitude: longitude.text,
                            cuisines: cuisines.text,
                            deliveryMin: deliveryMin.text,
                            deliveryMax: deliveryMax.text,
                            deliveryFee: appDeliveryFee.text,
                            freeDeliveryDistanceKm: freeDeliveryDistanceKm.text,
                            deliveryPricePerKm: deliveryPricePerKm.text,
                            appDeliveryFee: appDeliveryFee.text,
                            minimumOrder: minimumOrder.text,
                            discountPercent: discountPercent.text,
                            discountMinOrder: discountMinOrder.text,
                            rating: rating.text,
                            ratingsCount: ratingsCount.text,
                            openingTime: openingTime.text,
                            closingTime: closingTime.text,
                            status: status,
                            isOpen: isOpen,
                            freeDelivery: freeDelivery,
                            isFeatured: isFeatured,
                          );

                          if (isEdit) {
                            adminCubit.updateRestaurant(
                              restaurantId: restaurant.id,
                              fields: fields,
                              logoPath: logoPath,
                              coverPath: coverPath,
                            );
                          } else {
                            adminCubit.createRestaurant(
                              fields: fields,
                              logoPath: logoPath!,
                              coverPath: coverPath,
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

class _SwitchRow extends StatelessWidget {
  const _SwitchRow({
    required this.title,
    required this.value,
    required this.onChanged,
  });

  final String title;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 38,
      child: Row(
        children: [
          Text(
            title,
            style: const TextStyle(
              color: Color(0xFF151B18),
              fontSize: 11,
              fontWeight: FontWeight.w800,
            ),
          ),
          const Spacer(),
          Switch(value: value, activeColor: primaryColor, onChanged: onChanged),
        ],
      ),
    );
  }
}

class _LocationPickerField extends StatelessWidget {
  const _LocationPickerField({
    required this.latitude,
    required this.longitude,
    required this.onTap,
  });

  final String latitude;
  final String longitude;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final hasLocation =
        latitude.trim().isNotEmpty && longitude.trim().isNotEmpty;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        height: 48,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: const Color(0xFFE3E5E6)),
        ),
        child: Row(
          children: [
            const Icon(Iconsax.map_1, color: primaryColor, size: 19),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    'تحديد موقع المطعم على الخريطة',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: Color(0xFF151B18),
                      fontSize: 10,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    hasLocation
                        ? '$latitude, $longitude'
                        : 'اضغط لاختيار الموقع',
                    textDirection:
                        hasLocation ? TextDirection.ltr : TextDirection.rtl,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Color(0xFF8E9295),
                      fontSize: 8,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
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

class _StatusDropdown extends StatelessWidget {
  const _StatusDropdown({required this.value, required this.onChanged});

  final String value;
  final ValueChanged<String?> onChanged;

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
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          isExpanded: true,
          icon: const Icon(Icons.keyboard_arrow_down_rounded, size: 18),
          items: const [
            DropdownMenuItem(value: 'active', child: Text('فعال')),
            DropdownMenuItem(value: 'pending', child: Text('قيد المراجعة')),
            DropdownMenuItem(value: 'blocked', child: Text('محظور')),
          ],
          onChanged: onChanged,
        ),
      ),
    );
  }
}

Map<String, dynamic> _restaurantFields({
  required String name,
  required String phone,
  required String password,
  required String description,
  required String address,
  required String area,
  required String latitude,
  required String longitude,
  required String cuisines,
  required String deliveryMin,
  required String deliveryMax,
  required String deliveryFee,
  required String freeDeliveryDistanceKm,
  required String deliveryPricePerKm,
  required String appDeliveryFee,
  required String minimumOrder,
  required String discountPercent,
  required String discountMinOrder,
  required String rating,
  required String ratingsCount,
  required String openingTime,
  required String closingTime,
  required String status,
  required bool isOpen,
  required bool freeDelivery,
  required bool isFeatured,
}) {
  final cuisineList =
      cuisines
          .split(',')
          .map((item) => item.trim())
          .where((item) => item.isNotEmpty)
          .toList();
  final parsedRating = _normalizeRating(rating);
  final parsedRatingsCount = _normalizePositiveInt(ratingsCount);

  return {
    'name': name.trim(),
    'phone': phone.trim(),
    if (password.trim().isNotEmpty) 'password': password.trim(),
    'description': description.trim(),
    'address': address.trim(),
    'area': area.trim(),
    'latitude': latitude.trim(),
    'longitude': longitude.trim(),
    'cuisineTypes': jsonEncode(cuisineList),
    'deliveryTimeMin': deliveryMin.trim(),
    'deliveryTimeMax': deliveryMax.trim(),
    'deliveryFee': deliveryFee.trim(),
    'freeDeliveryDistanceKm': freeDeliveryDistanceKm.trim(),
    'deliveryPricePerKm': deliveryPricePerKm.trim(),
    'appDeliveryFee': appDeliveryFee.trim(),
    'minimumOrder': minimumOrder.trim(),
    'discountPercent': discountPercent.trim(),
    'discountMinOrder': discountMinOrder.trim(),
    'rating': parsedRating,
    'ratingsCount': parsedRatingsCount,
    'openingTime': openingTime.trim(),
    'closingTime': closingTime.trim(),
    'status': status,
    'isOpen': isOpen,
    'freeDelivery': freeDelivery,
    'isFeatured': isFeatured,
  };
}

String _normalizeRating(String value) {
  final parsed = double.tryParse(value.trim().replaceAll(',', '.')) ?? 0;
  return parsed.clamp(0, 5).toString();
}

String _normalizePositiveInt(String value) {
  final parsed = int.tryParse(value.trim()) ?? 0;
  return (parsed < 0 ? 0 : parsed).toString();
}

String _statusLabel(String status) {
  if (status == 'active') return 'فعال';
  if (status == 'blocked') return 'محظور';
  return 'قيد المراجعة';
}
