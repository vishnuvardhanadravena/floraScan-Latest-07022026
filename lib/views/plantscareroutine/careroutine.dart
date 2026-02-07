import 'dart:typed_data';

import 'package:aiplantidentifier/database/database.dart';
import 'package:aiplantidentifier/main.dart';
import 'package:aiplantidentifier/utils/app_colors.dart';
import 'package:aiplantidentifier/utils/loader.dart';
import 'package:aiplantidentifier/utils/sarech_bar.dart';
import 'package:aiplantidentifier/views/progress/growth_screen.dart';
import 'package:flutter/material.dart';

class RoutinePlant {
  final int id;
  final String name;
  final String image;
  final String status;
  final String category;
  final String todayTask;
  final String lastUpdate;
  final bool isHealthy;
  final String maintenance;
  final List<TimelineItem> timeline;
  final List<UpcomingCare> upcomingCare;
  final String aiTip;

  RoutinePlant({
    required this.id,
    required this.name,
    required this.image,
    required this.status,
    required this.category,
    required this.todayTask,
    required this.lastUpdate,
    required this.isHealthy,
    required this.maintenance,
    required this.timeline,
    required this.upcomingCare,
    required this.aiTip,
  });
}

class TimelineItem {
  final String title;
  final String subtitle;
  final bool isCompleted;

  TimelineItem({
    required this.title,
    required this.subtitle,
    required this.isCompleted,
  });
}

class UpcomingCare {
  final String title;
  final String subtitle;
  final String timeframe;
  final String icon;
  final Color color;

  UpcomingCare({
    required this.title,
    required this.subtitle,
    required this.timeframe,
    required this.icon,
    required this.color,
  });
}

class RoutineScreen extends StatefulWidget {
  const RoutineScreen({super.key});

  @override
  State<RoutineScreen> createState() => _RoutineScreenState();
}

class _RoutineScreenState extends State<RoutineScreen> with RouteAware {
  late Future<List<RoutinePlant>> _plantsFuture;

  final TextEditingController _searchController = TextEditingController();

  List<RoutinePlant> _allPlants = [];

  List<RoutinePlant> _filteredPlants = [];

  @override
  void initState() {
    super.initState();
    _load();

    RoutineRefreshNotifier.notifier.addListener(_onRefresh);
  }

  @override
  void didPopNext() {
    _reloadFromDb();
  }

  void _load() {
    _plantsFuture = DatabaseHelper.instance.getRoutinePlantsFromResult().then((
      plants,
    ) {
      _allPlants = plants;
      _filteredPlants = plants;
      return plants;
    });
  }

  void _reloadFromDb() {
    debugPrint('🔄 Reloading Routine data');
    setState(() {
      _load();
    });
  }

  void _onRefresh() {
    debugPrint('📥 RoutineRefreshNotifier triggered');
    _reloadFromDb();
  }

  void _onSearch(String query) {
    final text = query.trim().toLowerCase();

    setState(() {
      if (text.isEmpty) {
        _filteredPlants = _allPlants;
      } else {
        _filteredPlants =
            _allPlants.where((plant) {
              return plant.name.toLowerCase().contains(text);
            }).toList();
      }
    });
  }

