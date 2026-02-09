import 'dart:convert';
import 'dart:io';
import 'package:aiplantidentifier/main.dart';
import 'package:aiplantidentifier/models/routineplant_model.dart';
import 'package:aiplantidentifier/utils/helper_methodes.dart';
import 'package:aiplantidentifier/views/plantscareroutine/careroutine.dart';
import 'package:aiplantidentifier/models/dairy_plant_model.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mysql1/mysql1.dart';

class DatabaseHelper {
  static const table = 'plant_identification_history';

  static const columnId = 'id';
  static const columnName = 'name';
  static const columnImagePath = 'image_path';
  static const columnResult = 'result';
  static const columnTimestamp = 'timestamp';
  static const columnPlantType = 'plant_type';
  static const columnHealthStatus = 'health_status';

  DatabaseHelper._privateConstructor();
  static final DatabaseHelper instance = DatabaseHelper._privateConstructor();
  static MySqlConnection? _connection;
  static final _settings = ConnectionSettings(
    host: '193.203.184.8',
    port: 3306,
    user: 'u679077773_flora_plants',
    password: 'Bstore@9652',
    db: 'u679077773_flora_plants',
  );
  static Future<MySqlConnection> _getConnection() async {
    if (_connection == null) {
      _connection = await MySqlConnection.connect(_settings);
      printGreen('✅ MySQL connected (new)');
      return _connection!;
    }
    try {
      await _connection!.query('SELECT 1');
      return _connection!;
    } catch (e) {
      printRed('🔄 MySQL connection lost, reconnecting...');
      try {
        await _connection!.close();
      } catch (_) {}
      _connection = await MySqlConnection.connect(_settings);
      return _connection!;
    }
  }

  static Future<void> close() async {
    if (_connection != null) {
      await _connection!.close();
      _connection = null;
      printRed('❌ MySQL connection closed');
    }
  }

  Future<int> insertIdentification(Map<String, dynamic> row) async {
    final conn = await _getConnection();
    try {
      final imageBytes = row[columnImagePath];
      Uint8List actualBytes;
      if (imageBytes is Uint8List) {
        actualBytes = imageBytes;
      } else if (imageBytes is Blob) {
        actualBytes = Uint8List.fromList(imageBytes.toBytes());
      } else if (imageBytes is List<int>) {
        actualBytes = Uint8List.fromList(imageBytes);
      } else {
        throw ArgumentError(
          'Invalid image data type: ${imageBytes.runtimeType}',
        );
      }
      final base64Image = base64Encode(actualBytes);
      printGreen(
        '💾 Storing image as Base64 (${actualBytes.length} bytes → ${base64Image.length} chars)',
      );
      final result = await conn.query(
        '''
        INSERT INTO $table
        ($columnName, $columnImagePath, $columnResult, $columnTimestamp,
         $columnPlantType, $columnHealthStatus)
        VALUES (?, ?, ?, ?, ?, ?)
        ''',
        [
          row[columnName],
          base64Image,
          row[columnResult],
          row[columnTimestamp],
          row[columnPlantType],
          row[columnHealthStatus],
        ],
      );
      printGreen('✅ Image stored successfully with ID: ${result.insertId}');
      RoutineRefreshNotifier.refresh();
      return result.insertId!;
    } finally {
      // await conn.close();
    }
  }

  Future<List<Map<String, dynamic>>> getAllIdentifications() async {
    final conn = await _getConnection();
    try {
      final results = await conn.query('''
        SELECT $columnId, $columnName, $columnResult,
               $columnTimestamp, $columnPlantType, $columnHealthStatus
        FROM $table
        ORDER BY $columnTimestamp DESC
      ''');
      final List<Map<String, dynamic>> data = [];
      for (final row in results) {
        final map = Map<String, dynamic>.from(row.fields);
        final value = map[columnResult];
        if (value is Blob) {
          map[columnResult] = String.fromCharCodes(value.toBytes());
        }
        data.add(map);
      }
      return data;
    } finally {
      // await conn.close();
    }
  }

