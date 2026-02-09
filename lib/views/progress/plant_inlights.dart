
import 'package:aiplantidentifier/models/plant_growth.dart';
import 'package:aiplantidentifier/models/plant_inlight.dart';
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