  @override
  void dispose() {
    RoutineRefreshNotifier.notifier.removeListener(_onRefresh);
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(title: const Text('Routine')),
      body: Column(
        children: [
          PlantSearchBar(
            controller: _searchController,
            onChanged: _onSearch,
            onMenuTap: () {},
          ),

          Expanded(
            child: FutureBuilder<List<RoutinePlant>>(
              future: _plantsFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: AppColors.primarySwatch,
                    ),
                  );
                }

                if (snapshot.hasError) {
                  return const Center(
                    child: Text('Failed to load routine plants'),
                  );
                }

                if (_filteredPlants.isEmpty) {
                  return EmptyStateWidgett(
                    imageAsset: 'images/error_plant.png',
                    title: 'No Plant Data Yet',
                    description:
                        'Identify plants to track your progress and see\n'
                        'detailed statistics.',
                  );
                }

                return ListView.builder(
                  padding: EdgeInsets.symmetric(horizontal: width * 0.04),
                  itemCount: _filteredPlants.length,
                  itemBuilder: (context, index) {
                    final plant = _filteredPlants[index];

                    return PlantListItem(
                      plant: plant,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => PlantDetailScreen(plant: plant),
                          ),
                        );
                      },
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class PlantListItem extends StatelessWidget {
  final RoutinePlant plant;
  final VoidCallback onTap;

  const PlantListItem({super.key, required this.plant, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    final double spacing = size.width * 0.03;
    final double imageSize = size.width * 0.16;
    final double titleSize = size.width * 0.042;
    final double bodySize = size.width * 0.034;
    final double smallSize = size.width * 0.03;

    return Container(
      margin: EdgeInsets.only(bottom: spacing),
      padding: EdgeInsets.all(spacing),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(size.width * 0.04),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: size.width * 0.04,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(size.width * 0.04),
        onTap: onTap,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(
              width: imageSize,
              height: imageSize,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(size.width * 0.03),
                child: FutureBuilder<Uint8List?>(
                  future: DatabaseHelper.instance.getIdentificationImage(
                    plant.id,
                  ),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Container(
                        color: Colors.grey.shade200,
                        child: Center(
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
                      child: Icon(
                        Icons.local_florist,
                        size: imageSize * 0.5,
                        color: Colors.grey.shade400,
                      ),
                    );
                  },
                ),
              ),
            ),

            SizedBox(width: spacing),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    plant.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: titleSize,
                      color: Colors.black,
                    ),
                  ),

                  SizedBox(height: spacing * 0.4),

                  Wrap(
                    spacing: spacing * 0.5,
                    runSpacing: spacing * 0.3,
                    children: [
                      _chip(
                        plant.status,
                        plant.isHealthy ? Colors.green : Colors.red,
                        smallSize,
                      ),
                      _chip(plant.category, Colors.blue, smallSize),
                    ],
                  ),

                  SizedBox(height: spacing * 0.4),

                  Text(
                    'Today: ${plant.todayTask}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: bodySize,
                    ),
                  ),

                  Text(
                    'Last update: ${plant.lastUpdate}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: Colors.grey[500],
                      fontSize: smallSize,
                    ),
                  ),
                ],
              ),
            ),

            Icon(
              Icons.chevron_right,
              color: Colors.grey[400],
              size: imageSize * 0.35,
            ),
          ],
        ),
      ),
    );
  }

  Widget _chip(String text, Color color, double fontSize) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: fontSize * 0.9,
        vertical: fontSize * 0.4,
      ),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(fontSize),
      ),
      child: Text(
        text,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          color: color,
          fontSize: fontSize,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}

class PlantDetailScreen extends StatefulWidget {
  final RoutinePlant plant;

  const PlantDetailScreen({super.key, required this.plant});

  @override
  State<PlantDetailScreen> createState() => _PlantDetailScreenState();
}

class _PlantDetailScreenState extends State<PlantDetailScreen> {
  late final RoutinePlant plant;
  late Future<List<CareTask>> _careTasksFuture;

  @override
  void initState() {
    super.initState();
    plant = widget.plant;
    _careTasksFuture = Future.value(<CareTask>[]);
    _loadCareTasks();
  }

  void _loadCareTasks() {
    setState(() {
      _careTasksFuture = DatabaseHelper.instance
          .getCareTasksByPlantId(widget.plant.id)
          .then((rows) => rows.map(CareTask.fromMap).toList());
    });
  }

