import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:iconsax/iconsax.dart';

import '../../../core/ navigation/navigation.dart';
import '../../../core/styles/themes.dart';
import '../../../core/widgets/show_toast.dart';
import '../../restaurant/model/restaurant_models.dart';
import '../../restaurant/view/widgets/restaurant_ui_widgets.dart';
import '../cubit/admin_cubit.dart';
import '../cubit/admin_states.dart';

class AdminCategoriesPage extends StatefulWidget {
  const AdminCategoriesPage({super.key});

  @override
  State<AdminCategoriesPage> createState() => _AdminCategoriesPageState();
}

class _AdminCategoriesPageState extends State<AdminCategoriesPage> {
  bool _loaded = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_loaded) {
      _loaded = true;
      context.read<AdminCubit>().loadCategories();
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
              if (state is AdminCategoriesErrorState) {
                showToastError(text: state.message, context: context);
              }
            },
            builder: (context, state) {
              final cubit = context.read<AdminCubit>();
              final isLoading = state is AdminCategoriesLoadingState;

              return CustomScrollView(
                physics: const BouncingScrollPhysics(
                  parent: AlwaysScrollableScrollPhysics(),
                ),
                slivers: [
                  const RestaurantHeaderSliver(title: 'إدارة الأقسام'),
                  const SliverToBoxAdapter(child: SizedBox(height: 14)),
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 14),
                      child: _AddCategoryButton(
                        onTap: () => _showAdminCategorySheet(context),
                      ),
                    ),
                  ),
                  const SliverToBoxAdapter(child: SizedBox(height: 12)),
                  SliverToBoxAdapter(
                    child: RestaurantSectionHeader(
                      title: 'أقسام التطبيق',
                      icon: Iconsax.category,
                      count: cubit.categories.length,
                    ),
                  ),
                  const SliverToBoxAdapter(child: SizedBox(height: 8)),
                  if (isLoading && cubit.categories.isEmpty)
                    const SliverFillRemaining(
                      hasScrollBody: false,
                      child: Center(
                        child: CircularProgressIndicator(color: primaryColor),
                      ),
                    )
                  else if (cubit.categories.isEmpty)
                    const SliverFillRemaining(
                      hasScrollBody: false,
                      child: Center(
                        child: Text(
                          'لا توجد أقسام حالياً',
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
                        final category = cubit.categories[index];
                        return Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 14),
                          child: _AdminCategoryCard(category: category),
                        );
                      },
                      separatorBuilder: (_, __) => const SizedBox(height: 8),
                      itemCount: cubit.categories.length,
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

class _AdminCategoryCard extends StatelessWidget {
  const _AdminCategoryCard({required this.category});

  final RestaurantCategoryModel category;

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
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Color(0xFF151B18),
                    fontSize: 11,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                Text(
                  '${category.itemsCount} أكلة مرتبطة',
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
                () => context.read<AdminCubit>().updateCategory(
                  categoryId: category.id,
                  name: category.name,
                  isActive: !category.isActive,
                  showInSearchSuggestions: category.showInSearchSuggestions,
                ),
          ),
          RestaurantIconAction(
            icon:
                category.showInSearchSuggestions
                    ? Iconsax.search_favorite
                    : Iconsax.search_normal,
            color:
                category.showInSearchSuggestions
                    ? secondaryColor
                    : const Color(0xFF8A8F8D),
            onTap:
                () => context.read<AdminCubit>().updateCategory(
                  categoryId: category.id,
                  name: category.name,
                  isActive: category.isActive,
                  showInSearchSuggestions: !category.showInSearchSuggestions,
                ),
          ),
          RestaurantIconAction(
            icon: Iconsax.edit_2,
            color: secondaryColor,
            onTap: () => _showAdminCategorySheet(context, category: category),
          ),
          RestaurantIconAction(
            icon: Iconsax.trash,
            color: const Color(0xFFE34B4B),
            onTap:
                () => showRestaurantDeleteDialog(
                  context: context,
                  title: 'حذف القسم؟',
                  message:
                      'راح ينحذف القسم من التطبيق، والوجبات المرتبطة بيه تبقى بدون قسم.',
                  onConfirm:
                      () => context.read<AdminCubit>().deleteCategory(
                        category.id,
                      ),
                ),
          ),
        ],
      ),
    );
  }
}

class _AddCategoryButton extends StatelessWidget {
  const _AddCategoryButton({required this.onTap});

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
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Iconsax.add_circle, color: Colors.white, size: 18),
            SizedBox(width: 8),
            Text(
              'إضافة قسم',
              style: TextStyle(
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

Future<void> _showAdminCategorySheet(
  BuildContext context, {
  RestaurantCategoryModel? category,
}) {
  final name = TextEditingController(text: category?.name ?? '');
  String? imagePath;
  bool showInSearchSuggestions = category?.showInSearchSuggestions ?? false;

  return showRestaurantSheet(
    context: context,
    title: category == null ? 'إضافة قسم' : 'تعديل القسم',
    icon: Iconsax.category,
    children: [
      StatefulBuilder(
        builder: (context, setSheetState) {
          return Column(
            children: [
              RestaurantSheetTextField(
                controller: name,
                label: 'اسم القسم',
                icon: Iconsax.edit_2,
              ),
              const SizedBox(height: 8),
              RestaurantImagePickerField(
                label:
                    category == null ? 'إضافة صورة للقسم' : 'تغيير صورة القسم',
                onChanged: (path) => imagePath = path,
              ),
              const SizedBox(height: 8),
              Container(
                height: 42,
                padding: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: const Color(0xFFE3E5E6)),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Iconsax.search_normal,
                      color: primaryColor,
                      size: 18,
                    ),
                    const SizedBox(width: 8),
                    const Expanded(
                      child: Text(
                        'إظهار ضمن اقتراحات البحث',
                        style: TextStyle(
                          color: Color(0xFF151B18),
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                    Switch(
                      value: showInSearchSuggestions,
                      activeColor: primaryColor,
                      onChanged:
                          (value) => setSheetState(
                            () => showInSearchSuggestions = value,
                          ),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    ],
    buttonText: category == null ? 'إضافة القسم' : 'حفظ التعديل',
    onSubmit: () {
      final cubit = context.read<AdminCubit>();
      if (category == null) {
        cubit.createCategory(
          name.text.trim(),
          imagePath: imagePath,
          showInSearchSuggestions: showInSearchSuggestions,
        );
      } else {
        cubit.updateCategory(
          categoryId: category.id,
          name: name.text.trim(),
          isActive: category.isActive,
          showInSearchSuggestions: showInSearchSuggestions,
          imagePath: imagePath,
        );
      }
      navigateBack(context);
    },
  );
}
