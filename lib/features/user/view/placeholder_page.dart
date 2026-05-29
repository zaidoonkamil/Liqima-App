import 'package:flutter/material.dart';

import '../../../core/widgets/user_nav_header.dart';

class PlaceholderPage extends StatelessWidget {
  const PlaceholderPage({super.key, required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
          bottom: false,
          child: CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              const UserNavHeaderSliver(),
              SliverFillRemaining(
                hasScrollBody: false,
                child: Center(
                  child: Text(
                    title,
                    style: const TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.w900,
                      color: Color(0xFF17231C),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
