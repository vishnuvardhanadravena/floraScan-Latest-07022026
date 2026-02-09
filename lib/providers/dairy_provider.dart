import 'package:aiplantidentifier/database/database.dart';
import 'package:flutter/material.dart';
import '../models/dairy_plant_model.dart';

class PlantProvider extends ChangeNotifier {
  List<DairyPlantModel> _plants = [];
  List<DairyPlantModel> get plants => _plants;

  DairyPlantModel? lastInsertedPlant;
  PlantEntry? lastInsertedEntry;
  List<PlantEntry> lastFetchedEntries = [];
  int? lastInsertedPlantId;
  int? lastInsertedEntryId;

  Future<List<DairyPlantModel>> loadPlants() async {
    _plants = await DatabaseHelper.instance.fetchPlants();
    notifyListeners();
    return _plants;
  }

  DairyPlantModel? getPlantById(int? plantId) {
    try {
      return _plants.firstWhere((p) => p.id == plantId);
    } catch (_) {
      return null;
    }
  }

  Future<int> addPlant(DairyPlantModel plant) async {
    final id = await DatabaseHelper.instance.insertPlant(plant);

    lastInsertedPlantId = id;
    lastInsertedPlant = plant.copyWith(id: id);

    await loadPlants();
    return id;
  }

  Future<List<PlantEntry>> fetchEntriesbyid(DairyPlantModel plant) async {
    final entries =
        await DatabaseHelper.instance.fetchEntries(plant.id ?? 0);

    lastFetchedEntries = entries;
    return entries;
  }

  Future<List<PlantEntry>> fetchEntriesbyidd(int plantId) async {
    final entries = await DatabaseHelper.instance.fetchEntries(plantId);

    lastFetchedEntries = entries;
    return entries;
  }

  Future<DairyPlantModel> updatePlant(DairyPlantModel plant) async {
    await DatabaseHelper.instance.updatePlant(plant);

    await loadPlants();
    return plant;
  }

  Future<PlantEntry> updateEntry(PlantEntry entry) async {
    await DatabaseHelper.instance.updateEntry(entry);

    lastInsertedEntry = entry;
    await fetchEntriesbyidd(entry.plantId);

    return entry;
  }

  Future<bool> deletePlant(String plantId) async {
    await DatabaseHelper.instance.deletePlant(plantId);

    await loadPlants();
    return true;
  }

  Future<int> addEntry(int plantId, PlantEntry entry) async {
    final id =
        await DatabaseHelper.instance.insertEntry(entry, plantId);

    lastInsertedEntryId = id;
    lastInsertedEntry = entry.copyWith(id: id);

    await loadPlants();
    return id;
  }

  Future<bool> deleteEntry(int plantId, int entryId) async {
    await DatabaseHelper.instance.deleteEntry(entryId);

    await loadPlants();
    return true;
  }

  void searchPlants(String query) {
    if (query.isEmpty) {
      loadPlants();
      return;
    }

    _plants =
        _plants
            .where((p) => p.name.toLowerCase().contains(query.toLowerCase()))
            .toList();
    notifyListeners();
  }

  Future<({
    int plantId,
    int entryId,
  })> savePlantWithEntry({
    required DairyPlantModel plant,
    required PlantEntry entry,
  }) async {
    try {
      final plantId =
          await DatabaseHelper.instance.insertPlant(plant);

      final entryId =
          await DatabaseHelper.instance.insertEntry(entry, plantId);

      lastInsertedPlantId = plantId;
      lastInsertedEntryId = entryId;

      await loadPlants();

      return (plantId: plantId, entryId: entryId);
    } catch (e) {
      debugPrint('[PLANT_PROVIDER] Save failed: $e');
      rethrow;
    }
  }
}
