import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:aiplantidentifier/core/config.dart';
import 'package:aiplantidentifier/utils/app_Toast.dart';
import 'package:aiplantidentifier/utils/app_colors.dart';
import 'package:aiplantidentifier/utils/custum_buttons.dart';
import 'package:aiplantidentifier/views/custom_dropdown.dart';
import 'package:aiplantidentifier/views/plantidentification/plant.dart';
import 'package:aiplantidentifier/models/dairy_plant_model.dart';
import 'package:aiplantidentifier/providers/dairy_provider.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:mysql1/mysql1.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:image_picker/image_picker.dart';

import '../../database/database.dart';
import '../../models/hyderation.dart';
import '../../providers/analyze.dart';

import 'package:http/http.dart' as http;

class PlantDiaryScreen extends StatefulWidget {
  final DairyPlantModel? currentPlant;

  const PlantDiaryScreen({super.key, this.currentPlant});

  @override
  State<PlantDiaryScreen> createState() => _PlantDiaryScreenState();
}

class _PlantDiaryScreenState extends State<PlantDiaryScreen> {
  static const Color _scaffoldBgColor = Color(0xFFF5F7FA);
  static const Color _primaryColor = Color(0xFF4CAF50); // Green
  static const Color _cardColor = Colors.white;
  static const Color _textPrimary = Color(0xFF333333);
  static const Color _textSecondary = Color(0xFF666666);
  static const Color _iconColor = Color(0xFF4CAF50);
  static const Color _errorColor = Color(0xFFD32F2F);

  final ImagePicker _picker = ImagePicker();
  DateTime _selectedDate = DateTime.now();
  String? _selectedPlantType;
  String? _notes;
  Uint8List? _diaryImage;
  bool _aiLoading = false;
  bool _uplodadingImage = false;
  int? _plantId;

