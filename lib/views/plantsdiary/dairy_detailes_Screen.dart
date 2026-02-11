import 'package:aiplantidentifier/utils/app_Toast.dart';
import 'package:aiplantidentifier/views/plantsdiary/dairy_Screen.dart';
import 'package:aiplantidentifier/models/dairy_plant_model.dart';
import 'package:aiplantidentifier/providers/dairy_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class DairyDetailesScreen extends StatefulWidget {
  final DairyPlantModel plant;

  const DairyDetailesScreen({super.key, required this.plant});

  @override
  State<DairyDetailesScreen> createState() => _DairyDetailesScreenState();
}

class _DairyDetailesScreenState extends State<DairyDetailesScreen> {
  late DairyPlantModel currentPlant;
  late List<PlantEntry> currentPlantEntries;
  final bool _isUpdating = false;
  PlantEntry? _selectedEntry;

  @override
  void initState() {
    super.initState();
    final plantProvider = context.read<PlantProvider>();
    currentPlant = plantProvider.getPlantById(widget.plant.id) ?? widget.plant;
    currentPlantEntries = currentPlant.entries ?? [];
    _loadEntries();
  }

  Future<void> _loadEntries() async {
    try {
      final plantProvider = context.read<PlantProvider>();
      final entries = await plantProvider.fetchEntriesbyid(currentPlant);

      if (!mounted) return;

      setState(() {
        currentPlantEntries = entries;
        currentPlant =
            plantProvider.getPlantById(currentPlant.id ?? 0) ?? currentPlant;

        if (_selectedEntry == null && currentPlantEntries.isNotEmpty) {
          _selectedEntry = currentPlantEntries.last;
        }
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error loading entries: $e')));
      }
    }
  }

  void _addNewEntry() {
    try {
      _showAddEntryDialog();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    }
  }

  void _showAddEntryDialog() {
    final descriptionController = TextEditingController();
    final statusController = TextEditingController();

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        bool isUpdating = false;

        return StatefulBuilder(
          builder: (context, setDialogState) {
            return Dialog(
              insetPadding: EdgeInsets.all(12),

              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),

              child: MediaQuery.removePadding(
                context: context,
                removeTop: true,
                removeBottom: true,
                removeLeft: true,
                removeRight: true,

                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text(
                        'Add Diary Entry',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),

                      const SizedBox(height: 16),

                      TextField(
                        controller: descriptionController,
                        // minLines: 3,
                        // maxLines: 5,
                        decoration: InputDecoration(
                          labelText: 'Description',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),

                      const SizedBox(height: 16),

                      TextField(
                        controller: statusController,
                        decoration: InputDecoration(
                          labelText: 'Status',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),

                      const SizedBox(height: 24),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          TextButton(
                            onPressed:
                                isUpdating
                                    ? null
                                    : () => Navigator.pop(context),
                            child: const Text('Cancel'),
                          ),

                          const SizedBox(width: 12),

                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF2E7D32),
                            ),
                            onPressed:
                                isUpdating
                                    ? null
                                    : () async {
                                      if (descriptionController.text.isEmpty) {
                                        AppToast.error(
                                          'Please enter description',
                                        );
                                        return;
                                      }

                                      setDialogState(() => isUpdating = true);

                                      try {
                                        final newEntry = PlantEntry(
                                          plantId: currentPlant.id ?? 0,
                                          description:
                                              descriptionController.text,
                                          imageUrl: currentPlant.imageUrl,
                                          status:
                                              statusController.text.isEmpty
                                                  ? 'No status'
                                                  : statusController.text,
                                          timestamp: _formatDate(
                                            DateTime.now(),
                                          ),
                                          updateTime: _formatTime(
                                            DateTime.now(),
                                          ),
                                          userNotes: descriptionController.text,
                                        );

                                        await context
                                            .read<PlantProvider>()
                                            .updateEntry(newEntry);

                                        await _loadEntries();

                                        if (!mounted) return;
                                        Navigator.pop(context);

                                        AppToast.success(
                                          'Entry updated successfully',
                                        );
                                      } catch (e) {
                                        setDialogState(
                                          () => isUpdating = false,
                                        );
                                        AppToast.error('Update failed');
                                      }
                                    },
                            child:
                                isUpdating
                                    ? const SizedBox(
                                      height: 18,
                                      width: 18,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        color: Colors.white,
                                      ),
                                    )
                                    : const Text('Save'),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  String _formatDate(DateTime dateTime) {
    final monthMap = {
      1: 'Jan',
      2: 'Feb',
      3: 'Mar',
      4: 'Apr',
      5: 'May',
      6: 'Jun',
      7: 'Jul',
      8: 'Aug',
      9: 'Sep',
      10: 'Oct',
      11: 'Nov',
      12: 'Dec',
    };
    final dayMap = {
      1: 'Monday',
      2: 'Tuesday',
      3: 'Wednesday',
      4: 'Thursday',
      5: 'Friday',
      6: 'Saturday',
      0: 'Sunday',
    };

    final month = monthMap[dateTime.month] ?? 'Jan';
    final day = dateTime.day;
    final year = dateTime.year;
    final weekDay = dayMap[dateTime.weekday] ?? 'Monday';

    return '$month $day, $year $weekDay';
  }

  String _formatTime(DateTime dateTime) {
    final hour = dateTime.hour % 12 == 0 ? 12 : dateTime.hour % 12;
    final minute = dateTime.minute.toString().padLeft(2, '0');
    final period = dateTime.hour >= 12 ? 'PM' : 'AM';

    return '$hour:$minute $period';
  }

  bool _isDeleting = false;

  void _deleteEntry(int entryId) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Delete Entry'),
          content: const Text('Are you sure you want to delete this entry?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              child: const Text('Delete'),
              onPressed: () async {
                Navigator.pop(dialogContext);

                const tag = '[PLANT_ENTRY_DELETE]';

                try {
                  setState(() => _isDeleting = true);
                  debugPrint('$tag Deleting entryId=$entryId');
                  final plantProvider = context.read<PlantProvider>();
                  await plantProvider.deleteEntry(
                    currentPlant.id ?? 0,
                    entryId,
                  );
                  debugPrint('$tag Delete success');

                  if (!mounted) return;

                  Navigator.pop(context);
                } catch (e, stack) {
                  debugPrint('$tag ERROR: $e');
                  debugPrint(stack.toString().split('\n').first);

                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Failed to delete entry')),
                    );
                  }
                } finally {
                  if (mounted) {
                    setState(() => _isDeleting = false);
                  }
                }
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _onRefresh() async {
    if (_isDeleting || _isUpdating) return;
    await _loadEntries();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => !_isDeleting,
      child: Stack(
        children: [
          IgnorePointer(
            ignoring: _isDeleting,
            child: Scaffold(
              backgroundColor: const Color.fromARGB(205, 255, 255, 255),
              appBar: AppBar(
                // backgroundColor: Colors.white,
                elevation: 0,
                leading: IconButton(
                  onPressed: _isDeleting ? null : () => Navigator.pop(context),
                  icon: const Icon(Icons.arrow_back),
                ),
                title: const Text('Plant Detail'),
                actions: [
                  IconButton(
                    onPressed:
                        _isDeleting
                            ? null
                            : () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder:
                                      (_) => PlantDiaryScreen(
                                        currentPlant: currentPlant,
                                      ),
                                ),
                              );
                            },
                    icon: const Icon(Icons.add),
                  ),
                ],
              ),
              body: SafeArea(
                child: Consumer<PlantProvider>(
                  builder: (context, plantProvider, _) {
                    final updatedPlant = plantProvider.getPlantById(
                      currentPlant.id,
                    );

                    if (updatedPlant != null) {
                      currentPlant = updatedPlant;
                    }

                    final hasEntries = currentPlantEntries.isNotEmpty;

                    if (!hasEntries) {
                      return RefreshIndicator(
                        onRefresh: _onRefresh,
                        color: const Color(0xFF2E7D32),
                        child: ListView(
                          physics: const AlwaysScrollableScrollPhysics(),
                          children: [
                            SizedBox(
                              height: MediaQuery.of(context).size.height * 0.7,
                              child: _buildNoDataWidget(context),
                            ),
                          ],
                        ),
                      );
                    }

                    return RefreshIndicator(
                      onRefresh: _onRefresh,
                      color: const Color(0xFF2E7D32),
                      child: SingleChildScrollView(
                        physics: const AlwaysScrollableScrollPhysics(),
                        padding: const EdgeInsets.all(16),
                        child: _buildEntriesWidget(context),
                      ),
                    );
                  },
                ),
              ),
            ),
          ),

          if (_isDeleting)
            Container(
              color: Colors.black.withOpacity(0.35),
              child: const Center(
                child: CircularProgressIndicator(color: Colors.white),
              ),
            ),
          if (_isUpdating)
            Container(
              color: Colors.black.withOpacity(0.35),
              child: const Center(
                child: CircularProgressIndicator(color: Colors.white),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildNoDataWidget(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(height: MediaQuery.of(context).size.height * 0.15),
          Icon(Icons.note_outlined, size: 80, color: Colors.grey[300]),
          const SizedBox(height: 24),
          Text(
            'No Data Yet',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              color: Colors.grey[600],
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Start adding diary entries for ${currentPlant.name}',
            textAlign: TextAlign.center,
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: Colors.grey[500]),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () {
              _addNewEntry();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF2E7D32),
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
            ),
            child: const Text(
              'Add Diary Entry',
              style: TextStyle(color: Colors.white),
            ),
          ),
          SizedBox(height: MediaQuery.of(context).size.height * 0.15),
        ],
      ),
    );
  }

  Widget _buildEntriesWidget(BuildContext context) {
    final entry =
        _selectedEntry ??
        (currentPlantEntries.isNotEmpty ? currentPlantEntries.last : null);

    if (entry == null) {
      return const SizedBox();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: double.infinity,
          height: 250,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            image: DecorationImage(
              image: MemoryImage(decodeBase64Image(entry.imageUrl)!),
              fit: BoxFit.cover,
            ),
            color: Colors.grey[200],
          ),
        ),

        const SizedBox(height: 12),

        Text(
          'Notes:',
          style: Theme.of(
            context,
          ).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.bold),
        ),
        Text(
          entry.userNotes ?? "No notes provided.",
          style: Theme.of(context).textTheme.bodyLarge,
        ),

