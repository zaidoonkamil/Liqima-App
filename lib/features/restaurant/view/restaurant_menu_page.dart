import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:iconsax/iconsax.dart';

import '../../../core/ navigation/navigation.dart';
import '../../../core/styles/themes.dart';
import '../cubit/restaurant_cubit.dart';
import '../cubit/restaurant_states.dart';
import '../model/restaurant_models.dart';
import 'widgets/restaurant_ui_widgets.dart';

class RestaurantMenuPage extends StatelessWidget {
  const RestaurantMenuPage({super.key});

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
                  const RestaurantHeaderSliver(title: 'إدارة القائمة'),
                  const SliverToBoxAdapter(child: SizedBox(height: 14)),
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 14),
                      child: Row(
                        children: [
                          Expanded(
                            child: _AddButton(
                              text: 'إضافة أكلة',
                              icon: Iconsax.reserve,
                              onTap: () => showProductSheet(context: context),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: _AddButton(
                              text: 'إضافة قسم',
                              icon: Iconsax.category,
                              onTap: () {},
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SliverToBoxAdapter(child: SizedBox(height: 12)),
                  SliverToBoxAdapter(
                    child: RestaurantSectionHeader(
                      title: 'الأقسام',
                      icon: Iconsax.category,
                      count: dashboard.categories.length,
                    ),
                  ),
                  const SliverToBoxAdapter(child: SizedBox(height: 8)),
                  SliverList.separated(
                    itemBuilder: (context, index) {
                      final category = dashboard.categories[index];
                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 14),
                        child: CategoryCard(category: category),
                      );
                    },
                    separatorBuilder: (_, __) => const SizedBox(height: 8),
                    itemCount: 0,
                  ),
                  const SliverToBoxAdapter(child: SizedBox(height: 12)),
                  SliverToBoxAdapter(
                    child: RestaurantSectionHeader(
                      title: 'الأكلات',
                      icon: Iconsax.reserve,
                      count: dashboard.products.length,
                    ),
                  ),
                  const SliverToBoxAdapter(child: SizedBox(height: 8)),
                  SliverList.separated(
                    itemBuilder: (context, index) {
                      final product = dashboard.products[index];
                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 14),
                        child: ProductCard(
                          product: product,
                          categories: dashboard.categories,
                          onEdit:
                              () => showProductSheet(
                                context: context,
                                product: product,
                              ),
                          onDelete:
                              () => showRestaurantDeleteDialog(
                                context: context,
                                title: 'حذف الأكلة؟',
                                message:
                                    'راح تنحذف الأكلة من قائمة المطعم بشكل نهائي.',
                                onConfirm:
                                    () => context
                                        .read<RestaurantCubit>()
                                        .deleteProduct(product.id),
                              ),
                        ),
                      );
                    },
                    separatorBuilder: (_, __) => const SizedBox(height: 8),
                    itemCount: dashboard.products.length,
                  ),
                  const SliverToBoxAdapter(child: SizedBox(height: 12)),
                  SliverToBoxAdapter(
                    child: RestaurantSectionHeader(
                      title: 'الإضافات الأخرى',
                      icon: Iconsax.additem,
                      count: dashboard.generalAddons.length,
                    ),
                  ),
                  const SliverToBoxAdapter(child: SizedBox(height: 8)),
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 14),
                      child: _AddButton(
                        text: 'إضافة جديدة',
                        icon: Iconsax.add_square,
                        onTap: () => showGeneralAddonSheet(context: context),
                      ),
                    ),
                  ),
                  const SliverToBoxAdapter(child: SizedBox(height: 8)),
                  SliverList.separated(
                    itemBuilder: (context, index) {
                      final addon = dashboard.generalAddons[index];
                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 14),
                        child: GeneralAddonCard(addon: addon),
                      );
                    },
                    separatorBuilder: (_, __) => const SizedBox(height: 8),
                    itemCount: dashboard.generalAddons.length,
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

class CategoryCard extends StatelessWidget {
  const CategoryCard({super.key, required this.category});

