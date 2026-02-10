import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:aiplantidentifier/core/app_settings.dart';
import 'package:flutter/material.dart';
import 'package:aiplantidentifier/utils/app_Toast.dart';

class ForgotPasswordProvider extends ChangeNotifier {
  bool isLoading = false;
  String userEmail = '';
  int currentStep = 0;
  void _setLoading(bool value) {
    isLoading = value;
    notifyListeners();
  }

  Future<void> sendOtp(String emailController) async {
    _setLoading(true);
    if (emailController.isEmpty) {
      AppToast.error('Please enter your email address');
      _setLoading(false);
      return;
    }

    try {
      await Future.delayed(const Duration(seconds: 2));

      userEmail = emailController;
      currentStep = 1;
      AppToast.success('OTP sent successfully');
    } on SocketException {
      AppToast.error('No internet connection');
    } on TimeoutException {
      AppToast.error('Request timeout. Try again');
    } catch (e) {
      AppToast.error('Something went wrong');
    } finally {
      _setLoading(false);
    }
  }

  Future<void> verifyOtp(String otp) async {
    if (otp.length != 6) {
      AppToast.error('Please enter all 6 digits');
      return;
    }

    _setLoading(true);

    try {
      await Future.delayed(const Duration(seconds: 2));

      if (otp != '123456') {
        throw Exception('Invalid OTP');
      }
      currentStep = 2;
      AppToast.success('OTP verified');
    } on SocketException {
      AppToast.error('No internet connection');
    } on TimeoutException {
      AppToast.error('Request timeout. Try again');
    } catch (e) {
      AppToast.error(e.toString().replaceAll('Exception: ', ''));
    } finally {
      _setLoading(false);
    }
  }

  Future<void> resetPassword(
    String passwordController,
    String confirmPasswordController,
  ) async {
    if (passwordController.isEmpty) {
      AppToast.error('Please enter a new password');
      return;
    }

    if (passwordController.length < 8) {
      AppToast.error('Password must be at least 8 characters');
      return;
    }

    if (passwordController != confirmPasswordController) {
      AppToast.error('Passwords do not match');
      return;
    }

    _setLoading(true);

    try {
      await Future.delayed(const Duration(seconds: 2));
      currentStep = 3;
      AppToast.success('Password reset successful');
    } on SocketException {
      AppToast.error('No internet connection');
    } on TimeoutException {
      AppToast.error('Request timeout. Try again');
    } catch (e) {
      AppToast.error('Failed to reset password');
    } finally {
      _setLoading(false);
    }
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

      _setinputerrormsg(result.message);
      _setloginLoading(false);
      return result;
    }

    if (!_isValidEmail(email)) {
      final result = ApiResult(success: false, message: 'Enter a valid email');
      _setinputerrormsg(result.message);
      _setloginLoading(false);
      return result;
    }

    if (password.isEmpty) {
      final result = ApiResult(success: false, message: 'Password is required');
      _setinputerrormsg(result.message);
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
    if (currentStep > 0) {
      currentStep--;
      notifyListeners();
    } else {
      Navigator.pop(context);
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
