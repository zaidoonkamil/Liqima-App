import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:iconsax/iconsax.dart';

import '../../../core/ navigation/navigation.dart';
import '../../../core/styles/themes.dart';
import '../cubit/restaurant_cubit.dart';
import '../cubit/restaurant_states.dart';
import '../model/restaurant_models.dart';
import 'widgets/restaurant_ui_widgets.dart';

class RestaurantDeliveriesPage extends StatelessWidget {
  const RestaurantDeliveriesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
          bottom: false,
          child: BlocBuilder<RestaurantCubit, RestaurantState>(
            builder: (context, state) {
              final dashboard = context.read<RestaurantCubit>().dashboard;
              if (dashboard == null) {
                return const Center(
                  child: CircularProgressIndicator(color: primaryColor),
                );
              }

              return CustomScrollView(
                physics: const BouncingScrollPhysics(),
                slivers: [
                  const RestaurantHeaderSliver(title: 'إدارة الدلفرية'),
                  const SliverToBoxAdapter(child: SizedBox(height: 14)),
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 14),
                      child: _AddButton(
                        text: 'إضافة دلفري جديد',
                        icon: Icons.delivery_dining_rounded,
                        onTap: () => showDeliverySheet(context: context),
                      ),
                    ),
                  ),
                  const SliverToBoxAdapter(child: SizedBox(height: 12)),
                  SliverToBoxAdapter(
                    child: RestaurantSectionHeader(
                      title: 'الدلفرية الخاصين',
                      icon: Icons.delivery_dining_rounded,
                      count: dashboard.deliveries.length,
                    ),
                  ),
                  const SliverToBoxAdapter(child: SizedBox(height: 8)),
                  SliverList.separated(
                    itemBuilder: (context, index) {
                      final delivery = dashboard.deliveries[index];
                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 14),
                        child: DeliveryCard(
                          delivery: delivery,
                          onEdit:
                              () => showDeliverySheet(
                                context: context,
                                delivery: delivery,
                              ),
                          onDelete:
                              () => showRestaurantDeleteDialog(
                                context: context,
                                title: 'حذف الدلفري؟',
                                message:
                                    'راح ينحذف هذا الدلفري من مطعمك بشكل نهائي.',
                                onConfirm:
                                    () => context
                                        .read<RestaurantCubit>()
                                        .deleteDelivery(delivery.id),
                              ),
                        ),
                      );
                    },
                    separatorBuilder: (_, __) => const SizedBox(height: 8),
                    itemCount: dashboard.deliveries.length,
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

class DeliveryCard extends StatelessWidget {
  const DeliveryCard({
    super.key,
    required this.delivery,
    required this.onEdit,
    required this.onDelete,
  });

  final RestaurantDeliveryModel delivery;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final color = delivery.isAvailable ? primaryColor : const Color(0xFFFFA51E);
    return Container(
      height: 76,
      decoration: restaurantSoftDecoration(radius: 18),
      padding: const EdgeInsets.all(10),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: color.withValues(alpha: .10),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.delivery_dining_rounded, color: color, size: 24),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  delivery.name,
                  style: const TextStyle(
                    color: Color(0xFF151B18),
                    fontSize: 12,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                Text(
                  '${delivery.vehicleType}  ·  ${delivery.phone}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Color(0xFF747D79),
                    fontSize: 8,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(
                      Iconsax.star,
                      color: Color(0xFFFFA51E),
                      size: 12,
                    ),
                    const SizedBox(width: 3),
                    Text(
                      delivery.rating.toStringAsFixed(1),
                      style: const TextStyle(
                        fontSize: 9,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          RestaurantStatusPill(
            text: delivery.isAvailable ? 'متاح' : 'مشغول',
            color: color,
          ),
          const SizedBox(width: 6),
          RestaurantIconAction(
            icon: Iconsax.edit_2,
            color: secondaryColor,
            onTap: onEdit,
          ),
          RestaurantIconAction(
            icon: Iconsax.trash,
            color: const Color(0xFFE34B4B),
            onTap: onDelete,
          ),
        ],
      ),
    );
  }
}

Future<void> showDeliverySheet({
  required BuildContext context,
  RestaurantDeliveryModel? delivery,
}) {
  final name = TextEditingController(text: delivery?.name ?? '');
  final phone = TextEditingController(text: delivery?.phone ?? '');
  final vehicle = TextEditingController(text: delivery?.vehicleType ?? '');
  final password = TextEditingController();

  return showRestaurantSheet(
    context: context,
    title: delivery == null ? 'إضافة دلفري' : 'تعديل الدلفري',
    icon: Icons.delivery_dining_rounded,
    children: [
      RestaurantSheetTextField(
        controller: name,
        label: 'اسم الدلفري',
        icon: Iconsax.user,
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
        controller: vehicle,
        label: 'نوع المركبة',
        icon: Icons.delivery_dining_rounded,
      ),
      if (delivery == null) ...[
        const SizedBox(height: 8),
        RestaurantSheetTextField(
          controller: password,
          label: 'كلمة المرور',
          icon: Iconsax.lock,
        ),
      ],
    ],
    buttonText: delivery == null ? 'إضافة الدلفري' : 'حفظ التعديل',
    onSubmit: () {
      final cubit = context.read<RestaurantCubit>();
      if (delivery == null) {
        cubit.createDelivery(
          name: name.text.trim(),
          phone: phone.text.trim(),
          password:
              password.text.trim().isEmpty ? '12345678' : password.text.trim(),
          vehicleType: vehicle.text.trim(),
        );
      } else {
        cubit.updateDelivery(
          deliveryId: delivery.id,
          name: name.text.trim(),
          phone: phone.text.trim(),
          vehicleType: vehicle.text.trim(),
          isAvailable: delivery.isAvailable,
        );
      }
      navigateBack(context);
    },
  );
}

class _AddButton extends StatelessWidget {
  const _AddButton({
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
