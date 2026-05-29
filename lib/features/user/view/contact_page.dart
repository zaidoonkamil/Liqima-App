import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:liqima/core/widgets/user_nav_header.dart';

import '../../../core/styles/themes.dart';
import '../data/contact_page_data.dart';

class ContactPage extends StatelessWidget {
  const ContactPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
          bottom: false,
          child: CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            slivers: const [
              UserAppBarSliver(),
              SliverToBoxAdapter(child: SizedBox(height: 16)),
              SliverToBoxAdapter(child: _SupportCard()),
              SliverToBoxAdapter(child: SizedBox(height: 18)),
              SliverToBoxAdapter(child: _SectionTitle(title: 'تواصل سريع')),
              SliverToBoxAdapter(child: SizedBox(height: 10)),
              SliverToBoxAdapter(child: _QuickContactGrid()),
              SliverToBoxAdapter(child: SizedBox(height: 10)),
              SliverToBoxAdapter(child: _MessageForm()),
              // SliverToBoxAdapter(child: SizedBox(height: 18)),
              // SliverToBoxAdapter(
              //   child: _SectionTitle(
              //     title: 'الأسئلة الشائعة',
              //     action: 'عرض الكل',
              //   ),
              // ),
              // SliverToBoxAdapter(child: SizedBox(height: 10)),
              // SliverToBoxAdapter(child: _FaqList()),
              SliverToBoxAdapter(child: SizedBox(height: 18)),
              SliverToBoxAdapter(child: _CompanyInfo()),
              SliverToBoxAdapter(child: SizedBox(height: 104)),
            ],
          ),
        ),
      ),
    );
  }
}

