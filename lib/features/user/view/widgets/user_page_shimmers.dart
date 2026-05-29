import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

import '../../../../core/widgets/user_nav_header.dart';

class HomePageShimmer extends StatelessWidget {
  const HomePageShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      physics: const AlwaysScrollableScrollPhysics(
        parent: BouncingScrollPhysics(),
      ),
      slivers: [
        const UserNavHeaderSliver(),
        const SliverToBoxAdapter(child: SizedBox(height: 16)),
        const SliverToBoxAdapter(child: _SearchRowSkeleton()),
        const SliverToBoxAdapter(child: SizedBox(height: 16)),
        const SliverToBoxAdapter(
          child: _ShimmerPadding(child: _SkeletonBox(height: 130, radius: 16)),
        ),
        const SliverToBoxAdapter(child: SizedBox(height: 18)),
        const SliverToBoxAdapter(child: _CategoryStripSkeleton()),
        const SliverToBoxAdapter(child: SizedBox(height: 22)),
        const SliverToBoxAdapter(child: _SectionHeaderSkeleton()),
        const SliverToBoxAdapter(child: SizedBox(height: 12)),
        SliverToBoxAdapter(
          child: SizedBox(
            height: 190,
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              scrollDirection: Axis.horizontal,
              physics: const NeverScrollableScrollPhysics(),
              itemBuilder: (_, __) => const _MealCardSkeleton(),
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemCount: 3,
            ),
          ),
        ),
        const SliverToBoxAdapter(child: SizedBox(height: 16)),
        const SliverToBoxAdapter(child: _SectionHeaderSkeleton()),
        const SliverToBoxAdapter(child: SizedBox(height: 12)),
        SliverList.separated(
          itemBuilder:
              (_, __) => const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: _RestaurantCardSkeleton(),
              ),
          separatorBuilder: (_, __) => const SizedBox(height: 8),
          itemCount: 3,
        ),
        const SliverToBoxAdapter(child: SizedBox(height: 110)),
      ],
    );
  }
}

class CartPageShimmerSlivers extends StatelessWidget {
  const CartPageShimmerSlivers({super.key});

  @override
  Widget build(BuildContext context) {
    return SliverMainAxisGroup(
      slivers: [
        const SliverToBoxAdapter(child: _CartDeliverySkeleton()),
        const SliverToBoxAdapter(child: SizedBox(height: 12)),
        const SliverToBoxAdapter(child: _CartItemsSkeleton()),
        const SliverToBoxAdapter(child: SizedBox(height: 12)),
        const SliverToBoxAdapter(child: _CartCouponSkeleton()),
        const SliverToBoxAdapter(child: SizedBox(height: 12)),
        const SliverToBoxAdapter(child: _CartSummarySkeleton()),
      ],
    );
  }
}

class FavoritesPageShimmerSlivers extends StatelessWidget {
  const FavoritesPageShimmerSlivers({super.key});

  @override
  Widget build(BuildContext context) {
    return SliverMainAxisGroup(
      slivers: [
        const SliverToBoxAdapter(child: _SectionHeaderSkeleton()),
        const SliverToBoxAdapter(child: SizedBox(height: 10)),
        SliverList.separated(
          itemBuilder:
              (_, __) => const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: _FavoriteMealSkeleton(),
              ),
          separatorBuilder: (_, __) => const SizedBox(height: 8),
          itemCount: 4,
        ),
        const SliverToBoxAdapter(child: SizedBox(height: 16)),
        const SliverToBoxAdapter(child: _SectionHeaderSkeleton()),
        const SliverToBoxAdapter(child: SizedBox(height: 10)),
        SliverList.separated(
          itemBuilder:
              (_, __) => const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: _RestaurantCardSkeleton(),
              ),
          separatorBuilder: (_, __) => const SizedBox(height: 8),
          itemCount: 3,
        ),
      ],
    );
  }
}

class CouponsPageShimmerSlivers extends StatelessWidget {
  const CouponsPageShimmerSlivers({super.key});

  @override
  Widget build(BuildContext context) {
    return SliverMainAxisGroup(
      slivers: [
        const SliverToBoxAdapter(
          child: _ShimmerPadding(child: _SkeletonBox(height: 92, radius: 14)),
        ),
        const SliverToBoxAdapter(child: SizedBox(height: 14)),
        SliverList.separated(
          itemBuilder:
              (_, index) => Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: _CouponSkeleton(accentOnRight: index.isEven),
              ),
          separatorBuilder: (_, __) => const SizedBox(height: 10),
          itemCount: 4,
        ),
      ],
    );
  }
}

