import 'package:fl_chart/fl_chart.dart';

class ProgressData {
  final String overallStatus;
  final int daysTracked;
  final List<TimelineEntry> timeline;
  final ChartData chart;

  ProgressData({
    required this.overallStatus,
    required this.daysTracked,
    required this.timeline,
    required this.chart,
  });

  factory ProgressData.fromJson(Map<String, dynamic> json) {
    return ProgressData(
      overallStatus: json['overall_status'] ?? '',
      daysTracked: json['days_tracked'] ?? 0,
      timeline:
          (json['timeline'] as List? ?? [])
              .map((e) => TimelineEntry.fromJson(e))
              .toList(),
      chart: ChartData.fromJson(json['chart'] ?? {}),
    );
  }
}

class TimelineEntry {
  final String date;
  final String title;
  final String status;

  TimelineEntry({
    required this.date,
    required this.title,
    required this.status,
  });

  factory TimelineEntry.fromJson(Map<String, dynamic> json) {
    return TimelineEntry(
      date: json['date'] ?? '',
      title: json['title'] ?? '',
      status: json['status'] ?? '',
    );
  }
}

class ChartData {
  final List<String> labels;
  final List<double> heights;
  final List<double> leaves;

  ChartData({
    required this.labels,
    required this.heights,
    required this.leaves,
  });

  factory ChartData.fromJson(Map<String, dynamic> json) {
    return ChartData(
      labels: List<String>.from(json['labels'] ?? []),

      heights:
          (json['height'] as List? ?? [])
              .map((e) => double.tryParse(e.toString()) ?? 0.0)
              .toList(),

      leaves:
          (json['leaves'] as List? ?? [])
              .map((e) => double.tryParse(e.toString()) ?? 0.0)
              .toList(),
    );
  }

  List<FlSpot> get heightSpots =>
      List.generate(heights.length, (i) => FlSpot(i.toDouble(), heights[i]));

  List<FlSpot> get leafSpots =>
      List.generate(leaves.length, (i) => FlSpot(i.toDouble(), leaves[i]));
}
