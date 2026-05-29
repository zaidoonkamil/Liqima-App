import 'package:conditional_builder_null_safety/conditional_builder_null_safety.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:iconsax/iconsax.dart';
import 'package:liqima/features/auth/view/register.dart';

import '../../../core/ navigation/navigation.dart';
import '../../../core/network/local/cache_helper.dart';
import '../../../core/navigation_bar/navigation_bar.dart';
import '../../../core/navigation_bar/navigation_bar_admin.dart';
import '../../../core/navigation_bar/navigation_bar_agents.dart';
import '../../../core/navigation_bar/navigation_bar_restaurant.dart';
import '../../../core/services/location_service.dart';
import '../../../core/styles/themes.dart';
import '../../../core/widgets/constant.dart';
import '../../../core/widgets/show_toast.dart' show showToastError;
import '../cubit/cubit.dart';
import '../cubit/states.dart';
import 'loginCode.dart';

class Login extends StatefulWidget {
  const Login({super.key});

  static final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  static final TextEditingController userNameController =
      TextEditingController();
  static final TextEditingController passwordController =
      TextEditingController();
  static bool isValidationPassed = false;

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  bool rememberMe = true;
  bool completingLogin = false;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (BuildContext context) => LoginCubit(),
      child: BlocConsumer<LoginCubit, LoginStates>(
        listener: (context, state) async {
          if (state is LoginSuccessState) {
            if (mounted) setState(() => completingLogin = true);
            final loginCubit = LoginCubit.get(context);
            final role = loginCubit.role.toString();
            final isUser = role == 'user';

            if (loginCubit.isVerified == true || !isUser) {
              await CacheHelper.saveData(key: 'token', value: loginCubit.token);
              await CacheHelper.saveData(key: 'id', value: loginCubit.id);
              await CacheHelper.saveData(key: 'role', value: role);

              token = loginCubit.token.toString();
              id = loginCubit.id.toString();
              adminOrUser = role;
              await LocationService.startLocationUpdates();

              if (!context.mounted) return;
              if (role == 'restaurant') {
                navigateAndFinish(context, const BottomNavBarRestaurant());
              } else if (role == 'admin') {
                navigateAndFinish(context, const BottomNavBarAdmin());
              } else if (role == 'delivery') {
                navigateAndFinish(context, const BottomNavBarAgents());
              } else {
                navigateAndFinish(context, const BottomNavBar());
              }
            } else if (loginCubit.isVerified == false && isUser) {
              if (mounted) setState(() => completingLogin = false);
              if (!context.mounted) return;
              navigateTo(context, LoginCode(phone: loginCubit.phonee!));
            } else {
              if (mounted) setState(() => completingLogin = false);
              if (!context.mounted) return;
              showToastError(text: 'حدث خطأ', context: context);
            }
          } else if (state is LoginAccountNotVerifiedState) {
            if (mounted) setState(() => completingLogin = false);
            final loginCubit = LoginCubit.get(context);
            if (!context.mounted) return;
            navigateTo(
              context,
              LoginCode(
                phone:
                    loginCubit.phonee ?? Login.userNameController.text.trim(),
              ),
            );
          } else if (state is LoginErrorState) {
            if (mounted) setState(() => completingLogin = false);
          }
        },
        builder: (context, state) {
          final cubit = LoginCubit.get(context);
          final isLoading = state is LoginLoadingState || completingLogin;

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
                  ),
                  SafeArea(
                    child: SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      padding: const EdgeInsets.fromLTRB(4, 10, 4, 28),
                      child: Form(
                        key: Login.formKey,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16.0),
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
                                    'مرحبا بعودتك !',
                                    style: TextStyle(
                                      color: Colors.black,
                                      fontWeight: FontWeight.w700,
                                      fontSize: 15,
                                    ),
                                  ),
                                  SizedBox(height: 2),
                                  Text(
                                    'سجل دخولك واطلب من اطباقك المفضلة',
                                    style: TextStyle(
                                      color: Color(0xFF343A40),
                                      fontWeight: FontWeight.w700,
                                      fontSize: 8,
                                    ),
                                  ),
                                ],
                              ),

                              SizedBox(height: 20),
                              _PhoneField(
                                controller: Login.userNameController,
                                validator: (value) {
                                  if (value == null || value.trim().isEmpty) {
                                    return 'رجاءً ادخل رقم الهاتف';
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: 18),
                              _PasswordField(
                                controller: Login.passwordController,
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
                              Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  GestureDetector(
                                    onTap: () {
                                      showToastError(
                                        text:
                                            'ميزة استعادة كلمة المرور غير مفعلة حالياً',
                                        context: context,
                                      );
                                    },
                                    child: const Text(
                                      'نسيت كلمة المرور؟',
                                      style: TextStyle(
                                        color: primaryColor,
                                        fontWeight: FontWeight.w800,
                                        fontSize: 11,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 26),
                              ConditionalBuilder(
                                condition: !isLoading,
                                builder: (context) {
                                  return _PrimaryLoginButton(
                                    onTap: () {
                                      FocusManager.instance.primaryFocus
                                          ?.unfocus();
                                      if (Login.formKey.currentState!
                                          .validate()) {
                                        cubit.signIn(
                                          phone:
                                              Login.userNameController.text
                                                  .trim(),
                                          password:
                                              Login.passwordController.text
                                                  .trim(),
                                          context: context,
                                        );
                                      }
                                    },
                                  );
                                },
                                fallback:
                                    (context) => const _LoginLoadingButton(),
                              ),
                              const SizedBox(height: 18),
                              const _DividerLabel(),
                              const SizedBox(height: 24),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Text(
                                    'ليس لديك حساب؟',
                                    style: TextStyle(
                                      color: Color(0xFF5D646B),
                                      fontWeight: FontWeight.w600,
                                      fontSize: 11,
                                    ),
                                  ),
                                  const SizedBox(width: 4),
                                  GestureDetector(
                                    onTap:
                                        () => navigateTo(context, Register()),
                                    child: const Text(
                                      'إنشاء حساب جديد',
                                      style: TextStyle(
                                        color: secondaryColor,
                                        fontWeight: FontWeight.w800,
                                        fontSize: 11,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
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

class _PhoneField extends StatelessWidget {
  const _PhoneField({required this.controller, required this.validator});

  final TextEditingController controller;
  final String? Function(String?) validator;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 44,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFE3E5E6)),
      ),
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
                      vertical: 17,
                    ),
                    hintText: 'رقم الهاتف',
                    hintStyle: TextStyle(
                      color: Color(0xFF8E9295),
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                    ),
                    suffixIcon: Icon(
                      Iconsax.call,
                      color: primaryColor,
                      size: 22,
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
    required this.isHidden,
    required this.onToggle,
    required this.validator,
  });

  final TextEditingController controller;
  final bool isHidden;
  final VoidCallback onToggle;
  final String? Function(String?) validator;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 44,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFE3E5E6)),
      ),
      child: TextFormField(
        controller: controller,
        obscureText: isHidden,
        validator: validator,
        textAlign: TextAlign.right,
        decoration: InputDecoration(
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 14,
            vertical: 17,
          ),
          hintText: 'كلمة المرور',
          hintStyle: const TextStyle(
            color: Color(0xFF8E9295),
            fontSize: 12,
            fontWeight: FontWeight.w700,
          ),
          suffixIcon: IconButton(
            onPressed: onToggle,
            icon: Icon(
              isHidden ? Iconsax.eye_slash : Iconsax.eye,
              color: const Color(0xFF6B7280),
              size: 20,
            ),
          ),
          prefixIcon: const Icon(Iconsax.lock, color: primaryColor, size: 22),
        ),
      ),
    );
  }
}