        SizedBox(height: MediaQuery.of(context).size.height * 0.01),

        Text(
          'AI Description:',
          style: Theme.of(
            context,
          ).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.bold),
        ),
        Text(
          entry.description ?? "No description provided.",
          style: Theme.of(context).textTheme.bodyLarge,
        ),

        SizedBox(height: MediaQuery.of(context).size.height * 0.02),

        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Status',
                  style: Theme.of(
                    context,
                  ).textTheme.labelSmall?.copyWith(color: Colors.grey[500]),
                ),
                const SizedBox(height: 4),
                Text(
                  entry.status,
                  style: Theme.of(
                    context,
                  ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w500),
                ),
              ],
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  'Entry last update',
                  style: Theme.of(
                    context,
                  ).textTheme.labelSmall?.copyWith(color: Colors.grey[500]),
                ),
                const SizedBox(height: 4),
                Text(
                  'at ${entry.updateTime}',
                  style: Theme.of(
                    context,
                  ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w500),
                ),
              ],
            ),
          ],
        ),

        const SizedBox(height: 24),

        Row(
          children: [
            Expanded(
              child: ElevatedButton(
                onPressed: () => _deleteEntry(entry.id ?? 0),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.pink[100],
                ),
                child: Text(
                  'Delete Entry',
                  style: TextStyle(color: Colors.pink[400]),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: ElevatedButton(
                onPressed: _addNewEntry,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2E7D32),
                ),
                child: const Text(
                  'Edit Entry',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ),
          ],
        ),

        const SizedBox(height: 16),
        if (currentPlantEntries.length > 1) ...[
          Divider(color: Colors.grey[300]),
          const SizedBox(height: 16),
          Text(
            'All Entries',
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),

          ListView.builder(
            shrinkWrap: true,
            reverse: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: currentPlantEntries.length,
            itemBuilder: (context, index) {
              final item = currentPlantEntries[index];
              final isSelected = _selectedEntry?.id == item.id;

              return GestureDetector(
                onTap: () {
                  setState(() {
                    _selectedEntry = item;
                  });
                },
                child: _buildEntryTile(context, item, isSelected),
              );
            },
          ),
        ],

        // if (currentPlantEntries.length > 1) ...[
        //   Divider(color: Colors.grey[300]),
        //   const SizedBox(height: 16),
        //   Text(
        //     'Previous Entries',
        //     style: Theme.of(
        //       context,
        //     ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
        //   ),
        //   const SizedBox(height: 12),

        //   ListView.builder(
        //     shrinkWrap: true,
        //     physics: const NeverScrollableScrollPhysics(),
        //     itemCount:
        //         currentPlantEntries
        //             .where((e) => e.id != _selectedEntry?.id)
        //             .length,
        //     itemBuilder: (context, index) {
        //       final filteredEntries =
        //           currentPlantEntries
        //               .where((e) => e.id != _selectedEntry?.id)
        //               .toList();

        //       final item = filteredEntries[index];

        //       return GestureDetector(
        //         onTap: () {
        //           setState(() {
        //             _selectedEntry = item;
        //           });
        //         },
        //         child: Container(
        //           decoration: BoxDecoration(
        //             color: const Color(0xFF2E7D32).withOpacity(0.1),
        //             borderRadius: BorderRadius.circular(8),
        //           ),
        //           child: _buildEntryTile(context, item),
        //         ),
        //       );
        //     },
        //   ),
        // ],
      ],
    );
  }

  Widget _buildEntryTile(
    BuildContext context,
    PlantEntry entry,
    bool isSelected,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color:
            isSelected
                ? Color(0xFF2E7D32).withOpacity(0.15)
                : Theme.of(context).brightness == Brightness.dark
                ? Colors.black
                : Colors.white,
        border: Border.all(
          color: isSelected ? const Color(0xFF2E7D32) : Colors.grey[200]!,
          width: isSelected ? 1.5 : 1,
        ),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                entry.timestamp,
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color:
                      isSelected ? const Color(0xFF2E7D32) : Colors.grey[600],
                ),
              ),
              Text(
                entry.status,
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color:
                      isSelected ? const Color(0xFF2E7D32) : Colors.grey[600],
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            entry.description ?? "",
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
      ),
    );
  }
}
