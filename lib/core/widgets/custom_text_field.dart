import 'package:flutter/material.dart';

import '../styles/themes.dart';

class CustomTextField extends StatelessWidget {
  final String hintText;
  final IconData? prefixIcon;
  final Widget? suffixIcon;
  final TextInputType keyboardType;
  final bool obscureText;
  final String? Function(String?)? validate;
  final void Function()? onTap;
  final TextEditingController? controller;
  final int maxLines;

  const CustomTextField({
    super.key,
    this.controller,
    this.validate,
    required this.hintText,
    this.onTap,
    this.prefixIcon,
    this.suffixIcon,
    this.keyboardType = TextInputType.text,
    this.obscureText = false,
    this.maxLines = 1,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(46),
        border: Border.all(
          color: borderColor ,
          width: 1,
        ),
      ),
      child: TextFormField(
        textAlign:TextAlign.right,
        keyboardType: keyboardType,
        obscureText: obscureText,
        controller: controller,
        maxLines: maxLines,
        validator: validate,
        onTap: onTap,
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: TextStyle(
            color: Color(0XFF949D9E)
          ),
          border: InputBorder.none,
          prefixIcon: suffixIcon ,
        ),
      ),
    );
  }
}