  final RestaurantCategoryModel category;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 58,
      decoration: restaurantSoftDecoration(radius: 16),
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: primaryColor.withValues(alpha: .10),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Iconsax.category, color: primaryColor, size: 18),
          ),
          const SizedBox(width: 9),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  category.name,
                  style: const TextStyle(
                    color: Color(0xFF151B18),
                    fontSize: 11,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                Text(
                  '${category.itemsCount} أكلة',
                  style: const TextStyle(
                    color: Color(0xFF747D79),
                    fontSize: 8,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
          RestaurantStatusPill(
            text: category.isActive ? 'فعال' : 'متوقف',
            color: category.isActive ? primaryColor : const Color(0xFF8A8F8D),
          ),
          const SizedBox(width: 6),
          RestaurantIconAction(
            icon: Iconsax.refresh,
            color: primaryColor,
            onTap:
                () => context.read<RestaurantCubit>().updateCategory(
                  categoryId: category.id,
                  name: category.name,
                  isActive: !category.isActive,
                ),
          ),
          RestaurantIconAction(
            icon: Iconsax.edit_2,
            color: secondaryColor,
            onTap:
                () => showCategorySheet(context: context, category: category),
          ),
          RestaurantIconAction(
            icon: Iconsax.trash,
            color: const Color(0xFFE34B4B),
            onTap:
                () => showRestaurantDeleteDialog(
                  context: context,
                  title: 'حذف القسم؟',
                  message:
                      'راح ينحذف القسم، والوجبات المرتبطة بيه تبقى بدون قسم.',
                  onConfirm:
                      () => context.read<RestaurantCubit>().deleteCategory(
                        category.id,
                      ),
                ),
          ),
        ],
      ),
    );
  }
}

class ProductCard extends StatelessWidget {
  const ProductCard({
    super.key,
    required this.product,
    required this.categories,
    required this.onEdit,
    required this.onDelete,
  });

  final RestaurantProductModel product;
  final List<RestaurantCategoryModel> categories;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final image =
        product.imageUrl ??
        'https://images.unsplash.com/photo-1546069901-ba9599a7e63c?auto=format&fit=crop&w=700&q=80';
    return Container(
      height: 120,
      decoration: restaurantSoftDecoration(radius: 18),
      padding: const EdgeInsets.all(10),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(15),
            child: Image.network(
              image,
              width: 88,
              height: 78,
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
                  product.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Color(0xFF151B18),
                    fontSize: 12,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                Text(
                  product.categoryName,
                  style: const TextStyle(
                    color: Color(0xFF747D79),
                    fontSize: 8,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 5),
                Row(
                  children: [
                    const Icon(
                      Iconsax.star1,
                      color: Color(0xFFFFA51E),
                      size: 12,
                    ),
                    const SizedBox(width: 3),
                    Text(
                      '${product.rating.toStringAsFixed(1)} (${product.ratingsCount})',
                      style: const TextStyle(
                        color: Color(0xFF747D79),
                        fontSize: 8,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 5),
                Text(
                  'د.ع ${formatRestaurantPrice(product.price)}',
                  style: const TextStyle(
                    color: primaryColor,
                    fontSize: 11,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 6),
                RestaurantStatusPill(
                  text: product.isAvailable ? 'متوفر' : 'غير متوفر',
                  color:
                      product.isAvailable
                          ? primaryColor
                          : const Color(0xFF8A8F8D),
                ),
              ],
            ),
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              RestaurantIconAction(
                icon: Iconsax.refresh,
                color: primaryColor,
                onTap:
                    () => context.read<RestaurantCubit>().updateProduct(
                      productId: product.id,
                      name: product.name,
                      description: product.description ?? '',
                      price: product.price,
                      rating: product.rating,
                      ratingsCount: product.ratingsCount,
                      categoryId: product.categoryId,
                      isAvailable: !product.isAvailable,
                    ),
              ),
              const SizedBox(height: 6),
              RestaurantIconAction(
                icon: Iconsax.edit_2,
                color: secondaryColor,
                onTap: onEdit,
              ),
              const SizedBox(height: 6),
              RestaurantIconAction(
                icon: Iconsax.trash,
                color: const Color(0xFFE34B4B),
                onTap: onDelete,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class GeneralAddonCard extends StatelessWidget {
  const GeneralAddonCard({super.key, required this.addon});

  final RestaurantAddonModel addon;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 64,
      decoration: restaurantSoftDecoration(radius: 16),
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: primaryColor.withValues(alpha: .10),
              borderRadius: BorderRadius.circular(12),
            ),
            child:
                addon.imageUrl == null
                    ? const Icon(Iconsax.additem, color: primaryColor, size: 18)
                    : ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.network(addon.imageUrl!, fit: BoxFit.cover),
                    ),
          ),
          const SizedBox(width: 9),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  addon.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Color(0xFF151B18),
                    fontSize: 11,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                Text(
                  'د.ع ${formatRestaurantPrice(addon.price)}',
                  style: const TextStyle(
                    color: primaryColor,
                    fontSize: 9,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ],
            ),
          ),
          RestaurantStatusPill(
            text: addon.isAvailable ? 'متوفر' : 'متوقف',
            color: addon.isAvailable ? primaryColor : const Color(0xFF8A8F8D),
          ),
          const SizedBox(width: 6),
          RestaurantIconAction(
            icon: Iconsax.refresh,
            color: primaryColor,
            onTap:
                () => context.read<RestaurantCubit>().updateGeneralAddon(
                  addonId: addon.id,
                  name: addon.name,
                  price: addon.price,
                  isAvailable: !addon.isAvailable,
                ),
          ),
          RestaurantIconAction(
            icon: Iconsax.edit_2,
            color: secondaryColor,
            onTap: () => showGeneralAddonSheet(context: context, addon: addon),
          ),
          RestaurantIconAction(
            icon: Iconsax.trash,
            color: const Color(0xFFE34B4B),
            onTap:
                () => showRestaurantDeleteDialog(
                  context: context,
                  title: 'حذف الإضافة؟',
                  message: 'راح تنحذف الإضافة من كل الوجبات.',
                  onConfirm:
                      () => context.read<RestaurantCubit>().deleteGeneralAddon(
                        addon.id,
                      ),
                ),
          ),
        ],
      ),
    );
  }
}

