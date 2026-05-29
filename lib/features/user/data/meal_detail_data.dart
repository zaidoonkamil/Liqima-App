class MealSizeData {
  const MealSizeData({
    required this.title,
    required this.price,
    this.isPopular = false,
  });

  final String title;
  final int price;
  final bool isPopular;
}

class MealExtraData {
  const MealExtraData({
    required this.title,
    required this.price,
    required this.icon,
  });

  final String title;
  final int price;
  final String icon;
}

class MealDetailData {
  const MealDetailData._();

  static const title = 'دجاج مشوي مع رز';
  static const description =
      'دجاج مشوي على الفحم بتتبيلة خاصة، يقدم مع رز بسمتي متبل بالخضار وسلطة خضراء وصوص الثوم.';
  static const price = 7500;
  static const rating = 4.7;
  static const ratingCount = '1.2K';
  static const calories = 320;
  static const imageUrl =
      'https://images.unsplash.com/photo-1598515214211-89d3c73ae83b?auto=format&fit=crop&w=1200&q=90';

  static const sizes = [
    MealSizeData(title: 'كبير', price: 9000),
    MealSizeData(title: 'وسط', price: 7500, isPopular: true),
    MealSizeData(title: 'صغير', price: 5000),
  ];

  static const extras = [
    MealExtraData(title: 'بطاطا مقلية', price: 1500, icon: '🍟'),
    MealExtraData(title: 'مشروب غازي', price: 1000, icon: '🥤'),
    MealExtraData(title: 'خبز عربي', price: 500, icon: '🥖'),
    MealExtraData(title: 'صوص ثوم إضافي', price: 500, icon: '🥣'),
  ];
}
