import 'package:flutter/material.dart';

import '../../core/ navigation/navigation.dart';
import '../../core/navigation_bar/navigation_bar.dart';
import '../../core/navigation_bar/navigation_bar_admin.dart';
import '../../core/navigation_bar/navigation_bar_agents.dart';
import '../../core/navigation_bar/navigation_bar_restaurant.dart';
import '../../core/network/local/cache_helper.dart';
import '../../core/services/location_service.dart';
import '../../core/widgets/constant.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(seconds: 1), () async {
      Widget? widget;
      if (CacheHelper.getData(key: 'token') == null) {
        token = '';
        id = '';
        adminOrUser = 'user';
        widget = const BottomNavBar();
      } else {
        if (CacheHelper.getData(key: 'role') == null) {
          widget = const BottomNavBar();
          adminOrUser = 'user';
        } else {
          adminOrUser = CacheHelper.getData(key: 'role');
          if (adminOrUser == 'admin') {
            widget = BottomNavBarAdmin();
          } else if (adminOrUser == 'delivery') {
            widget = const BottomNavBarAgents();
          } else if (adminOrUser == 'restaurant') {
            widget = const BottomNavBarRestaurant();
          } else if (adminOrUser == 'user') {
            widget = const BottomNavBar();
          } else {
            widget = const BottomNavBar();
          }
        }
        token = CacheHelper.getData(key: 'token');
        id = CacheHelper.getData(key: 'id') ?? '';
      }
      LocationService.loadCachedLocation();
      await LocationService.startLocationUpdates();

      if (!mounted) return;
      navigateAndFinish(context, widget);
    });
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Expanded(
              child: SizedBox(
                width: double.maxFinite,
                height: double.maxFinite,
                child: Center(
                  child: Image.asset(
                    'assets/images/$logo',
                    width: 80,
                    height: 80,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