  final List<String> _plantTypes = [
    'Indoor',
    'Outdoor',
    'Succulent',
    'Flowering',
    'Vegetable',
    'Herb',
    'Tree',
    'Shrub',
    'Other',
  ];
  @override
  void initState() {
    super.initState();
    if (widget.currentPlant != null) {
      _selectedPlantType = widget.currentPlant!.plantType;
      _plantId = widget.currentPlant?.id;
      _diaryImage = base64Decode(widget.currentPlant!.imageUrl);
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Plant Diary'),
        elevation: 2,
        foregroundColor: _primaryColor,
        actions: [
          IconButton(
            icon: const Icon(Icons.calendar_today),
            onPressed: _pickDate,
          ),
        ],
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.all(10),
            child: Column(
              children: [
                Card(
                  color: Colors.white,
                  elevation: 3,
                  margin: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: Column(
                      children: [
                        _buildDateSelector(context),
                        const SizedBox(height: 4),

                        _buildPlantTypeSelector(),
                        const SizedBox(height: 4),

                        _buildImageUpload(),
                        const SizedBox(height: 4),

                        _buildNotesField(),
                        const SizedBox(height: 8),

                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: CustomButton(
                            text: 'Save Today Entry',
                            onPressed:
                                _aiLoading
                                    ? null
                                    : () {
                                      _addNewEntry();
                                    },
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                _buildPreviousEntries(),
              ],
            ),
          ),

          if (_aiLoading)
            Positioned.fill(
              child: AbsorbPointer(
                absorbing: true,
                child: Container(
                  color: Colors.black.withOpacity(0.4),
                  child: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        CircularProgressIndicator(
                          color: Colors.green,
                          strokeWidth: 2,
                        ),
                        //  const CircularProgressIndicator(
                        //       valueColor: AlwaysStoppedAnimation<Color>(
                        //         Colors.green,
                        //       ),
                        //     ),
                        // SizedBox(
                        //   width: MediaQuery.of(context).size.width * 0.25,
                        //   height: MediaQuery.of(context).size.width * 0.25,
                        //   child: LeafRippleLoader(),
                        // ),
                        SizedBox(height: 16),
                        Text(
                          'Processing...',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildDateSelector(BuildContext context) {
    return GestureDetector(
      onTap: _pickDate,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade300),
        ),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: DateSelector(
            selectedDate: _selectedDate,
            onDateChanged: (date) {
              setState(() {
                _selectedDate = date;
              });
            },
          ),
        ),
      ),
    );
  }

  Widget _buildPlantTypeSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 8),
        CustomDropdown(
          hint: 'Select plant type',
          value: _selectedPlantType,
          items: _plantTypes,
          onChanged: (value) {
            setState(() {
              _selectedPlantType = value;
            });
          },
          prefixIcon: const Icon(Icons.eco, color: Color(0xFF2D5F3F)),
        ),
      ],
    );
  }

  void _pickImageFromCamera() {
    _pickImage(source: ImageSource.camera);
  }

  void _pickImageFromGallery() {
    _pickImage(source: ImageSource.gallery);
  }

  Widget _buildImageUpload() {
    return SizedBox(
      width: double.infinity,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Upload Photo',
            style: TextStyle(fontSize: 16, color: _textSecondary),
          ),
          const SizedBox(height: 12),
          PhotoUploadWidget(
            imageBytes: _diaryImage,
            isLoading: _aiLoading || _uplodadingImage,
            onCameraPressed: _pickImageFromCamera,
            onGalleryPressed: _pickImageFromGallery,
          ),
        ],
      ),
    );
  }

  Widget _buildNotesField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Notes',
          style: TextStyle(
            fontSize: 16,
            color: Colors.black,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          maxLines: 4,
          style: TextStyle(color: Colors.black),
          decoration: InputDecoration(
            hintText: 'How is your plant doing today? Any changes?',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          ),
          onChanged: (value) {
            _notes = value;
          },
        ),
      ],
    );
  }

  Widget _buildPreviousEntries() {
    return Consumer<PlantIdentificationProvider>(
      builder: (context, provider, child) {
        final diaryEntries =
            provider.identificationHistory.where((entry) {
              final entryDate = DateTime.fromMillisecondsSinceEpoch(
                entry['timestamp'],
              );
              return entryDate.year == _selectedDate.year &&
                  entryDate.month == _selectedDate.month &&
                  entryDate.day == _selectedDate.day;
            }).toList();

        if (diaryEntries.isEmpty) {
          return Container();
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Today\'s Entries',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: _textPrimary,
              ),
            ),
            const SizedBox(height: 12),
            ...diaryEntries.map((entry) => _buildDiaryEntryCard(entry)),
          ],
        );
      },
    );
  }

  Widget _buildDiaryEntryCard(Map<String, dynamic> entry) {
    final result = PlantIdentificationResult.fromJson(
      jsonDecode(entry[DatabaseHelper.columnResult]),
    );
    final time = DateFormat('hh:mm a').format(
      DateTime.fromMillisecondsSinceEpoch(
        entry[DatabaseHelper.columnTimestamp],
      ),
    );

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      color: Colors.white,
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${entry[DatabaseHelper.columnPlantType]} • $time',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: _textPrimary,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: _getHealthStatusColor(
                      result.healthStatus,
                    ).withAlpha((0.2 * 255).toInt()),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    result.healthStatus,
                    style: TextStyle(
                      color: _getHealthStatusColor(result.healthStatus),
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            if (result.commonName != null) ...[
              Text(
                result.commonName!,
                style: TextStyle(
                  fontStyle: FontStyle.italic,
                  color: _textSecondary,
                ),
              ),
              const SizedBox(height: 4),
            ],
            FutureBuilder<Uint8List?>(
              future: Provider.of<PlantIdentificationProvider>(
                context,
                listen: false,
              ).getIdentificationImage(entry['id']),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasData && snapshot.data != null) {
                  return ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.memory(
                      snapshot.data!,
                      height: 140,
                      width: double.infinity,
                      fit: BoxFit.cover,
                    ),
                  );
                }
                return Container();
              },
            ),
            const SizedBox(height: 5),
            if (result.description.isNotEmpty) ...[
              Text(
                'Notes: ${result.description}',
                maxLines: 2,
                style: TextStyle(color: _textSecondary),
              ),
              const SizedBox(height: 8),
            ],
            if (result.careTips.isNotEmpty) ...[
              Text(
                'Care Tips:',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: _textPrimary,
                ),
              ),
              ...result.careTips.map(
                (tip) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 2),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(Icons.check, size: 16, color: Colors.green),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          maxLines: 1,
                          tip,
                          style: TextStyle(color: _textSecondary),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Future<void> _pickDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> _pickImage({required ImageSource source}) async {
    const tag = '[IMAGE_PICK]';

    try {
      setState(() => _uplodadingImage = true);

      debugPrint('$tag Opening ${source.name}');

      final XFile? pickedFile = await _picker.pickImage(
        source: source,
        imageQuality: 100,
      );

      if (!mounted) return;

      if (pickedFile == null) {
        debugPrint('$tag User cancelled image picking');
        return;
      }

      final originalBytes = await File(pickedFile.path).readAsBytes();
      debugPrint(
        '$tag Original size: ${originalBytes.lengthInBytes ~/ 1024} KB',
      );
      final compressedBytes = await compute(
        compressImageIsolate,
        originalBytes,
      );
      // final compressedBytes = await compressImageTo150KB(originalBytes);
      debugPrint(
        '$tag Compressed size: ${compressedBytes.lengthInBytes ~/ 1024} KB',
      );

      if (!mounted) return;

      setState(() {
        _diaryImage = compressedBytes;
      });

      debugPrint('$tag Image stored successfully');
    } catch (e, stack) {
      debugPrint('$tag ERROR: $e');
      debugPrint('$tag STACK: $stack');

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Failed to pick image'),
          backgroundColor: _errorColor,
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _uplodadingImage = false);
      }
    }
  }

  Future<void> _addNewEntry() async {
    const tag = '[PLANT_DIARY_AI]';

    debugPrint('$tag Add new entry started');

    if (_selectedPlantType == null || _diaryImage == null) {
      AppToast.error('Please select a plant type and upload an image');
      return;
    }
    setState(() => _aiLoading = true);
    try {
      final base64Image = base64Encode(_diaryImage!);
      final mimeType = _getMimeType(_diaryImage!);

      debugPrint('$tag Image prepared (mime=$mimeType)');
      final aiResult = await AIPlantService.analyzePlant(
        base64Image: base64Image,
        notes: _notes ?? '',
        mimeType: mimeType,
      );

      if (!aiResult.containsKey('plant') || !aiResult.containsKey('entry')) {
        throw const FormatException('Invalid AI response structure');
      }

      final plantData = aiResult['plant'] as Map<String, dynamic>;
      final entryData = aiResult['entry'] as Map<String, dynamic>;
      int plantId;

      if (_plantId == null) {
        final plant = DairyPlantModel(
          plantType: _selectedPlantType,
          id: null,
          name: plantData['name'] ?? _selectedPlantType!,
          imageUrl: base64Image,
          status: plantData['status'] ?? 'Unknown',
          statusColor: plantData['statusColor'] ?? 'green',
          lastUpdated:
              plantData['lastUpdated'] ?? DateTime.now().toIso8601String(),
          additionalStatus: plantData['additionalStatus'] ?? '',
          entries: const [],
        );

        plantId = await context.read<PlantProvider>().addPlant(plant);

        if (plantId == 0) {
          AppToast.error('Unable to save plant');
          return;
        }
      } else {
        plantId = widget.currentPlant!.id!;
      }

      if (plantId == 0) {
        AppToast.error(
          'Unable to save plant. Please check your internet connection.',
        );
        return;
      }
      final entry = PlantEntry(
        plantType: _selectedPlantType,
        id: null,
        plantId: plantId,
        description: entryData['description'] ?? 'AI analysis completed',
        imageUrl: base64Image,
        status: entryData['status'] ?? 'Analyzed',
        timestamp: entryData['timestamp'] ?? DateTime.now().toIso8601String(),
        updateTime: entryData['updateTime'] ?? DateTime.now().toIso8601String(),
        userNotes: _notes ?? '',
      );

      final entryId = await context.read<PlantProvider>().addEntry(
        plantId,
        entry,
      );

      if (entryId == 0) {
        AppToast.error('Plant saved, but entry could not be saved.');
        return;
      }
      if (!mounted) return;

      AppToast.success('Entry saved successfully');

      setState(() {
        _diaryImage = null;
        _selectedPlantType = null;
        _notes = null;
      });

      debugPrint('$tag Entry flow completed successfully');
      if (mounted) {
        Provider.of<PlantProvider>(context, listen: false).loadPlants();
        Navigator.of(context).pop();
      }
    } on ArgumentError catch (e) {
      debugPrint('$tag Argument error: $e');
      AppToast.error('Invalid image data.');
    } on SocketException catch (e) {
      debugPrint('$tag Socket error: $e');
      AppToast.error('Network error. Please check your connection.');
    } on TimeoutException catch (e) {
      debugPrint('$tag Timeout error: $e');
      AppToast.error('Request timed out. Please try again.');
    } on FormatException catch (e) {
      debugPrint('$tag Format error: $e');
      AppToast.error('AI returned invalid data. Please try again.');
    } on MySqlException catch (e) {
      debugPrint('$tag Database error: $e');
      AppToast.error('Database unavailable. Please try again later.');
    } catch (e, stack) {
      debugPrint('$tag Unexpected error: $e');
      debugPrint(stack.toString().split('\n').first);
      AppToast.error('Something went wrong. Please try again.');
    } finally {
      if (mounted) {
        setState(() => _aiLoading = false);
      }
      debugPrint('$tag Add new entry process finished');
    }
  }
}

