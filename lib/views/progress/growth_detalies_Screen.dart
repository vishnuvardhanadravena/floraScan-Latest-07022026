import 'dart:convert';

import 'package:aiplantidentifier/models/plant_growth.dart';
import 'package:aiplantidentifier/models/plant_inlight.dart';
import 'package:aiplantidentifier/utils/app_colors.dart';
import 'package:aiplantidentifier/views/progress/plant_inlights.dart';
import 'package:aiplantidentifier/views/progress/plant_progress.dart';
import 'package:flutter/material.dart';

class GrowthDetaliesScreen extends StatefulWidget {
  final PlantGroewth plant;

  const GrowthDetaliesScreen({super.key, required this.plant});

  @override
  State<GrowthDetaliesScreen> createState() => _GrowthDetaliesScreenState();
}

class _GrowthDetaliesScreenState extends State<GrowthDetaliesScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late final PlantInsightsData insights;
  late final Map<String, dynamic> progressJson;

  @override
  void initState() {
    super.initState();

    _tabController = TabController(length: 2, vsync: this);

    final Map<String, dynamic> decoded = Map<String, dynamic>.from(
      jsonDecode(widget.plant.data),
    );

    insights = PlantInsightsData.fromRawJson(widget.plant.data);

    progressJson =
        decoded['growth_progress'] != null
            ? Map<String, dynamic>.from(decoded['growth_progress'])
            : <String, dynamic>{};
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;
    final width = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor:  const Color.fromARGB(205, 255, 255, 255),
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            if (!mounted) return;
            Navigator.pop(context);
          },
        ),
        title: const Text(
          'Growth',
          style: TextStyle(color: Colors.white, fontSize: 20),
        ),
      ),
      body: Column(
        children: [
          _buildTabHeader(height, width),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                PlantProgressTab(growthProgressJson: progressJson,plnat:  widget.plant),
                PlantInsightsTab(plantData: insights,plnat: widget.plant),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabHeader(double height, double width) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.15),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Plant Growth Details',
            style: TextStyle(color: AppColors.primaryColor, fontSize: 16),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              _tabButton(
                index: 0,
                label: 'Progress',
                height: height,
                width: width,
              ),
              SizedBox(width: width * 0.02),
              _tabButton(
                index: 1,
                label: 'Insights',
                height: height,
                width: width,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _tabButton({
    required int index,
    required String label,
    required double height,
    required double width,
  }) {
    final isSelected = _tabController.index == index;

    return Expanded(
      child: GestureDetector(
        onTap: () {
          if (!mounted) return;
          _tabController.animateTo(index);
          setState(() {});
        },
        child: Container(
          height: height * 0.05,
          decoration: BoxDecoration(
            color: isSelected ? const Color(0xFF5A7F5A) : Colors.grey[200],
            borderRadius: BorderRadius.circular(8),
          ),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                fontSize: width * 0.04,
                fontWeight: FontWeight.w600,
                color: isSelected ? Colors.white : const Color(0xFF5A7F5A),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
