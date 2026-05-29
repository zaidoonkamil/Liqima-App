import 'package:conditional_builder_null_safety/conditional_builder_null_safety.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:iconsax/iconsax.dart';

import '../../../core/ navigation/navigation.dart';
import '../../../core/styles/themes.dart';
import '../../../core/widgets/show_toast.dart';
import '../cubit/cubit.dart';
import '../cubit/states.dart';
import 'login.dart';
import 'loginCode.dart';

class Register extends StatelessWidget {
  const Register({super.key});

  static final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  static final TextEditingController userNameController =
      TextEditingController();
  static final TextEditingController phoneController = TextEditingController();
  static final TextEditingController passwordController =
      TextEditingController();
  static final TextEditingController rePasswordController =
      TextEditingController();

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (BuildContext context) => LoginCubit(),
      child: BlocConsumer<LoginCubit, LoginStates>(
        listener: (context, state) {
          if (state is SignUpSuccessState) {
            final phone =
                LoginCubit.get(context).phonee ?? phoneController.text.trim();
            userNameController.clear();
            phoneController.clear();
            passwordController.clear();
            rePasswordController.clear();
            showToastSuccess(text: 'تم انشاء الحساب بنجاح', context: context);
            navigateAndFinish(context, LoginCode(phone: phone));
          }
        },
        builder: (context, state) {
          final cubit = LoginCubit.get(context);
          return Directionality(
            textDirection: TextDirection.rtl,
            child: Scaffold(
              resizeToAvoidBottomInset: false,
              backgroundColor: Colors.white,
              body: Stack(
                children: [
                  Image.asset(
                    'assets/images/backgroundlogin.png',
                    width: double.maxFinite,
                    height: double.maxFinite,
                    fit: BoxFit.cover,
                  ),
                  SafeArea(
                    child: SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      padding: const EdgeInsets.fromLTRB(18, 18, 18, 28),
                      child: Form(
                        key: formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            SizedBox(height: 60),
                            Image.asset('assets/images/logo.png', height: 80),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  'الطعم اللي تحبه...يوصلك بلگمة',
                                  style: TextStyle(
                                    color: Color(0xFF343A40),
                                    fontWeight: FontWeight.w700,
                                    fontSize: 8,
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 40),
                            Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Text(
                                  'انشاء حساب جديد',
                                  style: TextStyle(
                                    color: Colors.black,
                                    fontWeight: FontWeight.w700,
                                    fontSize: 15,
                                  ),
                                ),
                                SizedBox(height: 2),
                                Text(
                                  'انشئ حسابك واستمتع بتجربة مميزة',
                                  style: TextStyle(
                                    color: Color(0xFF343A40),
                                    fontWeight: FontWeight.w700,
                                    fontSize: 8,
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 20),

                            _NameField(
                              controller: userNameController,
                              validator: (value) {
                                if (value == null || value.trim().isEmpty) {
                                  return 'رجاءً ادخل الاسم الكامل';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 12),
                            _PhoneField(
                              controller: phoneController,
                              validator: (value) {
                                if (value == null || value.trim().isEmpty) {
                                  return 'رجاءً ادخل رقم الهاتف';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 12),
                            _PasswordField(
                              controller: passwordController,
                              hint: 'أدخل كلمة المرور',
                              isHidden: cubit.isPasswordHidden,
                              onToggle: cubit.togglePasswordVisibility,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'رجاءً ادخل كلمة المرور';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 12),
                            _PasswordField(
                              controller: rePasswordController,
                              hint: 'أعد إدخال كلمة المرور',
                              isHidden: cubit.isPasswordHidden2,
                              onToggle: cubit.togglePasswordVisibility2,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'رجاءً أعد إدخال كلمة المرور';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 14),
                            ConditionalBuilder(
                              condition: state is! SignUpLoadingState,
                              builder: (context) {
                                return _CreateAccountButton(
                                  onTap: () {
                                    if (formKey.currentState!.validate()) {
                                      if (passwordController.text ==
                                          rePasswordController.text) {
                                        cubit.signUp(
                                          name: userNameController.text.trim(),
                                          phone: phoneController.text.trim(),
                                          location: '',
                                          password:
                                              passwordController.text.trim(),
                                          role: 'user',
                                          context: context,
                                        );
                                      } else {
                                        showToastError(
                                          text: 'كلمة المرور غير متطابقة',
                                          context: context,
                                        );
                                      }
                                    }
                                  },
                                );
                              },
                              fallback:
                                  (context) => const Center(
                                    child: CircularProgressIndicator(
                                      color: primaryColor,
                                    ),
                                  ),
                            ),
                            const SizedBox(height: 24),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Text(
                                  'لديك حساب بالفعل ؟',
                                  style: TextStyle(
                                    color: Color(0xFF5D646B),
                                    fontWeight: FontWeight.w600,
                                    fontSize: 11,
                                  ),
                                ),
                                const SizedBox(width: 4),
                                GestureDetector(
                                  onTap:
                                      () => navigateTo(context, const Login()),
                                  child: const Text(
                                    'تسجيل الدخول',
                                    style: TextStyle(
                                      color: secondaryColor,
                                      fontWeight: FontWeight.w800,
                                      fontSize: 11,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 24),
                          ],
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    left: 20,
                    top: 40,
                    child: _AppBarCircleButton(
                      icon: Icons.arrow_forward_ios,
                      onTap: () => navigateBack(context),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

BoxDecoration _softDecoration({required double radius}) {
  return BoxDecoration(
    color: Colors.white,
    borderRadius: BorderRadius.circular(radius),
    border: Border.all(color: const Color(0xFFF0F1EF)),
    boxShadow: [
      BoxShadow(
        color: Colors.black.withValues(alpha: .06),
        blurRadius: 14,
        offset: const Offset(0, 7),
      ),
    ],
  );
}

class _AppBarCircleButton extends StatelessWidget {
  const _AppBarCircleButton({required this.icon, required this.onTap});

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      customBorder: const CircleBorder(),
      child: Container(
        width: 36,
        height: 36,
        decoration: _softDecoration(radius: 18),
        child: Icon(icon, color: const Color(0xFF151B18), size: 17),
      ),
    );
  }
}

class _NameField extends StatelessWidget {
  const _NameField({required this.controller, required this.validator});

  final TextEditingController controller;
  final String? Function(String?) validator;

  @override
  Widget build(BuildContext context) {
    return _BaseField(
      child: TextFormField(
        controller: controller,
        validator: validator,
        textAlign: TextAlign.right,
        decoration: const InputDecoration(
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(horizontal: 14, vertical: 9),
          hintText: 'اكتب اسمك الكامل',
          labelText: 'الاسم الكامل',
          hintStyle: _hintStyle,
          labelStyle: _labelStyle,
          suffixIcon: Icon(Iconsax.user, color: primaryColor, size: 20),
        ),
      ),
    );
  }
}

class _PhoneField extends StatelessWidget {
  const _PhoneField({required this.controller, required this.validator});

  final TextEditingController controller;
  final String? Function(String?) validator;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 44,
      decoration: _fieldDecoration(),
      clipBehavior: Clip.antiAlias,
      child: Directionality(
        textDirection: TextDirection.ltr,
        child: Row(
          children: [
            Container(
              width: 112,
              height: double.infinity,
              alignment: Alignment.center,
              decoration: const BoxDecoration(
                color: Color(0xFFF8F8F8),
                border: Border(right: BorderSide(color: Color(0xFFE3E5E6))),
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('🇮🇶', style: TextStyle(fontSize: 20)),
                  SizedBox(width: 8),
                  Text(
                    '+964',
                    style: TextStyle(
                      color: Color(0xFF111827),
                      fontWeight: FontWeight.w800,
                      fontSize: 12,
                    ),
                  ),
                  SizedBox(width: 4),
                  Icon(Icons.keyboard_arrow_down_rounded, size: 16),
                ],
              ),
            ),
            Expanded(
              child: Directionality(
                textDirection: TextDirection.rtl,
                child: TextFormField(
                  controller: controller,
                  keyboardType: TextInputType.phone,
                  textAlign: TextAlign.right,
                  validator: validator,
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 9,
                    ),
                    hintText: 'مثال: 0770 123 4567',
                    labelText: 'رقم الهاتف',
                    hintStyle: _hintStyle,
                    labelStyle: _labelStyle,
                    suffixIcon: Icon(
                      Iconsax.call,
                      color: primaryColor,
                      size: 20,
                    ),
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

class _PasswordField extends StatelessWidget {
  const _PasswordField({
    required this.controller,
    required this.hint,
    required this.isHidden,
    required this.onToggle,
    required this.validator,
  });

  final TextEditingController controller;
  final String hint;
  final bool isHidden;
  final VoidCallback onToggle;
  final String? Function(String?) validator;

  @override
  Widget build(BuildContext context) {
    return _BaseField(
      child: TextFormField(
        controller: controller,
        obscureText: isHidden,
        validator: validator,
        textAlign: TextAlign.right,
        decoration: InputDecoration(
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 14,
            vertical: 9,
          ),
          hintText: hint,
          labelText:
              hint == 'أدخل كلمة المرور' ? 'كلمة المرور' : 'تأكيد كلمة المرور',
          hintStyle: _hintStyle,
          labelStyle: _labelStyle,
          suffixIcon: IconButton(
            onPressed: onToggle,
            icon: Icon(
              isHidden ? Iconsax.eye_slash : Iconsax.eye,
              color: const Color(0xFF6B7280),
              size: 20,
            ),
          ),
          prefixIcon: const Icon(Iconsax.lock, color: primaryColor, size: 20),
        ),
      ),
    );
  }
}

class _BaseField extends StatelessWidget {
  const _BaseField({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(height: 44, decoration: _fieldDecoration(), child: child);
  }
}

class _TermsRow extends StatelessWidget {
  const _TermsRow();

  @override
  Widget build(BuildContext context) {
    return const Row(
      children: [
        Icon(Icons.check_box_rounded, color: primaryColor, size: 18),
        SizedBox(width: 8),
        Expanded(
          child: Text(
            'أوافق على الشروط والأحكام وسياسة الخصوصية',
            style: TextStyle(
              color: primaryColor,
              fontSize: 9,
              fontWeight: FontWeight.w900,
            ),
          ),
        ),
      ],
    );
  }
}

class _CreateAccountButton extends StatelessWidget {
  const _CreateAccountButton({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 40,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          gradient: const LinearGradient(
            colors: [Color(0xFF0B7A43), primaryColor],
            begin: Alignment.centerRight,
            end: Alignment.centerLeft,
          ),
        ),
        alignment: Alignment.center,
        child: const Text(
          'إنشاء حساب',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w800,
            fontSize: 13,
          ),
        ),
      ),
    );
  }
}

BoxDecoration _fieldDecoration() {
  return BoxDecoration(
    color: Colors.white,
    borderRadius: BorderRadius.circular(10),
    border: Border.all(color: const Color(0xFFE3E5E6)),
  );
}

const _hintStyle = TextStyle(
  color: Color(0xFF8E9295),
  fontSize: 11,
  fontWeight: FontWeight.w700,
);

const _labelStyle = TextStyle(
  color: Color(0xFF111827),
  fontSize: 10,
  fontWeight: FontWeight.w800,
);
