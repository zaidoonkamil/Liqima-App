import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';

import '../../../core/styles/themes.dart';
import '../../../core/widgets/user_nav_header.dart';

class FaqPage extends StatefulWidget {
  const FaqPage({super.key});

  @override
  State<FaqPage> createState() => _FaqPageState();
}

class _FaqPageState extends State<FaqPage> {
  String selectedCategory = 'الكل';
  int? expandedIndex = 0;

  List<_FaqItem> get visibleFaqs {
    if (selectedCategory == 'الكل') return _faqItems;
    return _faqItems
        .where((item) => item.category == selectedCategory)
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final faqs = visibleFaqs;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
          bottom: false,
          child: CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            slivers: [
              const UserAppBarSliver(),
              const SliverToBoxAdapter(child: SizedBox(height: 10)),
              const SliverToBoxAdapter(child: _FaqHeroCard()),
              const SliverToBoxAdapter(child: SizedBox(height: 14)),
              SliverToBoxAdapter(
                child: _CategoryTabs(
                  selected: selectedCategory,
                  onChanged:
                      (category) => setState(() {
                        selectedCategory = category;
                        expandedIndex = 0;
                      }),
                ),
              ),
              const SliverToBoxAdapter(child: SizedBox(height: 12)),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    children: [
                      const Icon(
                        Iconsax.message_question,
                        color: primaryColor,
                        size: 18,
                      ),
                      const SizedBox(width: 7),
                      const Text(
                        'الأسئلة الشائعة',
                        style: TextStyle(
                          color: Color(0xFF151B18),
                          fontSize: 14,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const Spacer(),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF3FAF2),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Text(
                          '${faqs.length} سؤال',
                          style: const TextStyle(
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
              const SliverToBoxAdapter(child: SizedBox(height: 10)),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    children: [
                      for (var i = 0; i < faqs.length; i++) ...[
                        _FaqTile(
                          item: faqs[i],
                          expanded: expandedIndex == i,
                          onTap:
                              () => setState(
                                () =>
                                    expandedIndex =
                                        expandedIndex == i ? null : i,
                              ),
                        ),
                        if (i != faqs.length - 1) const SizedBox(height: 8),
                      ],
                    ],
                  ),
                ),
              ),
              const SliverToBoxAdapter(child: SizedBox(height: 14)),
              const SliverToBoxAdapter(child: _StillNeedHelpCard()),
              const SliverToBoxAdapter(child: SizedBox(height: 104)),
            ],
          ),
        ),
      ),
    );
  }
}