  Future<Uint8List?> getIdentificationImage(int id) async {
    debugPrint('📥 Fetching image for ID: $id');
    final conn = await _getConnection();
    try {
      final results = await conn.query(
        'SELECT $columnImagePath FROM $table WHERE $columnId = ? LIMIT 1',
        [id],
      );
      if (results.isEmpty) {
        printRed('❌ No image found for ID: $id');
        return null;
      }
      final value = results.first[columnImagePath];
      if (value == null) {
        printRed('❌ Image data is NULL for ID: $id');
        return null;
      }
      try {
        String base64String;
        if (value is String) {
          base64String = value;
        } else if (value is Blob) {
          base64String = String.fromCharCodes(value.toBytes());
        } else {
          printRed('❌ Unexpected type: ${value.runtimeType}');
          return null;
        }
        final imageBytes = base64Decode(base64String);
        debugPrint('✅ Decoded image: ${imageBytes.length} bytes');
        _debugImageHeader(imageBytes, id);
        return imageBytes;
      } catch (e) {
        printRed('❌ Base64 decode error for ID $id: $e');
        return null;
      }
    } finally {
      // await conn.close();
    }
  }

  Future<void> deleteAllAppData() async {
    final conn = await _getConnection();
    const tag = '[DB_CLEAR]';

    Future<void> safeDelete(String table) async {
      try {
        debugPrint('$tag 🧹 Deleting data from $table');

        final before = await conn.query('SELECT COUNT(*) AS count FROM $table');
        final beforeCount = before.first['count'];

        await conn.query('DELETE FROM $table');

        final after = await conn.query('SELECT COUNT(*) AS count FROM $table');
        final afterCount = after.first['count'];

        if (afterCount == 0) {
          debugPrint(
            '$tag ✅ $table cleared successfully (before=$beforeCount → after=$afterCount)',
          );
        } else {
          debugPrint(
            '$tag ⚠️ $table NOT fully cleared (remaining=$afterCount)',
          );
        }
      } catch (e) {
        // VERY IMPORTANT: do NOT throw
        printRed(
          '$tag ⚠️ Skipped $table (reason: ${e.toString().split('\n').first})',
        );
      }
    }

    try {
      debugPrint('$tag 🚨 Starting FULL database cleanup');

      await conn.query('SET FOREIGN_KEY_CHECKS = 0');

      await safeDelete('care_tasks');
      await safeDelete('plant_identification_history');
      await safeDelete('plant_entries');
      await safeDelete('dairyplants');
      await safeDelete('plants');

      await conn.query('SET FOREIGN_KEY_CHECKS = 1');

      debugPrint('$tag 🎉 DATABASE CLEANUP COMPLETED');
    } catch (e, stack) {
      printRed('$tag ❌ Unexpected error');
      printRed('$tag Error: $e');
      printRed(stack.toString().split('\n').first);
    } finally {
      // await conn.close();
      debugPrint('$tag 🔌 Database connection closed');
    }
  }

  void _debugImageHeader(Uint8List bytes, int id) {
    if (bytes.isEmpty) {
      printRed('❌ Empty image data for ID: $id');
      return;
    }

    final header = bytes.take(16).toList();
    final headerHex = header
        .map((b) => b.toRadixString(16).padLeft(2, '0'))
        .join(' ');

    debugPrint('📊 Image ID: $id | Size: ${bytes.length} bytes');
    debugPrint('📊 Header (hex): $headerHex');

    if (bytes.length >= 2) {
      if (bytes[0] == 0xFF && bytes[1] == 0xD8) {
        printGreen('✅ Valid JPEG detected');
      } else if (bytes[0] == 0x89 && bytes[1] == 0x50) {
        printGreen('✅ Valid PNG detected');
      } else {
        printGreen('⚠️ Unknown image format');
      }
    }
  }

  Future<int> deleteIdentification(int id) async {
    final conn = await _getConnection();
    try {
      final result = await conn.query(
        'DELETE FROM $table WHERE $columnId = ?',
        [id],
      );
      return result.affectedRows ?? 0;
    } finally {
      // await conn.close();
    }
  }

  Future<void> deleteAllIdentifications() async {
    final conn = await _getConnection();
    try {
      await conn.query('DELETE FROM $table');
      debugPrint('🗑️ All identifications deleted');
    } finally {
      // await conn.close();
    }
  }

