class ScanedImageResponce {
  bool? success;
  int? statuscode;
  String? message;
  Data? data;

  ScanedImageResponce({this.success, this.statuscode, this.message, this.data});

  ScanedImageResponce.fromJson(Map<String, dynamic> json) {
    success = json['success'];
    statuscode = json['statuscode'];
    message = json['message'];
    data = json['data'] != null ? new Data.fromJson(json['data']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['success'] = this.success;
    data['statuscode'] = this.statuscode;
    data['message'] = this.message;
    if (this.data != null) {
      data['data'] = this.data!.toJson();
    }
    return data;
  }
}

class Data {
  String? plantimage;
  String? species;
  String? health;
  double? confidence;
  String? commonname;
  String? scientificname;
  String? family;
  String? nativeregion;
  int? waterneeds;
  int? sunlightneeds;
  int? growthrate;
  int? toxicity;
  String? description;
  List<String>? caretips;
  String? bloomTime;

  Data({
    this.plantimage,
    this.species,
    this.health,
    this.confidence,
    this.commonname,
    this.scientificname,
    this.family,
    this.nativeregion,
    this.waterneeds,
    this.sunlightneeds,
    this.growthrate,
    this.toxicity,
    this.description,
    this.caretips,
    this.bloomTime,
  });

  Data.fromJson(Map<String, dynamic> json) {
    plantimage = json['plantimage'];
    species = json['species'];
    health = json['health'];
    confidence = json['confidence'];
    commonname = json['commonname'];
    scientificname = json['scientificname'];
    family = json['family'];
    nativeregion = json['nativeregion'];
    waterneeds = json['waterneeds'];
    sunlightneeds = json['sunlightneeds'];
    growthrate = json['growthrate'];
    toxicity = json['toxicity'];
    description = json['description'];
    caretips = json['caretips'].cast<String>();
    bloomTime = json['bloom_time'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['plantimage'] = this.plantimage;
    data['species'] = this.species;
    data['health'] = this.health;
    data['confidence'] = this.confidence;
    data['commonname'] = this.commonname;
    data['scientificname'] = this.scientificname;
    data['family'] = this.family;
    data['nativeregion'] = this.nativeregion;
    data['waterneeds'] = this.waterneeds;
    data['sunlightneeds'] = this.sunlightneeds;
    data['growthrate'] = this.growthrate;
    data['toxicity'] = this.toxicity;
    data['description'] = this.description;
    data['caretips'] = this.caretips;
    data['bloom_time'] = this.bloomTime;
    return data;
  }
}
