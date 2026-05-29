import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:liqima/features/auth/cubit/states.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';

import '../../../core/network/remote/dio_helper.dart';
import '../../../core/widgets/show_toast.dart';

class LoginCubit extends Cubit<LoginStates> {
  LoginCubit() : super(LoginInitialState());

  static LoginCubit get(context) => BlocProvider.of(context);

  void validation(){
    emit(ValidationState());
  }

  bool isPasswordHidden = true;
  void togglePasswordVisibility() {
    isPasswordHidden = !isPasswordHidden;
    emit(PasswordVisibilityChanged());
  }

  bool isPasswordHidden2 = true;
  void togglePasswordVisibility2() {
    isPasswordHidden2 = !isPasswordHidden2;
    emit(PasswordVisibilityChanged());
  }


  Future<void> registerDevice(String userId) async {
    final playerId = OneSignal.User.pushSubscription.id;

    if (playerId != null) {
      try {
        final response = await DioHelper.postData(
          url: "/register-device",
          data: {
            "user_id": userId,
            "player_id": playerId,
          },
        );

        if (response.statusCode == 200) {
          print("✅ تم تسجيل الجهاز بنجاح");
        } else {
          print("❌ خطأ أثناء تسجيل الجهاز: ${response.statusMessage}");
        }
      } catch (error) {
        print("❌ Error: $error");
      }
    } else {
      print("❌ لم يتم الحصول على player_id من OneSignal");
    }
  }

  String normalizePhone(String phone) {
    phone = phone.trim();

    if (phone.startsWith('964') && phone.length == 13) {
      return phone;
    } else if (phone.startsWith('0') && phone.length == 11) {
      return '964' + phone.substring(1);
    } else if (phone.length == 10) {
      return '964' + phone;
    } else {
      return phone;
    }
  }


  signUp({required String name, required String phone, required String password, required String location, required String role, required BuildContext context,}){
    phone=normalizePhone(phone);
    emit(SignUpLoadingState());
    DioHelper.postData(
      url: '/users',
      data:
      {
        'name': name,
        'phone': phone,
        'role': role,
        'location': location,
        'password': password,
      },
    ).then((value) {
      phonee=phone;
      emit(SignUpSuccessState());
    }).catchError((error)
    {
      if (error is DioError) {
        print(error.response?.data["error"]);
        showToastError(
          text: error.response?.data["error"],
          context: context,
        );
        emit(SignUpErrorState());
      }else {
        print("Unknown Error: $error");
      }
    });
  }


  String? token;
  String? role;
  String? id;
  String? phonee;
  bool? isVerified;

  signIn({required String phone, required String password,required BuildContext context,}){
    emit(LoginLoadingState());
    DioHelper.postData(
      url: '/login',
      data:
      {
        'phone': phone,
        'password': password,
      },
    ).then((value) {
     token=value.data['token'];
     role=value.data['user']['role'];
     id=value.data['user']['id'].toString();
     phonee=value.data['user']['phone'].toString();
     isVerified=value.data['user']['isVerified'];
     emit(LoginSuccessState());
    }).catchError((error)
    {
      if (error is DioError) {
        final data = error.response?.data;
        if (data is Map && data["code"] == "ACCOUNT_NOT_VERIFIED") {
          phonee = data["phone"]?.toString() ?? normalizePhone(phone);
          role = "user";
          isVerified = false;
          emit(LoginAccountNotVerifiedState());
          return;
        }
        showToastError(
          text: data is Map ? data["error"] : null,
          context: context,
        );
        emit(LoginErrorState());
      }else {
        print("Unknown Error: $error");
      }
    });
  }

  sendOtp({required String phone ,required BuildContext context,}){
    emit(LoginLoadingState());
    DioHelper.postData(
      url: '/send-otp',
      data: {
        'phone': phone ,
      },
    ).then((value) {
      emit(LoginSuccessState());
    }).catchError((error)
    {
      if (error is DioError) {
        showToastError(
          text: error.response?.data["error"] ?? "حدث خطأ غير معروف",
          context: context,
        );
        emit(LoginErrorState());
      }else {
        print("Unknown Error: $error");
      }
    });
  }

  verifyOtp({required String phone ,required String code ,required BuildContext context,}){
    emit(VerifyOtpLoadingState());
    DioHelper.postData(
      url: '/verify-otp',
      data: {
        'phone': phone ,
        'code': code ,
      },
    ).then((value) {
      emit(VerifyOtpSuccessState());
    }).catchError((error)
    {
      if (error is DioError) {
        showToastError(
          text: error.response?.data["error"] ?? "حدث خطأ غير معروف",
          context: context,
        );
        emit(VerifyOtpErrorState());
      }else {
        print("Unknown Error: $error");
      }
    });
  }

}
