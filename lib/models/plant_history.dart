class HistoryDetilesResponce {
  bool? success;
  int? statuscode;
  String? message;
  List<HistoryDetailes>? data;

  HistoryDetilesResponce({
    this.success,
    this.statuscode,
    this.message,
    this.data,
  });

  HistoryDetilesResponce.fromJson(Map<String, dynamic> json) {
    success = json['success'];
    statuscode = json['statuscode'];
    message = json['message'];
    if (json['data'] != null) {
      data = <HistoryDetailes>[];
      json['data'].forEach((v) {
        data!.add(new HistoryDetailes.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['success'] = this.success;
    data['statuscode'] = this.statuscode;
    data['message'] = this.message;
    if (this.data != null) {
      data['data'] = this.data!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class HistoryDetailes {
  String? sId;
  String? plantImage;
  String? plantId;
  History? history;
  String? createdAt;

  HistoryDetailes({
    this.sId,
    this.plantImage,
    this.plantId,
    this.history,
    this.createdAt,
  });

  HistoryDetailes.fromJson(Map<String, dynamic> json) {
    sId = json['_id'];
    plantImage = json['plant_image'];
    plantId = json['plantId'];
    history =
        json['history'] != null ? new History.fromJson(json['history']) : null;
    createdAt = json['createdAt'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['_id'] = this.sId;
    data['plant_image'] = this.plantImage;
    data['plantId'] = this.plantId;
    if (this.history != null) {
      data['history'] = this.history!.toJson();
    }
    data['createdAt'] = this.createdAt;
    return data;
  }
}

class History {
  PlantBio? plantBio;
  PlantCare? plantCare;

  History({this.plantBio, this.plantCare});

  History.fromJson(Map<String, dynamic> json) {
    plantBio =
        json['plant_bio'] != null
            ? new PlantBio.fromJson(json['plant_bio'])
            : null;
    plantCare =
        json['plant_care'] != null
            ? new PlantCare.fromJson(json['plant_care'])
            : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.plantBio != null) {
      data['plant_bio'] = this.plantBio!.toJson();
    }
    if (this.plantCare != null) {
      data['plant_care'] = this.plantCare!.toJson();
    }
    return data;
  }
}

class PlantBio {
  PlantInformation? plantInformation;
  String? plantOverview;
  OriginHabitat? originHabitat;
  KeyCharacteristics? keyCharacteristics;
  List<String>? benefitsUses;
  List<String>? toxicityInfo;

  PlantBio({
    this.plantInformation,
    this.plantOverview,
    this.originHabitat,
    this.keyCharacteristics,
    this.benefitsUses,
    this.toxicityInfo,
  });

  PlantBio.fromJson(Map<String, dynamic> json) {
    plantInformation =
        json['plant_information'] != null
            ? new PlantInformation.fromJson(json['plant_information'])
            : null;
    plantOverview = json['plant_overview'];
    originHabitat =
        json['origin_habitat'] != null
            ? new OriginHabitat.fromJson(json['origin_habitat'])
            : null;
    keyCharacteristics =
        json['key_characteristics'] != null
            ? new KeyCharacteristics.fromJson(json['key_characteristics'])
            : null;
    benefitsUses = json['benefits_uses'].cast<String>();
    toxicityInfo = json['toxicity_info'].cast<String>();
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.plantInformation != null) {
      data['plant_information'] = this.plantInformation!.toJson();
    }
    data['plant_overview'] = this.plantOverview;
    if (this.originHabitat != null) {
      data['origin_habitat'] = this.originHabitat!.toJson();
    }
    if (this.keyCharacteristics != null) {
      data['key_characteristics'] = this.keyCharacteristics!.toJson();
    }
    data['benefits_uses'] = this.benefitsUses;
    data['toxicity_info'] = this.toxicityInfo;
    return data;
  }
}

class PlantInformation {
  String? plantName;
  String? category;
  String? growthHabit;
  String? scientificName;

  PlantInformation({
    this.plantName,
    this.category,
    this.growthHabit,
    this.scientificName,
  });

  PlantInformation.fromJson(Map<String, dynamic> json) {
    plantName = json['plant_name'];
    category = json['category'];
    growthHabit = json['growth_habit'];
    scientificName = json['scientific_name'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['plant_name'] = this.plantName;
    data['category'] = this.category;
    data['growth_habit'] = this.growthHabit;
    data['scientific_name'] = this.scientificName;
    return data;
  }
}

class OriginHabitat {
  String? naativeRegion;
  String? naturalHabitat;

  OriginHabitat({this.naativeRegion, this.naturalHabitat});

  OriginHabitat.fromJson(Map<String, dynamic> json) {
    naativeRegion = json['naative_region'];
    naturalHabitat = json['natural_habitat'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['naative_region'] = this.naativeRegion;
    data['natural_habitat'] = this.naturalHabitat;
    return data;
  }
}

class KeyCharacteristics {
  String? leafShape;
  String? growthPattern;
  int? growthsSpeed;
  String? bestFor;

  KeyCharacteristics({
    this.leafShape,
    this.growthPattern,
    this.growthsSpeed,
    this.bestFor,
  });

  KeyCharacteristics.fromJson(Map<String, dynamic> json) {
    leafShape = json['leaf_shape'];
    growthPattern = json['growth_pattern'];
    growthsSpeed = json['growths_speed'];
    bestFor = json['best_for'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['leaf_shape'] = this.leafShape;
    data['growth_pattern'] = this.growthPattern;
    data['growths_speed'] = this.growthsSpeed;
    data['best_for'] = this.bestFor;
    return data;
  }
}

class PlantCare {
  Water? water;
  Sunlight? sunlight;
  Soil? soil;
  Temparature? temparature;
  Humidity? humidity;
  Fertilizer? fertilizer;
  List<String>? pruning;
  List<String>? commonIssues;

  PlantCare({
    this.water,
    this.sunlight,
    this.soil,
    this.temparature,
    this.humidity,
    this.fertilizer,
    this.pruning,
    this.commonIssues,
  });

  PlantCare.fromJson(Map<String, dynamic> json) {
    water = json['water'] != null ? new Water.fromJson(json['water']) : null;
    sunlight =
        json['sunlight'] != null
            ? new Sunlight.fromJson(json['sunlight'])
            : null;
    soil = json['soil'] != null ? new Soil.fromJson(json['soil']) : null;
    temparature =
        json['temparature'] != null
            ? new Temparature.fromJson(json['temparature'])
            : null;
    humidity =
        json['humidity'] != null
            ? new Humidity.fromJson(json['humidity'])
            : null;
    fertilizer =
        json['fertilizer'] != null
            ? new Fertilizer.fromJson(json['fertilizer'])
            : null;
    pruning = json['pruning'].cast<String>();
    commonIssues = json['common_issues'].cast<String>();
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.water != null) {
      data['water'] = this.water!.toJson();
    }
    if (this.sunlight != null) {
      data['sunlight'] = this.sunlight!.toJson();
    }
    if (this.soil != null) {
      data['soil'] = this.soil!.toJson();
    }
    if (this.temparature != null) {
      data['temparature'] = this.temparature!.toJson();
    }
    if (this.humidity != null) {
      data['humidity'] = this.humidity!.toJson();
    }
    if (this.fertilizer != null) {
      data['fertilizer'] = this.fertilizer!.toJson();
    }
    data['pruning'] = this.pruning;
    data['common_issues'] = this.commonIssues;
    return data;
  }
}

class Water {
  int? waterLevel;
  String? waterNotes;

  Water({this.waterLevel, this.waterNotes});

  Water.fromJson(Map<String, dynamic> json) {
    waterLevel = json['water_level'];
    waterNotes = json['water_notes'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['water_level'] = this.waterLevel;
    data['water_notes'] = this.waterNotes;
    return data;
  }
}

class Sunlight {
  int? sunlightLevel;
  String? sunlightNotes;

  Sunlight({this.sunlightLevel, this.sunlightNotes});

  Sunlight.fromJson(Map<String, dynamic> json) {
    sunlightLevel = json['sunlight_level'];
    sunlightNotes = json['sunlight_notes'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['sunlight_level'] = this.sunlightLevel;
    data['sunlight_notes'] = this.sunlightNotes;
    return data;
  }
}

class Soil {
  String? soilType;

  Soil({this.soilType});

  Soil.fromJson(Map<String, dynamic> json) {
    soilType = json['soil_type'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['soil_type'] = this.soilType;
    return data;
  }
}

class Temparature {
  String? temparatureRange;
  String? temparatureNotes;

  Temparature({this.temparatureRange, this.temparatureNotes});

  Temparature.fromJson(Map<String, dynamic> json) {
    temparatureRange = json['temparature_range'];
    temparatureNotes = json['temparature_notes'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['temparature_range'] = this.temparatureRange;
    data['temparature_notes'] = this.temparatureNotes;
    return data;
  }
}

class Humidity {
  String? humidityLevel;

  Humidity({this.humidityLevel});

  Humidity.fromJson(Map<String, dynamic> json) {
    humidityLevel = json['humidity_level'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['humidity_level'] = this.humidityLevel;
    return data;
  }
}

class Fertilizer {
  String? fertilizerFrequency;
  String? fertilizerNotes;

  Fertilizer({this.fertilizerFrequency, this.fertilizerNotes});

  Fertilizer.fromJson(Map<String, dynamic> json) {
    fertilizerFrequency = json['fertilizer_frequency'];
    fertilizerNotes = json['fertilizer_notes'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['fertilizer_frequency'] = this.fertilizerFrequency;
    data['fertilizer_notes'] = this.fertilizerNotes;
    return data;
  }
}
