import 'dart:convert';
import 'dart:typed_data';
import 'package:aiplantidentifier/utils/loader.dart';
import 'package:flutter/material.dart';

class PlantIdentificationDetailScreen extends StatefulWidget {
  final Map<String, dynamic> entry;
  final Uint8List? imageBytes;

  const PlantIdentificationDetailScreen({
    super.key,
    required this.entry,
    required this.imageBytes,
  });

  @override
  State<PlantIdentificationDetailScreen> createState() =>
      _PlantIdentificationDetailScreenState();
}

class _PlantIdentificationDetailScreenState
    extends State<PlantIdentificationDetailScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late Map<String, dynamic> bio;
  late Map<String, dynamic> care;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() {
      setState(() {});
    });

    final raw = jsonDecode(widget.entry['result'] ?? '{}');

    bio = {
      "name": raw["common_name"],
      "scientific": raw["scientific_name"],
      "category": raw["category"],
      "growth_habit": raw["growth_habit"],
      "overview": raw["description"],
      "origin_region": raw["native_region"],
      "origin_habitat": raw["natural_habitat"],
      "leaf_shape": raw["leaf_shape"],
      "growth_pattern": raw["growth_pattern"],
      "growth_speed": raw["growth_rate"],
      "best_for": raw["best_for"],
      "benefits": raw["benefits"] is List ? raw["benefits"] : [],
      "toxic_pets": (raw["toxicity_level"] ?? 0) > 2,
      "toxic_humans":
          (raw["toxicity_level"] ?? 0) > 2
              ? "Toxic - avoid ingestion"
              : "Generally safe",
    };

    care = {
      "water": {
        "frequency":
            raw["water_needs"] != null
                ? "Water level ${raw["water_needs"]}/10"
                : null,
        "notes": raw["water_notes"],
      },
      "sunlight": {
        "frequency":
            raw["sunlight_needs"] != null
                ? "Sunlight level ${raw["sunlight_needs"]}/10"
                : null,
        "notes": raw["sunlight_notes"],
      },
      "soil": raw["soil_type"],
      "temperature": {
        "range": raw["temperature_range"],
        "notes": raw["temperature_notes"],
      },
      "humidity": {
        "level": raw["humidity_level"],
        "notes": raw["humidity_notes"],
      },
      "fertilizer": {
        "frequency": raw["fertilizer_frequency"],
        "notes": raw["fertilizer_notes"],
      },
      "pruning":
          raw["care_tips"] is List
              ? (raw["care_tips"] as List).join("\n")
              : raw["care_tips"],
      "common_issues": raw["common_issues"] is List ? raw["common_issues"] : [],
    };
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
      body: Column(
        children: [
          _header(),
          _title(),
          _tabs(),
          Expanded(
            child: SingleChildScrollView(
              child: _tabController.index == 0 ? _plantBio() : _plantCare(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _header() {
    final screenWidth = MediaQuery.of(context).size.width;
    final headerHeight = screenWidth * 0.6;

    return Stack(
      children: [
        widget.imageBytes != null
            ? Image.memory(
              widget.imageBytes!,
              height: headerHeight,
              width: double.infinity,
              fit: BoxFit.cover,
            )
            : Container(
              height: headerHeight,
              color: Colors.grey[300],
              child: const Icon(Icons.image, size: 80, color: Colors.grey),
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
    );
  }

  Widget _title() {
    if (bio["name"] == null && bio["scientific"] == null) {
      return const SizedBox.shrink();
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      child: Text(
        '${bio["name"] ?? "Unknown Plant"}${bio["scientific"] != null ? " (${bio["scientific"]})" : ""}',
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

  Widget _plantBio() {
    return Column(
      children: [
        if (_hasAnyValue([
          bio["name"],
          bio["scientific"],
          bio["category"],
          bio["growth_habit"],
        ]))
          _card("Plant Information", [
            if (bio["name"] != null || bio["scientific"] != null)
              _row(
                "Plant Name",
                '${bio["name"] ?? "Unknown"}${bio["scientific"] != null ? " (${bio["scientific"]})" : ""}',
              ),
            if (bio["category"] != null) _row("Category", bio["category"]),
            if (bio["growth_habit"] != null)
              _row("Growth Habit", bio["growth_habit"]),
          ]),

        if (bio["overview"] != null)
          _card("Plant Overview", [_text(bio["overview"])]),

        if (_hasAnyValue([bio["origin_region"], bio["origin_habitat"]]))
          _card("Origin & Habitat", [
            if (bio["origin_region"] != null)
              _row("Native Region", bio["origin_region"]),
            if (bio["origin_habitat"] != null)
              _row("Natural Habitat", bio["origin_habitat"]),
          ]),

        if (_hasAnyValue([
          bio["leaf_shape"],
          bio["growth_pattern"],
          bio["growth_speed"],
          bio["best_for"],
        ]))
          _card("Key Characteristics", [
            if (bio["leaf_shape"] != null)
              _row("Leaf Shape", bio["leaf_shape"]),
            if (bio["growth_pattern"] != null)
              _row("Growth Pattern", bio["growth_pattern"]),
            if (bio["growth_speed"] != null)
              _row("Growth Speed", bio["growth_speed"]),
            if (bio["best_for"] != null) _row("Best For", bio["best_for"]),
          ]),

        if (bio["benefits"] != null && (bio["benefits"] as List).isNotEmpty)
          _card(
            "Benefits & Uses",
            (bio["benefits"] as List)
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

        _card("Toxicity Info", [
          _row("Toxic to pets", bio["toxic_pets"] ? "Yes (cats & dogs)" : "No"),
          if (bio["toxic_humans"] != null)
            _row("Safe for humans", bio["toxic_humans"]),
        ]),

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

  Widget _plantCare() {
    return Column(
      children: [
        if (_hasAnyValue([
          care['water']?['frequency'],
          care['water']?['notes'],
        ]))
          _careTile(
            icon: Icons.water_drop,
            color: Colors.blue,
            title: "Water",
            heading: care['water']?['frequency'] ?? '',
            description: care['water']?['notes'] ?? '',
          ),

        if (_hasAnyValue([
          care['sunlight']?['frequency'],
          care['sunlight']?['notes'],
        ]))
          _careTile(
            icon: Icons.wb_sunny,
            color: Colors.orange,
            title: "Sunlight",
            heading: care['sunlight']?['frequency'] ?? '',
            description: care['sunlight']?['notes'] ?? '',
          ),

        if (care['soil'] != null)
          _careTile(
            icon: Icons.park,
            color: Colors.brown,
            title: "Soil",
            heading: "Soil Type",
            description: care['soil'],
          ),

        if (_hasAnyValue([
          care['temperature']?['range'],
          care['temperature']?['notes'],
        ]))
          _careTile(
            icon: Icons.thermostat,
            color: Colors.red,
            title: "Temperature",
            heading: care['temperature']?['range'] ?? '',
            description: care['temperature']?['notes'] ?? '',
          ),

        if (_hasAnyValue([
          care['humidity']?['level'],
          care['humidity']?['notes'],
        ]))
          _careTile(
            icon: Icons.water,
            color: Colors.cyan,
            title: "Humidity",
            heading: care['humidity']?['level'] ?? '',
            description: care['humidity']?['notes'] ?? '',
          ),

        if (_hasAnyValue([
          care['fertilizer']?['frequency'],
          care['fertilizer']?['notes'],
        ]))
          _careTile(
            icon: Icons.agriculture,
            color: Colors.green,
            title: "Fertilizer",
            heading: care['fertilizer']?['frequency'] ?? '',
            description: care['fertilizer']?['notes'] ?? '',
          ),

        if (care['pruning'] != null)
          _careTile(
            icon: Icons.content_cut,
            color: Colors.purple,
            title: "Pruning",
            heading: "Pruning Guide",
            description: care['pruning'],
          ),

        if (care['common_issues'] != null &&
            (care['common_issues'] as List).isNotEmpty)
          _careList(
            title: "Common Issues",
            items: List<String>.from(care['common_issues']),
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
              fixEmoji(heading),
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
