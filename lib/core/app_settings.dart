import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:aiplantidentifier/utils/helper_methodes.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:http/http.dart' as http;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:http_parser/http_parser.dart';
import 'package:mime/mime.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum AuthResponse { FAILED, SUCCESS, EXCEPTION, OTHER_REASON }

enum RestResponse {
  failed,
  noDataFound,
  authFail,
  NODATARETRIEVEDFROMAPI,
  SERVERNOTRESPONDING,
}

enum SharedPreferenceIOType { STRING, INTEGER, BOOL, DOUBLE, LIST, OBJECT }

SharedPreferences? _sharedPreferences;

final ValueNotifier<bool> switchNotifier = ValueNotifier(false);

final ValueNotifier<bool> dotNotifier = ValueNotifier(true);

Future<bool> timeDifferenceInMinutes(String apiName) async {
  if (AppSettings.api['${apiName}_TIME'] != null) {
    int lastExecutedTime =
        await AppSettings.getData(
          '${apiName}_TIME',
          SharedPreferenceIOType.INTEGER,
        ) ??
        DateTime.now().millisecondsSinceEpoch;

    if (DateTime.now()
            .difference(DateTime.fromMillisecondsSinceEpoch(lastExecutedTime))
            .inMinutes >=
        AppSettings.api['${apiName}_TIME']) {
      return true;
    } else {
      return false;
    }
  }
  return true;
}

Future<bool> internetConnectivityCheck() async {
  List<ConnectivityResult> result = [];

  try {
    result = await Connectivity().checkConnectivity();
  } on PlatformException catch (e) {
    printRed(e.toString());
  }

  if (result.any((r) => r != ConnectivityResult.none)) {
    return true;
  }

  return false;
}

const defaultPadding = 16.0;

class AppSettings {
  static ApplicationCoreInfo? appInfo; // = new ApplicationCoreInfo();
  static String headerAndroidVersion = '';
  static String headerIosVersion = '';
  static bool versionCheck = true;
  static String headerCurrentDateTime = '';
  static Map<String, dynamic> api = {};
  static String host = 'https://apis.plantishtha.com';
  static String auth = '/podha/auth/appuser';

  static String users = '/users';
  static String plans = '/plans';
  static String deposite = '/deposit';
  static String withdrawals = '/withdrawals';
  static String support = '/support_ticket';
  static String document = '/documents';
  static String authPathUri = host + auth;
  static String usersPathUri = host + users;
  static String plansPathUri = host + plans;
  static String withdrawalsPathUri = host + withdrawals;
  static String depositePathUri = host + deposite;
  static String suportPathUri = host + support;
  static String documentPathUri = host + document;

  static void updateURL() {
    api = {
      'SIG_IN': '$authPathUri/appuser-login',
      'SIG_IN_TIME': 0,
      'PROFILE_DETAILS': '$authPathUri/get-user-details',
      'PROFILE_DETAILS_TIME': 0,
      'CHANGE_PASSWORD': '$authPathUri/change-password',
      'CHANGE_PASSWORD_TIME': 0,
      "SCAN-IMAGE": '$authPathUri/scan-image',
      'SCAN-IMAGE_TIME': 0,
      "LOG_OUT": '$authPathUri/logout',
      'LOG_OUT_TIME': 0,
    };
  }

  static void initializeAppInfoInstance() {
    appInfo = ApplicationCoreInfo();
    printBlue(appInfo.toString());
  }

  static ApiConstants apiConstants = ApiConstants();
  static UserLoginDetails userLoginDetails = UserLoginDetails();
  static Color GREY = Colors.grey;
  static Color WHITE = Colors.white;
  static var sliderupdateCount;
  static bool isDashboard = false;
  static String getBaseURL() {
    return "";
  }

  static Map theme = {};
  static Color toastFailed = Colors.red;

  static Future<dynamic> getData(
    String key,
    SharedPreferenceIOType type, {
    dynamic Function(Map<String, dynamic>)? fromJson,
  }) async {
    _sharedPreferences = await SharedPreferences.getInstance();

    try {
      if (type == SharedPreferenceIOType.STRING) {
        return _sharedPreferences!.getString(key) ?? '';
      } else if (type == SharedPreferenceIOType.INTEGER) {
        return _sharedPreferences!.getInt(key) ?? -1;
      } else if (type == SharedPreferenceIOType.BOOL) {
        return _sharedPreferences!.getBool(key) ?? false;
      } else if (type == SharedPreferenceIOType.DOUBLE) {
        return _sharedPreferences!.getDouble(key) ?? 0.0;
      } else if (type == SharedPreferenceIOType.OBJECT) {
        final jsonString = _sharedPreferences!.getString(key);
        if (jsonString == null || jsonString.isEmpty) return null;

        final Map<String, dynamic> jsonMap = jsonDecode(jsonString);
        return fromJson != null ? fromJson(jsonMap) : jsonMap;
      }
    } catch (e) {
      printRed('GET DATA ERROR :: $key :: $e');
    }

    return null;
  }

