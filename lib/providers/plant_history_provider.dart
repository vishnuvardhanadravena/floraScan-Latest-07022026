import 'dart:convert';

import 'package:aiplantidentifier/core/app_settings.dart';
import 'package:aiplantidentifier/models/plant_history.dart';
import 'package:aiplantidentifier/utils/helper_methodes.dart';
import 'package:flutter/foundation.dart';

class PlantHistoryProvider extends ChangeNotifier {
  bool _plant_history_loadinng = false;
  bool get plant_history_loading => _plant_history_loadinng;

  String _plant_list_error = "";
  String get plant_list_error => _plant_list_error;
  HistoryDetilesResponce? historyDetilesResponce;

  Future<void> fetchDetailes({
    bool forceReload = false,
    required String plant_id,
  }) async {
    _plant_history_loadinng = true;
    _plant_list_error = "";
    notifyListeners();

    try {
      final baseUrl = AppSettings.api['GET_PLANT_DETAILES'] ?? '';

      if (baseUrl.isEmpty) {
        throw Exception("GET_PLANT_DETAILES API not configured");
      }
      final urlWithParams = '$baseUrl/$plant_id';
      bool shouldCallAPI =
          await timeDifferenceInMinutes('GET_PLANT_DETAILES') || forceReload;
      String apiData = '';

      if (shouldCallAPI) {
        await AppSettings.callRemoteGetAPI(
          url: urlWithParams,
          urlRef: 'GET_PLANT_DETAILES',
        );
        apiData = await AppSettings.getData(
          'GET_PLANT_DETAILES_DATA',
          SharedPreferenceIOType.STRING,
        );
      }
      if (apiData.isEmpty) {
        throw Exception("Empty profile response");
      }
      final decoded = jsonDecode(apiData);
      final response = HistoryDetilesResponce.fromJson(decoded);
      historyDetilesResponce = response;
      if (response.success != true) {
        throw Exception(response.message ?? "Something went wrong");
      }
      if (response.data != null) {
        historyDetilesResponce = response;
        printGreen(historyDetilesResponce!.data.toString());
        // final profile = response.data!;
        // AppSettings.userLoginDetails.display_name = profile.name ?? "";
        // AppSettings.userLoginDetails.Email = profile.email ?? "";
        // AppSettings.userLoginDetails.Mobile_NUmber =
        //     profile.phone?.toString() ?? "";

        // await AppSettings.updateStoredPreferenceValues(
        //   newData: AppSettings.userLoginDetails,
        // );
        notifyListeners();
      }
    } catch (e) {
      _plant_list_error = e.toString();
    } finally {
      _plant_history_loadinng = false;
      notifyListeners();
    }
  }
}
