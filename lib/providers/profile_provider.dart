import 'dart:convert';

import 'package:aiplantidentifier/core/app_settings.dart';
import 'package:aiplantidentifier/models/profilemodel.dart';
import 'package:flutter/material.dart';

class ProfileProvider extends ChangeNotifier {
  bool _profileloading = false;
  String _profileerror = "";
  bool get profileloading => _profileloading;
  String get profileerror => _profileerror;
  bool isLoading = false;
  String? errorMessage;
  UserProfileResponse? profileResponse;

  Future<void> getUserProfileApi({bool forceReload = false}) async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      final baseUrl = AppSettings.api['PROFILE_DETAILS'] ?? '';

      if (baseUrl.isEmpty) {
        throw Exception("Profile API not configured");
      }

      final urlWithParams = '$baseUrl';

      bool shouldCallAPI =
          await timeDifferenceInMinutes('PROFILE_DETAILS') || forceReload;

      String apiData = '';

      if (shouldCallAPI) {
        await AppSettings.callRemoteGetAPI(
          url: urlWithParams,
          urlRef: 'PROFILE_DETAILS',
        );
        apiData = await AppSettings.getData(
          'PROFILE_DETAILS_DATA',
          SharedPreferenceIOType.STRING,
        );
      }
      if (apiData.isEmpty) {
        throw Exception("Empty profile response");
      }
      final decoded = jsonDecode(apiData);
      final response = UserProfileResponse.fromJson(decoded);
      profileResponse = response;
      if (response.success != true) {
        throw Exception(response.message ?? "Something went wrong");
      }

      if (response.data != null) {
        final profile = response.data!;
        AppSettings.userLoginDetails.display_name = profile.name ?? "";
        AppSettings.userLoginDetails.Email = profile.email ?? "";
        AppSettings.userLoginDetails.Mobile_NUmber =
            profile.phone?.toString() ?? "";

        await AppSettings.updateStoredPreferenceValues(
          newData: AppSettings.userLoginDetails,
        );
        notifyListeners();
      }
    } catch (e) {
      errorMessage = e.toString();
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}