String _getMimeType(Uint8List image) {
  if (image.lengthInBytes < 4) return 'image/jpeg';

  if (image[0] == 0x89 &&
      image[1] == 0x50 &&
      image[2] == 0x4E &&
      image[3] == 0x47) {
    return 'image/png';
  }

  if (image[0] == 0xFF && image[1] == 0xD8 && image[2] == 0xFF) {
    return 'image/jpeg';
  }

  return 'image/jpeg';
}

Color _getHealthStatusColor(String healthStatus) {
  switch (healthStatus.toLowerCase()) {
    case 'healthy':
      return Colors.green;
    case 'moderate':
      return Colors.orange;
    case 'unhealthy':
      return Colors.orange[800]!;
    case 'dying':
      return Colors.red;
    default:
      return Colors.grey;
  }
}

class DateSelector extends StatelessWidget {
  final DateTime selectedDate;
  final ValueChanged<DateTime> onDateChanged;

  const DateSelector({
    super.key,
    required this.selectedDate,
    required this.onDateChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Icon(Icons.calendar_today, color: Color(0xFF2D5F3F)),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            DateFormat('MMM dd, yyyy').format(selectedDate),
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: Colors.black,
            ),
          ),
        ),
        Text(
          DateFormat('EEEE').format(selectedDate),
          style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
        ),
      ],
    );
  }
}

