
import 'dart:convert';

import 'package:flutter/material.dart';

class PlantInsightsData {
  final String overallHealth;
  final String healthDescription;
  final List<InsightItem> patternInsights;
  final List<InsightItem> careEffectiveness;
  final List<String> suggestions;

  PlantInsightsData({
    required this.overallHealth,
    required this.healthDescription,
    required this.patternInsights,
    required this.careEffectiveness,
    required this.suggestions,
  });
  factory PlantInsightsData.fromRawJson(String rawJson) {
    final Map<String, dynamic> decoded = Map<String, dynamic>.from(
      jsonDecode(rawJson),
    );

    final Map<String, dynamic> ui =
        decoded['ui_insights'] != null
            ? Map<String, dynamic>.from(decoded['ui_insights'])
            : <String, dynamic>{};

    final Map<String, dynamic> healthSummary =
        ui['health_summary'] != null
            ? Map<String, dynamic>.from(ui['health_summary'])
            : <String, dynamic>{};

    return PlantInsightsData(
      overallHealth: healthSummary['overall_health']?.toString() ?? 'Unknown',

      healthDescription: healthSummary['message']?.toString() ?? '',

      patternInsights:
          (ui['pattern_insights'] as List? ?? [])
              .map((e) => InsightItem.fromPattern(Map<String, dynamic>.from(e)))
              .toList(),

      careEffectiveness: InsightItem.fromCare(
        ui['care_effectiveness'] != null
            ? Map<String, dynamic>.from(ui['care_effectiveness'])
            : <String, dynamic>{},
      ),

      suggestions: List<String>.from(ui['growth_suggestions'] ?? const []),
    );
  }
}

class InsightItem {
  final IconData icon;
  final Color color;
  final String title;
  final String status;
  final String text;

  InsightItem({
    required this.icon,
    required this.color,
    required this.text,
    this.title = '',
    this.status = '',
  });

  factory InsightItem.fromPattern(Map<String, dynamic> json) {
    return InsightItem(
      icon: _mapIcon(json['icon']?.toString()),
      color: Colors.blue,
      text: json['message']?.toString() ?? '',
    );
  }

  static List<InsightItem> fromCare(Map<String, dynamic> json) {
    return json.entries.map((e) {
      final value = e.value.toString();

      return InsightItem(
        icon: Icons.check_circle,
        color:
            value == 'on_track'
                ? Colors.green
                : value == 'needs_improvement'
                ? Colors.orange
                : Colors.grey,
        title: _capitalize(e.key),
        status: value.replaceAll('_', ' '),
        text: '',
      );
    }).toList();
  }

  static IconData _mapIcon(String? icon) {
    switch (icon) {
      case 'water':
        return Icons.water_drop;
      case 'sun':
        return Icons.wb_sunny;
      case 'growth':
        return Icons.trending_up;
      default:
        return Icons.water_drop;
    }
  }

  static String _capitalize(String s) =>
      s.isEmpty ? s : s[0].toUpperCase() + s.substring(1);
}
