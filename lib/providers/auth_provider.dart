import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:aiplantidentifier/core/app_settings.dart';
import 'package:aiplantidentifier/utils/helper_methodes.dart';
import 'package:flutter/material.dart';
import 'package:aiplantidentifier/utils/app_Toast.dart';

class ForgotPasswordProvider extends ChangeNotifier {
  bool isLoading = false;
  String userEmail = '';
  int currentStep = 2;

  void _setLoading(bool value) {
    isLoading = value;
    notifyListeners();
  }

  bool _isloginLoading = false;
  bool get isloginLoading => _isloginLoading;

  ApiResult<void>? _authResult;
  ApiResult<void>? get authResult => _authResult;

  String? get errorMessage =>
      _authResult != null && !_authResult!.success
          ? _authResult!.message
          : null;
  String? _inputerrormsg;
  String? get inputerrormsg => _inputerrormsg;

  bool get isSuccess => _authResult?.success == true;

  void _setloginLoading(bool value) {
    _isloginLoading = value;
    notifyListeners();
  }

  void _setAuthResult(ApiResult<void> result) {
    _authResult = result;
    notifyListeners();
  }

  void _setinputerrormsg(String value) {
    _inputerrormsg = value;
  }

  Future<ApiResult<void>> login(String email, String password) async {
    _setloginLoading(true);

    if (email.trim().isEmpty) {
      final result = ApiResult(success: false, message: 'Email is required');

      _setAuthResult(result);
      _setinputerrormsg(result.message);
      _setloginLoading(false);
      return result;
    }

    if (!_isValidEmail(email)) {
      final result = ApiResult(success: false, message: 'Enter a valid email');
      _setAuthResult(result);
      _setinputerrormsg(result.message);

      _setloginLoading(false);
      return result;
    }

    if (password.isEmpty) {
      final result = ApiResult(success: false, message: 'Password is required');
      _setinputerrormsg(result.message);
      _setAuthResult(result);
      _setloginLoading(false);
      return result;
    }

    try {
      final response = await AppSettings.callRemotePostAPI(
        url: AppSettings.api["SIG_IN"],
        payload: {'email': email, 'password': password},
        urlRef: 'LOGIN',
      );

      if (response == RestResponse.failed) {
        final result = ApiResult(
          success: false,
          message: 'Something went wrong. Try again',
        );
        _setAuthResult(result);
        return result;
      }

      if (response == RestResponse.SERVERNOTRESPONDING) {
        final result = ApiResult(
          success: false,
          message: 'Server not responding. Please try later',
        );
        _setAuthResult(result);
        return result;
      }

      final decoded = jsonDecode(response);

      if (decoded['success'] == true) {
        await AppSettings.saveData(
          'USER_ISLOGIN',
          true,
          SharedPreferenceIOType.BOOL,
        );

        await AppSettings.saveData(
          'USER_TOKEN',
          decoded['token'],
          SharedPreferenceIOType.STRING,
        );

        final result = ApiResult(success: true, message: 'Login successful');
        _setAuthResult(result);
        return result;
      } else {
        final result = ApiResult(
          success: false,
          message: decoded['message'] ?? 'Invalid credentials',
        );
        _setAuthResult(result);
        return result;
      }
    } catch (e) {
      final result = ApiResult(
        success: false,
        message: 'Unexpected error occurred',
      );
      _setAuthResult(result);
      return result;
    } finally {
      _setloginLoading(false);
    }
  }

  void goBack(BuildContext context) {
    Navigator.pop(context);
    // if (currentStep > 0) {
    //   currentStep--;
    //   notifyListeners();
    // } else {
    //   Navigator.pop(context);
    // }
  }

  bool changePassLoading = false;
  String changePassErrorMsg = '';
  void setchangePassErrorMsg(String value) {
    changePassErrorMsg = value;
    notifyListeners();
  }

  Future<bool> changePassword({
    required String oldPassword,
    required String newPassword,
    required String confrimpassword,
  }) async {
    changePassLoading = true;
    changePassErrorMsg = '';
    notifyListeners();
    if (oldPassword.isEmpty) {
      setchangePassErrorMsg("Old password is required");
      changePassLoading = false;
      notifyListeners();
      return false;
    }

    if (newPassword.isEmpty) {
      setchangePassErrorMsg("New password is required");
      changePassLoading = false;
      notifyListeners();
      return false;
    }
    if (confrimpassword != newPassword) {
      setchangePassErrorMsg("confrim password not Matched");
      changePassLoading = false;
      notifyListeners();
      return false;
    }

    // if (oldPassword == newPassword) {
    //   setchangePassErrorMsg("New password must be different");
    //   changePassLoading = false;
    //   notifyListeners();
    //   return false;
    // }

    try {
      final response = await AppSettings.callRemotePostAPI(
        urlRef: "CHANGE_PASSWORD",
        url: AppSettings.api['CHANGE_PASSWORD'],
        payload: {
          "oldpassword": oldPassword.trim(),
          "newpassword": newPassword.trim(),
          "confirmnewpassword": confrimpassword.trim(),
        },
      );
      if (response == null) {
        changePassErrorMsg = "Internal Server Error";
        notifyListeners();
        return false;
      }
      final decoded = jsonDecode(response);

      switch (decoded["statuscode"]) {
        case 200:
          printBlue(decoded["message"]);
          return true;
        case 400:
          changePassErrorMsg = "Password is wrong";
          notifyListeners();
          return false;
        case 404:
          changePassErrorMsg = "User not found";
          notifyListeners();
          return false;
        default:
          changePassErrorMsg = "Something went wrong";
          notifyListeners();
          return false;
      }
    } catch (e) {
      printRed(e.toString());
      changePassErrorMsg = "Internal Server Error";
      notifyListeners();
      return false;
    } finally {
      changePassLoading = false;
      notifyListeners();
    }
  }
}

class ApiResult<T> {
  final bool success;
  final String message;
  final T? data;

  ApiResult({required this.success, required this.message, this.data});
}

bool _isValidEmail(String email) {
  return RegExp(r'^[\w\.-]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
}