  static saveData(String key, value, type) async {
    _sharedPreferences = await SharedPreferences.getInstance();
    if (type == SharedPreferenceIOType.STRING) {
      try {
        await _sharedPreferences!.setString(key, value);
        // await _sharedPreferences!.setString(_key, MyEncryptionDecryption.encryptAES(_value));
      } catch (e) {
        printRed('INVALID DATA TYPE :: $key');
        await _sharedPreferences!.setString(key, value);
      }
    } else if (type == SharedPreferenceIOType.INTEGER) {
      try {
        await _sharedPreferences!.setInt(key, value);
      } catch (e) {
        printRed('INVALID DATA TYPE :: $key');
      }
    } else if (type == SharedPreferenceIOType.BOOL) {
      try {
        await _sharedPreferences!.setBool(key, value);
      } catch (e) {
        printRed('INVALID DATA TYPE :: $key');
      }
    } else if (type == SharedPreferenceIOType.DOUBLE) {
      try {
        await _sharedPreferences!.setDouble(key, value);
      } catch (e) {
        printRed('INVALID DATA TYPE :: $key');
      }
    } else if (type == SharedPreferenceIOType.OBJECT) {
      String jsonString = jsonEncode(value.toJson());
      await _sharedPreferences!.setString(key, jsonString);
    }
    try {
      await appInfo!.updateLocalVariablesWithSharedPreference();
    } catch (e) {}
  }

  static clearEntireStorage() async {
    await _sharedPreferences!.clear();
    DefaultCacheManager().emptyCache();
  }

  static clearSpecificStorage() async {
    try {
      for (var EachKey in _sharedPreferences!.getKeys()) {
        if (!EachKey.startsWith('ORG_')) {
          _sharedPreferences!.remove(EachKey);
        }
      }
    } catch (e) {}
  }

  static Future<void> loadAppDataToRunTimeVariables() async {
    try {
      updateURL();
    } catch (e) {
      //exception display error toast
    }
  }

  static Future<void> updateStoredPreferenceValues({
    UserLoginDetails? newData,
  }) async {
    try {
      // 🔹 SAVE DATA (only when new data is passed)
      if (newData != null) {
        await AppSettings.saveData(
          'userLogin_EmpId',
          newData.emp_id,
          SharedPreferenceIOType.STRING,
        );

        await AppSettings.saveData(
          'userLogin_UserId',
          newData.user_id,
          SharedPreferenceIOType.STRING,
        );

        await AppSettings.saveData(
          'userLogin_lastSessionId',
          newData.last_session_id,
          SharedPreferenceIOType.STRING,
        );

        await AppSettings.saveData(
          'LoginUserName',
          newData.login_user_name,
          SharedPreferenceIOType.STRING,
        );

        await AppSettings.saveData(
          'userLoginDisplayName',
          newData.display_name,
          SharedPreferenceIOType.STRING,
        );

        await AppSettings.saveData(
          'imageUrl',
          newData.UserProfilePic,
          SharedPreferenceIOType.STRING,
        );

        await AppSettings.saveData(
          'designationName',
          newData.designationName,
          SharedPreferenceIOType.STRING,
        );

        // 🔹 NEW PROFILE FIELDS
        await AppSettings.saveData(
          'userLoginEmail',
          newData.Email,
          SharedPreferenceIOType.STRING,
        );

        await AppSettings.saveData(
          'userLoginMobile',
          newData.Mobile_NUmber,
          SharedPreferenceIOType.STRING,
        );

        await AppSettings.saveData(
          'userLoginFullName',
          newData.display_name,
          SharedPreferenceIOType.STRING,
        );

        await AppSettings.saveData(
          'userLoginCountry',
          newData.countryName,
          SharedPreferenceIOType.STRING,
        );

        await AppSettings.saveData(
          'userLoginJoinedAt',
          newData.joinedAt,
          SharedPreferenceIOType.STRING,
        );
        await AppSettings.saveData(
          'userFirstName',
          newData.firstName,
          SharedPreferenceIOType.STRING,
        );
        await AppSettings.saveData(
          'userLastName',
          newData.lastName,
          SharedPreferenceIOType.STRING,
        );
        await AppSettings.saveData(
          'userAddress',
          newData.address,
          SharedPreferenceIOType.STRING,
        );
        await AppSettings.saveData(
          'userCity',
          newData.city,
          SharedPreferenceIOType.STRING,
        );
        await AppSettings.saveData(
          'userState',
          newData.state,
          SharedPreferenceIOType.STRING,
        );
        await AppSettings.saveData(
          'userZip',
          newData.zip,
          SharedPreferenceIOType.STRING,
        );
      }

      // 🔹 GET DATA (always)
      AppSettings.userLoginDetails.emp_id = await AppSettings.getData(
        'userLogin_EmpId',
        SharedPreferenceIOType.STRING,
      );

      AppSettings.userLoginDetails.user_id = await AppSettings.getData(
        'userLogin_UserId',
        SharedPreferenceIOType.STRING,
      );

      AppSettings.userLoginDetails.last_session_id = await AppSettings.getData(
        'userLogin_lastSessionId',
        SharedPreferenceIOType.STRING,
      );

      AppSettings.userLoginDetails.login_user_name = await AppSettings.getData(
        'LoginUserName',
        SharedPreferenceIOType.STRING,
      );

      AppSettings.userLoginDetails.display_name = await AppSettings.getData(
        'userLoginDisplayName',
        SharedPreferenceIOType.STRING,
      );

      AppSettings.userLoginDetails.UserProfilePic = await AppSettings.getData(
        'imageUrl',
        SharedPreferenceIOType.STRING,
      );

      AppSettings.userLoginDetails.designationName = await AppSettings.getData(
        'designationName',
        SharedPreferenceIOType.STRING,
      );

      // 🔹 NEW PROFILE FIELDS
      AppSettings.userLoginDetails.Email = await AppSettings.getData(
        'userLoginEmail',
        SharedPreferenceIOType.STRING,
      );

      AppSettings.userLoginDetails.Mobile_NUmber = await AppSettings.getData(
        'userLoginMobile',
        SharedPreferenceIOType.STRING,
      );

      AppSettings.userLoginDetails.display_name = await AppSettings.getData(
        'userLoginFullName',
        SharedPreferenceIOType.STRING,
      );

      AppSettings.userLoginDetails.countryName = await AppSettings.getData(
        'userLoginCountry',
        SharedPreferenceIOType.STRING,
      );

      AppSettings.userLoginDetails.joinedAt = await AppSettings.getData(
        'userLoginJoinedAt',
        SharedPreferenceIOType.STRING,
      );
      AppSettings.userLoginDetails.firstName = await AppSettings.getData(
        'userFirstName',
        SharedPreferenceIOType.STRING,
      );

      AppSettings.userLoginDetails.lastName = await AppSettings.getData(
        'userLastName',
        SharedPreferenceIOType.STRING,
      );

      AppSettings.userLoginDetails.address = await AppSettings.getData(
        'userAddress',
        SharedPreferenceIOType.STRING,
      );

      AppSettings.userLoginDetails.city = await AppSettings.getData(
        'userCity',
        SharedPreferenceIOType.STRING,
      );

      AppSettings.userLoginDetails.state = await AppSettings.getData(
        'userState',
        SharedPreferenceIOType.STRING,
      );

      AppSettings.userLoginDetails.zip = await AppSettings.getData(
        'userZip',
        SharedPreferenceIOType.STRING,
      );

      printGreen(
        "✅ UserLoginDetails Updated: ${AppSettings.userLoginDetails.display_name}",
      );
    } catch (e) {
      printRed("❌ updateStoredPreferenceValues Error: $e");
    }
  }