class _FaqHeroCard extends StatelessWidget {
  const _FaqHeroCard();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        height: 80,
        padding: const EdgeInsets.all(12),
        decoration: _softDecoration(radius: 16),
        child: Row(
          children: [
            Container(
              width: 58,
              height: 58,
              decoration: BoxDecoration(
                color: primaryColor.withValues(alpha: .10),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Iconsax.message_question,
                color: primaryColor,
                size: 26,
              ),
            ),
            const SizedBox(width: 6),
            const Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'كلشي تحتاج تعرفه',
                    style: TextStyle(
                      color: Color(0xFF151B18),
                      fontSize: 12,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'جمعنالك أهم الأسئلة عن الطلبات، التوصيل، الدفع، والكوبونات حتى توصل للجواب بسرعة.',
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: Color(0xFF747D79),
                      fontSize: 9,
                      height: 1.45,
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

class _CategoryTabs extends StatelessWidget {
  const _CategoryTabs({required this.selected, required this.onChanged});

  final String selected;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 34,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        itemBuilder: (context, index) {
          final category = _categories[index];
          final active = selected == category;
          return InkWell(
            onTap: () => onChanged(category),
            borderRadius: BorderRadius.circular(18),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              height: 34,
              padding: const EdgeInsets.symmetric(horizontal: 13),
              decoration: BoxDecoration(
                color: active ? primaryColor : Colors.white,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(
                  color: active ? primaryColor : const Color(0xFFE7ECE8),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: active ? .08 : .04),
                    blurRadius: active ? 12 : 8,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Center(
                child: Text(
                  category,
                  style: TextStyle(
                    color: active ? Colors.white : const Color(0xFF3D4541),
                    fontSize: 10,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ),
          );
        },
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemCount: _categories.length,
      ),
    );
  }
}

class _FaqTile extends StatelessWidget {
  const _FaqTile({
    required this.item,
    required this.expanded,
    required this.onTap,
  });

  final _FaqItem item;
  final bool expanded;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(15),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 210),
        curve: Curves.easeOut,
        padding: const EdgeInsets.fromLTRB(12, 12, 12, 11),
        decoration: BoxDecoration(
          color: expanded ? const Color(0xFFF8FBF8) : Colors.white,
          borderRadius: BorderRadius.circular(15),
          border: Border.all(
            color:
                expanded
                    ? primaryColor.withValues(alpha: .25)
                    : const Color(0xFFEDEFED),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: .05),
              blurRadius: 13,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Column(
          children: [
            Row(
              children: [
                Container(
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    color: item.color.withValues(alpha: .10),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(item.icon, color: item.color, size: 15),
                ),
                const SizedBox(width: 9),
                Expanded(
                  child: Text(
                    item.question,
                    style: const TextStyle(
                      color: Color(0xFF151B18),
                      fontSize: 11,
                      fontWeight: FontWeight.w900,
                      height: 1.35,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                AnimatedRotation(
                  turns: expanded ? .25 : 0,
                  duration: const Duration(milliseconds: 180),
                  child: const Icon(
                    Iconsax.arrow_left_2,
                    color: primaryColor,
                    size: 16,
                  ),
                ),
              ],
            ),
            AnimatedCrossFade(
              firstChild: const SizedBox.shrink(),
              secondChild: Padding(
                padding: const EdgeInsets.only(top: 10, right: 37),
                child: Text(
                  item.answer,
                  style: const TextStyle(
                    color: Color(0xFF68716D),
                    fontSize: 9,
                    height: 1.7,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              crossFadeState:
                  expanded
                      ? CrossFadeState.showSecond
                      : CrossFadeState.showFirst,
              duration: const Duration(milliseconds: 180),
            ),
          ],
        ),
      ),
    );
  }
}

class _StillNeedHelpCard extends StatelessWidget {
  const _StillNeedHelpCard();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        height: 54,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(
          color: const Color(0xFFF3FAF2),
          borderRadius: BorderRadius.circular(15),
          border: Border.all(color: primaryColor.withValues(alpha: .10)),
        ),
        child: const Row(
          children: [
            Icon(Iconsax.headphone, color: primaryColor, size: 20),
            SizedBox(width: 9),
            Expanded(
              child: Text(
                'بعدك محتاج مساعدة؟ فريق الدعم موجود حتى يجاوبك بأسرع وقت.',
                style: TextStyle(
                  color: Color(0xFF1D4534),
                  fontSize: 10,
                  fontWeight: FontWeight.w900,
                  height: 1.45,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FaqItem {
  const _FaqItem({
    required this.category,
    required this.question,
    required this.answer,
    required this.icon,
    required this.color,
  });

  final String category;
  final String question;
  final String answer;
  final IconData icon;
  final Color color;
}

const _categories = ['الكل', 'الطلبات', 'التوصيل', 'الدفع', 'الحساب'];

const _faqItems = [
  _FaqItem(
    category: 'الطلبات',
    question: 'شلون أتابع حالة طلبي؟',
    answer:
        'تقدر تتابع الطلب من صفحة طلباتي. الحالة تتحدث مباشرة من المطعم أو الدلفري، وتشوف إذا الطلب قيد التحضير، جاهز، في الطريق، أو تم التوصيل.',
    icon: Iconsax.bag_tick,
    color: primaryColor,
  ),
  _FaqItem(
    category: 'الطلبات',
    question: 'أكدر أعدل الطلب بعد ما أرسله؟',
    answer:
        'بعد تأكيد الطلب يوصل للمطعم مباشرة. إذا تحتاج تعديل سريع، تواصل ويه الدعم أو المطعم قبل ما يدخل الطلب مرحلة التحضير.',
    icon: Iconsax.edit,
    color: secondaryColor,
  ),
  _FaqItem(
    category: 'التوصيل',
    question: 'شلون ينحسب سعر التوصيل؟',
    answer:
        'سعر التوصيل يعتمد على سياسة المطعم والمسافة بين عنوانك والمطعم. بعض المطاعم توفر توصيل مجاني ضمن مسافة محددة، وقد تضاف رسوم التطبيق حسب إعداد المطعم.',
    icon: Iconsax.truck_fast,
    color: primaryColor,
  ),
  _FaqItem(
    category: 'التوصيل',
    question: 'ليش لازم أحدد عنواني من الخريطة؟',
    answer:
        'تحديد العنوان من الخريطة يساعد المطعم والدلفري يعرفون موقعك بدقة، ويخلي حساب المسافة ووقت التوصيل أقرب للواقع.',
    icon: Iconsax.location,
    color: Color(0xFF667085),
  ),
  _FaqItem(
    category: 'الدفع',
    question: 'شنو طرق الدفع المتاحة؟',
    answer:
        'حالياً تقدر تختار الدفع عند الاستلام. وراح يتم تفعيل طرق دفع إضافية مثل البطاقة وApple Pay حسب توفرها داخل التطبيق.',
    icon: Iconsax.card,
    color: secondaryColor,
  ),
  _FaqItem(
    category: 'الدفع',
    question: 'شلون أستخدم الكوبون؟',
    answer:
        'من صفحة السلة اضغط إضافة كوبون، اختار الكوبون المناسب، وبعدها يرجع التطبيق للسلة ويحسب الخصم تلقائياً ضمن ملخص الطلب.',
    icon: Icons.confirmation_number_outlined,
    color: primaryColor,
  ),
  _FaqItem(
    category: 'الحساب',
    question: 'هل أحتاج أسجل دخول حتى أطلب؟',
    answer:
        'تقدر تتصفح المطاعم والوجبات بدون تسجيل، لكن إضافة للسلة، الطلبات، المفضلة، العناوين، والإشعارات تحتاج تسجيل دخول.',
    icon: Iconsax.user,
    color: primaryColor,
  ),
  _FaqItem(
    category: 'الحساب',
    question: 'شلون أغير صورتي الشخصية؟',
    answer:
        'من الملف الشخصي افتح معلومات الحساب. هناك تقدر تعرض بياناتك وتغيّر صورة الحساب إذا احتجت.',
    icon: Iconsax.gallery,
    color: secondaryColor,
  ),
];

BoxDecoration _softDecoration({required double radius}) {
  return BoxDecoration(
    color: Colors.white,
    borderRadius: BorderRadius.circular(radius),
    border: Border.all(color: const Color(0xFFF0F1EF)),
    boxShadow: [
      BoxShadow(
        color: Colors.black.withValues(alpha: .07),
        blurRadius: 18,
        offset: const Offset(0, 8),
      ),
    ],
  );
}
