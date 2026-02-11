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
  String? species;
  String? health;
  String? commonname;
  String? scientificname;
  String? family;
  String? nativeregion;
  int? waterneeds;
  int? sunlightneeds;
  int? growthrate;
  String? description;
  List<String>? caretips;

  Data(
      {this.species,
      this.health,
      this.commonname,
      this.scientificname,
      this.family,
      this.nativeregion,
      this.waterneeds,
      this.sunlightneeds,
      this.growthrate,
      this.description,
      this.caretips});

  Data.fromJson(Map<String, dynamic> json) {
    species = json['species'];
    health = json['health'];
    commonname = json['commonname'];
    scientificname = json['scientificname'];
    family = json['family'];
    nativeregion = json['nativeregion'];
    waterneeds = json['waterneeds'];
    sunlightneeds = json['sunlightneeds'];
    growthrate = json['growthrate'];
    description = json['description'];
    caretips = json['caretips'].cast<String>();
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['species'] = this.species;
    data['health'] = this.health;
    data['commonname'] = this.commonname;
    data['scientificname'] = this.scientificname;
    data['family'] = this.family;
    data['nativeregion'] = this.nativeregion;
    data['waterneeds'] = this.waterneeds;
    data['sunlightneeds'] = this.sunlightneeds;
    data['growthrate'] = this.growthrate;
    data['description'] = this.description;
    data['caretips'] = this.caretips;
    return data;
  }
}
