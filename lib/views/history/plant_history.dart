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
          if (provider.plantListModelresponce!.data!.isEmpty) {
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
                          padding: const EdgeInsets.all(16),
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
      // Try milliseconds
      final millis = int.tryParse(rawValue);

      if (millis != null) {
        date = DateTime.fromMillisecondsSinceEpoch(millis);
      } else {
        // Try ISO string
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
          // Navigator.push(
          //   context,
          //   MaterialPageRoute(
          //     builder:
          //         (_) => PlantIdentificationDetailScreen(
          //           entry: entry,
          //           imageBytes: imageBytes,
          //         ),
          //   ),
          // );
        },
      ),
    );
  }
}

// import 'package:aiplantidentifier/models/plantlist_model.dart';
// import 'package:aiplantidentifier/providers/analyze.dart';
// import 'package:aiplantidentifier/views/mainscrens/mainscreen.dart';
// import 'package:flutter/material.dart';
// import 'package:intl/intl.dart';
// import 'package:provider/provider.dart';

// class PlantHistoryScreen extends StatefulWidget {
//   const PlantHistoryScreen({super.key});

//   @override
//   State<PlantHistoryScreen> createState() => _PlantHistoryScreenState();
// }

// class _PlantHistoryScreenState extends State<PlantHistoryScreen> {
//   final TextEditingController searchController = TextEditingController();
//   String _searchQuery = '';

//   @override
//   void initState() {
//     super.initState();
//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       context.read<PlantIdentificationProvider>().fetchplantlist();
//     });
//   }

//   List<Plantlist> _filterHistory(List<Plantlist> history) {
//     final query = _searchQuery.trim().toLowerCase();
//     if (query.isEmpty) return history;

//     return history.where((plant) {
//       final name = plant.plantname?.toLowerCase() ?? '';
//       final type = plant.planttype?.toLowerCase() ?? '';
//       return name.contains(query) || type.contains(query);
//     }).toList();
//   }

//   @override
//   void dispose() {
//     searchController.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       drawer: TelegramStyleDrawer(rootContext: context),
//       backgroundColor: const Color(0xFFF4F7F6),
//       body: Consumer<PlantIdentificationProvider>(
//         builder: (context, provider, _) {
//           if (provider.plantlistloading) {
//             return const Center(child: CircularProgressIndicator());
//           }

//           if (provider.plantlisterror.isNotEmpty) {
//             return Center(
//               child: Text(
//                 provider.plantlisterror,
//                 style: const TextStyle(color: Colors.red),
//               ),
//             );
//           }

//           final plantList = provider.plantListModelresponce?.data ?? [];

//           if (plantList.isEmpty) {
//             return const Center(child: Text("No Plant History Found"));
//           }

//           final filteredList = _filterHistory(plantList);

//           return RefreshIndicator(
//             onRefresh: () async {
//               await provider.fetchplantlist(forceReload: true);
//             },
//             child: CustomScrollView(
//               slivers: [
//                 _buildHeader(),
//                 SliverToBoxAdapter(child: _buildSearchBar()),
//                 SliverPadding(
//                   padding: const EdgeInsets.all(16),
//                   sliver: SliverList(
//                     delegate: SliverChildBuilderDelegate((context, index) {
//                       final plant = filteredList[index];
//                       return _buildPlantCard(context, plant);
//                     }, childCount: filteredList.length),
//                   ),
//                 ),
//               ],
//             ),
//           );
//         },
//       ),
//     );
//   }

//   // ================= HEADER =================

//   Widget _buildHeader() {
//     return SliverAppBar(
//       expandedHeight: 120,
//       floating: false,
//       pinned: true,
//       flexibleSpace: Container(
//         decoration: const BoxDecoration(
//           gradient: LinearGradient(
//             colors: [Color(0xFF2D6A4F), Color(0xFF40916C)],
//             begin: Alignment.topLeft,
//             end: Alignment.bottomRight,
//           ),
//         ),
//         alignment: Alignment.centerLeft,
//         padding: const EdgeInsets.symmetric(horizontal: 16),
//         child: const Text(
//           "Plant Identification History",
//           style: TextStyle(
//             color: Colors.white,
//             fontSize: 20,
//             fontWeight: FontWeight.w600,
//           ),
//         ),
//       ),
//     );
//   }

//   // ================= SEARCH =================

//   Widget _buildSearchBar() {
//     return Padding(
//       padding: const EdgeInsets.all(16),
//       child: TextField(
//         controller: searchController,
//         onChanged: (value) {
//           setState(() => _searchQuery = value);
//         },
//         decoration: InputDecoration(
//           hintText: "Search plants...",
//           prefixIcon: const Icon(Icons.search),
//           filled: true,
//           fillColor: Colors.white,
//           border: OutlineInputBorder(
//             borderRadius: BorderRadius.circular(14),
//             borderSide: BorderSide.none,
//           ),
//         ),
//       ),
//     );
//   }

//   // ================= CARD =================

//   Widget _buildPlantCard(BuildContext context, Plantlist plant) {
//     DateTime? date;
//     try {
//       date = DateTime.parse(plant.scandateandtime ?? '');
//     } catch (_) {}

//     return Container(
//       margin: const EdgeInsets.only(bottom: 14),
//       padding: const EdgeInsets.all(14),
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(18),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.black.withOpacity(0.05),
//             blurRadius: 12,
//             offset: const Offset(0, 6),
//           ),
//         ],
//       ),
//       child: Row(
//         children: [
//           ClipRRect(
//             borderRadius: BorderRadius.circular(14),
//             child:
//                 plant.plantimage != null && plant.plantimage!.isNotEmpty
//                     ? Image.network(
//                       plant.plantimage!,
//                       width: 75,
//                       height: 75,
//                       fit: BoxFit.cover,
//                     )
//                     : const Icon(Icons.local_florist, size: 60),
//           ),
//           const SizedBox(width: 16),
//           Expanded(
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text(
//                   plant.plantname ?? "Unknown Plant",
//                   style: const TextStyle(
//                     fontSize: 17,
//                     fontWeight: FontWeight.w600,
//                   ),
//                 ),
//                 const SizedBox(height: 6),
//                 if (date != null)
//                   Text(
//                     DateFormat('MMM d, hh:mm a').format(date),
//                     style: const TextStyle(fontSize: 12, color: Colors.grey),
//                   ),
//                 const SizedBox(height: 10),
//                 Row(
//                   children: [
//                     _chip(
//                       "${((plant.confidence ?? 0) * 100).toStringAsFixed(0)}%",
//                       const Color(0xFF2D6A4F),
//                     ),
//                     const SizedBox(width: 8),
//                     _chip(plant.planttype ?? "N/A", Colors.grey.shade700),
//                   ],
//                 ),
//               ],
//             ),
//           ),
//           const Icon(Icons.chevron_right),
//         ],
//       ),
//     );
//   }

//   Widget _chip(String text, Color color) {
//     return Container(
//       padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
//       decoration: BoxDecoration(
//         color: color.withOpacity(0.12),
//         borderRadius: BorderRadius.circular(20),
//       ),
//       child: Text(
//         text,
//         style: TextStyle(
//           fontSize: 11,
//           fontWeight: FontWeight.w600,
//           color: color,
//         ),
//       ),
//     );
//   }
// }