  static clearSPExceptORG() async {
    try {
      for (var EachKey in _sharedPreferences!.getKeys()) {
        if (EachKey.startsWith('user_login_organization') ||
            EachKey.startsWith('user_login_user_name')) {
          //   _sharedPreferences.remove(EachKey);
        } else {
          _sharedPreferences?.remove(EachKey);
        }
      }
    } catch (e) {
      printRed(e.toString());
    }
  }

  ///headers
  static Future<Map<String, String>> headers() async {
    Map<String, String> headers = <String, String>{};
    headers[HttpHeaders.contentTypeHeader] = 'application/json';
    headers['Authorization'] =
        "Bearer ${AppSettings.appInfo!.USER_TOKEN.trim()}";
    // "MW4UPlXwVBTrNpTCiSE6r7WXfriy4vKwlyjL4zYk853UQFei1rwnj0vgU32L";
    printGreen("User-TOKEN ${AppSettings.appInfo!.USER_TOKEN}");
    return headers;
  }

  static Future<dynamic> callRemotePostAPI({
    required String url,
    Map<String, dynamic>? payload,
    Map<String, String>? requestHeaders,
    String urlRef = '',
    BuildContext? context,
  }) async {
    printBlue("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━");
    printBlue("➡️ API POST CALL START");
    printBlue("URL        : $url");
    printBlue("URL REF    : $urlRef");
    printBlue("PAYLOAD    : ${payload ?? {}}");
    printBlue("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━");

    final bool internet = await internetConnectivityCheck();

    if (!internet) {
      printRed("❌ NO INTERNET CONNECTION");
      printRed("API        : $url");
      displayLongErrorToast("No Internet Connection");
      return RestResponse.failed;
    }

    try {
      final headersMap = requestHeaders ?? await headers();

      printBlue("HEADERS    : $headersMap");

      final response = await http
          .post(Uri.parse(url), body: jsonEncode(payload), headers: headersMap)
          .timeout(const Duration(seconds: 20));

      printBlue("STATUS CODE: ${response.statusCode}");

      /// ---------------- SUCCESS ----------------
      if (response.statusCode >= 200 && response.statusCode < 300) {
        printGreen("✅ API POST SUCCESS");
        printGreen("RESPONSE   : ${response.body}");
        printGreen("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━");

        await saveData(
          '${urlRef}_TIME',
          DateTime.now().millisecondsSinceEpoch,
          SharedPreferenceIOType.INTEGER,
        );

        await saveData('${urlRef}_STATE', 1, SharedPreferenceIOType.INTEGER);

        await saveData(
          '${urlRef}_DATA',
          response.body,
          SharedPreferenceIOType.STRING,
        );

        return response.body;
      }
      /// ---------------- CLIENT ERROR ----------------
      else if (response.statusCode >= 400 && response.statusCode < 500) {
        printRed("⚠️ API CLIENT ERROR");
        printRed("STATUS     : ${response.statusCode}");
        printRed("RESPONSE   : ${response.body}");
        printRed("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━");

        await saveData('${urlRef}_STATE', 2, SharedPreferenceIOType.INTEGER);

        await saveData(
          '${urlRef}_DATA',
          response.body,
          SharedPreferenceIOType.STRING,
        );

        if (response.statusCode == 401) {
          printRed("🔐 UNAUTHORIZED (401)");
          // triggerLogout();
        }

        return response.body;
      }
      /// ---------------- SERVER ERROR ----------------
      else {
        printRed("❌ API SERVER ERROR");
        printRed("STATUS     : ${response.statusCode}");
        printRed("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━");

        await saveData('${urlRef}_STATE', 3, SharedPreferenceIOType.INTEGER);

        await saveData(
          '${urlRef}_DATA',
          'SERVER_ERROR',
          SharedPreferenceIOType.STRING,
        );

        return RestResponse.SERVERNOTRESPONDING;
      }
    }
    /// ---------------- TIMEOUT ----------------
    on TimeoutException {
      printRed("⏳ API TIMEOUT");
      printRed("URL        : $url");
      printRed("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━");

      await saveData('${urlRef}_STATE', 3, SharedPreferenceIOType.INTEGER);
      return RestResponse.SERVERNOTRESPONDING;
    }
    /// ---------------- UNKNOWN ERROR ----------------
    catch (e) {
      printRed("💥 API EXCEPTION");
      printRed("URL        : $url");
      printRed("ERROR      : $e");
      printRed("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━");

      await saveData('${urlRef}_STATE', 3, SharedPreferenceIOType.INTEGER);
      return RestResponse.failed;
    }
  }

