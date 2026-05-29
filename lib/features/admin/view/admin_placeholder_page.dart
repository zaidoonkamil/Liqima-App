import 'package:flutter/material.dart';

import '../../../core/styles/themes.dart';

class AdminPlaceholderPage extends StatelessWidget {
  const AdminPlaceholderPage({super.key, required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
          bottom: false,
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 10, 16, 0),
                child: SizedBox(
                  height: 58,
                  child: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Image.asset('assets/images/logo.png', height: 44),
                        const Text(
                          'إدارة التطبيق',
                          style: TextStyle(
                            color: secondaryColor,
                            fontSize: 7,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              Expanded(
                child: Center(
                  child: Text(
                    title,
                    style: const TextStyle(
                      color: Color(0xFF151B18),
                      fontSize: 16,
                      fontWeight: FontWeight.w900,
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