class OrdersPageShimmerSlivers extends StatelessWidget {
  const OrdersPageShimmerSlivers({super.key});

  @override
  Widget build(BuildContext context) {
    return SliverList.separated(
      itemBuilder:
          (_, __) => const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: _OrderCardSkeleton(),
          ),
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemCount: 4,
    );
  }
}

class ProfilePageShimmer extends StatelessWidget {
  const ProfilePageShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return const CustomScrollView(
      physics: AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
      slivers: [
        UserNavHeaderSliver(),
        SliverToBoxAdapter(child: SizedBox(height: 14)),
        SliverToBoxAdapter(child: _ProfileUserCardSkeleton()),
        SliverToBoxAdapter(child: SizedBox(height: 12)),
        SliverToBoxAdapter(child: _ProfileWalletSkeleton()),
        SliverToBoxAdapter(child: SizedBox(height: 12)),
        SliverToBoxAdapter(child: _ProfileAddressesSkeleton()),
        SliverToBoxAdapter(child: SizedBox(height: 12)),
        SliverToBoxAdapter(child: _ProfileOptionsSkeleton()),
      ],
    );
  }
}

class ListPageShimmerSlivers extends StatelessWidget {
  const ListPageShimmerSlivers({super.key, this.twoColumns = false});

  final bool twoColumns;

  @override
  Widget build(BuildContext context) {
    if (twoColumns) {
      return SliverPadding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        sliver: SliverGrid(
          delegate: SliverChildBuilderDelegate(
            (_, __) => const _MealCardSkeleton(),
            childCount: 6,
          ),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            mainAxisSpacing: 10,
            crossAxisSpacing: 10,
            childAspectRatio: .78,
          ),
        ),
      );
    }

    return SliverList.separated(
      itemBuilder:
          (_, __) => const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: _RestaurantCardSkeleton(),
          ),
      separatorBuilder: (_, __) => const SizedBox(height: 8),
      itemCount: 6,
    );
  }
}

class MealDetailsPageShimmer extends StatelessWidget {
  const MealDetailsPageShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      physics: const AlwaysScrollableScrollPhysics(
        parent: BouncingScrollPhysics(),
      ),
      slivers: [
        const SliverToBoxAdapter(child: _SkeletonBox(height: 202, radius: 0)),
        SliverToBoxAdapter(
          child: Transform.translate(
            offset: const Offset(0, -22),
            child: const _ShimmerPadding(
              child: _SkeletonBox(height: 360, radius: 26),
            ),
          ),
        ),
        const SliverToBoxAdapter(child: SizedBox(height: 16)),
        SliverToBoxAdapter(
          child: SizedBox(
            height: 118,
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              scrollDirection: Axis.horizontal,
              physics: const NeverScrollableScrollPhysics(),
              itemBuilder:
                  (_, __) =>
                      const _SkeletonBox(width: 96, height: 108, radius: 14),
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemCount: 4,
            ),
          ),
        ),
      ],
    );
  }
}

class RestaurantDetailsPageShimmer extends StatelessWidget {
  const RestaurantDetailsPageShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      physics: const AlwaysScrollableScrollPhysics(
        parent: BouncingScrollPhysics(),
      ),
      slivers: [
        const SliverToBoxAdapter(child: _SkeletonBox(height: 205, radius: 0)),
        SliverToBoxAdapter(
          child: Transform.translate(
            offset: const Offset(0, -28),
            child: const _ShimmerPadding(
              child: _SkeletonBox(height: 210, radius: 26),
            ),
          ),
        ),
        const SliverToBoxAdapter(child: SizedBox(height: 8)),
        const SliverToBoxAdapter(child: _CategoryStripSkeleton()),
        const SliverToBoxAdapter(child: SizedBox(height: 16)),
        const SliverToBoxAdapter(child: _SectionHeaderSkeleton()),
        const SliverToBoxAdapter(child: SizedBox(height: 12)),
        SliverList.separated(
          itemBuilder:
              (_, __) => const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: _FavoriteMealSkeleton(),
              ),
          separatorBuilder: (_, __) => const SizedBox(height: 10),
          itemCount: 4,
        ),
      ],
    );
  }
}

class _SearchRowSkeleton extends StatelessWidget {
  const _SearchRowSkeleton();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          _SkeletonCircle(size: 38),
          SizedBox(width: 6),
          Expanded(child: _SkeletonBox(height: 38, radius: 28)),
        ],
      ),
    );
  }
}

