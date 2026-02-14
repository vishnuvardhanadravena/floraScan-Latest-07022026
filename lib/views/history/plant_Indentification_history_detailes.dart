import 'dart:convert';
import 'dart:typed_data';
import 'package:aiplantidentifier/models/plant_history.dart';
import 'package:aiplantidentifier/providers/plant_history_provider.dart';
import 'package:aiplantidentifier/utils/loader.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';

class PlantIdentificationDetailScreen extends StatefulWidget {
  final String plant_id;
  const PlantIdentificationDetailScreen({super.key, required this.plant_id});

  @override
  State<PlantIdentificationDetailScreen> createState() =>
      _PlantIdentificationDetailScreenState();
}

class _PlantIdentificationDetailScreenState
    extends State<PlantIdentificationDetailScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  HistoryDetailes? selectedData;
  PlantBio? plantBio;
  PlantCare? plantCare;

  @override
  void initState() {
    super.initState();

    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() {
      setState(() {});
    });

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final provider = context.read<PlantHistoryProvider>();
      await provider.fetchDetailes(plant_id: widget.plant_id);
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: Consumer<PlantHistoryProvider>(
        builder: (context, plantHistoryProvider, child) {
          if (plantHistoryProvider.plant_history_loading) {
            return const PlantDetailShimmer();
          }

          if (plantHistoryProvider.plant_list_error.isNotEmpty) {
            return Container(
              child: Column(
                children: [
                  Text("Something Went worng please try again later "),
                  SizedBox(height: 10),
                  ElevatedButton(
                    onPressed: () async {
                      await plantHistoryProvider.fetchDetailes(
                        plant_id: widget.plant_id,
                      );
                    },
                    child: Text("Try Again "),
                  ),
                ],
              ),
            );
          }

          selectedData =
              plantHistoryProvider.historyDetilesResponce?.data?.first;
          plantBio = selectedData?.history?.plantBio;
          plantCare = selectedData?.history?.plantCare;

          return Column(
            children: [
              _header(plantHistoryProvider),
              _title(plantHistoryProvider),
              _tabs(),
              Expanded(
                child: SingleChildScrollView(
                  child:
                      _tabController.index == 0
                          ? _plantBio(plantHistoryProvider)
                          : _plantCare(plantHistoryProvider),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  // Widget _header(PlantHistoryProvider plantHistoryProvider) {
  //   final screenWidth = MediaQuery.of(context).size.width;
  //   final headerHeight = screenWidth * 0.6;

  //   return Stack(
  //     children: [
  //       // widget.imageBytes != null
  //       //     ? Image.memory(
  //       //       widget.imageBytes!,
  //       //       height: headerHeight,
  //       //       width: double.infinity,
  //       //       fit: BoxFit.cover,
  //       //     )
  //       //     : Container(
  //       //       height: headerHeight,
  //       //       color: Colors.grey[300],
  //       //       child: const Icon(Icons.image, size: 80, color: Colors.grey),
  //       //     ),
  //       Positioned(
  //         top: MediaQuery.of(context).padding.top + 8,
  //         left: 12,
  //         child: CircleAvatar(
  //           backgroundColor: Colors.white,
  //           child: IconButton(
  //             icon: const Icon(Icons.arrow_back, color: Colors.black),
  //             onPressed: () => Navigator.pop(context),
  //           ),
  //         ),
  //       ),
  //     ],
  //   );
  // }
  Widget _header(PlantHistoryProvider provider) {
    final screenWidth = MediaQuery.of(context).size.width;
    final headerHeight = screenWidth * 0.6;

    return SizedBox(
      height: headerHeight,
      width: double.infinity,
      child: Stack(
        children: [
          if (provider.historyDetilesResponce?.data?.first.plantImage != null)
            Image.network(
              provider.historyDetilesResponce!.data!.first.plantImage!,
              height: headerHeight,
              width: double.infinity,
              fit: BoxFit.cover,
            )
          else
            Container(
              height: headerHeight,
              width: double.infinity,
              color: Colors.grey[300],
            ),

          Positioned(
            top: MediaQuery.of(context).padding.top + 8,
            left: 12,
            child: CircleAvatar(
              backgroundColor: Colors.white,
              child: IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.black),
                onPressed: () => Navigator.pop(context),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _title(PlantHistoryProvider plantHistoryProvider) {
    if (plantBio?.plantInformation?.plantName == null &&
        plantBio?.plantInformation?.scientificName == null) {
      return const SizedBox.shrink();
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      child: Text(
        '${plantBio?.plantInformation?.plantName ?? "Unknown Plant"}${plantBio?.plantInformation?.scientificName != null ? " (${plantBio?.plantInformation?.scientificName})" : ""}',
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Color(0xFF2E5E2E),
        ),
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget _tabs() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          _tabButton("Plant Bio", 0),
          const SizedBox(width: 12),
          _tabButton("Plant Care", 1),
        ],
      ),
    );
  }

  Widget _tabButton(String text, int index) {
    final active = _tabController.index == index;
    return Expanded(
      child: GestureDetector(
        onTap: () => _tabController.animateTo(index),
        child: Container(
          height: 42,
          decoration: BoxDecoration(
            color: active ? const Color(0xFF5A7F5A) : Colors.grey[200],
            borderRadius: BorderRadius.circular(8),
          ),
          child: Center(
            child: Text(
              text,
              style: TextStyle(
                color: active ? Colors.white : Colors.green[800],
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _plantBio(PlantHistoryProvider plantHistoryProvider) {
    final plantname = plantBio?.plantInformation?.plantName;
    final scientificName = plantBio?.plantInformation?.scientificName;
    final category = plantBio?.plantInformation?.category;
    final growthHabit = plantBio?.plantInformation?.growthHabit;
    return Column(
      children: [
        if (_hasAnyValue([plantname, scientificName, category, growthHabit]))
          _card("Plant Information", [
            if (plantname != null || scientificName != null)
              _row(
                "Plant Name",
                '${plantname ?? "Unknown"}${scientificName != null ? " (${scientificName})" : ""}',
              ),
            if (category != null) _row("Category", category),
            if (growthHabit != null) _row("Growth Habit", growthHabit),
          ]),

        if (plantBio?.plantOverview != null)
          _card("Plant Overview", [_text(plantBio?.plantOverview)]),

        if (_hasAnyValue([
          plantBio?.originHabitat?.naativeRegion,
          plantBio?.originHabitat?.naturalHabitat,
        ]))
          _card("Origin & Habitat", [
            if (plantBio?.originHabitat?.naativeRegion != null)
              _row("Native Region", plantBio?.originHabitat?.naativeRegion),
            if (plantBio?.originHabitat?.naturalHabitat != null)
              _row("Natural Habitat", plantBio?.originHabitat?.naturalHabitat),
          ]),

        if (_hasAnyValue([
          plantBio?.keyCharacteristics?.leafShape,
          plantBio?.keyCharacteristics?.growthPattern,
          plantBio?.keyCharacteristics?.growthsSpeed,
          plantBio?.keyCharacteristics?.bestFor,
        ]))
          _card("Key Characteristics", [
            if (plantBio?.keyCharacteristics?.leafShape != null)
              _row("Leaf Shape", plantBio?.keyCharacteristics?.leafShape),
            if (plantBio?.keyCharacteristics?.growthPattern != null)
              _row(
                "Growth Pattern",
                plantBio?.keyCharacteristics?.growthPattern,
              ),
            if (plantBio?.keyCharacteristics?.growthsSpeed != null)
              _row("Growth Speed", plantBio?.keyCharacteristics?.growthsSpeed),
            if (plantBio?.keyCharacteristics?.bestFor != null)
              _row("Best For", plantBio?.keyCharacteristics?.bestFor),
          ]),

        if (plantBio?.benefitsUses != null &&
            (plantBio?.benefitsUses as List).isNotEmpty)
          _card(
            "Benefits & Uses",
            (plantBio?.benefitsUses ?? [])
                .map<Widget>(
                  (e) => Padding(
                    padding: const EdgeInsets.symmetric(vertical: 2),
                    child: Text(
                      "• $e",
                      style: const TextStyle(height: 1.4, color: Colors.black),
                    ),
                  ),
                )
                .toList(),
          ),
        _card(
          "Toxicity Info",
          (plantBio?.toxicityInfo ?? [])
              .map<Widget>(
                (e) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 2),
                  child: Text(
                    "• $e",
                    style: const TextStyle(height: 1.4, color: Colors.black),
                  ),
                ),
              )
              .toList(),
        ),

        // _card("Toxicity Info", [
        //   _row("Toxic to pets", bio["toxic_pets"] ? "Yes (cats & dogs)" : "No"),
        //   if (bio["toxic_humans"] != null)
        //     _row("Safe for humans", bio["toxic_humans"]),
        // ]),
        const SizedBox(height: 16),
      ],
    );
  }

  Map<String, Map<String, dynamic>> careConfig = {
    'water': {
      'icon': Icons.water_drop,
      'color': Color(0xFF2196F3), // blue
      'title': 'Water',
    },
    'sunlight': {
      'icon': Icons.wb_sunny,
      'color': Color(0xFFFFC107), // amber
      'title': 'Sunlight',
    },
    'soil': {
      'icon': Icons.park,
      'color': Color(0xFF795548), // brown
      'title': 'Soil',
    },
    'temperature': {
      'icon': Icons.thermostat,
      'color': Color(0xFFF44336), // red
      'title': 'Temperature',
    },
    'humidity': {
      'icon': Icons.water,
      'color': Color(0xFF26C6DA), // cyan
      'title': 'Humidity',
    },
    'fertilizer': {
      'icon': Icons.agriculture,
      'color': Color(0xFF4CAF50), // green
      'title': 'Fertilizer',
    },
    'pruning': {
      'icon': Icons.content_cut,
      'color': Color(0xFF9C27B0), // purple
      'title': 'Pruning',
    },
  };

  Widget _plantCare(PlantHistoryProvider plantHistoryProvider) {
    return Column(
      children: [
        if (_hasAnyValue([
          plantCare?.water?.waterLevel,
          plantCare?.water?.waterNotes,
        ]))
          _careTile(
            icon: Icons.water_drop,
            color: Colors.blue,
            title: "Water",
            heading: plantCare?.water?.waterLevel.toString() ?? '',
            description: plantCare?.water?.waterNotes ?? '',
          ),

        if (_hasAnyValue([
          plantCare?.sunlight?.sunlightLevel.toString(),
          plantCare?.sunlight?.sunlightNotes,
        ]))
          _careTile(
            icon: Icons.wb_sunny,
            color: Colors.orange,
            title: "Sunlight",
            heading: plantCare?.sunlight?.sunlightLevel.toString() ?? '',
            description: plantCare?.sunlight?.sunlightNotes ?? '',
          ),

        // if (care['soil'] != null)
        //   _careTile(
        //     icon: Icons.park,
        //     color: Colors.brown,
        //     title: "Soil",
        //     heading: "Soil Type",
        //     description: care['soil'],
        //   ),
        if (_hasAnyValue([
          plantCare?.temparature?.temparatureRange.toString(),
          plantCare?.temparature?.temparatureNotes,
        ]))
          _careTile(
            icon: Icons.thermostat,
            color: Colors.red,
            title: "Temperature",
            heading: plantCare?.temparature?.temparatureRange ?? '',
            description: plantCare?.temparature?.temparatureNotes ?? '',
          ),

        if (_hasAnyValue([
          plantCare?.humidity?.humidityLevel,
          plantCare?.humidity?.humidityLevel,
        ]))
          _careTile(
            icon: Icons.water,
            color: Colors.cyan,
            title: "Humidity",
            heading: plantCare?.humidity?.humidityLevel ?? '',
            description: plantCare?.humidity?.humidityLevel ?? '',
          ),

        if (_hasAnyValue([
          plantCare?.fertilizer?.fertilizerFrequency,
          plantCare?.fertilizer?.fertilizerNotes,
        ]))
          _careTile(
            icon: Icons.agriculture,
            color: Colors.green,
            title: "Fertilizer",
            heading: plantCare?.fertilizer?.fertilizerFrequency ?? '',
            description: plantCare?.fertilizer?.fertilizerNotes ?? '',
          ),

        // if (care['pruning'] != null)
        //   _careTile(
        //     icon: Icons.content_cut,
        //     color: Colors.purple,
        //     title: "Pruning",
        //     heading: "Pruning Guide",
        //     description: care['pruning'],
        //   ),
        if (plantCare?.commonIssues != null &&
            plantCare!.commonIssues!.isNotEmpty)
          _careList(
            title: "Common Issues",
            items: List<String>.from(plantCare?.commonIssues ?? []),
          ),

        const SizedBox(height: 16),
      ],
    );
  }

  Widget _careTile({
    required IconData icon,
    required String title,
    required Color color,
    required String heading,
    required String description,
  }) {
    if (heading.isEmpty && description.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.12),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.15),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: color, size: 22),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: color,
                  ),
                ),
              ),
            ],
          ),
          if (heading.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              heading,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 14,
                color: color,
              ),
            ),
          ],
          if (description.isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(
              description,
              style: const TextStyle(
                height: 1.4,
                fontSize: 14,
                color: Colors.black87,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _careList({required String title, required List<String> items}) {
    if (items.isEmpty) return const SizedBox.shrink();

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: const [
              Icon(Icons.warning_amber, color: Colors.redAccent, size: 24),
              SizedBox(width: 8),
              Text(
                "Common Issues",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: Color(0xFF2E7D32),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ...items.map(
            (e) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 2),
              child: Text(
                "• $e",
                style: const TextStyle(height: 1.4, color: Colors.black),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _card(String title, List<Widget> children) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: Color(0xFF2E7D32),
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 12),
          ...children,
        ],
      ),
    );
  }

  Widget _row(String label, dynamic value) {
    if (value == null || value.toString().isEmpty) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: RichText(
        text: TextSpan(
          style: const TextStyle(
            fontSize: 14,
            color: Colors.black87,
            height: 1.4,
          ),
          children: [
            TextSpan(
              text: '$label: ',
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
            TextSpan(text: value.toString()),
          ],
        ),
      ),
    );
  }

  Widget _text(dynamic text) {
    if (text == null || text.toString().isEmpty) {
      return const SizedBox.shrink();
    }

    return Text(
      text.toString(),
      style: const TextStyle(height: 1.5, fontSize: 14, color: Colors.black87),
    );
  }

  bool _hasAnyValue(List<dynamic> values) {
    return values.any((v) {
      if (v == null) return false;
      if (v is String) return v.isNotEmpty;
      if (v is List) return v.isNotEmpty;
      if (v is Map) return v.isNotEmpty;
      return true;
    });
  }
}

class PlantDetailShimmer extends StatelessWidget {
  const PlantDetailShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final headerHeight = screenWidth * 0.6;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: Shimmer.fromColors(
        baseColor: const Color(0xFFE8F5E9),
        highlightColor: const Color(0xFFF1F8E9),
        child: Column(
          children: [
            // 🔹 Header Image Shimmer
            Container(
              height: headerHeight,
              width: double.infinity,
              color: Colors.white,
            ),

            const SizedBox(height: 16),

            // 🔹 Title Shimmer
            Container(
              height: 20,
              width: 200,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(6),
              ),
            ),

            const SizedBox(height: 20),

            // 🔹 Tabs Shimmer
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  Expanded(child: _shimmerBox(height: 42)),
                  const SizedBox(width: 12),
                  Expanded(child: _shimmerBox(height: 42)),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // 🔹 Cards Shimmer
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: List.generate(4, (index) => _shimmerCard()),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _shimmerCard() {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Card Title
          _shimmerBox(height: 16, width: 150),

          const SizedBox(height: 12),

          // Content lines
          _shimmerBox(height: 12),
          const SizedBox(height: 8),
          _shimmerBox(height: 12),
          const SizedBox(height: 8),
          _shimmerBox(height: 12, width: 180),
        ],
      ),
    );
  }

  Widget _shimmerBox({double height = 12, double? width}) {
    return Container(
      height: height,
      width: width ?? double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(6),
      ),
    );
  }
}
