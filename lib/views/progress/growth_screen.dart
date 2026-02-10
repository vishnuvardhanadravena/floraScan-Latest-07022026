import 'dart:typed_data';

import 'package:aiplantidentifier/models/plant_growth.dart';
import 'package:aiplantidentifier/utils/app_colors.dart';
import 'package:aiplantidentifier/utils/helper_methodes.dart';
import 'package:aiplantidentifier/utils/loader.dart';
import 'package:aiplantidentifier/utils/sarech_bar.dart';
import 'package:aiplantidentifier/views/mainscrens/mainscreen.dart';
import 'package:aiplantidentifier/views/progress/growth_detalies_Screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

import '../../database/database.dart';
import '../../providers/analyze.dart';



class GrowthScreen extends StatefulWidget {
  const GrowthScreen({super.key});

  @override
  State<GrowthScreen> createState() => _GrowthScreenState();
}

class _GrowthScreenState extends State<GrowthScreen> {
  final TextEditingController searchController = TextEditingController();
  String _searchQuery = '';

  List<PlantGroewth> _mapFromProvider(List<Map<dynamic, dynamic>> history) {
    return history.map((e) {
      return PlantGroewth(
        data: e[DatabaseHelper.columnResult] ?? '',
        id: e[DatabaseHelper.columnId].toString(),
        name: e[DatabaseHelper.columnName] ?? 'Unknown Plant',
        status: _mapHealthStatus(e[DatabaseHelper.columnHealthStatus]),
        stage: _mapStage(e[DatabaseHelper.columnHealthStatus]),
        imagePath: e[DatabaseHelper.columnImagePath] ?? '',
        lastUpdate: DateTime.fromMillisecondsSinceEpoch(
          e[DatabaseHelper.columnTimestamp],
        ),
      );
    }).toList();
  }

  List<PlantGroewth> _filterPlants(List<PlantGroewth> plants) {
    if (_searchQuery.isEmpty) {
      return plants;
    }
    return plants.where((plant) {
      return plant.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          plant.status.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          plant.stage.toLowerCase().contains(_searchQuery.toLowerCase());
    }).toList();
  }

  String _mapHealthStatus(String? status) {
    switch (status?.toLowerCase()) {
      case 'healthy':
        return 'Healthy';
      case 'moderate':
        return 'Attention';
      case 'unhealthy':
      case 'dying':
        return 'Critical';
      default:
        return 'Unknown';
    }
  }

  String _mapStage(String? status) {
    switch (status?.toLowerCase()) {
      case 'healthy':
        return 'Growing';
      case 'moderate':
        return 'Growing';
      case 'unhealthy':
        return 'Mature';
      case 'dying':
        return 'Critical';
      default:
        return 'Growing';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<PlantIdentificationProvider>(
      builder: (context, provider, _) {
        final plants = _mapFromProvider(provider.identificationHistory);
        final filteredPlants = _filterPlants(plants);

        return Scaffold(
           drawer: AnimatedAppDrawer(rootContext: context),
          backgroundColor: Colors.white,
          appBar: AppBar(
            title: const Text(
              'Growth',
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.w500,
              ),
            ),
            elevation: 0,
          ),
          body:
              plants.isEmpty
                  ? EmptyStateWidgett(
                    imageAsset: 'images/error_plant.png',
                    title: 'No Plant Data Yet',
                    description:
                        'Identify plants to track your progress and see\n'
                        'detailed statistics.',
                  )
                  : _buildPlantList(filteredPlants, plants.length),
        );
      },
    );
  }

  Widget _buildPlantList(List<PlantGroewth> filteredPlants, int totalPlants) {
    return Column(
      children: [
        _searchBar(),
        Expanded(
          child:
              filteredPlants.isEmpty
                  ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.search_off,
                          size: 64,
                          color: Colors.grey.shade400,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No plants found',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: Colors.grey.shade700,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Try a different search term',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  )
                  : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: filteredPlants.length,
                    itemBuilder: (context, index) {
                      printGreen(
                        'Building plant card for: ${filteredPlants[index].data}',
                      );
                      return _buildPlantCard(filteredPlants[index]);
                    },
                  ),
        ),
      ],
    );
  }

  Widget _searchBar() {
    return Row(
      children: [
        Expanded(
          child: PlantSearchBar(
            controller: searchController,
            onChanged: (value) {
              setState(() {
                _searchQuery = value;
              });
            },
            onMenuTap: () {},
          ),
        ),
      ],
    );
  }

  Widget _buildPlantCard(PlantGroewth plant) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: _cardDecoration(radius: 16),
      child: InkWell(
        onTap:
            () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => GrowthDetaliesScreen(plant: plant),
              ),
            ),
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              _plantImage(plant.id),
              const SizedBox(width: 14),
              Expanded(child: _plantInfo(plant)),
              const Icon(Icons.chevron_right),
            ],
          ),
        ),
      ),
    );
  }

  Widget _plantImage(String plantId) {
    return SizedBox(
      width: 64,
      height: 64,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: FutureBuilder<Uint8List?>(
          future: DatabaseHelper.instance.getIdentificationImage(
            int.parse(plantId),
          ),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Container(
                color: Colors.grey.shade200,
                child: const Center(
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: AppColors.primarySwatch,
                  ),
                ),
              );
            }

            if (snapshot.hasData && snapshot.data != null) {
              return Image.memory(snapshot.data!, fit: BoxFit.cover);
            }

            return Container(
              color: Colors.grey.shade200,
              child: const Icon(Icons.local_florist),
            );
          },
        ),
      ),
    );
  }

  Widget _plantInfo(PlantGroewth plant) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          plant.name,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.black,
          ),
        ),
        const SizedBox(height: 6),
        Wrap(
          spacing: 6,
          children: [
            _tag(
              plant.status,
              _statusBg(plant.status),
              _statusFg(plant.status),
            ),
            _tag(plant.stage, _stageBg(plant.stage), _stageFg(plant.stage)),
          ],
        ),
        const SizedBox(height: 6),
        Text(
          'Last update: ${DateFormat('MMM d, yyyy').format(plant.lastUpdate)}',
          style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
        ),
      ],
    );
  }

  Widget _tag(String text, Color bg, Color fg) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(text, style: TextStyle(fontSize: 12, color: fg)),
    );
  }

  BoxDecoration _cardDecoration({double radius = 12}) {
    return BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(radius),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.05),
          blurRadius: 10,
          offset: const Offset(0, 2),
        ),
      ],
    );
  }

  Color _statusBg(String s) =>
      s == 'Healthy'
          ? Colors.green.shade100
          : s == 'Attention'
          ? Colors.orange.shade100
          : Colors.red.shade100;

  Color _statusFg(String s) =>
      s == 'Healthy'
          ? Colors.green.shade700
          : s == 'Attention'
          ? Colors.orange.shade700
          : Colors.red.shade700;

  Color _stageBg(String s) =>
      s == 'Growing'
          ? Colors.blue.shade100
          : s == 'Mature'
          ? Colors.purple.shade100
          : Colors.red.shade100;

  Color _stageFg(String s) =>
      s == 'Growing'
          ? Colors.blue.shade700
          : s == 'Mature'
          ? Colors.purple.shade700
          : Colors.red.shade700;

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }
}