  Future<void> _ensureCareTasksSchema() async {
    final conn = await _getConnection();
    try {
      await conn.query('''
    CREATE TABLE IF NOT EXISTS care_tasks (
      id INT AUTO_INCREMENT PRIMARY KEY,
      plantId INT NOT NULL,
      title VARCHAR(255) NOT NULL,
      intervalDays INT NOT NULL,
      nextRunAt DATETIME NOT NULL,
      isEnabled TINYINT(1) DEFAULT 1,
      createdAt DATETIME DEFAULT CURRENT_TIMESTAMP,
      INDEX idx_plantId (plantId)
    )
    ''');

      final columns = await conn.query(
        "SHOW COLUMNS FROM care_tasks LIKE 'lastCompletedAt'",
      );

      if (columns.isEmpty) {
        debugPrint('🛠 Adding missing column: lastCompletedAt');

        await conn.query('''
        ALTER TABLE care_tasks
        ADD COLUMN lastCompletedAt DATETIME NULL AFTER nextRunAt
      ''');
      }
    } finally {
      // await conn.close();
    }
  }

  Future<void> insertCareTask({
    required int plantId,
    required String title,
    required int intervalDays,
    bool isEnabled = true,
    required DateTime nextRunAt,
  }) async {
    await _ensureCareTasksSchema();

    final conn = await _getConnection();
    try {
      await conn.query(
        '''
      INSERT INTO care_tasks
      (plantId, title, intervalDays, nextRunAt, lastCompletedAt, isEnabled)
      VALUES (?, ?, ?, ?, ?, ?)
      ''',
        [
          plantId,
          title,
          intervalDays,
          DateTime.now().toIso8601String(),
          null,
          isEnabled ? 1 : 0,
        ],
      );
    } finally {
      // await conn.close();
    }
  }

  Future<List<Map<String, dynamic>>> getCareTasksByPlantId(int plantId) async {
    final conn = await _getConnection();

    try {
      final results = await conn.query(
        'SELECT * FROM care_tasks WHERE plantId = ? ORDER BY nextRunAt ASC',
        [plantId],
      );

      final rows =
          results.map((r) => Map<String, dynamic>.from(r.fields)).toList();

      // 🔍 DEBUG PRINT WITH TAGS
      const tag = '[CARE_TASK_DB]';

      debugPrint('$tag Plant ID: $plantId');
      debugPrint('$tag Total Rows: ${rows.length}');

      for (int i = 0; i < rows.length; i++) {
        debugPrint('$tag ---- Row ${i + 1} ----');
        rows[i].forEach((key, value) {
          debugPrint('$tag $key : $value');
        });
      }

      return rows;
    } finally {
      // await conn.close();
    }
  }

  Future<void> updatePlantReminders(int plantId, bool enabled) async {
    final conn = await _getConnection();
    try {
      await conn.query(
        'UPDATE care_tasks SET isEnabled = ? WHERE plantId = ?',
        [enabled ? 1 : 0, plantId],
      );
    } finally {
      // await conn.close();
    }
  }

  Future<void> markTaskCompleted(int taskId) async {
    final conn = await _getConnection();
    try {
      final result = await conn.query(
        'SELECT intervalDays, nextRunAt FROM care_tasks WHERE id = ?',
        [taskId],
      );

      if (result.isEmpty) return;

      final intervalDays = result.first['intervalDays'] as int;
      final currentRun = DateTime.parse(result.first['nextRunAt'].toString());

      final now = DateTime.now();
      final nextRun = currentRun.add(Duration(days: intervalDays));

      await conn.query(
        '''
      UPDATE care_tasks
      SET 
        lastCompletedAt = ?,
        nextRunAt = ?
      WHERE id = ?
      ''',
        [now.toIso8601String(), nextRun.toIso8601String(), taskId],
      );
    } finally {
      // await conn.close();
    }
  }

  int extractDays(String text) {
    final match = RegExp(r'(\d+)').firstMatch(text);
    return match != null ? int.parse(match.group(1)!) : 1;
  }

  Future<void> createCareTasksFromLLM({
    required int plantId,
    required Map<String, dynamic> llmResult,
  }) async {
    final timeline = llmResult['timeline'] ?? [];

    for (final item in timeline) {
      final days = extractDays(item['subtitle'] ?? '');

      await DatabaseHelper.instance.insertCareTask(
        plantId: plantId,
        title: item['title'],
        intervalDays: days,
        nextRunAt: DateTime.now().add(Duration(days: days)),
      );
    }
  }