class _SupportCard extends StatelessWidget {
  const _SupportCard();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        height: 90,
        padding: const EdgeInsets.all(14),
        decoration: _softDecoration(radius: 16),
        child: Row(
          children: [
            Image.asset('assets/images/calcenter.png', width: 50),
            const SizedBox(width: 6),
            const Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'خدمة العملاء',
                    style: TextStyle(
                      color: Color(0xFF151B18),
                      fontSize: 12,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  SizedBox(height: 2),
                  Text(
                    'متواجدون على مدار الساعة للرد على استفساراتك وملاحظاتك',
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: Color(0xFF747D79),
                      fontSize: 9,
                      height: 1.5,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 10),
            Container(
              width: 70,
              height: 74,
              decoration: BoxDecoration(
                color: const Color(0xFFF1FAF3),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'متوفر',
                    style: TextStyle(
                      color: primaryColor,
                      fontSize: 8,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  SizedBox(height: 5),
                  Text(
                    '24/7',
                    style: TextStyle(
                      color: primaryColor,
                      fontSize: 15,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  SizedBox(height: 3),
                  Text(
                    'للخدمة',
                    style: TextStyle(
                      color: primaryColor,
                      fontSize: 8,
                      fontWeight: FontWeight.w900,
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

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.title, this.action});

  final String title;
  final String? action;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          Text(
            title,
            style: const TextStyle(
              color: Color(0xFF151B18),
              fontSize: 12,
              fontWeight: FontWeight.w900,
            ),
          ),
          const Spacer(),
          if (action != null)
            Row(
              children: [
                Text(
                  action!,
                  style: const TextStyle(
                    color: primaryColor,
                    fontSize: 10,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const Icon(
                  Icons.chevron_right_rounded,
                  color: primaryColor,
                  size: 18,
                ),
              ],
            ),
        ],
      ),
    );
  }
}

class _QuickContactGrid extends StatelessWidget {
  const _QuickContactGrid();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          for (var i = 0; i < ContactPageData.quickContacts.length; i++) ...[
            Expanded(
              child: _QuickContactCard(data: ContactPageData.quickContacts[i]),
            ),
            if (i != ContactPageData.quickContacts.length - 1)
              const SizedBox(width: 4),
          ],
        ],
      ),
    );
  }
}

class _QuickContactCard extends StatelessWidget {
  const _QuickContactCard({required this.data});

  final QuickContactData data;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 84,
      decoration: _softDecoration(radius: 12),
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 12),
      child: Column(
        children: [
          Icon(data.icon, color: data.color, size: 28),
          const Spacer(),
          Text(
            data.title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Color(0xFF151B18),
              fontSize: 8,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            data.subtitle,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Color(0xFF747D79),
              fontSize: 6,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _MessageForm extends StatelessWidget {
  const _MessageForm();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        padding: const EdgeInsets.fromLTRB(14, 14, 14, 14),
        decoration: _softDecoration(radius: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'أرسل لنا رسالة',
              style: TextStyle(
                color: Color(0xFF151B18),
                fontSize: 12,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _InputBox(
                    label: 'الاسم',
                    hint: 'اكتب اسمك',
                    textAlign: TextAlign.right,
                    alignEnd: true,
                  ),
                ),
                const SizedBox(width: 4),
                Expanded(
                  child: _InputBox(
                    label: 'البريد الإلكتروني',
                    hint: 'example@mail.com',
                    keyboardType: TextInputType.emailAddress,
                    textAlign: TextAlign.center,
                    alignEnd: false,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            const _InputBox(
              label: 'موضوع الرسالة',
              hint: 'اكتب موضوع الرسالة',
              textAlign: TextAlign.right,
              alignEnd: true,
            ),
            const SizedBox(height: 4),
            const _TextAreaBox(),
            const SizedBox(height: 10),
            Container(
              height: 36,
              decoration: BoxDecoration(
                color: primaryColor,
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Iconsax.send_2, color: Colors.white, size: 18),
                  SizedBox(width: 10),
                  Text(
                    'إرسال الرسالة',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w900,
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

class _InputBox extends StatelessWidget {
  const _InputBox({
    required this.label,
    required this.hint,
    required this.alignEnd,
    this.keyboardType,
    this.textAlign = TextAlign.right,
  });

  final String label;
  final String hint;
  final bool alignEnd;
  final TextInputType? keyboardType;
  final TextAlign textAlign;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 54,
      child: TextFormField(
        keyboardType: keyboardType,
        textAlign: textAlign,
        textDirection: TextDirection.rtl,
        style: const TextStyle(
          color: Color(0xFF151B18),
          fontSize: 10,
          fontWeight: FontWeight.w800,
        ),
        decoration: InputDecoration(
          filled: true,
          fillColor: Colors.white,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 12,
            vertical: 7,
          ),
          labelText: label,
          labelStyle: const TextStyle(
            color: Color(0xFF151B18),
            fontSize: 9,
            fontWeight: FontWeight.w800,
          ),
          floatingLabelAlignment:
              alignEnd
                  ? FloatingLabelAlignment.start
                  : FloatingLabelAlignment.center,
          hintText: hint,
          hintTextDirection: TextDirection.rtl,
          hintStyle: const TextStyle(
            color: Color(0xFFA0A5A3),
            fontSize: 9,
            fontWeight: FontWeight.w700,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: Color(0xFFE8EAE8)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: primaryColor),
          ),
        ),
      ),
    );
  }
}

class _TextAreaBox extends StatelessWidget {
  const _TextAreaBox();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 98,
      child: TextFormField(
        maxLines: null,
        expands: true,
        maxLength: 500,
        textAlign: TextAlign.right,
        textDirection: TextDirection.rtl,
        style: const TextStyle(
          color: Color(0xFF151B18),
          fontSize: 10,
          fontWeight: FontWeight.w800,
        ),
        decoration: InputDecoration(
          filled: true,
          fillColor: Colors.white,
          alignLabelWithHint: true,
          contentPadding: const EdgeInsets.fromLTRB(12, 10, 12, 8),
          labelText: 'رسالتك',
          labelStyle: const TextStyle(
            color: Color(0xFF151B18),
            fontSize: 9,
            fontWeight: FontWeight.w800,
          ),
          hintText: 'اكتب رسالتك هنا...',
          hintTextDirection: TextDirection.rtl,
          hintStyle: const TextStyle(
            color: Color(0xFFA0A5A3),
            fontSize: 9,
            fontWeight: FontWeight.w700,
          ),
          counterStyle: const TextStyle(
            color: Color(0xFF747D79),
            fontSize: 8,
            fontWeight: FontWeight.w700,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: Color(0xFFE8EAE8)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: primaryColor),
          ),
        ),
      ),
    );
  }
}

class _FaqList extends StatelessWidget {
  const _FaqList();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        decoration: _softDecoration(radius: 16),
        child: Column(
          children: [
            for (var i = 0; i < ContactPageData.faqs.length; i++) ...[
              _FaqTile(faq: ContactPageData.faqs[i]),
              if (i != ContactPageData.faqs.length - 1)
                const Divider(height: 1, color: Color(0xFFF0F1EF)),
            ],
          ],
        ),
      ),
    );
  }
}

class _FaqTile extends StatelessWidget {
  const _FaqTile({required this.faq});

  final FaqData faq;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 44,
      child: Row(
        children: [
          const SizedBox(width: 14),
          const Icon(Iconsax.message_question, color: primaryColor, size: 18),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              faq.question,
              style: const TextStyle(
                color: Color(0xFF151B18),
                fontSize: 10,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          const Icon(Iconsax.arrow_left_2, color: Color(0xFF555D59), size: 15),
          const SizedBox(width: 12),
        ],
      ),
    );
  }
}

class _CompanyInfo extends StatelessWidget {
  const _CompanyInfo();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'معلومات عنا',
            style: TextStyle(
              color: Color(0xFF151B18),
              fontSize: 12,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              for (var i = 0; i < ContactPageData.companyInfo.length; i++) ...[
                Expanded(
                  child: _CompanyInfoItem(data: ContactPageData.companyInfo[i]),
                ),
                if (i != ContactPageData.companyInfo.length - 1)
                  Container(
                    width: 1,
                    height: 38,
                    color: const Color(0xFFE7EAE7),
                  ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}

class _CompanyInfoItem extends StatelessWidget {
  const _CompanyInfoItem({required this.data});

  final CompanyInfoData data;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(data.icon, color: primaryColor, size: 22),
        const SizedBox(width: 8),
        Column(
          children: [
            Text(
              data.title,
              style: const TextStyle(
                color: Color(0xFF747D79),
                fontSize: 8,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 5),
            Text(
              data.value,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Color(0xFF151B18),
                fontSize: 8,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
      ],
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
