import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:iconsax/iconsax.dart';

import '../../../core/styles/themes.dart';

class QuickContactData {
  const QuickContactData({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
}

class FaqData {
  const FaqData({required this.question});

  final String question;
}

class CompanyInfoData {
  const CompanyInfoData({
    required this.title,
    required this.value,
    required this.icon,
  });

  final String title;
  final String value;
  final IconData icon;
}

class ContactPageData {
  const ContactPageData._();

  static const quickContacts = [
    QuickContactData(
      title: 'واتساب',
      subtitle: 'محادثة فورية',
      icon: FontAwesomeIcons.whatsapp,
      color: primaryColor,
    ),
    QuickContactData(
      title: 'اتصل بنا',
      subtitle: 'مكالمة مباشرة',
      icon: Iconsax.call,
      color: secondaryColor,
    ),
    QuickContactData(
      title: 'البريد الإلكتروني',
      subtitle: 'راسلنا',
      icon: Iconsax.sms,
      color: primaryColor,
    ),
    QuickContactData(
      title: 'الدردشة المباشرة',
      subtitle: 'تحدث معنا',
      icon: Iconsax.messages_2,
      color: secondaryColor,
    ),
  ];

  static const faqs = [
    FaqData(question: 'كيف يمكنني تتبع طلبي؟'),
    FaqData(question: 'ما هي طرق الدفع المتاحة؟'),
    FaqData(question: 'كم يستغرق التوصيل؟'),
  ];

  static const companyInfo = [
    CompanyInfoData(
      title: 'رقم الهاتف',
      value: '+964 770 123 4567',
      icon: Iconsax.call,
    ),
    // CompanyInfoData(
    //   title: 'العنوان',
    //   value: 'بغداد، المنصور، شارع 14 رمضان',
    //   icon: Iconsax.location,
    // ),
    CompanyInfoData(
      title: 'البريد الإلكتروني',
      value: 'info@lokmah.com',
      icon: Iconsax.sms,
    ),
  ];
}