  Future<List<RoutinePlant>> getRoutinePlantsFromResult() async {
    final conn = await _getConnection();
    debugPrint('🟢 MySQL connection opened');

    try {
      debugPrint('📤 Running SELECT query on $table');

      final results = await conn.query('''
      SELECT $columnId, $columnName, $columnResult
      FROM $table
      ORDER BY $columnTimestamp DESC
    ''');

      debugPrint('📥 Total rows fetched: ${results.length}');

      final List<RoutinePlant> plants = [];
      int index = 0;

      for (final row in results) {
        index++;

        debugPrint('\n------------ PLANT ROW #$index ------------');

        final plantId = row[columnId] as int;
        final name = row[columnName] as String;
        final resultRaw = row[columnResult];

        debugPrint('🆔 plantId        : $plantId');
        debugPrint('🌱 plantName      : $name');
        debugPrint('📦 resultRaw type : ${resultRaw.runtimeType}');

        String resultJson;
        if (resultRaw is Blob) {
          debugPrint('🔄 Converting Blob → String');
          resultJson = utf8.decode(resultRaw.toBytes());
        } else {
          debugPrint('🔄 Using String result directly');
          resultJson = resultRaw.toString();
        }

        debugPrint('📄 Raw JSON length: ${resultJson.length}');
        debugPrint(
          '📄 Raw JSON preview:\n'
          '${resultJson.length > 400 ? '${resultJson.substring(0, 400)}...' : resultJson}',
        );

        Map<String, dynamic> decoded;
        try {
          decoded = jsonDecode(resultJson);
          debugPrint('✅ JSON decoded successfully');
        } catch (e) {
          debugPrint('❌ JSON decode failed for plantId $plantId');
          debugPrint('❌ Error: $e');
          continue;
        }

        final routine = decoded['routine'];
        if (routine == null) {
          debugPrint('⚠️ routine block is NULL for plantId $plantId');
        } else {
          debugPrint('🧩 routine keys: ${routine.keys.toList()}');

          debugPrint('📌 routine_status    : ${routine['routine_status']}');
          debugPrint('📌 maintenance_level : ${routine['maintenance_level']}');
          debugPrint('📌 today_task        : ${routine['today_task']}');
          debugPrint('📌 ai_tip            : ${routine['ai_tip']}');

          debugPrint(
            '📌 timeline count    : ${(routine['timeline'] as List?)?.length ?? 0}',
          );
          debugPrint(
            '📌 upcoming_care cnt : ${(routine['upcoming_care'] as List?)?.length ?? 0}',
          );
        }

        final plant = _routinePlantFromLLM(
          plantId: plantId,
          name: name,
          llm: decoded,
        );

        debugPrint('🎨 UI MODEL CREATED');
        debugPrint('   name        : ${plant.name}');
        debugPrint('   status      : ${plant.status}');
        debugPrint('   maintenance : ${plant.maintenance}');
        debugPrint('   todayTask   : ${plant.todayTask}');
        debugPrint('   aiTip       : ${plant.aiTip}');
        debugPrint('   timeline    : ${plant.timeline.length}');
        debugPrint('   upcoming    : ${plant.upcomingCare.length}');

        plants.add(plant);
      }

      debugPrint('\n================ ROUTINE FETCH END =================');
      debugPrint('✅ Total RoutinePlant objects: ${plants.length}');

      return plants;
    } catch (e, stack) {
      debugPrint('🔥 FATAL ERROR in getRoutinePlantsFromResult');
      debugPrint('🔥 Error: $e');
      debugPrint('🔥 Stack: $stack');
      rethrow;
    } finally {
      // await conn.close();
      debugPrint('🔴 MySQL connection closed');
    }
  }

  RoutinePlant _routinePlantFromLLM({
    required int plantId,
    required String name,
    required Map<String, dynamic> llm,
  }) {
    final routine = llm['routine'] ?? {};

    debugPrint('🔁 Mapping RoutinePlant for plantId: $plantId');
    debugPrint('   routine keys: ${routine.keys.toList()}');

    return RoutinePlant(
      id: plantId,
      name: name,

      image: '',

      status: routine['routine_status'] ?? 'Unknown',

      category: llm['category'] ?? '',

      todayTask: routine['today_task'] ?? '',

      lastUpdate: formatDateTime(DateTime.now().toIso8601String()),

      isHealthy:
          (routine['routine_status'] ?? '').toString().toLowerCase() ==
          'healthy',

      maintenance: routine['maintenance_level'] ?? '',

      aiTip: routine['ai_tip'] ?? '',

      timeline: _buildTimeline(routine['timeline']),

      upcomingCare: _buildUpcomingCare(routine['upcoming_care']),
    );
  }

