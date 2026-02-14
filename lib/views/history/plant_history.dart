import 'dart:convert';
import 'dart:typed_data';

import 'package:aiplantidentifier/models/plantlist_model.dart';
import 'package:aiplantidentifier/utils/loader.dart';
import 'package:aiplantidentifier/views/history/plant_Indentification_history_detailes.dart';
import 'package:aiplantidentifier/views/mainscrens/mainscreen.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../database/database.dart';
import '../../models/hyderation.dart';
import '../../providers/analyze.dart';
import '../../utils/sarech_bar.dart';
import 'package:shimmer/shimmer.dart';

class PlantHistoryScreen extends StatefulWidget {
  const PlantHistoryScreen({super.key});

  @override
  State<PlantHistoryScreen> createState() => _PlantHistoryScreenState();
}

class _PlantHistoryScreenState extends State<PlantHistoryScreen> {
  final TextEditingController searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<PlantIdentificationProvider>().fetchplantlist();
    });
  }

  List<Plantlist> _filterHistory(List<Plantlist> history) {
    final query = _searchQuery.trim().toLowerCase();
    if (query.isEmpty) return history;

    return history.where((plant) {
      final name = plant.plantname?.toLowerCase() ?? '';
      final type = plant.planttype?.toLowerCase() ?? '';
      return name.contains(query) || type.contains(query);
    }).toList();
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  Widget _searchBar() {
    return PlantSearchBar(
      controller: searchController,
      onChanged: (value) {
        setState(() {
          _searchQuery = value;
        });
      },
      onMenuTap: () {},
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // drawer: AnimatedAppDrawer(rootContext: context),
      drawer: TelegramStyleDrawer(rootContext: context),
      backgroundColor: const Color.fromARGB(205, 255, 255, 255),
      appBar: AppBar(
        title: const Text(
          'Identification History',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
      ),
      body: Consumer<PlantIdentificationProvider>(
        builder: (context, provider, _) {
          if (provider.plantlistloading) {
            return const PlantHistoryShimmer();
          }

          if (provider.plantListModelresponce == null) {
            return EmptyStateWidgett(
              imageAsset: 'images/error_plant.png',
              title: 'No Plant Data Yet',
              description:
                  'Identify plants to track your progress and see\n'
                  'detailed statistics.',
            );
          }

          final filteredHistory = _filterHistory(
            provider.plantListModelresponce?.data ?? [],
          );

          return Column(
            children: [
              _searchBar(),
              Expanded(
                child:
                    filteredHistory.isEmpty
                        ? const Center(
                          child: Text(
                            'No matching plants found',
                            style: TextStyle(fontSize: 16),
                          ),
                        )
                        : ListView.builder(
                          padding: const EdgeInsets.all(13),
                          itemCount: filteredHistory.length,
                          itemBuilder: (context, index) {
                            final entry = filteredHistory[index];
                            return _buildCard(context, entry, false);
                          },
                        ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildCard(BuildContext context, Plantlist plant, bool loading) {
    print('Parsed date--->plant history: ${plant.scandateandtime}');

    final imageUrl = plant.plantimage;
    double confidence = 0.0;
    DateTime? date;

    final rawValue = plant.scandateandtime;

    if (rawValue != null && rawValue.isNotEmpty) {
      final millis = int.tryParse(rawValue);

      if (millis != null) {
        date = DateTime.fromMillisecondsSinceEpoch(millis);
      } else {
        date = DateTime.tryParse(rawValue)?.toLocal();
      }
    }

    if (plant.confidence is double) {
      confidence = plant.confidence as double;
    } else if (plant.confidence is int) {
      confidence = (plant.confidence as int).toDouble();
    } else if (plant.confidence is String) {
      confidence = double.tryParse(plant.confidence as String) ?? 0.0;
    }
    return Container(
      margin: const EdgeInsets.only(bottom: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8),
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.all(10),
        leading: ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child:
              loading
                  ? const SizedBox(
                    width: 40,
                    height: 40,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                  : (imageUrl != null && imageUrl.isNotEmpty)
                  ? Image.network(
                    imageUrl,
                    width: 60,
                    height: 60,
                    fit: BoxFit.cover,
                  )
                  : Container(
                    width: 60,
                    height: 60,
                    color: Colors.grey[300],
                    child: const Icon(Icons.local_florist),
                  ),
        ),

        title: Text(
          plant.plantname ?? "",
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            color: Color(0xFF1B4332),
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            if (date != null)
              Text(
                DateFormat('MMM d, hh:mm a').format(date),
                style: TextStyle(fontSize: 12, color: Colors.grey[600]),
              ),
            const SizedBox(height: 6),
            Row(
              children: [
                Text(
                  '${(confidence * 100).toStringAsFixed(0)}%',

                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF2D6A4F),
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    plant.planttype ?? "",
                    style: const TextStyle(fontSize: 11),
                  ),
                ),
              ],
            ),
          ],
        ),
        trailing: const Icon(Icons.chevron_right),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder:
                  (_) => PlantIdentificationDetailScreen(
                    plant_id: plant.sId ?? "",
                  ),
            ),
          );
        },
      ),
    );
  }
}

class PlantHistoryShimmer extends StatelessWidget {
  const PlantHistoryShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(205, 255, 255, 255),
      body: Shimmer.fromColors(
        baseColor: const Color(0xFFE8F5E9),
        highlightColor: const Color(0xFFF1F8E9),
        child: Column(
          children: [
            // 🔹 Search Bar Shimmer
            Padding(
              padding: const EdgeInsets.all(12),
              child: Container(
                height: 50,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),

            // 🔹 List Shimmer
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.all(13),
                itemCount: 6,
                itemBuilder: (_, __) => _buildShimmerCard(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

Widget _buildShimmerCard() {
  return Container(
    margin: const EdgeInsets.only(bottom: 4),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(12),
      boxShadow: [
        BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8),
      ],
    ),
    child: ListTile(
      contentPadding: const EdgeInsets.all(10),
      leading: Shimmer.fromColors(
        baseColor: Colors.grey.shade300,
        highlightColor: Colors.grey.shade100,
        child: Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            color: Colors.grey,
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ),
      title: Shimmer.fromColors(
        baseColor: Colors.grey.shade300,
        highlightColor: Colors.grey.shade100,
        child: Container(
          height: 14,
          width: double.infinity,
          color: Colors.grey,
        ),
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 8),
          Shimmer.fromColors(
            baseColor: Colors.grey.shade300,
            highlightColor: Colors.grey.shade100,
            child: Container(height: 10, width: 120, color: Colors.grey),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Shimmer.fromColors(
                baseColor: Colors.grey.shade300,
                highlightColor: Colors.grey.shade100,
                child: Container(height: 12, width: 40, color: Colors.grey),
              ),
              const SizedBox(width: 8),
              Shimmer.fromColors(
                baseColor: Colors.grey.shade300,
                highlightColor: Colors.grey.shade100,
                child: Container(
                  height: 18,
                  width: 60,
                  decoration: BoxDecoration(
                    color: Colors.grey,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
      trailing: Shimmer.fromColors(
        baseColor: Colors.grey.shade300,
        highlightColor: Colors.grey.shade100,
        child: Container(width: 20, height: 20, color: Colors.grey),
      ),
    ),
  );
}
