import 'package:aiplantidentifier/models/plant_growth.dart';
import 'package:aiplantidentifier/models/progress_data.dart';
import 'package:aiplantidentifier/utils/loader.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class PlantProgressTab extends StatelessWidget {
  final Map<String, dynamic> growthProgressJson;
  final PlantGroewth plnat;

  const PlantProgressTab({
    super.key,
    required this.growthProgressJson,
    required this.plnat,
  });

  @override
  Widget build(BuildContext context) {
    final progress = ProgressData.fromJson(growthProgressJson);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _progressCard(context, progress),

          const SizedBox(height: 24),

          const Text(
            'Growth Timeline',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 12),

          ...progress.timeline.map(_timelineEntry),

          const SizedBox(height: 24),

          const Text(
            'Plant Growth Overview',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Visual summary of your plant\'s development',
            style: TextStyle(fontSize: 14, color: Colors.grey[600]),
          ),
          const SizedBox(height: 16),

          _growthChart(progress.chart),

          const SizedBox(height: 16),

          Row(
            children: [
              Expanded(
                child: _statCard(
                  'Days Tracked',
                  '${progress.daysTracked} Days',
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _statCard('Current Status', progress.overallStatus),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _progressCard(BuildContext context, ProgressData p) {
    final progressValue = (p.daysTracked / 150).clamp(0.0, 1.0);

    return LayoutBuilder(
      builder: (context, constraints) {
        final cardWidth = constraints.maxWidth;
        final cardHeight = cardWidth * 0.35;
        final circleSize = cardHeight * 0.65;

        return Center(
          child: Container(
            width: cardWidth,
            height: cardHeight,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFFE8F5E9),
              borderRadius: BorderRadius.circular(cardHeight),
            ),
            child: Row(
              children: [
                Stack(
                  alignment: Alignment.center,
                  children: [
                    SizedBox(
                      width: circleSize,
                      height: circleSize,
                      child: CircularProgressIndicator(
                        value: progressValue,
                        strokeWidth: circleSize * 0.08,
                        backgroundColor: Colors.green.shade100,
                        valueColor: const AlwaysStoppedAnimation(
                          Color(0xFF2D5016),
                        ),
                      ),
                    ),
                    CircleAvatar(
                      radius: circleSize * 0.45,
                      backgroundColor: Colors.white,
                      child: plantImagee(plnat.id, circleSize * 0.45),
                    ),
                  ],
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        p.overallStatus,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: cardHeight * 0.15,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF2D5016),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Tracked for ${p.daysTracked} days',
                        style: TextStyle(
                          fontSize: cardHeight * 0.11,
                          color: Colors.grey[700],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _timelineEntry(TimelineEntry e) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          plantImage(plnat.id),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${e.date}: ${e.title}',
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE8F5E9),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    e.status,
                    style: const TextStyle(
                      fontSize: 12,
                      color: Color(0xFF2D5016),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _growthChart(ChartData chart) {
    if (chart.heightSpots.isEmpty || chart.leafSpots.isEmpty) {
      return Container(
        height: 200,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: const Color(0xFFF5F5F5),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            Icon(Icons.show_chart, size: 40, color: Colors.grey),
            SizedBox(height: 8),
            Text('Not enough data yet', style: TextStyle(color: Colors.grey)),
          ],
        ),
      );
    }
    return Container(
      height: 200,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF5F5F5),
        borderRadius: BorderRadius.circular(12),
      ),
      child: LineChart(
        LineChartData(
          borderData: FlBorderData(show: false),
          gridData: FlGridData(show: true),
          titlesData: FlTitlesData(
            leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
            rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
            topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget:
                    (v, _) => Text(
                      chart.labels[v.toInt()],
                      style: const TextStyle(fontSize: 10, color: Colors.black),
                    ),
              ),
            ),
          ),
          lineBarsData: [
            LineChartBarData(
              spots: chart.heightSpots,
              isCurved: true,
              color: const Color(0xFF5C8F3D),
              dotData: FlDotData(show: false),
            ),
            LineChartBarData(
              spots: chart.leafSpots,
              isCurved: true,
              color: const Color(0xFF2D5016),
              dotData: FlDotData(show: false),
            ),
          ],
        ),
      ),
    );
  }

  Widget _statCard(String label, String value) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFF5F5F5),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: TextStyle(color: Colors.grey[600], fontSize: 12)),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 14,
              color: Colors.black,
            ),
          ),
        ],
      ),
    );
  }
}