class _CategoryStripSkeleton extends StatelessWidget {
  const _CategoryStripSkeleton();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 80,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        scrollDirection: Axis.horizontal,
        physics: const NeverScrollableScrollPhysics(),
        itemBuilder:
            (_, __) => const SizedBox(
              width: 66,
              child: Column(
                children: [
                  _SkeletonBox(width: 52, height: 52, radius: 16),
                  SizedBox(height: 8),
                  _SkeletonBox(width: 40, height: 8, radius: 6),
                ],
              ),
            ),
        separatorBuilder: (_, __) => const SizedBox(width: 6),
        itemCount: 6,
      ),
    );
  }
}

class _SectionHeaderSkeleton extends StatelessWidget {
  const _SectionHeaderSkeleton();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          _SkeletonBox(width: 52, height: 10, radius: 8),
          Spacer(),
          _SkeletonBox(width: 116, height: 18, radius: 8),
        ],
      ),
    );
  }
}

class _MealCardSkeleton extends StatelessWidget {
  const _MealCardSkeleton();

  @override
  Widget build(BuildContext context) {
    return const _SkeletonCard(
      width: 132,
      padding: EdgeInsets.all(8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
            children: [
              _SkeletonBox(height: 90, radius: 12),
              Positioned(top: 6, left: 6, child: _SkeletonCircle(size: 22)),
              Positioned(
                right: 6,
                bottom: 6,
                child: _SkeletonBox(width: 48, height: 16, radius: 10),
              ),
            ],
          ),
          SizedBox(height: 8),
          _SkeletonBox(width: 96, height: 12, radius: 8),
          SizedBox(height: 6),
          _SkeletonBox(width: 70, height: 8, radius: 8),
          Spacer(),
          Row(
            children: [
              _SkeletonBox(width: 52, height: 13, radius: 8),
              Spacer(),
              _SkeletonCircle(size: 24),
            ],
          ),
        ],
      ),
    );
  }
}

class _RestaurantCardSkeleton extends StatelessWidget {
  const _RestaurantCardSkeleton();

  @override
  Widget build(BuildContext context) {
    return const _SkeletonCard(
      height: 92,
      radius: 18,
      child: Padding(
        padding: EdgeInsets.all(8),
        child: Row(
          children: [
            _SkeletonBox(width: 115, height: 76, radius: 14),
            SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Row(
                    children: [
                      // _SkeletonBox(width: 84, height: 13, radius: 8),
                      // Spacer(),
                      _SkeletonBox(width: 62, height: 13, radius: 12),
                    ],
                  ),
                  SizedBox(height: 8),
                  _SkeletonBox(width: 130, height: 9, radius: 8),
                  SizedBox(height: 10),
                  Row(
                    children: [
                      _SkeletonBox(width: 40, height: 9, radius: 8),
                      SizedBox(width: 10),
                      _SkeletonBox(width: 58, height: 9, radius: 8),
                    ],
                  ),
                ],
              ),
            ),
            SizedBox(width: 8),
            _SkeletonCircle(size: 54),
          ],
        ),
      ),
    );
  }
}

class _FavoriteMealSkeleton extends StatelessWidget {
  const _FavoriteMealSkeleton();

  @override
  Widget build(BuildContext context) {
    return const _SkeletonCard(
      height: 95,
      radius: 18,
      child: Padding(
        padding: EdgeInsets.all(10),
        child: Row(
          children: [
            _SkeletonCircle(size: 18),
            SizedBox(width: 8),
            _SkeletonBox(width: 80, height: 80, radius: 12),
            SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _SkeletonBox(width: 110, height: 12, radius: 8),
                  SizedBox(height: 8),
                  _SkeletonBox(width: 78, height: 9, radius: 8),
                  SizedBox(height: 10),
                  _SkeletonBox(width: 92, height: 11, radius: 8),
                ],
              ),
            ),
            SizedBox(width: 8),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _SkeletonCircle(size: 46),
                SizedBox(height: 6),
                _SkeletonBox(width: 76, height: 18, radius: 10),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _CouponSkeleton extends StatelessWidget {
  const _CouponSkeleton({required this.accentOnRight});

  final bool accentOnRight;

  @override
  Widget build(BuildContext context) {
    final accent = const SizedBox(
      width: 96,
      height: 96,
      child: Stack(
        children: [
          Positioned.fill(child: _SkeletonBox(height: 96, radius: 10)),
          Positioned(right: -7, top: 38, child: _CutCircle()),
          Positioned(left: -7, top: 38, child: _CutCircle()),
          Positioned(
            right: 18,
            top: 24,
            child: _SkeletonBox(width: 58, height: 12, radius: 8),
          ),
          Positioned(
            right: 18,
            top: 48,
            child: _SkeletonBox(width: 58, height: 18, radius: 8),
          ),
        ],
      ),
    );
    final details = const Expanded(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _SkeletonBox(width: 74, height: 18, radius: 10),
            SizedBox(height: 12),
            _SkeletonBox(width: 130, height: 15, radius: 8),
            SizedBox(height: 8),
            _SkeletonBox(width: 100, height: 9, radius: 8),
            Spacer(),
            Row(
              children: [
                _SkeletonBox(width: 86, height: 9, radius: 8),
                Spacer(),
                _SkeletonBox(width: 50, height: 9, radius: 8),
              ],
            ),
          ],
        ),
      ),
    );

    return _SkeletonCard(
      height: 96,
      radius: 12,
      child: Row(
        children: accentOnRight ? [details, accent] : [accent, details],
      ),
    );
  }
}

