import 'package:flutter/material.dart';

import '../styles/themes.dart';
import 'constant.dart';

class CustomAppBar extends StatelessWidget {
  const CustomAppBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.maxFinite,
      height: 70,
      color: Theme.of(context).scaffoldBackgroundColor,
      child: Column(
        children: [
          SizedBox(height: 6,),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0,vertical: 6),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Image.asset('assets/images/elements.png'),
                Image.asset('assets/images/$logo',width: 36,height: 36,),
              ],
            ),
          ),
          Container(width: double.maxFinite,height: 1,color: borderColor,)
        ],
      ),
    );
  }
}
