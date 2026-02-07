class PlantIdentificationResult {
  final String species;
  final String? plant_type;
  final String healthStatus;
  final double confidence;
  final String description;
  final List<String> careTips;

  // Plant-specific metrics
  final String? commonName;
  final String? scientificName;
  final String? family;
  final String? nativeRegion;
  final double? waterNeeds;
  final double? sunlightNeeds;
  final double? growthRate;
  final double? toxicityLevel;
  final String? bloomTime;
  final String? soilType;

  PlantIdentificationResult({
    required this.species,
    required this.healthStatus,
    required this.confidence,
    required this.description,
    required this.careTips,
    this.commonName,
    this.scientificName,
    this.family,
    this.nativeRegion,
    this.waterNeeds,
    this.sunlightNeeds,
    this.growthRate,
    this.toxicityLevel,
    this.bloomTime,
    this.soilType,
    this.plant_type,
  });

  factory PlantIdentificationResult.fromJson(Map<String, dynamic> json) {
    return PlantIdentificationResult(
      species: json['species'] as String? ?? 'Unknown Species',
      healthStatus: json['health_status'] as String? ?? 'Unknown',
      confidence: (json['confidence'] as num?)?.toDouble() ?? 0.0,
      description: json['description'] as String? ?? 'No description available',
      careTips:
          (json['care_tips'] as List<dynamic>?)
              ?.map((item) => item.toString())
              .toList() ??
          ['No care tips available'],
      commonName: json['common_name'] as String?,
      scientificName: json['scientific_name'] as String?,
      family: json['family'] as String?,
      nativeRegion: json['native_region'] as String?,
      waterNeeds: (json['water_needs'] as num?)?.toDouble(),
      sunlightNeeds: (json['sunlight_needs'] as num?)?.toDouble(),
      growthRate: (json['growth_rate'] as num?)?.toDouble(),
      toxicityLevel: (json['toxicity_level'] as num?)?.toDouble(),
      bloomTime: json['bloom_time'] as String?,
      soilType: json['soil_type'] as String?,
      plant_type: json["plant_type"] as String?,
    );
  }
}
