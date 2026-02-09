import 'dart:convert';
import 'dart:typed_data';

import 'package:aiplantidentifier/utils/loader.dart';
import 'package:aiplantidentifier/views/plant_history_Screens/plant_Indentification_history_detailes.dart';
import 'package:aiplantidentifier/views/progress/growth_screen.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../database/database.dart';
import '../../models/hyderation.dart';
import '../../providers/analyze.dart';
import '../../utils/sarech_bar.dart';

class PlantHistoryScreen extends StatefulWidget {
  const PlantHistoryScreen({super.key});

  @override
  State<PlantHistoryScreen> createState() => _PlantHistoryScreenState();
}

class _PlantHistoryScreenState extends State<PlantHistoryScreen> {
  final TextEditingController searchController = TextEditingController();
  String _searchQuery = '';

  List<Map<String, dynamic>> _filterHistory(
    List<Map<String, dynamic>> history,
  ) {
    final query = _searchQuery.trim().toLowerCase();
    if (query.isEmpty) return history;

    return history.where((entry) {
      final result = jsonDecode(entry[DatabaseHelper.columnResult]);
      final identification = PlantIdentificationResult.fromJson(result);

      final species = identification.species.toLowerCase();
      final plantType =
          (entry[DatabaseHelper.columnPlantType] ?? '')
              .toString()
              .toLowerCase();

      return species.contains(query) || plantType.contains(query);
    }).toList();
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
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F7F8),
      appBar: AppBar(
        title: const Text(
          'Identification History',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
      ),
      body: Consumer<PlantIdentificationProvider>(
        builder: (context, provider, _) {
          if (provider.identificationHistory.isEmpty) {
            return EmptyStateWidgett(
              imageAsset: 'images/error_plant.png',
              title: 'No Plant Data Yet',
              description:
                  'Identify plants to track your progress and see\n'
                  'detailed statistics.',
            );
          }

          final filteredHistory = _filterHistory(
            provider.identificationHistory,
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
                          padding: const EdgeInsets.all(16),
                          itemCount: filteredHistory.length,
                          itemBuilder: (context, index) {
                            final entry = filteredHistory[index];

                            return FutureBuilder<Uint8List?>(
                              future: provider.getIdentificationImage(
                                entry[DatabaseHelper.columnId],
                              ),
                              builder: (context, snapshot) {
                                final result = jsonDecode(
                                  entry[DatabaseHelper.columnResult],
                                );
                                final identification =
                                    PlantIdentificationResult.fromJson(result);

                                return _buildCard(
                                  context,
                                  entry,
                                  identification,
                                  snapshot.data,
                                  snapshot.connectionState ==
                                      ConnectionState.waiting,
                                );
                              },
                            );
                          },
                        ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildCard(
    BuildContext context,
    Map<String, dynamic> entry,
    PlantIdentificationResult identification,
    Uint8List? imageBytes,
    bool loading,
  ) {
    print(
      'Parsed date--->plant history: ${entry[DatabaseHelper.columnTimestamp]}',
    );
    final date = DateTime.fromMillisecondsSinceEpoch(
      entry[DatabaseHelper.columnTimestamp],
    );

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8),
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.all(12),
        leading: ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child:
              loading
                  ? const SizedBox(
                    width: 40,
                    height: 40,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                  : imageBytes != null
                  ? Image.memory(
                    imageBytes,
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
          identification.species,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            color: Color(0xFF1B4332),
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(
              DateFormat('MMM d, hh:mm a').format(date),
              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
            ),
            const SizedBox(height: 6),
            Row(
              children: [
                Text(
                  '${(identification.confidence * 100).toStringAsFixed(0)}%',
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
                    entry[DatabaseHelper.columnPlantType] ?? 'N/A',
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
                    entry: entry,
                    imageBytes: imageBytes,
                  ),
            ),
          );
        },
      ),
    );
  }
}
