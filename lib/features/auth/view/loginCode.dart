import 'package:conditional_builder_null_safety/conditional_builder_null_safety.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/ navigation/navigation.dart';
import '../../../core/styles/themes.dart';
import '../../../core/widgets/custom_text_field.dart';
import '../../../core/widgets/show_toast.dart';
import '../cubit/cubit.dart';
import '../cubit/states.dart';
import 'login.dart';

class LoginCode extends StatelessWidget {
  const LoginCode({super.key, required this.phone});

  final String phone;
  static GlobalKey<FormState> formKey = GlobalKey<FormState>();
  static TextEditingController codeController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (BuildContext context) => LoginCubit()..sendOtp(phone: phone, context: context),
      child: BlocConsumer<LoginCubit,LoginStates>(
        listener: (context,state){
          if(state is VerifyOtpSuccessState){
            showToastSuccess(
              text: "تم تفعيل الحساب بنجاح",
              context: context,
            );
            navigateAndFinish(context, Login());
          }
        },
        builder: (context,state){
          var cubit=LoginCubit.get(context);
          return SafeArea(
            child: Scaffold(
              backgroundColor: const Color(0xFFF5F5F5),
              body: SingleChildScrollView(
                physics: AlwaysScrollableScrollPhysics(),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0),
                  child: Form(
                    key: formKey,
                    child: Column(
                      children: [
                        SizedBox(height: 20,),
                        Row(
                          children: [
                            GestureDetector(
                                onTap: (){
                                  navigateBack(context);
                                },
                                child: Icon(Icons.arrow_back_ios_new_rounded,size: 30,),
                            ),
                          ],
                        ),

                        const SizedBox(height: 40),
                        Text(
                          'تفعيل الحساب',
                          style: TextStyle(
                            fontSize: 25,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'قم بأدخال كود التحقق الذي \nوصل الى رقم هاتفك',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        SizedBox(height: 6,),
                        Text(
                          phone,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: primaryColor,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 70),
                        CustomTextField(
                          controller: codeController,
                          hintText: 'ادخل كود التفعيل',
                          prefixIcon: Icons.code,
                          keyboardType: TextInputType.phone,
                          validate: (String? value) {
                            if (value!.isEmpty) {
                              return 'رجائا اخل كود التفعيل';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 60),
                        ConditionalBuilder(
                          condition: state is !VerifyOtpLoadingState,
                          builder: (context){
                            return GestureDetector(
                              onTap: (){
                                if (formKey.currentState!.validate()) {
                                     cubit.verifyOtp(
                                      phone: phone,
                                      code: codeController.text.trim(),
                                      context: context
                                    );
                                }
                              },
                              child: Container(
                                width: double.infinity,
                                height: 48,
                                decoration: BoxDecoration(
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.2),
                                        blurRadius: 10,
                                        spreadRadius: 2,
                                        offset: const Offset(5, 5),
                                      ),
                                    ],
                                    borderRadius:  BorderRadius.circular(12),
                                    color: primaryColor
                                ),
                                child: Center(
                                  child: Text('التحقق',
                                    style: TextStyle(color: Colors.white,fontSize: 18 ),),
                                ),
                              ),
                            );
                          },
                          fallback: (c)=> CircularProgressIndicator(color: primaryColor,),
                        ),
                        const SizedBox(height: 40),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