Future<void> showGeneralAddonSheet({
  required BuildContext context,
  RestaurantAddonModel? addon,
}) {
  final name = TextEditingController(text: addon?.name ?? '');
  final price = TextEditingController(text: addon?.price.toString() ?? '');
  String? imagePath;

  return showRestaurantSheet(
    context: context,
    title: addon == null ? 'إضافة أخرى' : 'تعديل الإضافة',
    icon: Iconsax.additem,
    children: [
      RestaurantSheetTextField(
        controller: name,
        label: 'اسم الإضافة',
        icon: Iconsax.edit_2,
      ),
      const SizedBox(height: 8),
      RestaurantSheetTextField(
        controller: price,
        label: 'السعر',
        icon: Iconsax.money_4,
        keyboardType: TextInputType.number,
      ),
      if (addon == null) ...[
        const SizedBox(height: 8),
        RestaurantImagePickerField(
          label: 'صورة الإضافة',
          onChanged: (path) => imagePath = path,
        ),
      ],
    ],
    buttonText: addon == null ? 'إضافة' : 'حفظ التعديل',
    onSubmit: () {
      final cubit = context.read<RestaurantCubit>();
      final parsedPrice = int.tryParse(price.text.trim()) ?? addon?.price ?? 0;
      if (addon == null) {
        cubit.createGeneralAddon(
          name: name.text.trim(),
          price: parsedPrice,
          imagePath: imagePath,
        );
      } else {
        cubit.updateGeneralAddon(
          addonId: addon.id,
          name: name.text.trim(),
          price: parsedPrice,
          isAvailable: addon.isAvailable,
        );
      }
      navigateBack(context);
    },
  );
}

Future<void> showCategorySheet({
  required BuildContext context,
  RestaurantCategoryModel? category,
}) {
  final name = TextEditingController(text: category?.name ?? '');
  String? imagePath;
  return showRestaurantSheet(
    context: context,
    title: category == null ? 'إضافة قسم' : 'تعديل القسم',
    icon: Iconsax.category,
    children: [
      RestaurantSheetTextField(
        controller: name,
        label: 'اسم القسم',
        icon: Iconsax.edit_2,
      ),
      if (category == null) ...[
        const SizedBox(height: 8),
        RestaurantImagePickerField(
          label: 'إضافة صورة للقسم',
          onChanged: (path) => imagePath = path,
        ),
      ],
    ],
    buttonText: category == null ? 'إضافة القسم' : 'حفظ التعديل',
    onSubmit: () {
      final cubit = context.read<RestaurantCubit>();
      if (category == null) {
        cubit.createCategory(name.text.trim(), imagePath: imagePath);
      } else {
        cubit.updateCategory(
          categoryId: category.id,
          name: name.text.trim(),
          isActive: category.isActive,
        );
      }
      navigateBack(context);
    },
  );
}