  String _remainingText(DateTime nextRunAt) {
    final now = DateTime.now();
    final diff = nextRunAt.difference(now).inDays;

    if (diff <= 0) return 'Due now';
    if (diff == 1) return 'Tomorrow';
    return 'In $diff days';
  }

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;
    final width = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          'Personalized Plant Care',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              margin: EdgeInsets.all(width * 0.04),
              padding: EdgeInsets.all(width * 0.02),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.green[100]!, Colors.green[50]!],
                ),
                borderRadius: BorderRadius.circular(200),
              ),
              child: Row(
                children: [
                  plantCircleImage(size: width * 0.3, plantId: plant.id),
                  SizedBox(width: width * 0.04),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          plant.name,
                          style: TextStyle(
                            fontSize: width * 0.05,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                        SizedBox(height: height * 0.006),
                        Text(
                          plant.maintenance,
                          style: TextStyle(color: Colors.grey[700]),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            /// ================= CARE TASKS =================
            Padding(
              padding: EdgeInsets.symmetric(horizontal: width * 0.04),
              child: Text(
                'Care Tasks',
                style: TextStyle(
                  fontSize: width * 0.05,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
            ),

            SizedBox(height: height * 0.015),

            FutureBuilder<List<CareTask>>(
              future: _careTasksFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: AppColors.primarySwatch,
                    ),
                  );
                }

                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return Padding(
                    padding: EdgeInsets.all(width * 0.04),
                    child: const Text('No care tasks available'),
                  );
                }

                final tasks = snapshot.data!;

                return Column(
                  children:
                      tasks.map((task) {
                        final now = DateTime.now();

                        final bool isCompleted =
                            task.lastCompletedAt != null &&
                            now.isBefore(task.nextRunAt);

                        final bool isDue =
                            task.lastCompletedAt == null ||
                            now.isAfter(task.nextRunAt);

                        return GestureDetector(
                          behavior: HitTestBehavior.opaque,
                          onTap:
                              isDue
                                  ? () async {
                                    debugPrint(
                                      '\x1B[31m[CARE_TASK_UI] USER COMPLETED taskId=${task.id}\x1B[0m',
                                    );
                                    try {
                                      await DatabaseHelper.instance
                                          .markTaskCompleted(task.id);
                                    } catch (e) {
                                      debugPrint('❌ DB schema not updated: $e');
                                    }

                                    _loadCareTasks();
                                  }
                                  : null,

                          child: Container(
                            margin: EdgeInsets.symmetric(
                              horizontal: width * 0.04,
                              vertical: height * 0.006,
                            ),
                            padding: EdgeInsets.all(width * 0.04),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(14),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.04),
                                  blurRadius: 8,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Row(
                              children: [
                                /// 🔘 RADIO
                                Container(
                                  width: 26,
                                  height: 26,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: Colors.green,
                                      width: 2,
                                    ),
                                    color:
                                        isCompleted
                                            ? Colors.green
                                            : Colors.transparent,
                                  ),
                                  child:
                                      isCompleted
                                          ? const Icon(
                                            Icons.check,
                                            size: 16,
                                            color: Colors.white,
                                          )
                                          : null,
                                ),

                                SizedBox(width: width * 0.04),

                                /// TEXT
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        task.title,
                                        style: TextStyle(
                                          fontSize: width * 0.042,
                                          fontWeight: FontWeight.w600,
                                          color: Colors.black,
                                        ),
                                      ),
                                      SizedBox(height: height * 0.006),
                                      Text(
                                        isCompleted
                                            ? _remainingText(task.nextRunAt)
                                            : 'Tap to complete',
                                        style: TextStyle(
                                          fontSize: width * 0.034,
                                          color: Colors.grey[600],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      }).toList(),
                );
              },
            ),

            SizedBox(height: height * 0.02),
            if (plant.upcomingCare.isNotEmpty) ...[
              SizedBox(height: height * 0.02),

              Padding(
                padding: EdgeInsets.symmetric(horizontal: width * 0.04),
                child: Text(
                  'Upcoming care',
                  style: TextStyle(
                    fontSize: width * 0.05,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
              ),

              SizedBox(height: height * 0.015),

              ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: height * 0.16,
                  maxHeight: height * 0.16,
                ),
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: EdgeInsets.symmetric(horizontal: width * 0.04),
                  itemCount: plant.upcomingCare.length,
                  itemBuilder: (context, index) {
                    final care = plant.upcomingCare[index];
                    return UpcomingCareCard(
                      care: care,
                      width: width,
                      height: height,
                    );
                  },
                ),
              ),
            ],
            SizedBox(height: height * 0.02),
            Container(
              margin: EdgeInsets.all(width * 0.04),
              padding: EdgeInsets.all(width * 0.04),
              decoration: BoxDecoration(
                color: Colors.green[50],
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.green[200]!),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('💡', style: TextStyle(fontSize: 22)),
                  SizedBox(width: width * 0.03),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'AI Tip',
                          style: TextStyle(
                            fontSize: width * 0.04,
                            fontWeight: FontWeight.w600,
                            color: Colors.green[800],
                          ),
                        ),
                        SizedBox(height: height * 0.006),
                        Text(
                          plant.aiTip,
                          style: TextStyle(
                            fontSize: width * 0.035,
                            color: Colors.grey[800],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget plantCircleImage({required double size, required int plantId}) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: Colors.green, width: 3),
      ),
      child: ClipOval(
        child: FutureBuilder<Uint8List?>(
          future: DatabaseHelper.instance.getIdentificationImage(plantId),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: AppColors.primarySwatch,
                ),
              );
            }
            if (snapshot.hasData && snapshot.data != null) {
              return Image.memory(snapshot.data!, fit: BoxFit.cover);
            }
            return const Icon(Icons.local_florist);
          },
        ),
      ),
    );
  }
}