  static Future<dynamic> callRemoteGetAPI({
    String? url,
    Map<String, String>? requestHeaders,
    String? urlRef = '',
    BuildContext? buildContext,
  }) async {
    bool internet = await internetConnectivityCheck();
    if (!internet) {
      printRed("❌ NO INTERNET | API: $url");
      displayLongErrorToast("No Internet Connection");
      return RestResponse.failed;
    }

    try {
      Map<String, String> customHeaders = requestHeaders ?? await headers();
      final uri = Uri.parse(url!);

      printBlue("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━");
      printBlue("➡️ API CALL START");
      printBlue("URL      : $uri");
      printBlue("METHOD   : GET");
      printBlue("HEADERS  : $customHeaders");
      printBlue("REF KEY  : $urlRef");
      printBlue("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━");

      final response = await http.get(uri, headers: customHeaders);

      if (response.statusCode == 200) {
        printGreen("✅ API SUCCESS");
        printGreen("STATUS   : ${response.statusCode}");
        printGreen("RESPONSE : ${response.body}");
        printGreen("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━");

        await saveData(
          '${urlRef!}_TIME',
          DateTime.now().millisecondsSinceEpoch,
          SharedPreferenceIOType.INTEGER,
        );
        await saveData('${urlRef}_STATE', 1, SharedPreferenceIOType.INTEGER);
        await saveData(
          '${urlRef}_DATA',
          response.body.toString(),
          SharedPreferenceIOType.STRING,
        );

        return response.body;
      } else if (response.statusCode == 400) {
        printRed("⚠️ API CLIENT ERROR");
        printRed("STATUS   : ${response.statusCode}");
        printRed("RESPONSE : ${response.body}");
        printRed("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━");

        await saveData('${urlRef!}_STATE', 2, SharedPreferenceIOType.INTEGER);
        await saveData(
          '${urlRef}_DATA',
          response.body.toString(),
          SharedPreferenceIOType.STRING,
        );

        return RestResponse.authFail;
      } else {
        printRed("❌ API FAILED");
        printRed("STATUS   : ${response.statusCode}");
        printRed("RESPONSE : ${response.body}");
        printRed("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━");

        await saveData('${urlRef!}_STATE', 2, SharedPreferenceIOType.INTEGER);
        await saveData(
          '${urlRef}_DATA',
          response.body.toString(),
          SharedPreferenceIOType.STRING,
        );

        return RestResponse.authFail;
      }
    } catch (e) {
      printRed("💥 API EXCEPTION");
      printRed("URL   : $url");
      printRed("ERROR : $e");
      printRed("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━");

      await saveData('${urlRef!}_STATE', 2, SharedPreferenceIOType.INTEGER);
      await saveData('${urlRef}_DATA', 'FAILED', SharedPreferenceIOType.STRING);

      return RestResponse.failed;
    }
  }