class _PrimaryLoginButton extends StatelessWidget {
  const _PrimaryLoginButton({required this.onTap});

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
          boxShadow: [
            BoxShadow(
              color: primaryColor.withValues(alpha: 0.24),
              blurRadius: 18,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        alignment: Alignment.center,
        child: const Text(
          'تسجيل الدخول',
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

class _LoginLoadingButton extends StatelessWidget {
  const _LoginLoadingButton();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 40,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        gradient: const LinearGradient(
          colors: [Color(0xFF0B7A43), primaryColor],
          begin: Alignment.centerRight,
          end: Alignment.centerLeft,
        ),
        boxShadow: [
          BoxShadow(
            color: primaryColor.withValues(alpha: 0.18),
            blurRadius: 18,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: const Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: 16,
            height: 16,
            child: CircularProgressIndicator(
              color: Colors.white,
              strokeWidth: 2,
            ),
          ),
          SizedBox(width: 10),
          Text(
            'جاري تسجيل الدخول...',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w800,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}

class _DividerLabel extends StatelessWidget {
  const _DividerLabel();

  @override
  Widget build(BuildContext context) {
    return const Row(
      children: [
        Expanded(child: Divider(color: Color(0xFFE5E7EB))),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 14),
          child: Text(
            'أو',
            style: TextStyle(
              color: Color(0xFF111827),
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
        Expanded(child: Divider(color: Color(0xFFE5E7EB))),
      ],
    );
  }
}
