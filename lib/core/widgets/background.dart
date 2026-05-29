import 'package:flutter/material.dart';

class Background extends StatelessWidget {
  const Background({super.key});

  @override
  Widget build(BuildContext context) {
    return  Container(
      width: double.infinity,
      height: double.infinity,
      child: Image.asset(
        'assets/images/patren.png',
        fit: BoxFit.fill,
      ),
    );
  }
}
