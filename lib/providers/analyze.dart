import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';

import '../database/database.dart';

class PlantIdentificationProvider with ChangeNotifier {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;
  List<Map<String, dynamic>> _identificationHistory = [];
  List<Map<String, dynamic>> get identificationHistory =>
      _identificationHistory;

  PlantIdentificationProvider() {
    _initialize();
  }

  Future<void> _initialize() async {
    await loadHistory();
  }

  Future<void> loadHistory() async {
    try {
      _identificationHistory = await _dbHelper.getAllIdentifications();
      notifyListeners();
    } catch (e) {
      debugPrint('Error loading history: $e');
      _identificationHistory = [];
      notifyListeners();
    }
  }

  Future<void> saveIdentification(
    String name,
    Uint8List imageBytes,
    String result, {
    String? plantType,
    String? healthStatus,
  }) async {
    try {
      if (imageBytes.isEmpty) {
        throw ArgumentError('Image bytes cannot be empty');
      }

      if (!_isValidImageFormat(imageBytes)) {
        debugPrint('⚠️ Warning: Image may not be in a standard format');
      }

      final Map<String, dynamic> decodedResult = jsonDecode(result);

      final plantId = await _dbHelper.insertIdentification({
        DatabaseHelper.columnName: name,
        DatabaseHelper.columnImagePath: imageBytes,
        DatabaseHelper.columnResult: result,
        DatabaseHelper.columnPlantType: plantType,
        DatabaseHelper.columnHealthStatus: healthStatus,
        DatabaseHelper.columnTimestamp: DateTime.now().millisecondsSinceEpoch,
      });

      debugPrint('🌱 Plant saved with ID: $plantId');

      final routine = decodedResult['routine'];
      if (routine != null) {
        await DatabaseHelper.instance.createCareTasksFromLLM(
          plantId: plantId,
          llmResult: routine,
        );
        debugPrint('📝 Care tasks created for plantId: $plantId');
      } else {
        debugPrint('⚠️ No routine found in AI response');
      }

      await loadHistory();
    } catch (e) {
      debugPrint('❌ Error saving identification: $e');
      rethrow;
    }
  }

  bool _isValidImageFormat(Uint8List bytes) {
    if (bytes.length < 2) return false;

    if (bytes[0] == 0xFF && bytes[1] == 0xD8) return true;

    if (bytes.length >= 4 &&
        bytes[0] == 0x89 &&
        bytes[1] == 0x50 &&
        bytes[2] == 0x4E &&
        bytes[3] == 0x47) {
      return true;
    }

    if (bytes.length >= 12 &&
        bytes[0] == 0x52 &&
        bytes[1] == 0x49 &&
        bytes[2] == 0x46 &&
        bytes[3] == 0x46 &&
        bytes[8] == 0x57 &&
        bytes[9] == 0x45 &&
        bytes[10] == 0x42 &&
        bytes[11] == 0x50) {
      return true;
    }

    return false;
  }

  Future<Uint8List?> getIdentificationImage(int id) async {
    return await _dbHelper.getIdentificationImage(id);
  }

  Future<void> deleteIdentification(int id) async {
    await _dbHelper.deleteIdentification(id);
    await loadHistory();
  }

  Map<String, int> getPlantsByType() {
    final Map<String, int> plantTypeCounts = {};
    for (var entry in _identificationHistory) {
      final plantType =
          entry[DatabaseHelper.columnPlantType] as String? ?? 'Unknown';
      plantTypeCounts[plantType] = (plantTypeCounts[plantType] ?? 0) + 1;
    }
    return plantTypeCounts;
  }

  Map<String, int> getPlantsByHealthStatus() {
    final Map<String, int> healthStatusCounts = {};
    for (var entry in _identificationHistory) {
      final healthStatus =
          entry[DatabaseHelper.columnHealthStatus] as String? ?? 'Unknown';
      healthStatusCounts[healthStatus] =
          (healthStatusCounts[healthStatus] ?? 0) + 1;
    }
    return healthStatusCounts;
  }
}