  List<TimelineItem> _buildTimeline(dynamic data) {
    if (data is! List) return [];

    return data.map<TimelineItem>((e) {
      return TimelineItem(
        title: e['title'] ?? '',
        subtitle: e['subtitle'] ?? '',
        isCompleted: e['isCompleted'] ?? false,
      );
    }).toList();
  }

  List<UpcomingCare> _buildUpcomingCare(dynamic data) {
    if (data is! List) return [];

    return data.map<UpcomingCare>((e) {
      return UpcomingCare(
        title: e['title'] ?? '',
        subtitle: e['subtitle'] ?? '',
        timeframe: e['timeframe'] ?? '',
        icon: e["icon"] ?? "",
        color: Colors.green,
      );
    }).toList();
  }

  Future<List<DairyPlantModel>> fetchPlants() async {
    final conn = await _getConnection();
    final plantRows = await conn.query('SELECT * FROM dairyplants');

    List<DairyPlantModel> plants = [];

    for (final row in plantRows) {
      final plantId = _asInt(row['id']);
      final entries = await fetchEntries(plantId ?? 0);

      final imageBase64 = _blobToString(row['image_url']);

      debugPrint('[PLANT_DB] image type: ${row["image_url"].runtimeType}');
      debugPrint('[PLANT_DB] base64 length: ${imageBase64.length}');

      plants.add(
        DairyPlantModel(
          id: plantId,
          name: _asString(row['name']),
          imageUrl: imageBase64,
          status: _asString(row['status']),
          statusColor: _asString(row['status_color']),
          plantType: _asString(row['plant_type']),
          lastUpdated: formatDateTime(row['last_updated']),
          additionalStatus: _asString(row['additional_status']),
          entries: entries,
        ),
      );
    }

    return plants;
  }

  String _blobToString(dynamic value) {
    if (value == null) return '';

    if (value is String) {
      return value;
    }

    if (value is Blob) {
      return String.fromCharCodes(value.toBytes());
    }

    throw Exception('Unsupported image_url type: ${value.runtimeType}');
  }

  static String _asString(dynamic v) {
    if (v == null) return '';
    if (v is Blob) {
      return String.fromCharCodes(v.toBytes());
    }
    return v.toString();
  }

  Future<int> insertPlant(DairyPlantModel plant) async {
    MySqlConnection? conn;

    try {
      conn = await _getConnection();

      await _createPlantsTableIfNotExists();
      await _createPlantEntriesTableIfNotExists();

      debugPrint('[PLANT_DB] Inserting plant: ${plant.name}');

      final result = await conn.query(
        '''
      INSERT INTO dairyplants
      (name, image_url, status, status_color, last_updated, additional_status, plant_type)
      VALUES (?, ?, ?, ?, ?, ?, ?)
      ''',
        [
          plant.name,
          plant.imageUrl,
          plant.status,
          plant.statusColor,
          plant.lastUpdated,
          plant.additionalStatus,
          plant.plantType,
        ],
      );

      final insertedId = result.insertId ?? 0;
      debugPrint('[PLANT_DB] Plant inserted with ID=$insertedId');

      return insertedId;
    } on SocketException catch (e) {
      debugPrint('[PLANT_DB] SocketException while inserting plant: $e');
      return 0;
    } on MySqlException catch (e) {
      debugPrint('[PLANT_DB] MySQL error while inserting plant: $e');
      return 0;
    } catch (e, stack) {
      debugPrint('[PLANT_DB] Unexpected error while inserting plant: $e');
      debugPrint(stack.toString().split('\n').first);
      return 0;
    } finally {
      try {
        await conn?.close();
        debugPrint('[PLANT_DB] Connection closed (insertPlant)');
      } catch (_) {
        // ignore close errors
      }
    }
  }

