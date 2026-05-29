import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:iconsax/iconsax.dart';

import '../../../core/ navigation/navigation.dart';
import '../../../core/styles/themes.dart';
import '../../../core/widgets/show_toast.dart';
import '../../restaurant/view/widgets/restaurant_ui_widgets.dart';
import '../cubit/admin_cubit.dart';
import '../cubit/admin_states.dart';
import '../model/admin_ad_model.dart';

class AdminAdsPage extends StatefulWidget {
  const AdminAdsPage({super.key});

  @override
  State<AdminAdsPage> createState() => _AdminAdsPageState();
}

class _AdminAdsPageState extends State<AdminAdsPage> {
  bool _loaded = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_loaded) {
      _loaded = true;
      context.read<AdminCubit>().loadAds();
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
              if (state is AdminAdsErrorState) {
                showToastError(text: state.message, context: context);
              }
            },
            builder: (context, state) {
              final cubit = context.read<AdminCubit>();
              final isLoading = state is AdminAdsLoadingState;

              return CustomScrollView(
                physics: const BouncingScrollPhysics(
                  parent: AlwaysScrollableScrollPhysics(),
                ),
                slivers: [
                  const RestaurantHeaderSliver(title: 'إدارة الإعلانات'),
                  const SliverToBoxAdapter(child: SizedBox(height: 14)),
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 14),
                      child: _AddAdButton(onTap: () => _showAdSheet(context)),
                    ),
                  ),
                  const SliverToBoxAdapter(child: SizedBox(height: 12)),
                  SliverToBoxAdapter(
                    child: RestaurantSectionHeader(
                      title: 'الإعلانات',
                      icon: Iconsax.gallery,
                      count: cubit.ads.length,
                    ),
                  ),
                  const SliverToBoxAdapter(child: SizedBox(height: 8)),
                  if (isLoading && cubit.ads.isEmpty)
                    const SliverFillRemaining(
                      hasScrollBody: false,
                      child: Center(
                        child: CircularProgressIndicator(color: primaryColor),
                      ),
                    )
                  else if (cubit.ads.isEmpty)
                    const SliverFillRemaining(
                      hasScrollBody: false,
                      child: Center(
                        child: Text(
                          'لا توجد إعلانات حالياً',
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
                        final ad = cubit.ads[index];
                        return Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 14),
                          child: _AdCard(ad: ad),
                        );
                      },
                      separatorBuilder: (_, __) => const SizedBox(height: 8),
                      itemCount: cubit.ads.length,
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

class _AdCard extends StatelessWidget {
  const _AdCard({required this.ad});

  final AdminAdModel ad;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 110,
      decoration: restaurantSoftDecoration(radius: 18),
      padding: const EdgeInsets.all(10),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(14),
            child:
                ad.imageUrl == null
                    ? Container(
                      width: 132,
                      height: 88,
                      color: primaryColor.withValues(alpha: .10),
                      child: const Icon(Iconsax.gallery, color: primaryColor),
                    )
                    : Image.network(
                      ad.imageUrl!,
                      width: 132,
                      height: 88,
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
                  'إعلان #${ad.id}',
                  style: const TextStyle(
                    color: Color(0xFF151B18),
                    fontSize: 12,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  '${ad.images.length} صورة',
                  style: const TextStyle(
                    color: Color(0xFF747D79),
                    fontSize: 9,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
          RestaurantIconAction(
            icon: Iconsax.trash,
            color: const Color(0xFFE34B4B),
            onTap:
                () => showRestaurantDeleteDialog(
                  context: context,
                  title: 'حذف الإعلان؟',
                  message: 'راح ينحذف هذا الإعلان من الصفحة الرئيسية.',
                  onConfirm: () => context.read<AdminCubit>().deleteAd(ad.id),
                ),
          ),
        ],
      ),
    );
  }
}

class _AddAdButton extends StatelessWidget {
  const _AddAdButton({required this.onTap});

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
            Icon(Iconsax.gallery_add, color: Colors.white, size: 18),
            SizedBox(width: 8),
            Text(
              'إضافة إعلان',
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

Future<void> _showAdSheet(BuildContext context) {
  String? imagePath;
  final adminCubit = context.read<AdminCubit>();

  return showRestaurantSheet(
    context: context,
    title: 'إضافة إعلان',
    icon: Iconsax.gallery_add,
    children: [
      RestaurantImagePickerField(
        label: 'اختيار صورة الإعلان',
        onChanged: (path) => imagePath = path,
      ),
    ],
    buttonText: 'إضافة الإعلان',
    onSubmit: () {
      if (imagePath == null) {
        showToastInfo(text: 'اختار صورة الإعلان أولاً', context: context);
        return;
      }
      adminCubit.createAd(imagePath: imagePath!);
      navigateBack(context);
    },
  );
}