class _OrderCardSkeleton extends StatelessWidget {
  const _OrderCardSkeleton();

  @override
  Widget build(BuildContext context) {
    return const _SkeletonCard(
      height: 150,
      radius: 18,
      child: Padding(
        padding: EdgeInsets.all(12),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Row(
                  //   children: [
                  //     _SkeletonBox(width: 68, height: 10, radius: 8),
                  //     Spacer(),
                  //     _SkeletonBox(width: 54, height: 12, radius: 8),
                  //   ],
                  // ),
                  // SizedBox(height: 14),
                  Row(
                    children: [
                      _SkeletonCircle(size: 46),
                      SizedBox(width: 10),
                      _SkeletonBox(width: 118, height: 14, radius: 8),
                    ],
                  ),
                  SizedBox(height: 10),
                  _SkeletonBox(width: 160, height: 9, radius: 8),
                  SizedBox(height: 10),
                  Row(
                    children: [
                      _SkeletonBox(width: 50, height: 9, radius: 8),
                      SizedBox(width: 12),
                      _SkeletonBox(width: 64, height: 9, radius: 8),
                    ],
                  ),
                  SizedBox(height: 14),
                  Row(
                    children: [
                      // _SkeletonBox(width: 72, height: 12, radius: 8),
                      // Spacer(),
                      _SkeletonBox(width: 108, height: 8, radius: 13),
                    ],
                  ),
                ],
              ),
            ),
            SizedBox(width: 12),
            SizedBox(
              width: 96,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _SkeletonBox(width: 76, height: 12, radius: 12),
                  SizedBox(height: 12),
                  _SkeletonCircle(size: 52),
                  SizedBox(height: 10),
                  _SkeletonBox(width: 76, height: 10, radius: 8),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CartDeliverySkeleton extends StatelessWidget {
  const _CartDeliverySkeleton();

  @override
  Widget build(BuildContext context) {
    return const _ShimmerPadding(
      child: _SkeletonCard(
        height: 56,
        radius: 16,
        padding: EdgeInsets.symmetric(horizontal: 14, vertical: 9),
        child: Row(
          children: [
            _SkeletonCircle(size: 38),
            SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Row(
                    children: [
                      _SkeletonBox(width: 64, height: 10, radius: 8),
                      Spacer(),
                      _SkeletonBox(width: 142, height: 10, radius: 8),
                    ],
                  ),
                  SizedBox(height: 8),
                  _SkeletonBox(height: 7, radius: 12),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CartItemsSkeleton extends StatelessWidget {
  const _CartItemsSkeleton();

  @override
  Widget build(BuildContext context) {
    return const _ShimmerPadding(
      child: _SkeletonCard(
        height: 258,
        radius: 18,
        padding: EdgeInsets.all(12),
        child: Column(
          children: [
            Row(
              children: [
                _SkeletonCircle(size: 48),
                SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _SkeletonBox(width: 112, height: 13, radius: 8),
                      SizedBox(height: 8),
                      _SkeletonBox(width: 150, height: 9, radius: 8),
                    ],
                  ),
                ),
                _SkeletonBox(width: 72, height: 18, radius: 10),
              ],
            ),
            SizedBox(height: 14),
            _CartItemRowSkeleton(),
            Divider(height: 18, color: Color(0xFFF0F1EF)),
            _CartItemRowSkeleton(),
            Divider(height: 18, color: Color(0xFFF0F1EF)),
            _CartItemRowSkeleton(),
          ],
        ),
      ),
    );
  }
}

class _CartItemRowSkeleton extends StatelessWidget {
  const _CartItemRowSkeleton();

  @override
  Widget build(BuildContext context) {
    return const SizedBox(
      height: 52,
      child: Row(
        children: [
          _SkeletonCircle(size: 26),
          SizedBox(width: 8),
          _SkeletonBox(width: 64, height: 28, radius: 12),
          Spacer(),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _SkeletonBox(width: 112, height: 12, radius: 8),
              SizedBox(height: 7),
              _SkeletonBox(width: 84, height: 8, radius: 8),
            ],
          ),
          SizedBox(width: 10),
          _SkeletonBox(width: 74, height: 52, radius: 12),
        ],
      ),
    );
  }
}

class _CartCouponSkeleton extends StatelessWidget {
  const _CartCouponSkeleton();

  @override
  Widget build(BuildContext context) {
    return const _ShimmerPadding(
      child: _SkeletonCard(
        height: 54,
        radius: 16,
        padding: EdgeInsets.symmetric(horizontal: 14),
        child: Row(
          children: [
            _SkeletonBox(width: 88, height: 26, radius: 13),
            Spacer(),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _SkeletonBox(width: 108, height: 11, radius: 8),
                SizedBox(height: 6),
                _SkeletonBox(width: 66, height: 8, radius: 8),
              ],
            ),
            SizedBox(width: 10),
            _SkeletonCircle(size: 28),
          ],
        ),
      ),
    );
  }
}

class _CartSummarySkeleton extends StatelessWidget {
  const _CartSummarySkeleton();

  @override
  Widget build(BuildContext context) {
    return const _ShimmerPadding(
      child: _SkeletonCard(
        height: 154,
        radius: 18,
        padding: EdgeInsets.all(14),
        child: Column(
          children: [
            Row(
              children: [
                _SkeletonBox(width: 70, height: 12, radius: 8),
                Spacer(),
                _SkeletonBox(width: 92, height: 16, radius: 8),
              ],
            ),
            SizedBox(height: 14),
            _SummaryLineSkeleton(),
            SizedBox(height: 10),
            _SummaryLineSkeleton(),
            SizedBox(height: 10),
            _SummaryLineSkeleton(),
            Spacer(),
            Row(
              children: [
                _SkeletonBox(width: 112, height: 38, radius: 14),
                SizedBox(width: 8),
                Expanded(child: _SkeletonBox(height: 38, radius: 14)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _SummaryLineSkeleton extends StatelessWidget {
  const _SummaryLineSkeleton();

  @override
  Widget build(BuildContext context) {
    return const Row(
      children: [
        _SkeletonBox(width: 58, height: 9, radius: 8),
        Spacer(),
        _SkeletonBox(width: 84, height: 9, radius: 8),
      ],
    );
  }
}

class _ProfileUserCardSkeleton extends StatelessWidget {
  const _ProfileUserCardSkeleton();

  @override
  Widget build(BuildContext context) {
    return const _ShimmerPadding(
      child: _SkeletonCard(
        height: 150,
        radius: 18,
        padding: EdgeInsets.all(14),
        child: Column(
          children: [
            Row(
              children: [
                _SkeletonCircle(size: 78),
                SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _SkeletonBox(width: 128, height: 17, radius: 8),
                      SizedBox(height: 10),
                      _SkeletonBox(width: 112, height: 10, radius: 8),
                      SizedBox(height: 10),
                      _SkeletonBox(width: 94, height: 20, radius: 10),
                    ],
                  ),
                ),
              ],
            ),
            Spacer(),
            Row(
              children: [
                Expanded(child: _ProfileMetricSkeleton()),
                SizedBox(width: 10),
                Expanded(child: _ProfileMetricSkeleton()),
                SizedBox(width: 10),
                Expanded(child: _ProfileMetricSkeleton()),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _ProfileMetricSkeleton extends StatelessWidget {
  const _ProfileMetricSkeleton();

  @override
  Widget build(BuildContext context) {
    return const Column(
      children: [
        _SkeletonBox(width: 38, height: 16, radius: 8),
        SizedBox(height: 7),
        _SkeletonBox(width: 52, height: 8, radius: 8),
      ],
    );
  }
}

class _ProfileWalletSkeleton extends StatelessWidget {
  const _ProfileWalletSkeleton();

  @override
  Widget build(BuildContext context) {
    return const _ShimmerPadding(
      child: _SkeletonCard(
        height: 76,
        radius: 16,
        padding: EdgeInsets.symmetric(horizontal: 18),
        child: Row(
          children: [
            _SkeletonCircle(size: 36),
            Spacer(),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _SkeletonBox(width: 62, height: 9, radius: 8),
                SizedBox(height: 9),
                _SkeletonBox(width: 92, height: 22, radius: 8),
              ],
            ),
            Spacer(),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _SkeletonBox(width: 62, height: 9, radius: 8),
                SizedBox(height: 9),
                _SkeletonBox(width: 52, height: 20, radius: 8),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _ProfileAddressesSkeleton extends StatelessWidget {
  const _ProfileAddressesSkeleton();

  @override
  Widget build(BuildContext context) {
    return const _ShimmerPadding(
      child: _SkeletonCard(
        height: 220,
        radius: 18,
        padding: EdgeInsets.all(14),
        child: Column(
          children: [
            Row(
              children: [
                _SkeletonBox(width: 58, height: 10, radius: 8),
                Spacer(),
                _SkeletonBox(width: 70, height: 16, radius: 8),
              ],
            ),
            SizedBox(height: 14),
            _AddressRowSkeleton(),
            SizedBox(height: 10),
            _AddressRowSkeleton(),
            Spacer(),
            _SkeletonBox(height: 42, radius: 14),
          ],
        ),
      ),
    );
  }
}

class _AddressRowSkeleton extends StatelessWidget {
  const _AddressRowSkeleton();

  @override
  Widget build(BuildContext context) {
    return const _SkeletonCard(
      height: 54,
      radius: 14,
      padding: EdgeInsets.symmetric(horizontal: 12),
      child: Row(
        children: [
          _SkeletonCircle(size: 34),
          SizedBox(width: 10),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _SkeletonBox(width: 140, height: 11, radius: 8),
                SizedBox(height: 7),
                _SkeletonBox(width: 94, height: 8, radius: 8),
              ],
            ),
          ),
          _SkeletonCircle(size: 18),
        ],
      ),
    );
  }
}

class _ProfileOptionsSkeleton extends StatelessWidget {
  const _ProfileOptionsSkeleton();

  @override
  Widget build(BuildContext context) {
    return const _ShimmerPadding(
      child: _SkeletonCard(
        height: 260,
        radius: 18,
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: [
                Spacer(),
                _SkeletonBox(width: 118, height: 16, radius: 8),
              ],
            ),
            SizedBox(height: 14),
            _OptionRowSkeleton(),
            _OptionRowSkeleton(),
            _OptionRowSkeleton(),
            _OptionRowSkeleton(),
            _OptionRowSkeleton(),
          ],
        ),
      ),
    );
  }
}

class _OptionRowSkeleton extends StatelessWidget {
  const _OptionRowSkeleton();

  @override
  Widget build(BuildContext context) {
    return const Expanded(
      child: Row(
        children: [
          _SkeletonCircle(size: 16),
          SizedBox(width: 12),
          Expanded(child: _SkeletonBox(height: 10, radius: 8)),
          SizedBox(width: 12),
          _SkeletonCircle(size: 18),
        ],
      ),
    );
  }
}

class _CutCircle extends StatelessWidget {
  const _CutCircle();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 14,
      height: 20,
      decoration: const BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
      ),
    );
  }
}

class _ShimmerPadding extends StatelessWidget {
  const _ShimmerPadding({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: child,
    );
  }
}

class _SkeletonCard extends StatelessWidget {
  const _SkeletonCard({
    required this.child,
    this.width,
    this.height,
    this.radius = 18,
    this.padding = EdgeInsets.zero,
  });

  final Widget child;
  final double? width;
  final double? height;
  final double radius;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      padding: padding,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(radius),
        border: Border.all(color: const Color(0xFFF0F1EF)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: .05),
            blurRadius: 14,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: child,
    );
  }
}

class _SkeletonCircle extends StatelessWidget {
  const _SkeletonCircle({required this.size});

  final double size;

  @override
  Widget build(BuildContext context) {
    return _SkeletonBox(width: size, height: size, radius: size);
  }
}

class _SkeletonBox extends StatelessWidget {
  const _SkeletonBox({required this.height, required this.radius, this.width});

  final double? width;
  final double height;
  final double radius;

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: const Color(0xFFE7EAE7),
      highlightColor: const Color(0xFFF6F8F6),
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(radius),
        ),
      ),
    );
  }
}