  Future<void> _createPlantsTableIfNotExists() async {
    final conn = await _getConnection();

    await conn.query('''
  CREATE TABLE IF NOT EXISTS dairyplants (
    id INT AUTO_INCREMENT PRIMARY KEY, 
    name VARCHAR(255) NOT NULL,
    image_url LONGTEXT,
    status VARCHAR(50),
    status_color VARCHAR(20),
    last_updated VARCHAR(100),
    additional_status VARCHAR(100),
    user_notes TEXT,
    plant_type VARCHAR(100),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
  ) ENGINE=InnoDB
  ''');
    conn.close();
  }

  Future<int> insertEntry(PlantEntry entry, int plantId) async {
    MySqlConnection? conn;

    if (plantId <= 0) {
      debugPrint('[PLANT_ENTRY_DB] Invalid plantId=$plantId');
      return 0;
    }

    try {
      conn = await _getConnection();

      await _createPlantEntriesTableIfNotExists();

      debugPrint('[PLANT_ENTRY_DB] Inserting entry for plant_id=$plantId');

      final result = await conn.query(
        '''
      INSERT INTO plant_entries
      (plant_id, description, image_url, status, timestamp, update_time, user_notes,plant_type)
      VALUES (?, ?, ?, ?, ?, ?, ?, ?)
      ''',
        [
          plantId,
          entry.description ?? '',
          entry.imageUrl,
          entry.status,
          entry.timestamp,
          entry.updateTime,
          entry.userNotes,
          entry.plantType,
        ],
      );

      final entryId = result.insertId ?? 0;
      debugPrint('[PLANT_ENTRY_DB] Entry inserted with ID=$entryId');

      return entryId;
    } on SocketException catch (e) {
      debugPrint('[PLANT_ENTRY_DB] SocketException: $e');
      return 0;
    } on MySqlException catch (e) {
      debugPrint('[PLANT_ENTRY_DB] MySQL exception: $e');
      return 0;
    } catch (e, stack) {
      debugPrint('[PLANT_ENTRY_DB] Unexpected error: $e');
      debugPrint(stack.toString().split('\n').first);
      return 0;
    } finally {
      try {
        await conn?.close();
        debugPrint('[PLANT_ENTRY_DB] Connection closed (insertEntry)');
      } catch (_) {
        // ignore close errors
      }
    }
  }

  Future<bool> updateEntry(PlantEntry entry) async {
    MySqlConnection? conn;

    if (entry.plantId <= 0) {
      debugPrint('[PLANT_ENTRY_DB] Invalid entryId=${entry.plantId}');
      return false;
    }

    try {
      conn = await _getConnection();

      debugPrint('[PLANT_ENTRY_DB] Updating entry id=${entry.plantId}');

      final result = await conn.query(
        '''
      UPDATE plant_entries SET
        description = ?,
        image_url = ?,
        status = ?,
        timestamp = ?,
        update_time = ?,
        user_notes = ?
        plant_type=?
      WHERE plant_id = ?
      ''',
        [
          entry.description ?? '',
          entry.imageUrl,
          entry.status,
          entry.timestamp,
          entry.updateTime,
          entry.userNotes,
          entry.plantId,
          entry.plantType,
        ],
      );

      final affectedRows = result.affectedRows ?? 0;
      debugPrint(
        '[PLANT_ENTRY_DB] Update completed, affectedRows=$affectedRows',
      );

      return affectedRows > 0;
    } on SocketException catch (e) {
      debugPrint('[PLANT_ENTRY_DB] SocketException: $e');
      return false;
    } on MySqlException catch (e) {
      debugPrint('[PLANT_ENTRY_DB] MySQL exception: $e');
      return false;
    } catch (e, stack) {
      debugPrint('[PLANT_ENTRY_DB] Unexpected error: $e');
      debugPrint(stack.toString().split('\n').first);
      return false;
    } finally {
      try {
        await conn?.close();
        debugPrint('[PLANT_ENTRY_DB] Connection closed (updateEntry)');
      } catch (_) {
        // ignore close errors
      }
    }
  }