Future<void> showProductSheet({
  required BuildContext context,
  RestaurantProductModel? product,
}) {
  final dashboard = context.read<RestaurantCubit>().dashboard;
  final categories = dashboard?.categories ?? const <RestaurantCategoryModel>[];
  final name = TextEditingController(text: product?.name ?? '');
  final description = TextEditingController(text: product?.description ?? '');
  final price = TextEditingController(text: product?.price.toString() ?? '');
  final rating = TextEditingController(
    text: product?.rating.toStringAsFixed(1) ?? '0',
  );
  final ratingsCount = TextEditingController(
    text: product?.ratingsCount.toString() ?? '0',
  );
  int? selectedCategoryId =
      product?.categoryId ?? (categories.isEmpty ? null : categories.first.id);
  String? imagePath;

  return showRestaurantSheet(
    context: context,
    title: product == null ? 'إضافة أكلة' : 'تعديل الأكلة',
    icon: Iconsax.reserve,
    children: [
      RestaurantSheetTextField(
        controller: name,
        label: 'اسم الأكلة',
        icon: Iconsax.reserve,
      ),
      const SizedBox(height: 8),
      _CategoryDropdown(
        categories: categories,
        selectedCategoryId: selectedCategoryId,
        onChanged: (value) => selectedCategoryId = value,
      ),
      const SizedBox(height: 8),
      RestaurantSheetTextField(
        controller: price,
        label: 'السعر',
        icon: Iconsax.money_4,
        keyboardType: TextInputType.number,
      ),
      const SizedBox(height: 8),
      RestaurantSheetTextField(
        controller: rating,
        label: 'تقييم الوجبة من المطعم',
        icon: Iconsax.star1,
        keyboardType: TextInputType.number,
      ),
      const SizedBox(height: 8),
      RestaurantSheetTextField(
        controller: ratingsCount,
        label: 'عدد تقييمات الوجبة',
        icon: Iconsax.people,
        keyboardType: TextInputType.number,
      ),
      const SizedBox(height: 8),
      RestaurantSheetTextField(
        controller: description,
        label: 'الوصف',
        icon: Iconsax.note,
        height: 86,
        maxLines: 3,
      ),
      if (product == null) ...[
        const SizedBox(height: 8),
        RestaurantImagePickerField(
          label: 'إضافة صورة للأكلة',
          onChanged: (path) => imagePath = path,
        ),
      ],
    ],
    buttonText: product == null ? 'إضافة الأكلة' : 'حفظ التعديل',
    onSubmit: () {
      final cubit = context.read<RestaurantCubit>();
      final parsedPrice =
          int.tryParse(price.text.trim()) ?? product?.price ?? 0;
      final parsedRating =
          double.tryParse(rating.text.trim()) ?? product?.rating ?? 0;
      final parsedRatingsCount =
          int.tryParse(ratingsCount.text.trim()) ?? product?.ratingsCount ?? 0;

      if (product == null) {
        cubit.createProduct(
          name: name.text.trim(),
          description: description.text.trim(),
          price: parsedPrice,
          rating: parsedRating.clamp(0, 5).toDouble(),
          ratingsCount: parsedRatingsCount < 0 ? 0 : parsedRatingsCount,
          categoryId: selectedCategoryId,
          imagePath: imagePath,
        );
      } else {
        cubit.updateProduct(
          productId: product.id,
          name: name.text.trim(),
          description: description.text.trim(),
          price: parsedPrice,
          rating: parsedRating.clamp(0, 5).toDouble(),
          ratingsCount: parsedRatingsCount < 0 ? 0 : parsedRatingsCount,
          categoryId: selectedCategoryId ?? product.categoryId,
          isAvailable: product.isAvailable,
        );
      }
      navigateBack(context);
    },
  );
}

class _CategoryDropdown extends StatefulWidget {
  const _CategoryDropdown({
    required this.categories,
    required this.selectedCategoryId,
    required this.onChanged,
  });

  final List<RestaurantCategoryModel> categories;
  final int? selectedCategoryId;
  final ValueChanged<int?> onChanged;

  @override
  State<_CategoryDropdown> createState() => _CategoryDropdownState();
}

class _CategoryDropdownState extends State<_CategoryDropdown> {
  late int? selectedCategoryId = widget.selectedCategoryId;

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
          const Icon(Iconsax.category, color: primaryColor, size: 19),
          const SizedBox(width: 8),
          Expanded(
            child: DropdownButtonHideUnderline(
              child: DropdownButton<int?>(
                value: selectedCategoryId,
                isExpanded: true,
                icon: const Icon(
                  Icons.keyboard_arrow_down_rounded,
                  color: Color(0xFF8E9295),
                  size: 18,
                ),
                hint: const Text(
                  'اختر القسم',
                  style: TextStyle(
                    color: Color(0xFF8E9295),
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                items:
                    widget.categories.map((category) {
                      return DropdownMenuItem<int?>(
                        value: category.id,
                        child: Text(
                          category.name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: Color(0xFF151B18),
                            fontSize: 11,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      );
                    }).toList(),
                onChanged: (value) {
                  setState(() => selectedCategoryId = value);
                  widget.onChanged(value);
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
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
