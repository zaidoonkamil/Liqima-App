class RestaurantMenuItemData {
  const RestaurantMenuItemData({
    required this.name,
    required this.description,
    required this.rating,
    required this.price,
    required this.imageUrl,
    this.badge,
  });

  final String name;
  final String description;
  final double rating;
  final int price;
  final String imageUrl;
  final String? badge;
}

class RestaurantDetailData {
  const RestaurantDetailData._();

  static const name = 'بيت الشاورما';
  static const subtitle = 'شاورما · ساندويشات · عربي';
  static const rating = 4.6;
  static const ratingCount = '2.3K';
  static const delivery = 'توصيل مجاني';
  static const deliveryTime = '25-35 د';
  static const offer = 'خصم 15% على الطلبات التي تزيد عن 15,000 د.ع';
  static const coverUrl =
      'https://images.unsplash.com/photo-1555396273-367ea4eb4db5?auto=format&fit=crop&w=1200&q=85';

  static const categories = [
    'الكل',
    'شاورما',
    'ساندويشات',
    'وجبات',
    'مقبلات',
    'مشروبات',
  ];

  static const bestSelling = [
    RestaurantMenuItemData(
      name: 'صحن شاورما دجاج',
      description: 'شاورما دجاج مع البطاطا والمخلل والثوم والخبز العربي',
      rating: 4.7,
      price: 7500,
      badge: 'الأكثر طلباً',
      imageUrl:
          'https://images.unsplash.com/photo-1598515214211-89d3c73ae83b?auto=format&fit=crop&w=700&q=80',
    ),
    RestaurantMenuItemData(
      name: 'ساندويش شاورما لحم',
      description: 'لحم شرائح متبلة مع الخضار والثوم والمخلل',
      rating: 4.6,
      price: 6000,
      imageUrl:
          'https://images.unsplash.com/photo-1626700051175-6818013e1d4f?auto=format&fit=crop&w=700&q=80',
    ),
    RestaurantMenuItemData(
      name: 'وجبة شاورما عربي',
      description: 'ساندويش عربي مع بطاطا ومشروب غازي',
      rating: 4.5,
      price: 5500,
      imageUrl:
          'https://images.unsplash.com/photo-1619740455993-9e612b1af08a?auto=format&fit=crop&w=700&q=80',
    ),
  ];
}