  static Future<dynamic> callRemoteMultipartPostAPI({
    required String url,
    required String urlRef,
    required Map<String, String> fields,
    required Map<String, File> files,
    Map<String, String>? requestHeaders,
    BuildContext? context,
  }) async {
    printBlue("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━");
    printBlue("➡️ API MULTIPART POST CALL START");
    printBlue("URL        : $url");
    printBlue("URL REF    : $urlRef");
    printBlue("FIELDS     : $fields");
    printBlue("FILES      : ${files.keys}");
    printBlue("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━");
    final bool internet = await internetConnectivityCheck();
    if (!internet) {
      printRed("❌ NO INTERNET CONNECTION");
      displayLongErrorToast("No Internet Connection");
      return RestResponse.failed;
    }
    try {
      final headersMap = requestHeaders ?? await headers();
      final request = http.MultipartRequest('POST', Uri.parse(url));

      /// 🔹 Headers (do NOT set content-type manually)
      request.headers.addAll(headersMap);

      /// 🔹 Text fields
      request.fields.addAll(fields);

      /// 🔹 Files
      // for (final entry in files.entries) {
      //   printBlue("ImagePath: ${entry.value.path},${entry.key}");
      //   request.files.add(
      //     await http.MultipartFile.fromPath(
      //       entry.key, // backend key (e.g. "image")
      //       entry.value.path,
      //     ),
      //   );
      // }
      for (final entry in files.entries) {
        final file = entry.value;

        final mimeType = lookupMimeType(file.path) ?? 'image/jpeg';
        final mimeSplit = mimeType.split('/');

        request.files.add(
          await http.MultipartFile.fromPath(
            entry.key,
            file.path,
            contentType: MediaType(mimeSplit[0], mimeSplit[1]),
          ),
        );
      }

      final streamedResponse = await request.send().timeout(
        const Duration(seconds: 30),
      );
      final response = await http.Response.fromStream(streamedResponse);
      printBlue("STATUS CODE: ${response.statusCode}");

      /// ---------------- SUCCESS ----------------
      if (response.statusCode >= 200 && response.statusCode < 300) {
        printGreen("✅ API MULTIPART SUCCESS");
        printGreen("RESPONSE   : ${response.body.toString()}");
        printGreen("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━");
        await saveData(
          '${urlRef}_TIME',
          DateTime.now().millisecondsSinceEpoch,
          SharedPreferenceIOType.INTEGER,
        );
        await saveData('${urlRef}_STATE', 1, SharedPreferenceIOType.INTEGER);
        await saveData(
          '${urlRef}_DATA',
          response.body,
          SharedPreferenceIOType.STRING,
        );
        return response.body;
      }
      /// ---------------- CLIENT ERROR ----------------
      else if (response.statusCode >= 400 && response.statusCode < 500) {
        printRed("⚠️ API CLIENT ERROR");
        printRed("STATUS     : ${response.statusCode}");
        printRed("RESPONSE   : ${response.body}");
        printRed("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━");
        await saveData('${urlRef}_STATE', 2, SharedPreferenceIOType.INTEGER);
        await saveData(
          '${urlRef}_DATA',
          response.body,
          SharedPreferenceIOType.STRING,
        );
        return response.body;
      }
      /// ---------------- SERVER ERROR ----------------
      else {
        printRed("❌ API SERVER ERROR");
        printRed("STATUS     : ${response.statusCode}");
        printRed("RESPONSE   : ${response.body}");
        printRed("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━");
        await saveData('${urlRef}_STATE', 3, SharedPreferenceIOType.INTEGER);
        await saveData(
          '${urlRef}_DATA',
          'SERVER_ERROR',
          SharedPreferenceIOType.STRING,
        );
        return RestResponse.SERVERNOTRESPONDING;
      }
    }
    /// ---------------- TIMEOUT ----------------
    on TimeoutException {
      printRed("⏳ API MULTIPART TIMEOUT");
      printRed("URL        : $url");
      await saveData('${urlRef}_STATE', 3, SharedPreferenceIOType.INTEGER);
      return RestResponse.SERVERNOTRESPONDING;
    }
    /// ---------------- UNKNOWN ERROR ----------------
    catch (e) {
      printRed("💥 API MULTIPART EXCEPTION");
      printRed("URL        : $url");
      printRed("ERROR      : $e");
      await saveData('${urlRef}_STATE', 3, SharedPreferenceIOType.INTEGER);
      return RestResponse.failed;
    }
  }

