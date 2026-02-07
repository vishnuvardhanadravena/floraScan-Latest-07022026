import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';

import '../../database/database.dart';
import '../../models/hyderation.dart';
import '../../providers/analyze.dart';

class PlantHealthDashboardScreen extends StatelessWidget {
  const PlantHealthDashboardScreen({super.key});

  // Updated UI Theme Colors & Styles for Plant App
  static const Color _scaffoldBackgroundColor = Color(0xFFF8F9FA);
  static const Color _appBarBackgroundColor = Colors.white;
  static const Color _primaryColor = Color(0xFF4CAF50); // Green
  static const Color _accentColor = Color(0xFF2E7D32); // Dark Green
  static const Color _cardBackgroundColor = Colors.white;
  static const Color _textColorPrimary = Color(0xFF2D3748);
  static const Color _textColorSecondary = Color(0xFF718096);
  static const Color _shadowColor = Color(0xFFE2E8F0);

  // Health status colors
  static const Color _healthyColor = Color(0xFF4CAF50); // Green
  static const Color _moderateColor = Color(0xFFFBC02D); // Yellow
  static const Color _unhealthyColor = Color(0xFFF57C00); // Orange
  static const Color _dyingColor = Color(0xFFE53935); // Red

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _scaffoldBackgroundColor,
      appBar: AppBar(
        // backgroundColor: _appBarBackgroundColor,
        elevation: 1.5,
        shadowColor: _shadowColor.withAlpha((0.9 * 255).toInt()),
        title: const Text(
          'Plant Health Dashboard',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            // color: _textColorPrimary,
            fontSize: 20,
          ),
        ),
        // centerTitle: true,
        iconTheme: const IconThemeData(color: _textColorPrimary),
      ),
      body: Consumer<PlantIdentificationProvider>(
        builder: (context, provider, child) {
          if (provider.identificationHistory.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.eco_outlined,
                      size: 90,
                      color: _textColorSecondary.withAlpha((0.6 * 255).toInt()),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      'No Data Available Yet',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                        color: _textColorPrimary,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Identify a few plants to unlock your personalized dashboard and track your plant health.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 15,
                        color: _textColorSecondary,
                        height: 1.5,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }

          final latestIdentification = PlantIdentificationResult.fromJson(
            jsonDecode(
              provider.identificationHistory.last[DatabaseHelper.columnResult],
            ),
          );

          return SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSectionHeader(
                  "Current Status",
                  Icons.visibility_outlined,
                ),
                _buildOverviewCard(context, latestIdentification, provider),
                const SizedBox(height: 5),

                _buildSectionHeader("Health Trend", Icons.trending_up_rounded),
                SizedBox(height: 140, child: _buildHealthScoreChart(provider)),
                const SizedBox(height: 4),

                _buildSectionHeader(
                  "Health Status Breakdown",
                  Icons.pie_chart_outline_rounded,
                ),
                SizedBox(
                  height: 230,
                  child: _buildHealthStatusPieChart(provider),
                ),
                const SizedBox(height: 10),

                _buildSectionHeader(
                  "Plant Characteristics",
                  Icons.nature_outlined,
                ),
                _buildCharacteristicsGrid(latestIdentification),
                const SizedBox(height: 24),

                _buildSectionHeader(
                  "Care Recommendations",
                  Icons.lightbulb_outline_rounded,
                ),
                _buildCareTipsCard(latestIdentification),
                const SizedBox(height: 20),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildSectionHeader(String title, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4.0, top: 8.0),
      child: Row(
        children: [
          Icon(icon, color: _accentColor, size: 22),
          const SizedBox(width: 10),
          Text(
            title,
            style: TextStyle(
              fontSize: 19,
              fontWeight: FontWeight.bold,
              color: _textColorPrimary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOverviewCard(
    BuildContext context,
    PlantIdentificationResult latestIdentification,
    PlantIdentificationProvider provider,
  ) {
    final DateFormat formatter = DateFormat('MMM dd, yyyy');
    final String formattedDate =
        provider.identificationHistory.isNotEmpty
            ? formatter.format(
              DateTime.fromMillisecondsSinceEpoch(
                provider.identificationHistory.last[DatabaseHelper
                    .columnTimestamp],
              ),
            )
            : "N/A";

    return Card(
      elevation: 3,
      shadowColor: _shadowColor.withAlpha((0.8 * 255).toInt()),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      color: _cardBackgroundColor,
      child: Padding(
        padding: const EdgeInsets.all(13),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Latest Identification: $formattedDate',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: _textColorSecondary,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 18,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: _getHealthStatusColor(
                      latestIdentification.healthStatus,
                    ).withAlpha((0.17 * 255).toInt()),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    latestIdentification.healthStatus,
                    style: TextStyle(
                      color: _getHealthStatusColor(
                        latestIdentification.healthStatus,
                      ),
                      fontWeight: FontWeight.w700,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 2),
            Text(
              latestIdentification.species,
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: _textColorPrimary,
              ),
            ),
            if (latestIdentification.commonName != null) ...[
              const SizedBox(height: 2),
              Text(
                latestIdentification.commonName!,
                style: TextStyle(fontSize: 16, color: _textColorSecondary),
              ),
            ],
            const SizedBox(height: 4),
            Row(
              children: [
                Icon(Icons.shield_outlined, color: _primaryColor, size: 18),
                const SizedBox(width: 6),
                Text(
                  'Confidence: ${(latestIdentification.confidence * 100).toStringAsFixed(0)}%',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: _textColorPrimary.withAlpha((0.90 * 255).toInt()),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            LinearProgressIndicator(
              value: latestIdentification.confidence,
              backgroundColor: _primaryColor.withAlpha((0.4 * 255).toInt()),
              valueColor: const AlwaysStoppedAnimation<Color>(_primaryColor),
              minHeight: 10,
              borderRadius: BorderRadius.circular(5),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHealthScoreChart(PlantIdentificationProvider provider) {
    final history = provider.identificationHistory.reversed.take(15).toList();
    if (history.isEmpty) {
      return const Center(
        child: Text(
          "Not enough data for trend.",
          style: TextStyle(color: _textColorSecondary),
        ),
      );
    }

    final spots = List<FlSpot>.generate(history.length, (index) {
      final result = PlantIdentificationResult.fromJson(
        jsonDecode(history[index][DatabaseHelper.columnResult]),
      );
      final score = _calculateHealthScore(result);
      return FlSpot(index.toDouble(), score);
    });

    return Card(
      elevation: 3,
      shadowColor: _shadowColor.withAlpha((0.7 * 255).toInt()),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 20, 20, 12),
        child: LineChart(
          LineChartData(
            gridData: FlGridData(
              show: true,
              drawVerticalLine: false,
              horizontalInterval: 2,
              getDrawingHorizontalLine: (value) {
                return FlLine(
                  color: _shadowColor.withAlpha((0.7 * 255).toInt()),
                  strokeWidth: 0.8,
                );
              },
            ),
            titlesData: FlTitlesData(
              bottomTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: history.length > 1,
                  interval:
                      (history.length /
                              (history.length > 5
                                  ? 4
                                  : history.length > 1
                                  ? 1
                                  : 0))
                          .clamp(1, double.infinity)
                          .toDouble(),
                  getTitlesWidget: (value, meta) {
                    if (value.toInt() < history.length) {
                      final date = DateTime.fromMillisecondsSinceEpoch(
                        history[value.toInt()][DatabaseHelper.columnTimestamp],
                      );
                      return Padding(
                        padding: const EdgeInsets.only(top: 8.0),
                        child: Text(
                          DateFormat('d MMM').format(date),
                          style: TextStyle(
                            fontSize: 10,
                            color: _textColorSecondary,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      );
                    }
                    return const SizedBox();
                  },
                ),
              ),
              leftTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  interval: 2,
                  getTitlesWidget: (value, meta) {
                    return Text(
                      value.toInt().toString(),
                      style: TextStyle(
                        fontSize: 10,
                        color: _textColorSecondary,
                        fontWeight: FontWeight.w500,
                      ),
                    );
                  },
                  reservedSize: 32,
                ),
              ),
              rightTitles: const AxisTitles(),
              topTitles: const AxisTitles(),
            ),
            borderData: FlBorderData(show: false),
            minX: 0,
            maxX: history.length > 1 ? (history.length - 1).toDouble() : 1,
            minY: 0,
            maxY: 10,
            lineTouchData: LineTouchData(
              touchTooltipData: LineTouchTooltipData(
                tooltipBgColor: _accentColor.withAlpha((0.9 * 255).toInt()),
                getTooltipItems: (touchedSpots) {
                  return touchedSpots.map((spot) {
                    final date = DateTime.fromMillisecondsSinceEpoch(
                      history[spot.spotIndex][DatabaseHelper.columnTimestamp],
                    );
                    return LineTooltipItem(
                      'Score: ${spot.y.toStringAsFixed(1)}\n',
                      const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                      children: [
                        TextSpan(
                          text: DateFormat('MMM d, hh:mm a').format(date),
                          style: TextStyle(
                            color: Colors.white.withAlpha((0.95 * 255).toInt()),
                            fontSize: 11,
                          ),
                        ),
                      ],
                    );
                  }).toList();
                },
              ),
            ),
            lineBarsData: [
              LineChartBarData(
                spots: spots,
                isCurved: true,
                color: _primaryColor,
                barWidth: 3.5,
                isStrokeCapRound: true,
                dotData: FlDotData(
                  show: true,
                  getDotPainter:
                      (spot, percent, barData, index) => FlDotCirclePainter(
                        radius: 4.5,
                        color: _primaryColor,
                        strokeWidth: 1.5,
                        strokeColor: _cardBackgroundColor,
                      ),
                ),
                belowBarData: BarAreaData(
                  show: true,
                  gradient: LinearGradient(
                    colors: [
                      _primaryColor.withAlpha((0.5 * 255).toInt()),
                      _primaryColor.withAlpha((0.0 * 255).toInt()),
                    ],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHealthStatusPieChart(PlantIdentificationProvider provider) {
    final healthData = provider.getPlantsByHealthStatus();
    if (healthData.isEmpty) {
      return const Center(
        child: Text(
          "No health data.",
          style: TextStyle(color: _textColorSecondary),
        ),
      );
    }

    final total = healthData.values.fold(0, (sum, item) => sum + item);

    return Card(
      elevation: 3,
      shadowColor: _shadowColor.withAlpha((0.7 * 255).toInt()),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      color: _cardBackgroundColor,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Expanded(
              flex: 2,
              child: PieChart(
                PieChartData(
                  sectionsSpace: 3,
                  centerSpaceRadius: 45,
                  startDegreeOffset: -90,
                  sections:
                      healthData.entries.map((entry) {
                        final percentage =
                            total > 0 ? (entry.value / total * 100) : 0.0;
                        return PieChartSectionData(
                          color: _getHealthStatusColor(entry.key),
                          value: percentage,
                          title: '${percentage.toStringAsFixed(0)}%',
                          radius: 30,
                          titleStyle: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            shadows: [
                              Shadow(color: Colors.black26, blurRadius: 2),
                            ],
                          ),
                        );
                      }).toList(),
                ),
              ),
            ),
            const SizedBox(width: 20),
            Expanded(
              flex: 1,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children:
                    healthData.entries.map((entry) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 5.0),
                        child: Row(
                          children: [
                            Container(
                              width: 12,
                              height: 12,
                              decoration: BoxDecoration(
                                color: _getHealthStatusColor(entry.key),
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              entry.key,
                              style: TextStyle(
                                fontSize: 13,
                                color: _textColorSecondary,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCharacteristicsGrid(
    PlantIdentificationResult latestIdentification,
  ) {
    List<Map<String, dynamic>> characteristics = [
      {
        "title": 'Water Needs',
        "value":
            latestIdentification.waterNeeds != null
                ? '${latestIdentification.waterNeeds!.toStringAsFixed(1)}/10'
                : 'N/A',
        "icon": Icons.water_drop_outlined,
        "color": const Color(0xFF3498DB),
      },
      {
        "title": 'Sunlight Needs',
        "value":
            latestIdentification.sunlightNeeds != null
                ? '${latestIdentification.sunlightNeeds!.toStringAsFixed(1)}/10'
                : 'N/A',
        "icon": Icons.wb_sunny_outlined,
        "color": const Color(0xFFF39C12),
      },
      {
        "title": 'Growth Rate',
        "value":
            latestIdentification.growthRate != null
                ? '${latestIdentification.growthRate!.toStringAsFixed(1)}/10'
                : 'N/A',
        "icon": Icons.trending_up_outlined,
        "color": _primaryColor,
      },
      {
        "title": 'Toxicity',
        "value":
            latestIdentification.toxicityLevel != null
                ? '${latestIdentification.toxicityLevel!.toStringAsFixed(1)}/10'
                : 'N/A',
        "icon": Icons.warning_amber_outlined,
        "color": const Color(0xFFE74C3C),
      },
    ];

    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      childAspectRatio: 1.60,
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      children:
          characteristics
              .map(
                (metric) => _buildCharacteristicCard(
                  metric['title'],
                  metric['value'],
                  metric['icon'],
                  metric['color'],
                ),
              )
              .toList(),
    );
  }

  Widget _buildCharacteristicCard(
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: _cardBackgroundColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: _shadowColor.withAlpha((0.7 * 255).toInt()),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 14,
                    color: _textColorSecondary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: color.withAlpha((0.15 * 255).toInt()),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(icon, size: 22, color: color),
                ),
              ],
            ),
            Text(
              value,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: _textColorPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCareTipsCard(PlantIdentificationResult identification) {
    if (identification.careTips.isEmpty) return const SizedBox.shrink();
    return Card(
      elevation: 3,
      shadowColor: _shadowColor.withAlpha((0.8 * 255).toInt()),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      color: _cardBackgroundColor,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ...identification.careTips
                .take(3)
                .map(
                  (tip) => Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(top: 3, right: 12),
                          child: Icon(
                            Icons.check_circle_rounded,
                            size: 20,
                            color: _healthyColor,
                          ),
                        ),
                        Expanded(
                          child: Text(
                            tip,
                            style: TextStyle(
                              color: _textColorPrimary.withAlpha(
                                (0.9 * 255).toInt(),
                              ),
                              fontSize: 15,
                              height: 1.45,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
          ],
        ),
      ),
    );
  }

  double _calculateHealthScore(PlantIdentificationResult result) {
    double score = 5.0;
    switch (result.healthStatus.toLowerCase()) {
      case 'healthy':
        score += 3;
        break;
      case 'moderate':
        score += 1;
        break;
      case 'unhealthy':
        score -= 2;
        break;
      case 'dying':
        score -= 4;
        break;
    }

    if (result.waterNeeds != null) {
      score += (result.waterNeeds! - 5) * 0.2;
    }

    if (result.sunlightNeeds != null) {
      score += (result.sunlightNeeds! - 5) * 0.2;
    }

    return score.clamp(0, 10).toDouble();
  }

  Color _getHealthStatusColor(String healthStatus) {
    switch (healthStatus.toLowerCase()) {
      case 'healthy':
        return _healthyColor;
      case 'moderate':
        return _moderateColor;
      case 'unhealthy':
        return _unhealthyColor;
      case 'dying':
        return _dyingColor;
      default:
        return _textColorSecondary;
    }
  }
}
