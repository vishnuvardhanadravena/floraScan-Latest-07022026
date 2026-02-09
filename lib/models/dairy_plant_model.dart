class DairyPlantModel {
  final int? id;
  final String name;
  final String imageUrl;
  final String status;
  final String statusColor;
  final String lastUpdated;
  final List<PlantEntry> entries;
  final String? additionalStatus;
  final String? plantType;

  DairyPlantModel({
    this.id,
    required this.name,
    required this.imageUrl,
    required this.status,
    required this.statusColor,
    required this.lastUpdated,
    required this.entries,
    this.additionalStatus,
    this.plantType,
  });

  // Copy with method for updating
  DairyPlantModel copyWith({
    int? id,
    String? name,
    String? imageUrl,
    String? status,
    String? statusColor,
    String? lastUpdated,
    List<PlantEntry>? entries,
    String? additionalStatus,
    String? plantType,
  }) {
    return DairyPlantModel(
      id: id ?? this.id,
      name: name ?? this.name,
      imageUrl: imageUrl ?? this.imageUrl,
      status: status ?? this.status,
      statusColor: statusColor ?? this.statusColor,
      lastUpdated: lastUpdated ?? this.lastUpdated,
      entries: entries ?? this.entries,
      additionalStatus: additionalStatus ?? this.additionalStatus,
      plantType: plantType ?? this.plantType,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DairyPlantModel &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          name == other.name;

  @override
  int get hashCode => id.hashCode ^ name.hashCode;
}

class PlantEntry {
  final int? id;
  final int plantId;
  final String? description;
  final String imageUrl;
  final String status;
  final String timestamp;
  final String updateTime;
  final String userNotes;
  final String? plantType;

  PlantEntry({
    this.id,
    required this.plantId,
    required this.description,
    required this.imageUrl,
    required this.status,
    required this.timestamp,
    required this.updateTime,
    required this.userNotes,
    this.plantType,
  });

  PlantEntry copyWith({
    int? id,
    int? plantId,
    String? description,
    String? imageUrl,
    String? status,
    String? timestamp,
    String? updateTime,
    String? userNotes,
    String? plantType,
  }) {
    return PlantEntry(
      id: id ?? this.id,
      plantId: plantId ?? this.plantId,
      description: description ?? this.description,
      imageUrl: imageUrl ?? this.imageUrl,
      status: status ?? this.status,
      timestamp: timestamp ?? this.timestamp,
      updateTime: updateTime ?? this.updateTime,
      userNotes: userNotes ?? this.userNotes,
      plantType: plantType ?? this.plantType,
    );
  }
}