  static Future<dynamic> callRemoteListMultipartPostAPI({
    required String url,
    required String urlRef,
    required Map<String, String> fields,
    required List<Map<String, dynamic>> files,
    Map<String, String>? requestHeaders,
    BuildContext? context,
  }) async {
    printBlue("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━");
    printBlue("➡️ API MULTIPART POST CALL START");
    printBlue("URL        : $url");
    printBlue("URL REF    : $urlRef");
    printBlue("FIELDS     : $fields");
    printBlue("FILES      : ${files.map((e) => e['field']).toList()}");
    printBlue("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━");
    final bool internet = await internetConnectivityCheck();
    if (!internet) {
      printRed("❌ NO INTERNET CONNECTION");
      displayLongErrorToast("No Internet Connection");
      return RestResponse.failed;
    }
    try {
      final headersMap = requestHeaders ?? await headers();
      final request = http.MultipartRequest('POST', Uri.parse(url));

      /// 🔹 Headers (do NOT set content-type manually)
      request.headers.addAll(headersMap);

      /// 🔹 Text fields
      request.fields.addAll(fields);

      /// 🔹 Files (UPDATED LOGIC)
      for (final file in files) {
        if (file['path'] != null) {
          request.files.add(
            await http.MultipartFile.fromPath(
              file['field'], // e.g. "attachments"
              file['path'],
              filename: file['name'],
            ),
          );
        }
      }
      final streamedResponse = await request.send().timeout(
        const Duration(seconds: 30),
      );
      final response = await http.Response.fromStream(streamedResponse);
      printBlue("STATUS CODE: ${response.statusCode}");

      /// ---------------- SUCCESS ----------------
      if (response.statusCode >= 200 && response.statusCode < 300) {
        printGreen("✅ API MULTIPART SUCCESS");
        printGreen("RESPONSE   : ${response.body}");
        printGreen("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━");
        await saveData(
          '${urlRef}_TIME',
          DateTime.now().millisecondsSinceEpoch,
          SharedPreferenceIOType.INTEGER,
        );
        await saveData('${urlRef}_STATE', 1, SharedPreferenceIOType.INTEGER);
        await saveData(
          '${urlRef}_DATA',
          response.body,
          SharedPreferenceIOType.STRING,
        );
        return response.body;
      }
      /// ---------------- CLIENT ERROR ----------------
      else if (response.statusCode >= 400 && response.statusCode < 500) {
        printRed("⚠️ API CLIENT ERROR");
        printRed("STATUS     : ${response.statusCode}");
        printRed("RESPONSE   : ${response.body}");
        printRed("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━");
        await saveData('${urlRef}_STATE', 2, SharedPreferenceIOType.INTEGER);
        await saveData(
          '${urlRef}_DATA',
          response.body,
          SharedPreferenceIOType.STRING,
        );
        return response.body;
      }
      /// ---------------- SERVER ERROR ----------------
      else {
        printRed("❌ API SERVER ERROR");
        printRed("STATUS     : ${response.statusCode}");
        printRed("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━");
        await saveData('${urlRef}_STATE', 3, SharedPreferenceIOType.INTEGER);
        await saveData(
          '${urlRef}_DATA',
          'SERVER_ERROR',
          SharedPreferenceIOType.STRING,
        );
        return RestResponse.SERVERNOTRESPONDING;
      }
    } catch (e, s) {
      printRed("❌ MULTIPART API EXCEPTION ($urlRef)");
      printRed(e.toString());
      printRed("stackTrace:$s");
      return RestResponse.failed;
    }
  }

  static displayLongErrorToast(String message) {
    Fluttertoast.showToast(
      msg: message,
      textColor: Colors.white,
      toastLength: Toast.LENGTH_LONG,
      timeInSecForIosWeb: 1,
      gravity: ToastGravity.BOTTOM,
      backgroundColor: toastFailed,
      fontSize: 12,
    );
  }

  static displayLongSuccessToast(String message) {
    Fluttertoast.showToast(
      msg: message,
      toastLength: Toast.LENGTH_LONG,
      gravity: ToastGravity.BOTTOM, // ✅ bottom of screen
      timeInSecForIosWeb: 2,
      backgroundColor: Colors.green,
      textColor: Colors.white,
      fontSize: 12,
    );
  }

  static displayCustomColorToast(String message, Color bcColor) {
    Fluttertoast.showToast(
      msg: message,
      textColor: Colors.white,
      toastLength: Toast.LENGTH_LONG,
      timeInSecForIosWeb: 1,
      gravity: ToastGravity.BOTTOM,
      backgroundColor: bcColor,
      fontSize: 12,
    );
  }

