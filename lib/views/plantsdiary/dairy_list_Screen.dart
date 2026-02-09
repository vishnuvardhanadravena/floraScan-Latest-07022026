import 'package:aiplantidentifier/utils/app_Toast.dart';
import 'package:aiplantidentifier/utils/loader.dart';
import 'package:aiplantidentifier/utils/sarech_bar.dart';
import 'package:aiplantidentifier/views/plantsdiary/dairy_Screen.dart';
import 'package:aiplantidentifier/views/plantsdiary/dairy_detailes_Screen.dart';
import 'package:aiplantidentifier/models/dairy_plant_model.dart';
import 'package:aiplantidentifier/providers/dairy_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:typed_data';
import 'dart:convert';

class PlantListScreen extends StatefulWidget {
  const PlantListScreen({super.key});

  @override
  State<PlantListScreen> createState() => _PlantListScreenState();
}

class _PlantListScreenState extends State<PlantListScreen> {
  late final TextEditingController _searchController;
  final FocusNode _searchFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();

    _searchController = TextEditingController();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _searchFocusNode.unfocus();
    });

    Future.microtask(() {
      context.read<PlantProvider>().loadPlants();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  void _handleSearch(String query) {
    context.read<PlantProvider>().searchPlants(query);
  }

  void _addNewDiary() {
    Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (_) => const PlantDiaryScreen()));
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final screenWidth = MediaQuery.of(context).size.width;
        final screenHeight = MediaQuery.of(context).size.height;
        final isTablet = screenWidth > 800;
        final isLargeTablet = screenWidth > 1200;

        return Scaffold(
          appBar: _buildAppBar(context, isTablet),
          backgroundColor: Colors.white,
          body: RefreshIndicator(
            onRefresh: () async {
              await context.read<PlantProvider>().loadPlants();
            },
            child: SafeArea(
              child: Column(
                children: [
                  _buildSearchBar(context, isTablet),
                  Expanded(
                    child: Consumer<PlantProvider>(
                      builder: (context, provider, _) {
                        final plantsWithEntries =
                            provider.plants
                                .where((p) => p.entries.isNotEmpty)
                                .toList();

                        if (plantsWithEntries.isEmpty) {
                          return _buildEmptyState(
                            context,
                            isTablet,
                            screenHeight,
                          );
                        }

                        return _buildPlantsList(
                          context,
                          plantsWithEntries,
                          isTablet,
                          isLargeTablet,
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context, bool isTablet) {
    return AppBar(
      elevation: 2,
      title: Text(
        'Plants Diary',
        style: TextStyle(
          fontSize: isTablet ? 24 : 20,
          fontWeight: FontWeight.w600,
        ),
      ),
      actions: [
        Padding(
          padding: EdgeInsets.only(right: isTablet ? 16 : 8),
          child: IconButton(
            icon: Icon(Icons.add, size: isTablet ? 28 : 24),
            onPressed: _addNewDiary,
            tooltip: 'Add New Plant',
          ),
        ),
      ],
      centerTitle: false,
    );
  }

  Widget _buildSearchBar(BuildContext context, bool isTablet) {
    final horizontalPadding = isTablet ? 24.0 : 16.0;
    final verticalPadding = isTablet ? 16.0 : 12.0;

    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: horizontalPadding,
        vertical: verticalPadding,
      ),
      child: Row(
        children: [
          Expanded(
            child: PlantSearchBar(
              controller: _searchController,
              focusNode: _searchFocusNode,
              onChanged: (value) {
                _handleSearch(value);
              },
              onMenuTap: () {},
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(
    BuildContext context,
    bool isTablet,
    double screenHeight,
  ) {
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      children: [
        SizedBox(
          height: screenHeight * 0.65,
          child: EmptyStateWidgett(
            title: 'No Plants Found',
            description: 'Add new plants to your diary!',
            imageAsset: 'images/error_plant.png',
            buttonText: 'Add New Plant',
            onButtonPressed: _addNewDiary,
            // titleColor: const Color(0xFF1B4332),
            // buttonColor: Colors.green.shade600,
          ),
        ),
      ],
    );
  }

  Widget _buildPlantsList(
    BuildContext context,
    List<DairyPlantModel> plants,
    bool isTablet,
    bool isLargeTablet,
  ) {
    final crossAxisCount = isLargeTablet ? 3 : (isTablet ? 2 : 1);
    final horizontalPadding = isTablet ? 24.0 : 16.0;

    if (crossAxisCount > 1) {
      return Padding(
        padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
        child: GridView.builder(
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            mainAxisSpacing: 16,
            crossAxisSpacing: 16,
            childAspectRatio: isLargeTablet ? 1.1 : 0.95,
          ),
          padding: const EdgeInsets.symmetric(vertical: 8),
          itemCount: plants.length,
          itemBuilder: (context, index) {
            return _PlantCard(plant: plants[index]);
          },
        ),
      );
    } else {
      return ListView.builder(
        padding: EdgeInsets.symmetric(
          horizontal: horizontalPadding,
          vertical: 8,
        ),
        itemCount: plants.length,
        itemBuilder: (context, index) {
          return _PlantCard(plant: plants[index]);
        },
      );
    }
  }
}

class _PlantCard extends StatelessWidget {
  final DairyPlantModel plant;

  const _PlantCard({required this.plant});

  Future<bool> _confirmDelete(BuildContext context) async {
    return await showDialog<bool>(
          context: context,
          builder:
              (ctx) => LayoutBuilder(
                builder: (ctx, constraints) {
                  final isTablet = MediaQuery.of(ctx).size.width > 800;

                  return AlertDialog(
                    title: Text(
                      'Delete Plant',
                      style: TextStyle(
                        fontSize: isTablet ? 22 : 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    content: Text(
                      'Are you sure you want to delete "${plant.name}"?\nThis action cannot be undone.',
                      style: TextStyle(fontSize: isTablet ? 16 : 14),
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(ctx, false),
                        child: Text(
                          'Cancel',
                          style: TextStyle(fontSize: isTablet ? 15 : 13),
                        ),
                      ),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                        ),
                        onPressed: () => Navigator.pop(ctx, true),
                        child: Text(
                          'Delete',
                          style: TextStyle(fontSize: isTablet ? 15 : 13),
                        ),
                      ),
                    ],
                  );
                },
              ),
        ) ??
        false;
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final screenWidth = MediaQuery.of(context).size.width;
        final isTablet = screenWidth > 800;

        return Dismissible(
          key: ValueKey(plant.id),
          direction: DismissDirection.endToStart,
          confirmDismiss: (_) => _confirmDelete(context),
          onDismissed: (_) {
            context.read<PlantProvider>().deletePlant(plant.id.toString());
            AppToast.success('Plant "${plant.name}" deleted successfully');
          },
          background: Container(
            margin: EdgeInsets.only(bottom: isTablet ? 16 : 12),
            padding: EdgeInsets.symmetric(horizontal: isTablet ? 24 : 20),
            decoration: BoxDecoration(
              color: Colors.red.shade400,
              borderRadius: BorderRadius.circular(12),
            ),
            alignment: Alignment.centerRight,
            child: Icon(
              Icons.delete,
              color: Colors.white,
              size: isTablet ? 32 : 28,
            ),
          ),
          child: GestureDetector(
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => DairyDetailesScreen(plant: plant),
                ),
              );
            },
            child: Container(
              margin: EdgeInsets.only(bottom: isTablet ? 16 : 12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade200),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: _buildCardContent(context, isTablet),
            ),
          ),
        );
      },
    );
  }

  Widget _buildCardContent(BuildContext context, bool isTablet) {
    // For tablet, use a more spacious layout
    if (isTablet && MediaQuery.of(context).size.width > 1000) {
      return _buildVerticalCardLayout(context, isTablet);
    } else {
      return _buildHorizontalCardLayout(context, isTablet);
    }
  }

  Widget _buildHorizontalCardLayout(BuildContext context, bool isTablet) {
    final imageSize = isTablet ? 100.0 : 80.0;
    final titleFontSize = isTablet ? 16.0 : 14.0;
    final subtitleFontSize = isTablet ? 13.0 : 11.0;

    return Padding(
      padding: EdgeInsets.all(isTablet ? 14 : 12),
      child: Row(
        children: [
          // Plant Image
          _buildPlantImage(imageSize),

          SizedBox(width: isTablet ? 14 : 12),

          // Plant Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Plant Name
                Text(
                  plant.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    fontSize: titleFontSize,
                    color: Colors.black,
                  ),
                ),

                SizedBox(height: isTablet ? 10 : 8),

                // Status Tags
                _buildStatusTags(isTablet),

                SizedBox(height: isTablet ? 10 : 8),

                // Last Updated
                Text(
                  plant.lastUpdated,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.grey,
                    fontSize: subtitleFontSize,
                  ),
                ),
              ],
            ),
          ),

          // Chevron Icon
          Icon(
            Icons.chevron_right,
            color: Colors.grey,
            size: isTablet ? 28 : 24,
          ),
        ],
      ),
    );
  }

  Widget _buildVerticalCardLayout(BuildContext context, bool isTablet) {
    final imageHeight = 140.0;
    final titleFontSize = 16.0;
    final subtitleFontSize = 12.0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Plant Image
        Container(
          width: double.infinity,
          height: imageHeight,
          decoration: BoxDecoration(
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(12),
              topRight: Radius.circular(12),
            ),
            color: Colors.grey.shade200,
            image: DecorationImage(
              image: MemoryImage(decodeBase64Image(plant.imageUrl)!),
              fit: BoxFit.cover,
            ),
          ),
        ),

        Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Plant Name
              Text(
                plant.name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  fontSize: titleFontSize,
                  color: Colors.black,
                ),
              ),

              const SizedBox(height: 10),

              // Status Tags
              _buildStatusTags(isTablet),

              const SizedBox(height: 10),

              // Last Updated
              Text(
                plant.lastUpdated,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Colors.grey,
                  fontSize: subtitleFontSize,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPlantImage(double size) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        color: Colors.grey.shade200,
        image: DecorationImage(
          image: MemoryImage(decodeBase64Image(plant.imageUrl)!),
          fit: BoxFit.cover,
        ),
      ),
    );
  }

  Widget _buildStatusTags(bool isTablet) {
    return Wrap(
      spacing: isTablet ? 10 : 8,
      runSpacing: isTablet ? 6 : 4,
      children: [
        _StatusTag(
          label: plant.status,
          backgroundColor: Color(
            int.parse(plant.statusColor.replaceFirst('#', '0xFF')),
          ),
          fontSize: isTablet ? 12.0 : 11.0,
        ),
        if (plant.additionalStatus != null)
          _StatusTag(
            label: plant.additionalStatus!,
            backgroundColor: Colors.grey.shade300,
            textColor: Colors.grey.shade700,
            fontSize: isTablet ? 12.0 : 11.0,
          ),
      ],
    );
  }
}

class _StatusTag extends StatelessWidget {
  final String label;
  final Color backgroundColor;
  final Color? textColor;
  final double? fontSize;

  const _StatusTag({
    required this.label,
    required this.backgroundColor,
    this.textColor,
    this.fontSize,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: fontSize != null && fontSize! > 12 ? 10 : 8,
        vertical: fontSize != null && fontSize! > 12 ? 5 : 4,
      ),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
          color: textColor ?? Colors.white,
          fontSize: fontSize ?? 11,
        ),
      ),
    );
  }
}

Uint8List? decodeBase64Image(String base64String) {
  try {
    final cleaned =
        base64String.contains(',')
            ? base64String.split(',').last
            : base64String;

    return base64Decode(cleaned);
  } catch (e) {
    return null;
  }
}
