import 'package:flutter/material.dart';

class CustomFormField extends StatelessWidget {
  CustomFormField(
      {super.key,
        this.hintText,
        this.onTap,
        this.textInputType,
        this.width,
        this.height,
        this.validate,
        this.controller,
        this.onTapp,
        this.enabledBorder,
        this.onChanged,
        this.textAlign,
        this.prefixIcon,
        this.colorBorderContent,
        this.textStyleHint,
        this.circleDecouration,
        this.suffixIcon,
        this.validationPassed,
        this.obscureText = false
      });

  void Function(String)? onTapp;
  void Function()? onTap;
  String? hintText;
  TextEditingController? controller;
  String? Function(String?)? validate;
  double? width;
  double? height;
  double? circleDecouration=6;
  bool? obscureText;
  TextInputType? textInputType;
  TextAlign? textAlign;
  TextStyle? textStyleHint;
  Color? enabledBorder;
  Color? colorBorderContent;
  Widget? prefixIcon;
  Widget? suffixIcon;
  void Function(String)? onChanged;
  bool? validationPassed=false;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          height:validationPassed==false? 46:88,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(circleDecouration??10),
            color: colorBorderContent?? Colors.red,
          ),
          child: TextFormField(
            onChanged: onChanged,
            onFieldSubmitted: onTapp,
            onTap: onTap,
            controller: controller,
            keyboardType:textInputType?? TextInputType.text ,
            textAlign:textAlign?? TextAlign.right,
            textAlignVertical: TextAlignVertical.bottom,
            obscureText: obscureText!,
            validator: validate,
            decoration: InputDecoration(
              prefixIcon: prefixIcon,
              hintText: hintText,
              suffixIcon: suffixIcon,
              hintStyle: textStyleHint?? TextStyle(
                color: Color(0XFF808080),
              ),
              disabledBorder: InputBorder.none,
              fillColor:  Theme.of(context).primaryColor,
              focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Theme.of(context).primaryColor, width: 1.5), // Border when focused
                borderRadius: BorderRadius.circular(circleDecouration??10),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(circleDecouration ??10),
                borderSide: BorderSide(
                    color:enabledBorder?? Color(0XFFDBDBDB), width: 1.5), // Border when not focused
              ),
              border: OutlineInputBorder(
                borderSide: BorderSide(
                  color:Theme.of(context).primaryColor,
                  width: 2.0,
                ),
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
        ),
      ],
    );
  }
}