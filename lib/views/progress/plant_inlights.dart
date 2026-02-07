import 'dart:convert';

import 'package:aiplantidentifier/views/progress/growth_screen.dart';
import 'package:flutter/material.dart';

class PlantInsightsTab extends StatelessWidget {
  final PlantInsightsData plantData;
  final PlantGroewth plnat;

  const PlantInsightsTab({
    super.key,
    required this.plantData,
    required this.plnat,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          _sectionCard(
            title: 'Health Summary',
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _statusPill(
                  'Overall Health : ${plantData.overallHealth}',
                  Colors.green,
                ),
                const SizedBox(height: 8),
                Text(
                  plantData.healthDescription,
                  style: TextStyle(color: Colors.grey[700], height: 1.4),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          _sectionCard(
            title: 'Pattern Insights',
            child: Column(
              children:
                  plantData.patternInsights.map((insight) {
                    return _iconRow(
                      icon: insight.icon,
                      color: insight.color,
                      text: insight.text,
                    );
                  }).toList(),
            ),
          ),

          const SizedBox(height: 16),

          _sectionCard(
            title: 'Care Effectiveness',
            child: Column(
              children:
                  plantData.careEffectiveness.map((care) {
                    return _iconRow(
                      icon: care.icon,
                      color: care.color,
                      text: '${care.title} : ${care.status}',
                    );
                  }).toList(),
            ),
          ),

          const SizedBox(height: 16),

          _sectionCard(
            title: 'Suggestions to improve growth',
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children:
                  plantData.suggestions.map((s) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: Text(
                        s,
                        style: TextStyle(color: Colors.grey[700], height: 1.4),
                      ),
                    );
                  }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _sectionCard({required String title, required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }

  Widget _iconRow({
    required IconData icon,
    required Color color,
    required String text,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: color),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                fontSize: 14,
                height: 1.3,
                color: Colors.black,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _statusPill(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.w600,
          fontSize: 13,
        ),
      ),
    );
  }
}

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
