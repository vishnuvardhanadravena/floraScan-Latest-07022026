import 'dart:async';
import 'dart:io';
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

  void goBack(BuildContext context) {
    if (currentStep > 0) {
      currentStep--;
      notifyListeners();
    } else {
      Navigator.pop(context);
    }
  }
}