  static void _showMessage(String message, BuildContext context) {
    printRed(message);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), behavior: SnackBarBehavior.floating),
    );
  }

  // static Future<DownloadResult> handleDownload(
  //   String? url,
  //   String? id,
  //   BuildContext context,
  //   String s,
  // ) async {
  //   try {
  //     if (url == null || url.isEmpty) {
  //       if (id == null || id.isEmpty) {
  //         displayLongErrorToast('Download URL not available');
  //         return DownloadResult(
  //           success: false,
  //           message: 'URL and ID both missing',
  //         );
  //       }

  //       debugPrint('🔍 Resolving URL using ID: $id');
  //       url = await _fetchDownloadUrlById(id);

  //       if (url == null || url.isEmpty) {
  //         displayLongErrorToast(
  //           'Unable to get download link',
  //         );
  //         return DownloadResult(
  //           success: false,
  //           message: 'Failed to resolve URL',
  //         );
  //       }
  //     }

  //     if (!await Gal.hasAccess(toAlbum: true)) {
  //       final granted = await Gal.requestAccess(toAlbum: true);
  //       if (!granted) {
  //         displayLongErrorToast(
  //           'Gallery access denied',
  //         );
  //         return DownloadResult(
  //           success: false,
  //           url: url,
  //           message: 'Permission denied',
  //         );
  //       }
  //     }

  //     final uri = Uri.parse(url);
  //     final response = await http.get(uri);

  //     if (response.statusCode != 200) {
  //       displayLongErrorToast(
  //         'Download failed: Server error ${response.statusCode}',
  //       );
  //       return DownloadResult(
  //         success: false,
  //         url: url,
  //         message: 'Server error ${response.statusCode}',
  //       );
  //     }

  //     final contentType = response.headers['content-type']?.toLowerCase() ?? '';
  //     final isImage = contentType.startsWith('image/');

  //     if (isImage) {
  //       await Gal.putImageBytes(
  //         response.bodyBytes,
  //         album: 'Quantix Downloads',
  //       );
  //       displayLongSuccessToast(
  //         'Image saved to Gallery',
  //       );
  //     } else {
  //       Directory downloadsDir;

  //       if (Platform.isAndroid) {
  //         downloadsDir = Directory('/storage/emulated/0/Download');
  //       } else {
  //         downloadsDir = await getApplicationDocumentsDirectory();
  //       }

  //       final fileName =
  //           'download_${s}_${DateTime.now().millisecondsSinceEpoch}';
  //       final filePath = '${downloadsDir.path}/$fileName';

  //       await File(filePath).writeAsBytes(response.bodyBytes);
  //       await MediaScanner.loadMedia(path: filePath);

  //       displayLongSuccessToast(
  //         'File saved to Downloads',
  //       );
  //     }

  //     return DownloadResult(
  //       success: true,
  //       url: url, // ✅ return resolved URL
  //     );
  //   } catch (e) {
  //     debugPrint('❌ Download error: $e');
  //     _showMessage('Download failed', context);
  //     return DownloadResult(
  //       success: false,
  //       message: e.toString(),
  //     );
  //   }
  // }

  static Future<void> logout({required BuildContext context}) async {
    printBlue("🚪 Logout started");

    // 🔵 Show loading dialog
    showLogoutDialog(context: context, isLoading: true);

    try {
      final response = await callRemotePostAPI(
        url: AppSettings.api['LOG_OUT'],
        urlRef: 'LOG_OUT',
        payload: {},
        context: context,
      );

      if (response == RestResponse.failed ||
          response == RestResponse.SERVERNOTRESPONDING) {
        Navigator.pop(context); // close loading
        showLogoutDialog(
          context: context,
          errorMessage:
              "Unable to logout. Please check your internet connection.",
        );
        return;
      }

      // ❌ Empty response
      if (response == null || response.toString().isEmpty) {
        Navigator.pop(context);
        showLogoutDialog(
          context: context,
          errorMessage: "Unexpected server response. Please try again.",
        );
        return;
      }

      final decoded = jsonDecode(response);

      if (decoded['status'] != true) {
        Navigator.pop(context);
        AppSettings.saveData(
          'USER_ISLOGIN',
          false,
          SharedPreferenceIOType.BOOL,
        );
        showLogoutDialog(
          context: context,
          errorMessage:
              decoded['message']?.toString() ?? "Logout failed. Try again.",
        );
        return;
      }

      debugPrint("✅ Logout API success");

      await clearAllLocalStorage();

      Navigator.pop(context);

      // Navigator.of(context).pushAndRemoveUntil(
      //   MaterialPageRoute(builder: (_) => const LoginScreen()),
      //   (route) => false,
      // );
    }
    // ⏳ Timeout
    on TimeoutException {
      Navigator.pop(context);
      showLogoutDialog(
        context: context,
        errorMessage: "Server timeout. Please try again later.",
      );
    }
    // 💥 Unknown exception
    catch (e) {
      debugPrint("💥 Logout exception: $e");
      Navigator.pop(context);
      showLogoutDialog(
        context: context,
        errorMessage:
            "Something went wrong while logging out.\nPlease try again.",
      );
    }
  }

  static Future<void> showLogoutDialog({
    required BuildContext context,
    String? errorMessage,
    bool isLoading = false,
  }) async {
    return showDialog(
      context: context,
      barrierDismissible: false, // ❗ cannot dismiss during logout
      builder:
          (_) => AlertDialog(
            title: const Text(
              "Logging Out",
              style: TextStyle(fontFamily: "Poppins"),
            ),
            content:
                isLoading
                    ? const Row(
                      children: [
                        SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                        SizedBox(width: 16),
                        Expanded(
                          child: Text(
                            "Please wait...",
                            style: TextStyle(fontFamily: "Poppins"),
                          ),
                        ),
                      ],
                    )
                    : Text(
                      errorMessage ?? "Something went wrong",
                      style: const TextStyle(fontFamily: "Poppins"),
                    ),
            actions:
                isLoading
                    ? []
                    : [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text("OK"),
                      ),
                    ],
          ),
    );
  }

  static Future<void> clearAllLocalStorage() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }

  static void printGreen(String s) {}
}

