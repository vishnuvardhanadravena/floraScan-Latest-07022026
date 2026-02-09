import 'package:flutter/material.dart';

class RoutinePlant {
  final int id;
  final String name;
  final String image;
  final String status;
  final String category;
  final String todayTask;
  final String lastUpdate;
  final bool isHealthy;
  final String maintenance;
  final List<TimelineItem> timeline;
  final List<UpcomingCare> upcomingCare;
  final String aiTip;

  RoutinePlant({
    required this.id,
    required this.name,
    required this.image,
    required this.status,
    required this.category,
    required this.todayTask,
    required this.lastUpdate,
    required this.isHealthy,
    required this.maintenance,
    required this.timeline,
    required this.upcomingCare,
    required this.aiTip,
  });
}

class TimelineItem {
  final String title;
  final String subtitle;
  final bool isCompleted;

  TimelineItem({
    required this.title,
    required this.subtitle,
    required this.isCompleted,
  });
}

class UpcomingCare {
  final String title;
  final String subtitle;
  final String timeframe;
  final String icon;
  final Color color;

  UpcomingCare({
    required this.title,
    required this.subtitle,
    required this.timeframe,
    required this.icon,
    required this.color,
  });
}
class CareTask {
  final int id;
  final String title;
  final int intervalDays;
  final DateTime nextRunAt;
  final DateTime? lastCompletedAt;

  CareTask({
    required this.id,
    required this.title,
    required this.intervalDays,
    required this.nextRunAt,
    this.lastCompletedAt,
  });

  factory CareTask.fromMap(Map<String, dynamic> map) {
    return CareTask(
      id: map['id'] as int,
      title: map['title'] as String,
      intervalDays: map['intervalDays'] as int,
      nextRunAt: DateTime.parse(map['nextRunAt'].toString()),
      lastCompletedAt:
          map['lastCompletedAt'] != null
              ? DateTime.parse(map['lastCompletedAt'].toString())
              : null,
    );
  }
}