class TimelineItemWidget extends StatelessWidget {
  final TimelineItem item;
  final double width;
  final double height;

  const TimelineItemWidget({
    super.key,
    required this.item,
    required this.width,
    required this.height,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(
        horizontal: width * 0.04,
        vertical: height * 0.008,
      ),
      padding: EdgeInsets.all(width * 0.04),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Row(
        children: [
          Container(
            width: width * 0.06,
            height: width * 0.06,
            decoration: BoxDecoration(
              color: item.isCompleted ? Colors.green[600] : Colors.white,
              shape: BoxShape.circle,
              border: Border.all(
                color:
                    item.isCompleted ? Colors.green[600]! : Colors.grey[400]!,
                width: 2,
              ),
            ),
            child:
                item.isCompleted
                    ? Icon(Icons.check, color: Colors.white, size: width * 0.04)
                    : null,
          ),
          SizedBox(width: width * 0.03),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.title,
                  style: TextStyle(
                    fontSize: width * 0.04,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
                SizedBox(height: height * 0.003),
                Text(
                  item.subtitle,
                  style: TextStyle(
                    fontSize: width * 0.035,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class UpcomingCareCard extends StatelessWidget {
  final UpcomingCare care;
  final double width;
  final double height;

  const UpcomingCareCard({
    super.key,
    required this.care,
    required this.width,
    required this.height,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width * 0.5,
      margin: EdgeInsets.only(right: width * 0.03),
      padding: EdgeInsets.all(width * 0.03),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                care.icon.isNotEmpty ? care.icon : '☀️',
                style: const TextStyle(fontSize: 15),
              ),

              SizedBox(width: width * 0.015),
              Expanded(
                child: Text(
                  care.title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: width * 0.035,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
              ),
            ],
          ),

          SizedBox(height: height * 0.01),

          Text(
            care.subtitle,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(fontSize: width * 0.03, color: Colors.grey[600]),
          ),

          SizedBox(height: height * 0.004),

          Text(
            care.timeframe,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: width * 0.028,
              color: Colors.grey[500],
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

class CareTask {
  final int id;
  final String title;
  final int intervalDays;
  final DateTime nextRunAt;
  final DateTime? lastCompletedAt;

  CareTask({
    required this.id,
    required this.title,
    required this.intervalDays,
    required this.nextRunAt,
    this.lastCompletedAt,
  });

  factory CareTask.fromMap(Map<String, dynamic> map) {
    return CareTask(
      id: map['id'] as int,
      title: map['title'] as String,
      intervalDays: map['intervalDays'] as int,
      nextRunAt: DateTime.parse(map['nextRunAt'].toString()),
      lastCompletedAt:
          map['lastCompletedAt'] != null
              ? DateTime.parse(map['lastCompletedAt'].toString())
              : null,
    );
  }
}

void _log(String message) {
  const red = '\x1B[31m';
  const reset = '\x1B[0m';
  debugPrint('$red[CARE_TASK_UI] $message$reset');
}