class PhotoUploadWidget extends StatelessWidget {
  final VoidCallback onCameraPressed;
  final VoidCallback onGalleryPressed;
  final Uint8List? imageBytes;
  final bool isLoading;

  const PhotoUploadWidget({
    super.key,
    required this.onCameraPressed,
    required this.onGalleryPressed,
    this.imageBytes,
    this.isLoading = false,
  });
  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Column(
      children: [
        DottedBorder(
          color: Colors.grey.shade400,
          strokeWidth: 2,
          dashPattern: const [6, 4],
          borderType: BorderType.RRect,
          radius: const Radius.circular(12),
          child: Container(
            width: double.infinity,
            height: size.height * 0.2,
            decoration: BoxDecoration(borderRadius: BorderRadius.circular(12)),
            child:
                imageBytes == null
                    ? InkWell(
                      onTap: isLoading ? null : onCameraPressed,
                      borderRadius: BorderRadius.circular(12),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(16),
                            child:
                                isLoading
                                    ? const SizedBox(
                                      width: 36,
                                      height: 36,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        color: AppColors.primarySwatch,
                                      ),
                                    )
                                    : Image.asset(
                                      'images/icons/camera.png',
                                      width: size.width * 0.1,
                                      height: size.width * 0.1,
                                      color: AppColors.primarySwatch,
                                    ),
                          ),

                          SizedBox(height: size.height * 0.01),

                          Text(
                            isLoading
                                ? 'Analyzing plant for detailed insights…'
                                : "Add today's plant photo",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 15,
                              color:
                                  isLoading
                                      ? Colors.grey.shade700
                                      : Colors.black87,
                              fontWeight:
                                  isLoading
                                      ? FontWeight.w500
                                      : FontWeight.normal,
                            ),
                          ),
                        ],
                      ),
                    )
                    : ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.memory(
                        imageBytes!,
                        fit: BoxFit.cover,
                        width: double.infinity,
                        height: double.infinity,
                      ),
                    ),
          ),
        ),

        SizedBox(height: size.height * 0.02),

        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: isLoading ? null : onCameraPressed,
                icon: const Icon(Icons.camera_alt, size: 20),
                label: Text(
                  'Camera',
                  style: TextStyle(color: AppColors.primaryColor),
                ),
                style: OutlinedButton.styleFrom(
                  foregroundColor: const Color(0xFF2D5F3F),
                  side: const BorderSide(color: Color(0xFF2D5F3F)),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
            ),

            SizedBox(width: size.width * 0.03),
            Expanded(
              child: OutlinedButton.icon(
                onPressed: isLoading ? null : onGalleryPressed,
                icon: const Icon(Icons.photo_library, size: 20),
                label: Text(
                  'Gallery',
                  style: TextStyle(color: AppColors.primaryColor),
                ),
                style: OutlinedButton.styleFrom(
                  foregroundColor: const Color(0xFF2D5F3F),
                  side: const BorderSide(color: Color(0xFF2D5F3F)),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class AIPlantService {
  static Future<Map<String, dynamic>> analyzePlant({
    required String base64Image,
    required String notes,
    required String mimeType,
  }) async {
    try {
      return await _analyzeWithOpenAI(base64Image, notes, mimeType);
    } catch (e) {
      return await _analyzeWithGemini(base64Image, notes, mimeType);
    }
  }

  static Future<Map<String, dynamic>> _analyzeWithOpenAI(
    String base64Image,
    String notes,
    String mimeType,
  ) async {
    final response = await http.post(
      Uri.parse('https://api.openai.com/v1/chat/completions'),
      headers: {
        'Authorization': 'Bearer $apiKey',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        "model": "gpt-4o-mini",
        "messages": [
          {
            "role": "system",
            "content": [
              {
                "type": "text",
                "text":
                    "Analyze this plant image and return ONLY the data needed for the following data models.\n\n"
                    "RULES:\n"
                    "- Return ONLY valid JSON\n"
                    "- Do NOT include markdown, code fences, or explanations\n"
                    "- Do NOT include any extra fields or change field names\n"
                    "- If unsure about any value, return null\n"
                    "- Keep all text values concise (max 200 characters)\n"
                    "- Plant status must be one of: ['Healthy', 'Needs Attention', 'Critical', 'Thriving', 'Struggling', 'Dormant']\n"
                    "- statusColor MUST be a HEX color string in format '#RRGGBB' ONLY\n"
                    "- additionalStatus MUST be ONLY 1 or 2 words (no sentences, no punctuation)\n"
                    "- additionalStatusColor MUST be a HEX color string in format '#RRGGBB' ONLY\n"
                    "- Do NOT return color names like 'green', 'red', 'yellow'\n"
                    "- Last updated must be current timestamp in ISO 8601 format\n\n"
                    "STATUS TO COLOR MAPPING (STRICT):\n"
                    "- Healthy -> #4CAF50\n"
                    "- Thriving -> #2E7D32\n"
                    "- Needs Attention -> #FFC107\n"
                    "- Struggling -> #FF9800\n"
                    "- Critical -> #F44336\n"
                    "- Dormant -> #9E9E9E\n\n"
                    "ADDITIONAL STATUS TO COLOR MAPPING (STRICT):\n"
                    "- Needs Water -> #42A5F5\n"
                    "- Mature -> #66BB6A\n"
                    "- Growing -> #81C784\n"
                    "- Low Light -> #FFB300\n"
                    "- Overwatered -> #EF5350\n"
                    "- Pest Risk -> #AB47BC\n"
                    "- Normal Growth -> #26A69A\n\n"
                    "REQUIRED DATA FOR DairyPlantModel:\n"
                    "{\n"
                    "  \"name\": \"string (plant common name)\",\n"
                    "  \"imageUrl\": \"string (describe the plant image)\",\n"
                    "  \"status\": \"string (plant health status)\",\n"
                    "  \"statusColor\": \"string (HEX color #RRGGBB)\",\n"
                    "  \"lastUpdated\": \"string (current timestamp)\",\n"
                    "  \"additionalStatus\": \"string\",\n"
                    "  \"additionalStatusColor\": \"string\"\n"
                    "}\n\n"
                    "REQUIRED DATA FOR PlantEntry (first diagnostic entry):\n"
                    "{\n"
                    "  \"description\": \"string (brief plant analysis)\",\n"
                    "  \"imageUrl\": \"string (same as plant image)\",\n"
                    "  \"status\": \"string (analysis status)\",\n"
                    "  \"timestamp\": \"string (current timestamp)\",\n"
                    "  \"updateTime\": \"string (current timestamp)\"\n"
                    "}\n\n"
                    "Return EXACTLY this JSON structure with no additional fields:\n"
                    "{\n"
                    "  \"plant\": {\n"
                    "    \"name\": \"string\",\n"
                    "    \"imageUrl\": \"string\",\n"
                    "    \"status\": \"string\",\n"
                    "    \"statusColor\": \"string\",\n"
                    "    \"lastUpdated\": \"string\",\n"
                    "    \"additionalStatus\": \"string\",\n"
                    "    \"additionalStatusColor\": \"string\"\n"
                    "  },\n"
                    "  \"entry\": {\n"
                    "    \"description\": \"string\",\n"
                    "    \"imageUrl\": \"string\",\n"
                    "    \"status\": \"string\",\n"
                    "    \"timestamp\": \"string\",\n"
                    "    \"updateTime\": \"string\"\n"
                    "  }\n"
                    "}",
              },
            ],
          },
          {
            "role": "user",
            "content": [
              {"text": notes},
              {
                "type": "image_url",
                "image_url": {"url": "data:image/jpeg;base64,$base64Image"},
              },
            ],
          },
        ],
      }),
    );

    if (response.statusCode != 200) {
      throw Exception(
        'OpenAI failed ${response.statusCode}\n${response.statusCode}',
      );
    }

    final decoded = jsonDecode(response.body);
    print("getting responce from the open ai");
    return jsonDecode(decoded['choices'][0]['message']['content']);
  }

  static Future<Map<String, dynamic>> _analyzeWithGemini(
    String base64Image,
    String notes,
    String mimeType,
  ) async {
    final response = await http
        .post(
          Uri.parse(
            'https://generativelanguage.googleapis.com/v1beta/models/'
            'gemini-2.5-flash-preview-09-2025:generateContent',
          ),
          headers: {
            'Content-Type': 'application/json',
            'X-goog-api-key': geminiApiKey,
          },
          body: jsonEncode({
            "contents": [
              {
                "parts": [
                  {
                    "text":
                        "Analyze this plant image and return ONLY the data needed for the following data models.\n\n"
                        "RULES:\n"
                        "- Return ONLY valid JSON\n"
                        "- Do NOT include markdown, code fences, or explanations\n"
                        "- Do NOT include any extra fields or change field names\n"
                        "- If unsure about any value, return null\n"
                        "- Keep all text values concise (max 200 characters)\n"
                        "- Plant status must be one of: ['Healthy', 'Needs Attention', 'Critical', 'Thriving', 'Struggling', 'Dormant']\n"
                        "- statusColor MUST be a HEX color string in format '#RRGGBB' ONLY\n"
                        "- additionalStatus MUST be ONLY 1 or 2 words (no sentences, no punctuation)\n"
                        "- additionalStatusColor MUST be a HEX color string in format '#RRGGBB' ONLY\n"
                        "- Do NOT return color names like 'green', 'red', 'yellow'\n"
                        "- Last updated must be current timestamp in ISO 8601 format\n\n"
                        "STATUS TO COLOR MAPPING (STRICT):\n"
                        "- Healthy -> #4CAF50\n"
                        "- Thriving -> #2E7D32\n"
                        "- Needs Attention -> #FFC107\n"
                        "- Struggling -> #FF9800\n"
                        "- Critical -> #F44336\n"
                        "- Dormant -> #9E9E9E\n\n"
                        "ADDITIONAL STATUS TO COLOR MAPPING (STRICT):\n"
                        "- Needs Water -> #42A5F5\n"
                        "- Mature -> #66BB6A\n"
                        "- Growing -> #81C784\n"
                        "- Low Light -> #FFB300\n"
                        "- Overwatered -> #EF5350\n"
                        "- Pest Risk -> #AB47BC\n"
                        "- Normal Growth -> #26A69A\n\n"
                        "REQUIRED DATA FOR DairyPlantModel:\n"
                        "{\n"
                        "  \"name\": \"string (plant common name)\",\n"
                        "  \"imageUrl\": \"string (describe the plant image)\",\n"
                        "  \"status\": \"string (plant health status)\",\n"
                        "  \"statusColor\": \"string (HEX color #RRGGBB)\",\n"
                        "  \"lastUpdated\": \"string (current timestamp)\",\n"
                        "  \"additionalStatus\": \"string\",\n"
                        "  \"additionalStatusColor\": \"string\"\n"
                        "}\n\n"
                        "REQUIRED DATA FOR PlantEntry (first diagnostic entry):\n"
                        "{\n"
                        "  \"description\": \"string (brief plant analysis)\",\n"
                        "  \"imageUrl\": \"string (same as plant image)\",\n"
                        "  \"status\": \"string (analysis status)\",\n"
                        "  \"timestamp\": \"string (current timestamp)\",\n"
                        "  \"updateTime\": \"string (current timestamp)\"\n"
                        "}\n\n"
                        "Return EXACTLY this JSON structure with no additional fields:\n"
                        "{\n"
                        "  \"plant\": {\n"
                        "    \"name\": \"string\",\n"
                        "    \"imageUrl\": \"string\",\n"
                        "    \"status\": \"string\",\n"
                        "    \"statusColor\": \"string\",\n"
                        "    \"lastUpdated\": \"string\",\n"
                        "    \"additionalStatus\": \"string\",\n"
                        "    \"additionalStatusColor\": \"string\"\n"
                        "  },\n"
                        "  \"entry\": {\n"
                        "    \"description\": \"string\",\n"
                        "    \"imageUrl\": \"string\",\n"
                        "    \"status\": \"string\",\n"
                        "    \"timestamp\": \"string\",\n"
                        "    \"updateTime\": \"string\"\n"
                        "  }\n"
                        "}",
                  },
                  {
                    "inline_data": {"mime_type": mimeType, "data": base64Image},
                  },
                ],
              },
            ],
            "generationConfig": {"temperature": 0.2, "maxOutputTokens": 6000},
          }),
        )
        .timeout(const Duration(seconds: 90));

    if (response.statusCode != 200) {
      throw Exception(
        'Gemini failed ${response.statusCode}\n${response.statusCode}',
      );
    }

    final decoded = jsonDecode(response.body);
    print("getting responce from the gemini ai ");
    return jsonDecode(decoded['candidates'][0]['content']['parts'][0]['text']);
  }
}

Uint8List? decodeBase64Image(String? base64String) {
  if (base64String == null || base64String.isEmpty) return null;

  try {
    return base64Decode(base64String);
  } catch (e) {
    debugPrint('[IMAGE] Base64 decode failed: $e');
    return null;
  }
}
