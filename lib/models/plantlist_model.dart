class PlantListModel {
  bool? success;
  int? statuscode;
  String? message;
  List<Plantlist>? data;

  PlantListModel({this.success, this.statuscode, this.message, this.data});

  PlantListModel.fromJson(Map<String, dynamic> json) {
    success = json['success'];
    statuscode = json['statuscode'];
    message = json['message'];
    if (json['data'] != null) {
      data = <Plantlist>[];
      json['data'].forEach((v) {
        data!.add(new Plantlist.fromJson(v));
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

class Plantlist {
  String? sId;
  String? userId;
  String? plantname;
  String? plantimage;
  double? confidence;
  String? maintenanceLevel;
  String? overallHealth;
  String? overallStatus;
  String? routineStatus;
  String? scandateandtime;
  String? todayRoutineTask;
  String? planttype;

  Plantlist({
    this.sId,
    this.userId,
    this.plantname,
    this.plantimage,
    this.confidence,
    this.maintenanceLevel,
    this.overallHealth,
    this.overallStatus,
    this.routineStatus,
    this.scandateandtime,
    this.todayRoutineTask,
    this.planttype,
  });

  Plantlist.fromJson(Map<String, dynamic> json) {
    sId = json['_id'];
    userId = json['userId'];
    plantname = json['plantname'];
    plantimage = json['plantimage'];
    confidence = json['confidence'];
    maintenanceLevel = json['maintenance_level'];
    overallHealth = json['overall_health'];
    overallStatus = json['overall_status'];
    routineStatus = json['routine_status'];
    scandateandtime = json['scandateandtime'];
    todayRoutineTask = json['today_routine_task'];
    planttype = json['planttype'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['_id'] = this.sId;
    data['userId'] = this.userId;
    data['plantname'] = this.plantname;
    data['plantimage'] = this.plantimage;
    data['confidence'] = this.confidence;
    data['maintenance_level'] = this.maintenanceLevel;
    data['overall_health'] = this.overallHealth;
    data['overall_status'] = this.overallStatus;
    data['routine_status'] = this.routineStatus;
    data['scandateandtime'] = this.scandateandtime;
    data['today_routine_task'] = this.todayRoutineTask;
    data['planttype'] = this.planttype;
    return data;
  }
}