  Future<void> _createPlantEntriesTableIfNotExists() async {
    const tag = '[DB_CREATE]';
    final conn = await _getConnection();

    debugPrint('$tag 🔍 Checking if plant_entries table exists...');

    try {
      debugPrint('$tag ├─ Ensuring dairyplants table exists...');
      await _createPlantsTableIfNotExists();
      debugPrint('$tag │  └─ dairyplants table verified');

      debugPrint('$tag ├─ Checking for existing plant_entries table...');
      final checkResult = await conn.query("SHOW TABLES LIKE 'plant_entries'");

      bool tableExists = checkResult.first.isNotEmpty;
      debugPrint('$tag │  └─ Table exists: $tableExists');

      if (!tableExists) {
        debugPrint('$tag ├─ Creating plant_entries table...');
        debugPrint(
          '$tag │  ├─ SQL: CREATE TABLE IF NOT EXISTS plant_entries (...)',
        );

        await conn.query('''
        CREATE TABLE plant_entries (
          id INT AUTO_INCREMENT PRIMARY KEY,  
          plant_id INT NOT NULL,  
          description TEXT,
          image_url LONGTEXT,
          status VARCHAR(50),
          timestamp VARCHAR(100),
          update_time VARCHAR(50),
          user_notes TEXT,
          plant_type VARCHAR(100),
          created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
          FOREIGN KEY (plant_id) REFERENCES dairyplants(id) ON DELETE CASCADE
        ) ENGINE=InnoDB
      ''');

        debugPrint('$tag │  └─ CREATE TABLE command executed');

        debugPrint('$tag ├─ Verifying table creation...');
        final verifyResult = await conn.query(
          "SHOW TABLES LIKE 'plant_entries'",
        );

        bool creationVerified = verifyResult.first.isNotEmpty;
        debugPrint('$tag │  └─ Creation verified: $creationVerified');

        if (creationVerified) {
          debugPrint(
            '$tag ├─ ✅ SUCCESS: plant_entries table created successfully!',
          );

          final structure = await conn.query('DESCRIBE plant_entries');
          debugPrint('$tag ├─ Table structure:');
          for (var row in structure.first) {
            debugPrint(
              '$tag │  ├─ ${row[0]} - ${row[1]} ${row[2] == 'NO' ? 'NOT NULL' : ''} ${row[3]}',
            );
          }
          debugPrint('$tag │  └─ Total columns: ${structure.first.length}');
        } else {
          debugPrint('$tag ├─ ❌ FAILURE: Table creation verification failed!');
          throw Exception('Failed to verify plant_entries table creation');
        }
      } else {
        debugPrint('$tag ├─ ✅ Table already exists, skipping creation');

        final tableInfo = await conn.query(
          "SELECT TABLE_NAME, ENGINE, TABLE_ROWS, CREATE_TIME FROM information_schema.TABLES WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = 'plant_entries'",
        );

        if (tableInfo.first.isNotEmpty) {
          final row = tableInfo.first[0];
          debugPrint('$tag ├─ Table info:');
          debugPrint('$tag │  ├─ Name: ${row[0]}');
          debugPrint('$tag │  ├─ Engine: ${row[1]}');
          debugPrint('$tag │  ├─ Rows: ${row[2]}');
          debugPrint('$tag │  └─ Created: ${row[3]}');
        }
      }

      debugPrint('$tag ├─ Performing final verification query...');
      try {
        await conn.query('SELECT 1 FROM plant_entries LIMIT 0');
        debugPrint('$tag │  └─ ✅ Verification query successful');
      } catch (e) {
        debugPrint('$tag │  └─ ❌ Verification query failed: $e');
        throw Exception('Table exists but query failed: $e');
      }

      debugPrint('$tag └─ 🏁 plant_entries table is READY for use');
    } catch (e, stack) {
      debugPrint('$tag 🔥 ERROR creating/verifying plant_entries table');
      debugPrint('$tag ├─ Error: $e');
      debugPrint('$tag ├─ Stack trace:');
      debugPrint('$tag │  ${stack.toString().split('\n').first}');
      debugPrint('$tag └─ Connection status: ${'Connected'}');

      debugPrint(
        '$tag 🔄 Attempting fallback creation (without foreign key)...',
      );
      try {
        await conn.query('''
        CREATE TABLE IF NOT EXISTS plant_entries (
          id INT AUTO_INCREMENT PRIMARY KEY,  
          plant_id INT NOT NULL,  
          description TEXT,
          image_url LONGTEXT,
          status VARCHAR(50),
          user_notes TEXT,
          timestamp VARCHAR(100),
          update_time VARCHAR(50),
          plant_type VARCHAR(100),
          created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
        )
      ''');
        debugPrint('$tag ├─ ✅ Fallback table created (no foreign key)');
      } catch (fallbackError) {
        debugPrint('$tag ├─ ❌ Fallback also failed: $fallbackError');
        rethrow;
      }
    }
  }