class ApiConstants {
  static String HOSTURL = 'https://hrview.edukares.in/';
  static String HOSTURLPATH = 'hrviewmobileapi/api/v1/mobile/';
  static String BASE_URL = HOSTURL + HOSTURLPATH;
  String AUTH = 'http://175.101.84.101:10001/MOBILE_USERS/KIOSK/USERLOGIN';

  String getLoginOtp = '${BASE_URL}loginOTP';

  String logOut = '${BASE_URL}createHrSessionOut';
}

class UserLoginDetails {
  String login_user_name = "";
  String emp_id = "";
  String emp_cd = "";
  String last_session_id = "";
  String display_name = "";
  String user_id = "";
  String UserProfilePicImageData = "";
  String UserProfilePic = "";
  String designationName = "";

  String Email = "";
  String Mobile_NUmber = "";
  String countryName = "";
  String joinedAt = "";

  // 🔹 Profile update fields
  String firstName = "";
  String lastName = "";
  String address = "";
  String city = "";
  String state = "";
  String zip = "";

  /// ✅ FULL SAFE COPY
  UserLoginDetails copy() {
    final clone = UserLoginDetails();
    clone.login_user_name = login_user_name;
    clone.emp_id = emp_id;
    clone.emp_cd = emp_cd;
    clone.last_session_id = last_session_id;
    clone.display_name = display_name;
    clone.user_id = user_id;
    clone.UserProfilePicImageData = UserProfilePicImageData;
    clone.UserProfilePic = UserProfilePic;
    clone.designationName = designationName;
    clone.Email = Email;
    clone.Mobile_NUmber = Mobile_NUmber;
    clone.countryName = countryName;
    clone.joinedAt = joinedAt;

    clone.firstName = firstName;
    clone.lastName = lastName;
    clone.address = address;
    clone.city = city;
    clone.state = state;
    clone.zip = zip;
    return clone;
  }
}

class ApplicationCoreInfo {
  int userMobileNumber2 = 0;
  bool isLogin = false;
  String USER_TOKEN = "";
  bool kyc_from_filled = false;
  bool argo_from_filled = false;
  bool email_verified = false;
  bool mobile_verified = false;
  bool profile_complited = false;
  ApplicationCoreInfo();
  Future<void> updateLocalVariablesWithSharedPreference() async {
    userMobileNumber2 = await AppSettings.getData(
      "USER_MOBILE_NUMBER2",
      SharedPreferenceIOType.INTEGER,
    );
    isLogin = await AppSettings.getData(
      "USER_ISLOGIN",
      SharedPreferenceIOType.BOOL,
    );
    USER_TOKEN = await AppSettings.getData(
      "USER_TOKEN",
      SharedPreferenceIOType.STRING,
    );
    // kyc_from_filled = await AppSettings.getData(
    //   "KYC_FROM_FILLED",
    //   SharedPreferenceIOType.BOOL,
    // );
    // argo_from_filled = await AppSettings.getData(
    //   "ARGO_FROM_FILLED",
    //   SharedPreferenceIOType.BOOL,
    // );
    // email_verified = await AppSettings.getData(
    //   "EMAIL_VERIFIED",
    //   SharedPreferenceIOType.BOOL,
    // );
    // mobile_verified = await AppSettings.getData(
    //   "MOBILE_VERIFIED",
    //   SharedPreferenceIOType.BOOL,
    // );
    // profile_complited = await AppSettings.getData(
    //   "PROFILE_COMPLITED",
    //   SharedPreferenceIOType.BOOL,
    // );

    /// aap data clear or reload for this method
  }
}

// void navigateWithLoader(BuildContext context, Widget screen) {
//   showCustomLoader(context);

//   Future.delayed(const Duration(milliseconds: 300), () {
//     Navigator.of(context, rootNavigator: true).pop();
//     KeyboardHelper.dismissKeyboard(context);

//     NavigationHelper.pushTo(context, screen);
//   });
// }

class DownloadResult {
  final bool success;
  final String? url;
  final String? message;

  DownloadResult({required this.success, this.url, this.message});
}