  Future<void> updatePlant(DairyPlantModel plant) async {
    final conn = await _getConnection();

    await conn.query(
      '''
      UPDATE dairyplants SET
        name = ?,
        image_url = ?,
        status = ?,
        status_color = ?,
        last_updated = ?,
        additional_status = ?
        plant_type=?
      WHERE id = ?
      ''',
      [
        plant.name,
        plant.imageUrl,
        plant.status,
        plant.statusColor,
        plant.lastUpdated,
        plant.additionalStatus,
        plant.id,
        plant.plantType,
      ],
    );
  }

  Future<bool> deletePlant(String plantId) async {
    try {
      final conn = await _getConnection();

      final result = await conn.query('DELETE FROM dairyplants WHERE id = ?', [
        plantId,
      ]);

      if (result.affectedRows == 0) {
        debugPrint('[PLANT_DB][DELETE] ❌ No record found for plantId=$plantId');
        return false;
      }

      debugPrint(
        '[PLANT_DB][DELETE] ✅ Plant deleted successfully (plantId=$plantId)',
      );
      return true;
    } catch (e, stack) {
      debugPrint('[PLANT_DB][DELETE] ❌ Error $e deleting plantId=$plantId');
      debugPrint('Error: $e');
      debugPrint('StackTrace: $stack');
      rethrow;
    }
  }

  int? _asInt(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    if (value is String) return int.tryParse(value);
    if (value is double) return value.toInt();
    return null;
  }

  Future<List<PlantEntry>> fetchEntries(int plantId) async {
    final conn = await _getConnection();

    final rows = await conn.query(
      'SELECT * FROM plant_entries WHERE plant_id = ?',
      [plantId],
    );

    return rows.map((r) {
      return PlantEntry(
        id: _asInt(r['id']),
        plantId: _asInt(r['plant_id']) ?? 0,
        description: _asString(r['description']),
        imageUrl: _asString(r['image_url']),
        status: _asString(r['status']),
        timestamp: formatDateTime(r['timestamp']),
        updateTime: formatDateTime(r['update_time']),

        userNotes: _asString(r['user_notes']),
      );
    }).toList();
  }

  String formatDateTime(dynamic value) {
    debugPrint('⏱️ [formatDateTime] INPUT  -> $value (${value.runtimeType})');

    if (value == null) return '';

    DateTime? date;

    if (value is DateTime) {
      date = value;
    } else if (value is String) {
      date = DateTime.tryParse(value);
    }

    if (date == null) return '';

    final local = date.toLocal();

    final formatted = DateFormat('MMM dd, hh:mm a').format(local);

    debugPrint('⏱️ [formatDateTime] OUTPUT -> $formatted');
    return formatted;
  }

  Future<void> deleteEntry(int entryId) async {
    final conn = await _getConnection();
    await conn.query('DELETE FROM plant_entries WHERE id = ?', [entryId]);
  }

  Future<void> deleteAllData() async {
    final conn = await _getConnection();

    Future<void> safeClear(String table) async {
      try {
        debugPrint('🧹 [DB_CLEAR] Processing table: $table');

        await conn.query('DELETE FROM $table');
        debugPrint('✅ [DB_CLEAR] Data deleted from $table');

        await conn.query('DROP TABLE IF EXISTS $table');
        debugPrint('✅ [DB_CLEAR] Table dropped: $table');
      } catch (e) {
        debugPrint(
          '⚠️ [DB_CLEAR] Skipped $table (reason: ${e.toString().split('\n').first})',
        );
      }
    }

    try {
      debugPrint('🚨 [DB_CLEAR] Starting FULL database cleanup');

      await safeClear('plant_entries');
      await safeClear('care_tasks');
      await safeClear('dairyplants');
      await safeClear('plants');

      debugPrint('🎉 [DB_CLEAR] Database cleanup completed (with tolerance)');
    } catch (e) {
      // This should almost never happen now
      debugPrint('❌ [DB_CLEAR] Unexpected fatal error: $e');
    } finally {
      // await conn.close();
      debugPrint('🔌 [DB_CLEAR] Database connection closed');
    }
  }
}
