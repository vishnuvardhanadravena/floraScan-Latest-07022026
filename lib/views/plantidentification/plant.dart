// import 'dart:async';
// import 'dart:convert';
// import 'dart:io';
// import 'dart:typed_data';
// import 'package:aiplantidentifier/core/config.dart';
// import 'package:aiplantidentifier/utils/app_Toast.dart';
// import 'package:aiplantidentifier/utils/app_colors.dart';
// import 'package:flutter/foundation.dart';
// import 'package:flutter/material.dart';
// import 'package:http/http.dart' as http;
// import 'package:image_picker/image_picker.dart';
// import 'package:provider/provider.dart';
// import 'package:image/image.dart' as img;
// import '../../models/hyderation.dart';
// import '../../providers/analyze.dart';

// class PlantIdentificationScreen extends StatelessWidget {
//   const PlantIdentificationScreen({super.key});

//   static const Color _scaffoldBackgroundColor = Color(0xFFF5F7FA);
//   static const Color _appBarTitleColor = Color(0xFF2E7D32); // Dark Green

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: _scaffoldBackgroundColor,
//       appBar: AppBar(
//         elevation: 0,
//         title: const Text(
//           'AI Plant Identifier',
//           style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
//         ),
//         actions: [],
//       ),
//       body: const SingleChildScrollView(
//         padding: EdgeInsets.symmetric(horizontal: 20.0, vertical: 5.0),
//         child: PlantIdentificationModule(),
//       ),
//     );
//   }
// }

// class PlantIdentificationModule extends StatefulWidget {
//   const PlantIdentificationModule({super.key});

//   @override
//   State<PlantIdentificationModule> createState() =>
//       _PlantIdentificationModuleState();
// }

// class _PlantIdentificationModuleState extends State<PlantIdentificationModule> {
//   static const Color _primaryColor = Color(0xFF4CAF50); // Green
//   static const Color _lightPrimaryColor = Color(0xFFC8E6C9); // Green 100
//   static const Color _accentColor = Color(0xFF2E7D32); // Dark Green
//   static const Color _cardBackgroundColor = Colors.white;
//   static const Color _textColorPrimary = Color(0xFF333333);
//   static const Color _textColorSecondary = Color(0xFF666666);
//   static const Color _iconColorActive = _primaryColor;
//   static const Color _iconColorInactive = Colors.grey;
//   static const Color _errorColor = Color(0xFFD32F2F);
//   static const Color _errorBackgroundColor = Color(0xFFFFEBEE);

//   Uint8List? _selectedImageBytes;
//   bool _isProcessing = false;
//   String? _errorMessage;
//   PlantIdentificationResult? _identificationResult;
//   final ImagePicker _picker = ImagePicker();
//   String? _selectedPlantType;

//   final List<Map<String, String>> plantTypes = [
//     {'title': 'Indoor', 'image': 'images/indoorimg.png', 'type': 'indoor'},
//     {'title': 'Outdoor', 'image': 'images/outdoorimg.png', 'type': 'outdoor'},
//     {
//       'title': 'Succulent',
//       'image': 'images/Succulentimg.png',
//       'type': 'succulent',
//     },
//     {
//       'title': 'Flowering',
//       'image': 'images/Floweringimg.png',
//       'type': 'flowering',
//     },
//     {'title': 'Herbs', 'image': "images/indoorimg.png", 'type': 'herbs'},
//     {'title': 'Trees', 'image': 'images/indoorimg.png', 'type': 'trees'},
//     {
//       'title': 'Medicinal',
//       'image': 'images/indoorimg.png',
//       'type': 'medicinal',
//     },
//     {'title': 'Cactus', 'image': 'images/indoorimg.png', 'type': 'cactus'},
//   ];
//   bool _isImageProcessing = false;

//   @override
//   Widget build(BuildContext context) {
//     return Stack(
//       children: [
//         Column(
//           crossAxisAlignment: CrossAxisAlignment.stretch,
//           children: [
//             const Text(
//               'Select Your Plant type',
//               style: TextStyle(
//                 fontSize: 16,
//                 fontWeight: FontWeight.w500,
//                 color: Colors.black87,
//               ),
//             ),
//             const SizedBox(height: 16),
//             SizedBox(
//               height: MediaQuery.of(context).size.height * 0.17,
//               child: ListView.builder(
//                 scrollDirection: Axis.horizontal,
//                 itemCount: plantTypes.length,
//                 padding: const EdgeInsets.symmetric(horizontal: 12),
//                 itemBuilder: (context, index) {
//                   final item = plantTypes[index];
//                   return _buildPlantTypeCard(
//                     item['title']!,
//                     item['image']!,
//                     item['type']!,
//                     context,
//                     (type) {
//                       setState(() {
//                         _selectedPlantType = type;
//                       });
//                     },
//                   );
//                 },
//               ),
//             ),

//             const SizedBox(height: 10),

//             Container(
//               child:
//                   _selectedImageBytes != null
//                       ? Center(
//                         child: ConstrainedBox(
//                           constraints: const BoxConstraints(
//                             minWidth: 220,
//                             minHeight: 220,
//                             maxWidth: 290,
//                             maxHeight: 290,
//                           ),
//                           child: AspectRatio(
//                             aspectRatio: 1,
//                             child: ClipRRect(
//                               borderRadius: BorderRadius.circular(15),
//                               child: Image.memory(
//                                 _selectedImageBytes!,
//                                 fit: BoxFit.cover,
//                               ),
//                             ),
//                           ),
//                         ),
//                       )
//                       : Center(
//                         child: ConstrainedBox(
//                           constraints: const BoxConstraints(
//                             minWidth: 220,
//                             minHeight: 220,
//                             maxWidth: 270,
//                             maxHeight: 270,
//                           ),
//                           child: AspectRatio(
//                             aspectRatio: 1,
//                             child: Container(
//                               decoration: BoxDecoration(
//                                 color: const Color(0xFFE8F5E9),
//                                 borderRadius: BorderRadius.circular(12),
//                               ),
//                               child: Stack(
//                                 children: [
//                                   Positioned(
//                                     top: 20,
//                                     left: 20,
//                                     child: _buildCornerBracket(true, true),
//                                   ),
//                                   Positioned(
//                                     top: 20,
//                                     right: 20,
//                                     child: _buildCornerBracket(true, false),
//                                   ),
//                                   Positioned(
//                                     bottom: 20,
//                                     left: 20,
//                                     child: _buildCornerBracket(false, true),
//                                   ),
//                                   Positioned(
//                                     bottom: 20,
//                                     right: 20,
//                                     child: _buildCornerBracket(false, false),
//                                   ),
//                                   Center(
//                                     child:
//                                         _isImageProcessing
//                                             ? const SizedBox(
//                                               width: 48,
//                                               height: 48,
//                                               child: CircularProgressIndicator(
//                                                 strokeWidth: 3,
//                                                 valueColor:
//                                                     AlwaysStoppedAnimation(
//                                                       Color(0xFF2D5F3F),
//                                                     ),
//                                               ),
//                                             )
//                                             : Icon(
//                                               Icons.camera_alt,
//                                               size: 56,
//                                               color: const Color(
//                                                 0xFF2D5F3F,
//                                               ).withOpacity(0.4),
//                                             ),
//                                   ),
//                                 ],
//                               ),
//                             ),
//                           ),
//                         ),
//                       ),
//             ),
//             const SizedBox(height: 10),
//             Row(
//               mainAxisAlignment: MainAxisAlignment.center,
//               crossAxisAlignment: CrossAxisAlignment.center,
//               children: [
//                 Text(
//                   "Position the leaf inside the frame",
//                   style: TextStyle(color: Colors.black),
//                 ),
//                 Icon(Icons.eco, color: AppColors.primaryColor),
//               ],
//             ),
//             const SizedBox(height: 10),
//             Row(
//               mainAxisAlignment: MainAxisAlignment.spaceAround,
//               children: [
//                 Expanded(
//                   child: OutlinedButton.icon(
//                     onPressed: _takePhoto,
//                     icon: const Icon(Icons.camera_alt),
//                     label: const Text('Camera'),
//                     style: ButtonStyle(
//                       backgroundColor: WidgetStateProperty.resolveWith<Color>((
//                         states,
//                       ) {
//                         if (states.contains(WidgetState.pressed)) {
//                           return AppColors.primaryColor;
//                         }
//                         return AppColors.galaryColor;
//                       }),

//                       foregroundColor: WidgetStateProperty.resolveWith<Color>((
//                         states,
//                       ) {
//                         if (states.contains(WidgetState.pressed)) {
//                           return Colors.white;
//                         }
//                         return const Color(0xFF2D5F3F);
//                       }),

//                       side: WidgetStateProperty.all(BorderSide.none),

//                       padding: WidgetStateProperty.all(
//                         const EdgeInsets.symmetric(vertical: 12),
//                       ),

//                       shape: WidgetStateProperty.all(
//                         RoundedRectangleBorder(
//                           borderRadius: BorderRadius.circular(20),
//                         ),
//                       ),
//                     ),
//                   ),
//                 ),
//                 SizedBox(width: 10),
//                 Expanded(
//                   child: OutlinedButton.icon(
//                     onPressed: _pickImageFromGallery,
//                     icon: const Icon(Icons.photo_library),
//                     label: const Text('Gallery'),
//                     style: ButtonStyle(
//                       backgroundColor: WidgetStateProperty.resolveWith<Color>((
//                         states,
//                       ) {
//                         if (states.contains(WidgetState.pressed)) {
//                           return AppColors.primaryColor;
//                         }
//                         return AppColors.galaryColor;
//                       }),

//                       foregroundColor: WidgetStateProperty.resolveWith<Color>((
//                         states,
//                       ) {
//                         if (states.contains(WidgetState.pressed)) {
//                           return Colors.white;
//                         }
//                         return const Color(0xFF2D5F3F);
//                       }),

//                       side: WidgetStateProperty.all(BorderSide.none),

//                       padding: WidgetStateProperty.all(
//                         const EdgeInsets.symmetric(vertical: 12),
//                       ),

//                       shape: WidgetStateProperty.all(
//                         RoundedRectangleBorder(
//                           borderRadius: BorderRadius.circular(20),
//                         ),
//                       ),
//                     ),
//                   ),
//                 ),
//               ],
//             ),

//             const SizedBox(height: 10),
//             SizedBox(
//               width: double.infinity,
//               child: ElevatedButton(
//                 onPressed:
//                     _selectedImageBytes != null && !_isProcessing
//                         ? _identifyPlant
//                         : null,
//                 style: ElevatedButton.styleFrom(
//                   backgroundColor: const Color.fromARGB(255, 34, 84, 52),
//                   disabledBackgroundColor: Colors.green.shade300,
//                   disabledForegroundColor: Colors.white70,
//                   padding: const EdgeInsets.symmetric(vertical: 10),
//                   shape: RoundedRectangleBorder(
//                     borderRadius: BorderRadius.circular(25),
//                   ),
//                 ),

//                 child:
//                     _isProcessing
//                         ? CircularProgressIndicator(
//                           strokeWidth: 2,
//                           color: AppColors.primarySwatch,
//                         )
//                         : const Text(
//                           'Identify Plant',
//                           style: TextStyle(
//                             fontSize: 16,
//                             fontWeight: FontWeight.w600,
//                             color: Colors.white,
//                           ),
//                         ),
//               ),
//             ),
//             if (_errorMessage != null)
//               Padding(
//                 padding: const EdgeInsets.only(top: 6),
//                 child: Container(
//                   padding: const EdgeInsets.symmetric(
//                     horizontal: 16,
//                     vertical: 12,
//                   ),
//                   decoration: BoxDecoration(
//                     color: _errorBackgroundColor,
//                     borderRadius: BorderRadius.circular(10),
//                     border: Border.all(
//                       color: _errorColor.withAlpha((0.7 * 255).toInt()),
//                     ),
//                   ),
//                   child: Row(
//                     children: [
//                       Icon(Icons.error_outline, color: _errorColor, size: 22),
//                       const SizedBox(width: 10),
//                       Expanded(
//                         child: Text(
//                           _errorMessage!,
//                           style: TextStyle(
//                             color: _errorColor,
//                             fontWeight: FontWeight.w500,
//                             fontSize: 14,
//                           ),
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//               ),

//             if (_identificationResult != null)
//               Padding(
//                 padding: const EdgeInsets.only(top: 10.0),
//                 child: _buildResultsCard(),
//               ),
//             const SizedBox(height: 20),
//           ],
//         ),
//       ],
//     );
//   }

//   Widget _buildCornerBracket(bool isTop, bool isLeft) {
//     return SizedBox(
//       width: 30,
//       height: 30,
//       child: CustomPaint(
//         painter: CornerBracketPainter(
//           isTop: isTop,
//           isLeft: isLeft,
//           color: const Color(0xFF2D5F3F),
//         ),
//       ),
//     );
//   }

//   Widget _buildInfoRow(
//     IconData icon,
//     String label,
//     String value, {
//     Color? valueColor,
//     FontWeight? valueWeight,
//   }) {
//     return Padding(
//       padding: const EdgeInsets.symmetric(vertical: 7.0),
//       child: Row(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Icon(icon, color: _iconColorActive, size: 22),
//           const SizedBox(width: 12),
//           Text(
//             '$label: ',
//             style: TextStyle(
//               fontWeight: FontWeight.w600,
//               color: _textColorPrimary,
//               fontSize: 16,
//             ),
//           ),
//           Expanded(
//             child: Text(
//               value,
//               style: TextStyle(
//                 fontSize: 16,
//                 color: valueColor ?? _textColorSecondary,
//                 fontWeight: valueWeight ?? FontWeight.normal,
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }

// Widget _buildResultsCard() {
//   return Card(
//     elevation: 3.0,
//     margin: EdgeInsets.zero,
//     shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.0)),
//     color: _cardBackgroundColor,
//     child: Padding(
//       padding: const EdgeInsets.all(10.0),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Text(
//             'Plant Identification Results',
//             style: Theme.of(context).textTheme.titleLarge?.copyWith(
//               fontWeight: FontWeight.bold,
//               color: _accentColor,
//             ),
//           ),
//           const SizedBox(height: 5),

//           _buildInfoRow(
//             Icons.nature_outlined,
//             'Species',
//             _identificationResult!.species,
//             valueWeight: FontWeight.w600,
//           ),
//           _buildInfoRow(
//             Icons.health_and_safety_outlined,
//             'Health',
//             _identificationResult!.healthStatus,
//             valueColor: _getHealthStatusColor(
//               _identificationResult!.healthStatus,
//             ),
//             valueWeight: FontWeight.w600,
//           ),
//           _buildInfoRow(
//             Icons.verified_user_outlined,
//             'Confidence',
//             '${(_identificationResult!.confidence * 100).toStringAsFixed(1)}%',
//             valueWeight: FontWeight.w500,
//           ),
//           if (_identificationResult!.commonName != null)
//             _buildInfoRow(
//               Icons.label_outlined,
//               'Common Name',
//               _identificationResult!.commonName!,
//             ),
//           Divider(height: 36, thickness: 0.8, color: Colors.grey.shade200),

//           Text(
//             'Plant Characteristics:',
//             style: TextStyle(
//               fontWeight: FontWeight.bold,
//               fontSize: 18,
//               color: _textColorPrimary,
//             ),
//           ),
//           const SizedBox(height: 16),
//           Wrap(
//             spacing: 12,
//             runSpacing: 12,
//             alignment: WrapAlignment.start,
//             children: [
//               if (_identificationResult!.scientificName != null)
//                 _buildMetricCard(
//                   'Scientific Name',
//                   _identificationResult!.scientificName!,
//                   Icons.science_outlined,
//                 ),
//               if (_identificationResult!.family != null)
//                 _buildMetricCard(
//                   'Family',
//                   _identificationResult!.family!,
//                   Icons.family_restroom_outlined,
//                 ),
//               if (_identificationResult!.nativeRegion != null)
//                 _buildMetricCard(
//                   'Native Region',
//                   _identificationResult!.nativeRegion!,
//                   Icons.public_outlined,
//                 ),
//               if (_identificationResult!.waterNeeds != null)
//                 _buildMetricCard(
//                   'Water Needs',
//                   '${_formatScore(_identificationResult!.waterNeeds)}/10',
//                   Icons.water_drop_outlined,
//                 ),
//               if (_identificationResult!.sunlightNeeds != null)
//                 _buildMetricCard(
//                   'Sunlight Needs',
//                   '${_formatScore(_identificationResult!.sunlightNeeds)}/10',
//                   Icons.wb_sunny_outlined,
//                 ),
//               if (_identificationResult!.growthRate != null)
//                 _buildMetricCard(
//                   'Growth Rate',
//                   '${_formatScore(_identificationResult!.growthRate)}/10',
//                   Icons.trending_up_outlined,
//                 ),
//               if (_identificationResult!.toxicityLevel != null)
//                 _buildMetricCard(
//                   'Toxicity',
//                   '${_formatScore(_identificationResult!.toxicityLevel)}/10',
//                   Icons.warning_amber_outlined,
//                 ),
//               if (_identificationResult!.bloomTime != null)
//                 _buildMetricCard(
//                   'Bloom Time',
//                   _identificationResult!.bloomTime!,
//                   Icons.calendar_today_outlined,
//                 ),
//               if (_identificationResult!.soilType != null)
//                 _buildMetricCard(
//                   'Soil Type',
//                   _identificationResult!.soilType!,
//                   Icons.terrain_outlined,
//                 ),
//             ],
//           ),

//           Divider(height: 36, thickness: 0.8, color: Colors.grey.shade200),

//           Text(
//             'Description:',
//             style: TextStyle(
//               fontWeight: FontWeight.bold,
//               fontSize: 17,
//               color: _textColorPrimary,
//             ),
//           ),
//           const SizedBox(height: 8),
//           Text(
//             _identificationResult!.description,
//             style: TextStyle(
//               color: _textColorSecondary,
//               fontSize: 15,
//               height: 1.5,
//             ),
//           ),
//           const SizedBox(height: 20),
//           Text(
//             'Care Tips:',
//             style: TextStyle(
//               fontWeight: FontWeight.bold,
//               fontSize: 17,
//               color: _textColorPrimary,
//             ),
//           ),
//           const SizedBox(height: 8),
//           Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children:
//                 _identificationResult!.careTips
//                     .map(
//                       (tip) => Padding(
//                         padding: const EdgeInsets.symmetric(vertical: 6.0),
//                         child: Row(
//                           crossAxisAlignment: CrossAxisAlignment.start,
//                           children: [
//                             Icon(
//                               Icons.check_circle_outline,
//                               color: _primaryColor,
//                               size: 20,
//                             ),
//                             const SizedBox(width: 10),
//                             Expanded(
//                               child: Text(
//                                 tip,
//                                 style: TextStyle(
//                                   color: _textColorSecondary,
//                                   fontSize: 15,
//                                   height: 1.5,
//                                 ),
//                               ),
//                             ),
//                           ],
//                         ),
//                       ),
//                     )
//                     .toList(),
//           ),
//         ],
//       ),
//     ),
//   );
// }

//   Widget _buildMetricCard(String title, String value, IconData iconData) {
//     final screenWidth = MediaQuery.of(context).size.width;
//     const double combinedPaddingPerSide = 20.0 + 20.0;
//     const double totalHorizontalPaddingAffectingWrap =
//         combinedPaddingPerSide * 2;
//     const double wrapItemSpacing = 12.0;

//     final double wrapContentAreaWidth =
//         screenWidth - totalHorizontalPaddingAffectingWrap;
//     double calculatedCardWidth = (wrapContentAreaWidth - wrapItemSpacing) / 2.0;

//     if (calculatedCardWidth < 0) {
//       calculatedCardWidth = 0;
//     }

//     return Container(
//       width: calculatedCardWidth,
//       padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
//       decoration: BoxDecoration(
//         color: _lightPrimaryColor.withAlpha((0.28 * 255).toInt()),
//         borderRadius: BorderRadius.circular(12),
//         border: Border.all(
//           color: _lightPrimaryColor.withAlpha((0.7 * 255).toInt()),
//           width: 1,
//         ),
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         mainAxisSize: MainAxisSize.min,
//         children: [
//           Row(
//             children: [
//               Icon(iconData, size: 20, color: _primaryColor),
//               const SizedBox(width: 8),
//               Expanded(
//                 child: Text(
//                   title,
//                   style: TextStyle(
//                     fontSize: 13,
//                     color: _accentColor,
//                     fontWeight: FontWeight.w600,
//                   ),
//                   overflow: TextOverflow.ellipsis,
//                 ),
//               ),
//             ],
//           ),
//           const SizedBox(height: 8),
//           Text(
//             value,
//             style: TextStyle(
//               fontWeight: FontWeight.bold,
//               fontSize: 18,
//               color: _textColorPrimary,
//             ),
//             overflow: TextOverflow.ellipsis,
//           ),
//         ],
//       ),
//     );
//   }

//   String _formatScore(double? score) {
//     return score?.toStringAsFixed(1) ?? 'N/A';
//   }

//   Color _getHealthStatusColor(String healthStatus) {
//     switch (healthStatus.toLowerCase()) {
//       case 'healthy':
//         return Colors.green.shade600;
//       case 'moderate':
//         return Colors.orange.shade700;
//       case 'unhealthy':
//         return Colors.red.shade700;
//       case 'dying':
//         return Colors.red.shade900;
//       default:
//         return _textColorSecondary;
//     }
//   }

//   Future<void> _pickAndProcessImage(ImageSource source) async {
//     if (_isImageProcessing) return; // prevent double tap

//     try {
//       setState(() {
//         _isImageProcessing = true;
//       });

//       final XFile? pickedFile = await _picker.pickImage(source: source);
//       if (pickedFile == null) {
//         _stopImageLoader();
//         return;
//       }

//       final bytes = await File(pickedFile.path).readAsBytes();

//       final compressedBytes = await compute(compressInIsolate, bytes);

//       if (!mounted) return;

//       setState(() {
//         _selectedImageBytes = compressedBytes;
//         _identificationResult = null;
//         _errorMessage = null;
//         _isImageProcessing = false;
//       });

//       debugPrint(
//         '📷 Image size: ${(compressedBytes.lengthInBytes / 1024).toStringAsFixed(1)} KB',
//       );
//     } catch (e, stack) {
//       debugPrint('❌ Image pick failed: $e');
//       debugPrint('📌 Stack trace:\n$stack');

//       if (mounted) {
//         setState(() {
//           _isImageProcessing = false;
//         });
//       }

//       AppToast.error("Image pick failed");
//     }
//   }

//   void _stopImageLoader() {
//     if (mounted) {
//       setState(() {
//         _isImageProcessing = false;
//       });
//     }
//   }

//   Future<void> _pickImageFromGallery() async {
//     await _pickAndProcessImage(ImageSource.gallery);
//   }

//   Future<void> _takePhoto() async {
//     await _pickAndProcessImage(ImageSource.camera);
//   }

//   DateTime? _lastRequestTime;
//   DateTime? _lastGeminiCallTime;
//   Timer? _geminiDebounceTimer;

//   static const Duration _geminiThrottleDuration = Duration(seconds: 20);

//   static const Duration _geminiDebounceDuration = Duration(milliseconds: 800);

//   Future<void> _identifyPlant() async {
//     if (_isProcessing) return;
//     if (_selectedImageBytes == null) return;

//     if (_lastRequestTime != null &&
//         DateTime.now().difference(_lastRequestTime!) <
//             const Duration(seconds: 10)) {
//       setState(() {
//         _errorMessage = 'Please wait a few seconds before trying again.';
//       });
//       return;
//     }

//     _lastRequestTime = DateTime.now();

//     setState(() {
//       _isProcessing = true;
//       _errorMessage = null;
//       _identificationResult = null;
//     });

//     final String base64Image = base64Encode(_selectedImageBytes!);
//     final String mimeType = _getMimeType(_selectedImageBytes!);

//     try {
//       final response = await http
//           .post(
//             Uri.parse('https://api.openai.com/v1/chat/completions'),
//             headers: {
//               'Authorization': 'Bearer $apiKey',
//               'Content-Type': 'application/json',
//             },
//             body: jsonEncode({
//               "model": "gpt-4o",
//               "messages": [
//                 {
//                   "role": "user",
//                   "content": [
//                     {
//                       "type": "text",
//                       "text":
//                           "Analyze this plant image thoroughly.\n\n"
//                           "IMPORTANT OUTPUT RULES (MANDATORY):\n"
//                           "- Return ONLY valid JSON\n"
//                           "- Do NOT include markdown, explanations, or comments\n"
//                           "- Do NOT include line breaks inside string values\n"
//                           "- All string values MUST be single-line\n"
//                           "- Escape quotes properly\n"
//                           "- If unsure, keep text short and simple\n"
//                           "- If a value cannot be determined, return null\n"
//                           "- Arrays must always be arrays, not strings\n\n"
//                           "Return a comprehensive analysis inferred ONLY from the image and general botanical knowledge.\n\n"
//                           "CORE ANALYSIS:\n"
//                           "- Plant species (scientific name if possible)\n"
//                           "- Health status (healthy/moderate/unhealthy/dying)\n"
//                           "- Confidence score (0-1)\n"
//                           "- Detailed description (single line, max 300 characters)\n"
//                           "- 3-5 personalized care tips (single-line items)\n\n"
//                           "PLANT CHARACTERISTICS:\n"
//                           "- Common name\n"
//                           "- Scientific name\n"
//                           "- Plant family\n"
//                           "- Native region\n"
//                           "- Category (houseplant, tree, herb, etc.)\n"
//                           "- Growth habit (upright, bushy, creeping, etc.)\n"
//                           "- Natural habitat\n"
//                           "- Leaf shape\n"
//                           "- Growth pattern\n"
//                           "- Best use (indoor decor, medicinal, air purification, etc.)\n"
//                           "- Benefits (array of short items)\n\n"
//                           "ENVIRONMENT & CARE DATA:\n"
//                           "- Water needs (0-10)\n"
//                           "- Water notes\n"
//                           "- Sunlight needs (0-10)\n"
//                           "- Sunlight notes\n"
//                           "- Growth rate (0-10)\n"
//                           "- Toxicity level (0-10)\n"
//                           "- Bloom time (if applicable)\n"
//                           "- Preferred soil type\n"
//                           "- Temperature range\n"
//                           "- Temperature notes\n"
//                           "- Humidity level\n"
//                           "- Humidity notes\n"
//                           "- Fertilizer frequency\n"
//                           "- Fertilizer notes\n"
//                           "- Common issues (array)\n\n"
//                           "UI INSIGHTS FOR HEALTH DASHBOARD:\n"
//                           "- Health summary (overall label + short message)\n"
//                           "- Pattern insights (watering, sunlight, or growth-related patterns)\n"
//                           "- Care effectiveness (status of watering, sunlight, soil)\n"
//                           "- Suggestions to improve growth (actionable, concise)\n\n"
//                           "PLANT GROWTH PROGRESS DATA:\n"
//                           "Generate progress data inferred from the current condition and typical growth behavior of the plant.\n"
//                           "Do NOT use fixed dates or hardcoded values.\n"
//                           "All values must be logically consistent and dynamically generated.\n"
//                           "- Growth duration must reflect realistic biological growth for the identified plant species\n"
//                           "- Dynamically choose time units such as days, weeks, or months based on actual plant growth speed\n"
//                           "- Fast-growing plants should favor days or weeks, slow-growing plants should favor weeks or months\n"
//                           "- Growth stages must represent real horticultural development stages such as seedling, acclimation, vegetative growth, branching, flowering, or maturity\n"
//                           "- Timeline date labels must be relative (for example Day X, Week Y, Month Z) and chosen dynamically\n"
//                           "- Timeline events must align logically with the total days_tracked value\n"
//                           "- Growth chart trends must be biologically plausible, showing gradual growth and slowing near maturity\n\n"
//                           "Progress data must include:\n"
//                           "- Overall growth status label\n"
//                           "- Total estimated days tracked (integer)\n"
//                           "- Growth timeline events (chronological, concise)\n"
//                           "- Growth chart data showing trends over time\n\n"
//                           "ROUTINE & REMINDER DATA (FOR DAILY CARE UI):\n"
//                           "Generate routine data suitable for a plant care dashboard.\n"
//                           "This data must be consistent with the analysis above and inferred logically.\n"
//                           "Rules:\n"
//                           "- Keep text short and UI-friendly\n"
//                           "- Do NOT repeat long explanations\n"
//                           "- Tasks must be actionable and realistic\n"
//                           "- Dates must be relative, not fixed calendar dates\n"
//                           "Generate:\n"
//                           "- routine_status: must be one of [Healthy, Attention, Critical]\n"
//                           "- maintenance_level: one of [Low Maintenance, Medium Maintenance, High Maintenance]\n"
//                           "- today_task: a single most important task for today\n"
//                           "- ai_tip: one concise helpful tip (max 120 characters)\n"
//                           "Routine timeline:\n"
//                           "- 2-4 routine timeline items\n"
//                           "- Each item must include title, subtitle, and isCompleted boolean\n"
//                           "Upcoming care:\n"
//                           "- 2–3 upcoming care items\n"
//                           "- Each item must include:\n"
//                           "- title\n"
//                           "- subtitle\n"
//                           "- timeframe\n"
//                           "- icon\n"
//                           "- The \"icon\" field MUST be a single emoji character\n"
//                           "- Use only emojis such as ☀️ 💧 🌱 🍃 🧪\n"
//                           "- Do NOT return words for icon\n"
//                           "- Do NOT return null or empty values\n\n"
//                           "- Return valid JSON only, no explanations"
//                           "Return ONLY a valid JSON object in this EXACT structure:\n"
//                           "{\n"
//                           "  \"species\": \"string\",\n"
//                           "  \"health_status\": \"string\",\n"
//                           "  \"confidence\": number,\n"
//                           "  \"description\": \"string\",\n"
//                           "  \"care_tips\": [\"string\"],\n\n"
//                           "  \"common_name\": \"string\",\n"
//                           "  \"scientific_name\": \"string\",\n"
//                           "  \"family\": \"string\",\n"
//                           "  \"native_region\": \"string\",\n\n"
//                           "  \"category\": \"string\",\n"
//                           "  \"growth_habit\": \"string\",\n"
//                           "  \"natural_habitat\": \"string\",\n"
//                           "  \"leaf_shape\": \"string\",\n"
//                           "  \"growth_pattern\": \"string\",\n"
//                           "  \"best_for\": \"string\",\n"
//                           "  \"benefits\": [\"string\"],\n\n"
//                           "  \"water_needs\": number,\n"
//                           "  \"water_notes\": \"string\",\n"
//                           "  \"sunlight_needs\": number,\n"
//                           "  \"sunlight_notes\": \"string\",\n"
//                           "  \"growth_rate\": number,\n"
//                           "  \"toxicity_level\": number,\n"
//                           "  \"bloom_time\": \"string\",\n"
//                           "  \"soil_type\": \"string\",\n\n"
//                           "  \"temperature_range\": \"string\",\n"
//                           "  \"temperature_notes\": \"string\",\n"
//                           "  \"humidity_level\": \"string\",\n"
//                           "  \"humidity_notes\": \"string\",\n"
//                           "  \"fertilizer_frequency\": \"string\",\n"
//                           "  \"fertilizer_notes\": \"string\",\n"
//                           "  \"common_issues\": [\"string\"],\n\n"
//                           "  \"ui_insights\": {\n"
//                           "    \"health_summary\": {\n"
//                           "      \"overall_health\": \"string\",\n"
//                           "      \"message\": \"string\"\n"
//                           "    },\n"
//                           "    \"pattern_insights\": [\n"
//                           "      {\n"
//                           "        \"type\": \"string\",\n"
//                           "        \"icon\": \"string\",\n"
//                           "        \"message\": \"string\"\n"
//                           "      }\n"
//                           "    ],\n"
//                           "    \"care_effectiveness\": {\n"
//                           "      \"watering\": \"string\",\n"
//                           "      \"sunlight\": \"string\",\n"
//                           "      \"soil\": \"string\"\n"
//                           "    },\n"
//                           "    \"growth_suggestions\": [\"string\"]\n"
//                           "  },\n\n"
//                           "  \"growth_progress\": {\n"
//                           "    \"overall_status\": \"string\",\n"
//                           "    \"days_tracked\": number,\n"
//                           "    \"timeline\": [\n"
//                           "      {\n"
//                           "        \"date\": \"string\",\n"
//                           "        \"title\": \"string\",\n"
//                           "        \"status\": \"string\"\n"
//                           "      }\n"
//                           "    ],\n"
//                           "    \"chart\": {\n"
//                           "      \"labels\": [\"string\"],\n"
//                           "      \"height\": [number],\n"
//                           "      \"leaves\": [number]\n"
//                           "    }\n"
//                           "  },\n\n"
//                           "  \"routine\": {\n"
//                           "    \"routine_status\": \"string\",\n"
//                           "    \"maintenance_level\": \"string\",\n"
//                           "    \"today_task\": \"string\",\n"
//                           "    \"ai_tip\": \"string\",\n"
//                           "    \"timeline\": [\n"
//                           "      {\n"
//                           "        \"title\": \"string\",\n"
//                           "        \"subtitle\": \"string\",\n"
//                           "        \"isCompleted\": boolean\n"
//                           "      }\n"
//                           "    ],\n"
//                           "    \"upcoming_care\": [\n"
//                           "      {\n"
//                           "        \"title\": \"string\",\n"
//                           "        \"subtitle\": \"string\",\n"
//                           "        \"timeframe\": \"string\"\n"
//                           "     \"icon\": \"emoji\"\n"
//                           "      }\n"
//                           "    ]\n"
//                           "  }\n"
//                           "}",
//                     },
//                     {
//                       "type": "image_url",
//                       "image_url": {
//                         "url": "data:$mimeType;base64,$base64Image",
//                         "detail": "auto",
//                       },
//                     },
//                   ],
//                 },
//               ],
//               "max_completion_tokens": 5000,
//             }),
//           )
//           .timeout(const Duration(seconds: 45));

//       if (response.statusCode == 429) {
//         throw Exception('RATE_LIMIT');
//       }
//       if (response.statusCode == 400) {
//         print("----->${response.toString()}");
//         throw Exception('OpenAI failed');
//       }

//       if (response.statusCode != 200) {
//         throw Exception('OpenAI failed');
//       }

//       _handleAiResponse(response.body);
//     } catch (openAiError) {
//       if (openAiError.toString().contains('RATE_LIMIT')) {
//         setState(() {
//           _errorMessage =
//               'Too many requests. Please wait a few seconds and try again.';
//         });
//         return;
//       }

//       debugPrint('OpenAI failed → switching to Gemini$openAiError');

//       try {
//         if (_lastGeminiCallTime != null &&
//             DateTime.now().difference(_lastGeminiCallTime!) <
//                 _geminiThrottleDuration) {
//           setState(() {
//             _errorMessage = 'Please wait a few seconds before retrying.';
//           });
//           return;
//         }

//         if (_geminiDebounceTimer?.isActive ?? false) {
//           return;
//         }
//         _geminiDebounceTimer = Timer(_geminiDebounceDuration, () {});
//         _lastGeminiCallTime = DateTime.now();
//         final response = await http
//             .post(
//               Uri.parse(
//                 'https://generativelanguage.googleapis.com/v1beta/models/'
//                 'gemini-2.5-flash-preview-09-2025:generateContent',
//               ),
//               headers: {
//                 'Content-Type': 'application/json',
//                 'X-goog-api-key': geminiApiKey,
//               },
//               body: jsonEncode({
//                 "contents": [
//                   {
//                     "parts": [
//                       {
// "text":
//     "Analyze this plant image thoroughly.\n\n"
//     "IMPORTANT OUTPUT RULES (MANDATORY):\n"
//     "- Return ONLY valid JSON\n"
//     "- Do NOT include markdown, explanations, or comments\n"
//     "- Do NOT include line breaks inside string values\n"
//     "- All string values MUST be single-line\n"
//     "- Escape quotes properly\n"
//     "- If unsure, keep text short and simple\n"
//     "- If a value cannot be determined, return null\n"
//     "- Arrays must always be arrays, not strings\n\n"
//     "Return a comprehensive analysis inferred ONLY from the image and general botanical knowledge.\n\n"
//     "CORE ANALYSIS:\n"
//     "- Plant species (scientific name if possible)\n"
//     "- Health status (healthy/moderate/unhealthy/dying)\n"
//     "- Confidence score (0-1)\n"
//     "- Detailed description (single line, max 300 characters)\n"
//     "- 3-5 personalized care tips (single-line items)\n\n"
//     "PLANT CHARACTERISTICS:\n"
//     "- Common name\n"
//     "- Scientific name\n"
//     "- Plant family\n"
//     "- Native region\n"
//     "- Category (houseplant, tree, herb, etc.)\n"
//     "- Growth habit (upright, bushy, creeping, etc.)\n"
//     "- Natural habitat\n"
//     "- Leaf shape\n"
//     "- Growth pattern\n"
//     "- Best use (indoor decor, medicinal, air purification, etc.)\n"
//     "- Benefits (array of short items)\n\n"
//     "ENVIRONMENT & CARE DATA:\n"
//     "- Water needs (0-10)\n"
//     "- Water notes\n"
//     "- Sunlight needs (0-10)\n"
//     "- Sunlight notes\n"
//     "- Growth rate (0-10)\n"
//     "- Toxicity level (0-10)\n"
//     "- Bloom time (if applicable)\n"
//     "- Preferred soil type\n"
//     "- Temperature range\n"
//     "- Temperature notes\n"
//     "- Humidity level\n"
//     "- Humidity notes\n"
//     "- Fertilizer frequency\n"
//     "- Fertilizer notes\n"
//     "- Common issues (array)\n\n"
//     "UI INSIGHTS FOR HEALTH DASHBOARD:\n"
//     "- Health summary (overall label + short message)\n"
//     "- Pattern insights (watering, sunlight, or growth-related patterns)\n"
//     "- Care effectiveness (status of watering, sunlight, soil)\n"
//     "- Suggestions to improve growth (actionable, concise)\n\n"
//     "PLANT GROWTH PROGRESS DATA:\n"
//     "Generate progress data inferred from the current condition and typical growth behavior of the plant.\n"
//     "Do NOT use fixed dates or hardcoded values.\n"
//     "All values must be logically consistent and dynamically generated.\n"
//     "- Growth duration must reflect realistic biological growth for the identified plant species\n"
//     "- Dynamically choose time units such as days, weeks, or months based on actual plant growth speed\n"
//     "- Fast-growing plants should favor days or weeks, slow-growing plants should favor weeks or months\n"
//     "- Growth stages must represent real horticultural development stages such as seedling, acclimation, vegetative growth, branching, flowering, or maturity\n"
//     "- Timeline date labels must be relative (for example Day X, Week Y, Month Z) and chosen dynamically\n"
//     "- Timeline events must align logically with the total days_tracked value\n"
//     "- Growth chart trends must be biologically plausible, showing gradual growth and slowing near maturity\n\n"
//     "Progress data must include:\n"
//     "- Overall growth status label\n"
//     "- Total estimated days tracked (integer)\n"
//     "- Growth timeline events (chronological, concise)\n"
//     "- Growth chart data showing trends over time\n\n"
//     "ROUTINE & REMINDER DATA (FOR DAILY CARE UI):\n"
//     "Generate routine data suitable for a plant care dashboard.\n"
//     "This data must be consistent with the analysis above and inferred logically.\n"
//     "Rules:\n"
//     "- Keep text short and UI-friendly\n"
//     "- Do NOT repeat long explanations\n"
//     "- Tasks must be actionable and realistic\n"
//     "- Dates must be relative, not fixed calendar dates\n"
//     "Generate:\n"
//     "- routine_status: must be one of [Healthy, Attention, Critical]\n"
//     "- maintenance_level: one of [Low Maintenance, Medium Maintenance, High Maintenance]\n"
//     "- today_task: a single most important task for today\n"
//     "- ai_tip: one concise helpful tip (max 120 characters)\n"
//     "Routine timeline:\n"
//     "- 2-4 routine timeline items\n"
//     "- Each item must include title, subtitle, and isCompleted boolean\n"
//     "Upcoming care:"
//     "- 2–3 upcoming care items"
//     "- Each item must include:"
//     "  - title"
//     "  - subtitle"
//     "  - timeframe"
//     "  - icon"
//     ""
//     "- The \"icon\" field MUST be a single emoji character"
//     "- Use only emojis such as: ☀️ 💧 🌱 🍃 🧪"
//     "- Do NOT return words like \"sun\", \"water\", or \"growth\" for icon"
//     "- Do NOT return null or empty values"
//     "- Return valid JSON only, no explanations"
//     "Return ONLY a valid JSON object in this EXACT structure:\n"
//     "{\n"
//     "  \"species\": \"string\",\n"
//     "  \"health_status\": \"string\",\n"
//     "  \"confidence\": number,\n"
//     "  \"description\": \"string\",\n"
//     "  \"care_tips\": [\"string\"],\n\n"
//     "  \"common_name\": \"string\",\n"
//     "  \"scientific_name\": \"string\",\n"
//     "  \"family\": \"string\",\n"
//     "  \"native_region\": \"string\",\n\n"
//     "  \"category\": \"string\",\n"
//     "  \"growth_habit\": \"string\",\n"
//     "  \"natural_habitat\": \"string\",\n"
//     "  \"leaf_shape\": \"string\",\n"
//     "  \"growth_pattern\": \"string\",\n"
//     "  \"best_for\": \"string\",\n"
//     "  \"benefits\": [\"string\"],\n\n"
//     "  \"water_needs\": number,\n"
//     "  \"water_notes\": \"string\",\n"
//     "  \"sunlight_needs\": number,\n"
//     "  \"sunlight_notes\": \"string\",\n"
//     "  \"growth_rate\": number,\n"
//     "  \"toxicity_level\": number,\n"
//     "  \"bloom_time\": \"string\",\n"
//     "  \"soil_type\": \"string\",\n\n"
//     "  \"temperature_range\": \"string\",\n"
//     "  \"temperature_notes\": \"string\",\n"
//     "  \"humidity_level\": \"string\",\n"
//     "  \"humidity_notes\": \"string\",\n"
//     "  \"fertilizer_frequency\": \"string\",\n"
//     "  \"fertilizer_notes\": \"string\",\n"
//     "  \"common_issues\": [\"string\"],\n\n"
//     "  \"ui_insights\": {\n"
//     "    \"health_summary\": {\n"
//     "      \"overall_health\": \"string\",\n"
//     "      \"message\": \"string\"\n"
//     "    },\n"
//     "    \"pattern_insights\": [\n"
//     "      {\n"
//     "        \"type\": \"string\",\n"
//     "        \"icon\": \"string\",\n"
//     "        \"message\": \"string\"\n"
//     "      }\n"
//     "    ],\n"
//     "    \"care_effectiveness\": {\n"
//     "      \"watering\": \"string\",\n"
//     "      \"sunlight\": \"string\",\n"
//     "      \"soil\": \"string\"\n"
//     "    },\n"
//     "    \"growth_suggestions\": [\"string\"]\n"
//     "  },\n\n"
//     "  \"growth_progress\": {\n"
//     "    \"overall_status\": \"string\",\n"
//     "    \"days_tracked\": number,\n"
//     "    \"timeline\": [\n"
//     "      {\n"
//     "        \"date\": \"string\",\n"
//     "        \"title\": \"string\",\n"
//     "        \"status\": \"string\"\n"
//     "      }\n"
//     "    ],\n"
//     "    \"chart\": {\n"
//     "      \"labels\": [\"string\"],\n"
//     "      \"height\": [number],\n"
//     "      \"leaves\": [number]\n"
//     "    }\n"
//     "  },\n\n"
//     "  \"routine\": {\n"
//     "    \"routine_status\": \"string\",\n"
//     "    \"maintenance_level\": \"string\",\n"
//     "    \"today_task\": \"string\",\n"
//     "    \"ai_tip\": \"string\",\n"
//     "    \"timeline\": [\n"
//     "      {\n"
//     "        \"title\": \"string\",\n"
//     "        \"subtitle\": \"string\",\n"
//     "        \"isCompleted\": boolean\n"
//     "      }\n"
//     "    ],\n"
//     "    \"upcoming_care\": [\n"
//     "      {\n"
//     "        \"title\": \"string\",\n"
//     "        \"subtitle\": \"string\",\n"
//     "        \"timeframe\": \"string\"\n"
//     "     \"icon\": \"emoji\"\n"
//     "      }\n"
//     "    ]\n"
//     "  }\n"
//     "}",
//                       },
//                       {
//                         "inline_data": {
//                           "mime_type": mimeType,
//                           "data": base64Image,
//                         },
//                       },
//                     ],
//                   },
//                 ],
//                 "generationConfig": {
//                   "temperature": 0.2,
//                   "maxOutputTokens": 6000,
//                 },
//               }),
//             )
//             .timeout(const Duration(seconds: 90));

//         if (response.statusCode == 429) {
//           throw Exception('RATE_LIMIT');
//         }
//         if (response.statusCode == 400) {
//           print("----->${response.body}");
//           throw Exception('Gemini failed');
//         }
//         if (response.statusCode != 200) {
//           print("----->${response.body}");
//           throw Exception('Gemini failed');
//         }

//         final decoded = jsonDecode(response.body);
//         print("----->$decoded");
//         final content = decoded['candidates'][0]['content']['parts'][0]['text'];

//         _handleCleanedContent(content);
//       } catch (error) {
//         print("------->${error.toString()}");
//         if (mounted) {
//           setState(() {
//             _errorMessage =
//                 'Both OpenAI and Gemini failed. Please try again later.';
//           });
//         }
//       }
//     } finally {
//       if (mounted) {
//         setState(() {
//           _isProcessing = false;
//         });
//       }
//     }
//   }

//   void _handleAiResponse(String body) {
//     final jsonResponse = jsonDecode(body);
//     print("----->$jsonResponse");
//     final content = jsonResponse['choices'][0]['message']['content'];
//     _handleCleanedContent(content);
//   }

//   void _handleCleanedContent(String content) {
//     String cleaned = content.trim();
//     print("Cleaned Content-Raw: $cleaned");

//     if (cleaned.startsWith('```')) {
//       cleaned = cleaned.replaceAll(RegExp(r'```(json)?'), '').trim();
//     }
//     print("Cleaned Content: $cleaned");
//     final resultJson = jsonDecode(cleaned);
//     print("Cleaned Content: $resultJson");
//     if (mounted) {
//       setState(() {
//         _identificationResult = PlantIdentificationResult.fromJson(resultJson);
//       });
//     }

//     final provider = Provider.of<PlantIdentificationProvider>(
//       context,
//       listen: false,
//     );

//     provider.saveIdentification(
//       _identificationResult!.species,
//       _selectedImageBytes!,
//       cleaned,
//       plantType: _selectedPlantType,
//       healthStatus: _identificationResult!.healthStatus,
//     );
//   }

//   String _getMimeType(Uint8List bytes) {
//     if (bytes.length >= 8) {
//       if (bytes[0] == 0xFF && bytes[1] == 0xD8) return 'image/jpeg';
//       if (bytes[0] == 0x89 &&
//           bytes[1] == 0x50 &&
//           bytes[2] == 0x4E &&
//           bytes[3] == 0x47) {
//         return 'image/png';
//       }
//     }
//     return 'image/jpeg';
//   }

//   Widget _buildPlantTypeCard(
//     String label,
//     String imagePath,
//     String type,
//     BuildContext context,
//     final Function(String)? onPlantTypeSelected,
//   ) {
//     final isSelected = _selectedPlantType == type;
//     final screenWidth = MediaQuery.of(context).size.width;

//     return GestureDetector(
//       onTap: () => onPlantTypeSelected?.call(type),
//       child: SizedBox(
//         width: screenWidth * 0.27,
//         child: Card(
//           elevation: isSelected ? 1 : 1,
//           color:
//               isSelected
//                   ? PlantIdentificationScreen._appBarTitleColor
//                   : Colors.white,
//           shape: RoundedRectangleBorder(
//             borderRadius: BorderRadius.circular(12),
//             // side: BorderSide(
//             //   color: AppColors.primarySwatch[700] ?? Colors.grey.shade300,
//             //   width: isSelected ? 2 : 1,
//             // ),
//           ),
//           child: Column(
//             mainAxisAlignment: MainAxisAlignment.start,
//             children: [
//               AspectRatio(
//                 aspectRatio: 1,
//                 child: Padding(
//                   padding: const EdgeInsets.all(6),
//                   child: ClipRRect(
//                     borderRadius: BorderRadius.circular(10),
//                     child: Image.asset(imagePath, fit: BoxFit.cover),
//                   ),
//                 ),
//               ),

//               const SizedBox(height: 4),

//               Padding(
//                 padding: const EdgeInsets.symmetric(horizontal: 6),
//                 child: Text(
//                   label,
//                   textAlign: TextAlign.center,
//                   maxLines: 1,
//                   overflow: TextOverflow.ellipsis,
//                   style: TextStyle(
//                     fontSize: 13,
//                     fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
//                     color: isSelected ? Colors.white : Colors.black87,
//                   ),
//                 ),
//               ),

//               const SizedBox(height: 6),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }

// class CornerBracketPainter extends CustomPainter {
//   final bool isTop;
//   final bool isLeft;
//   final Color color;

//   CornerBracketPainter({
//     required this.isTop,
//     required this.isLeft,
//     required this.color,
//   });

//   @override
//   void paint(Canvas canvas, Size size) {
//     final paint =
//         Paint()
//           ..color = color
//           ..strokeWidth = 3
//           ..style = PaintingStyle.stroke
//           ..strokeCap = StrokeCap.round;

//     final path = Path();

//     if (isTop && isLeft) {
//       path.moveTo(size.width, 0);
//       path.lineTo(0, 0);
//       path.lineTo(0, size.height);
//     } else if (isTop && !isLeft) {
//       path.moveTo(0, 0);
//       path.lineTo(size.width, 0);
//       path.lineTo(size.width, size.height);
//     } else if (!isTop && isLeft) {
//       path.moveTo(0, 0);
//       path.lineTo(0, size.height);
//       path.lineTo(size.width, size.height);
//     } else {
//       path.moveTo(0, size.height);
//       path.lineTo(size.width, size.height);
//       path.lineTo(size.width, 0);
//     }

//     canvas.drawPath(path, paint);
//   }

//   @override
//   bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
// }

// Future<Uint8List> compressImageTo150KB(Uint8List originalBytes) async {
//   img.Image? image = img.decodeImage(originalBytes);
//   if (image == null) return originalBytes;

//   if (image.width > 1024) {
//     image = img.copyResize(image, width: 1024);
//   }

//   int quality = 90;
//   Uint8List compressed;

//   do {
//     compressed = Uint8List.fromList(img.encodeJpg(image, quality: quality));
//     quality -= 5;
//   } while (compressed.lengthInBytes > 150 * 1024 && quality > 40);

//   return compressed;
// }

// Uint8List compressImageIsolate(Uint8List originalBytes) {
//   img.Image? image = img.decodeImage(originalBytes);
//   if (image == null) return originalBytes;

//   if (image.width > 1024) {
//     image = img.copyResize(image, width: 1024);
//   }

//   int quality = 90;
//   Uint8List compressed;

//   do {
//     compressed = Uint8List.fromList(img.encodeJpg(image, quality: quality));
//     quality -= 5;
//   } while (compressed.lengthInBytes > 150 * 1024 && quality > 40);

//   return compressed;
// }

// Future<Uint8List> compressImageBelow60KB(Uint8List originalBytes) async {
//   img.Image? image = img.decodeImage(originalBytes);
//   if (image == null) return originalBytes;

//   int quality = 95;
//   Uint8List compressed = Uint8List.fromList(
//     img.encodeJpg(image, quality: quality),
//   );

//   while (compressed.lengthInBytes > 60 * 1024 && quality > 30) {
//     quality -= 3;
//     compressed = Uint8List.fromList(img.encodeJpg(image, quality: quality));
//   }

//   debugPrint(
//     '[IMG_COMPRESS] final=${compressed.lengthInBytes ~/ 1024}KB '
//     'quality=$quality '
//     'size=${image.width}x${image.height}',
//   );

//   return compressed;
// }

// Uint8List compressInIsolate(Uint8List bytes) {
//   final image = img.decodeImage(bytes);
//   if (image == null) return bytes;

//   int quality = 90;
//   Uint8List result = bytes;

//   while (quality >= 20) {
//     result = Uint8List.fromList(img.encodeJpg(image, quality: quality));

//     if (result.lengthInBytes <= 150 * 1024) {
//       break;
//     }
//     quality -= 10;
//   }

//   return result;
// }

// final String getPlantDataPrompt = '''
// "Analyze this plant image thoroughly."

// "IMPORTANT OUTPUT RULES (MANDATORY):"
// "- Return ONLY valid JSON"
// "- Do NOT include markdown, explanations, or comments"
// "- Do NOT include line breaks inside string values"
// "- All string values MUST be single-line"
// "- Escape quotes properly"
// "- If unsure, keep text short and simple"
// "- If a value cannot be determined, return null"
// "- Arrays must always be arrays, not strings"

// "Return a comprehensive analysis inferred ONLY from the image and general botanical knowledge."

// "CORE ANALYSIS:"
// "- Plant species (scientific name if possible)"
// "- Health status (healthy/moderate/unhealthy/dying)"
// "- Confidence score (0-1)"
// "- Detailed description (single line, max 300 characters)"
// "- 3-5 personalized care tips (single-line items)"

// "PLANT CHARACTERISTICS:"
// "- Common name"
// "- Scientific name"
// "- Plant family"
// "- Native region"
// "- Category (houseplant, tree, herb, etc.)"
// "- Growth habit (upright, bushy, creeping, etc.)"
// "- Natural habitat"
// "- Leaf shape"
// "- Growth pattern"
// "- Best use (indoor decor, medicinal, air purification, etc.)"
// "- Benefits (array of short items)"

// "ENVIRONMENT & CARE DATA:"
// "- Water needs (0-10)"
// "- Water notes"
// "- Sunlight needs (0-10)"
// "- Sunlight notes"
// "- Growth rate (0-10)"
// "- Toxicity level (0-10)"
// "- Bloom time (if applicable)"
// "- Preferred soil type"
// "- Temperature range"
// "- Temperature notes"
// "- Humidity level"
// "- Humidity notes"
// "- Fertilizer frequency"
// "- Fertilizer notes"
// "- Common issues (array)"

// "UI INSIGHTS FOR HEALTH DASHBOARD:"
// "- Health summary (overall label + short message)"
// "- Pattern insights (watering, sunlight, or growth-related patterns)"
// "- Care effectiveness (status of watering, sunlight, soil)"
// "- Suggestions to improve growth (actionable, concise)"

// "PLANT GROWTH PROGRESS DATA:"
// "- Generate realistic, biologically plausible growth progress"
// "- Use relative time labels (Day X, Week Y, Month Z)"
// "- Growth stages must match real horticultural stages"

// "ROUTINE & REMINDER DATA:"
// "- routine_status: Healthy | Attention | Critical"
// "- maintenance_level: Low | Medium | High Maintenance"
// "- today_task: one most important task"
// "- ai_tip: max 120 characters"
// "- Icons must be a single emoji only (☀️ 💧 🌱 🍃 🧪)"

// "Return ONLY a valid JSON object in this EXACT structure:"
// {
//   "species": "string",
//   "health_status": "string",
//   "confidence": number,
//   "description": "string",
//   "care_tips": ["string"],

//   "common_name": "string",
//   "scientific_name": "string",
//   "family": "string",
//   "native_region": "string",

//   "category": "string",
//   "growth_habit": "string",
//   "natural_habitat": "string",
//   "leaf_shape": "string",
//   "growth_pattern": "string",
//   "best_for": "string",
//   "benefits": ["string"],

//   "water_needs": number,
//   "water_notes": "string",
//   "sunlight_needs": number,
//   "sunlight_notes": "string",
//   "growth_rate": number,
//   "toxicity_level": number,
//   "bloom_time": "string",
//   "soil_type": "string",

//   "temperature_range": "string",
//   "temperature_notes": "string",
//   "humidity_level": "string",
//   "humidity_notes": "string",
//   "fertilizer_frequency": "string",
//   "fertilizer_notes": "string",
//   "common_issues": ["string"],

//   "ui_insights": {
//     "health_summary": {
//       "overall_health": "string",
//       "message": "string"
//     },
//     "pattern_insights": [
//       {
//         "type": "string",
//         "icon": "emoji",
//         "message": "string"
//       }
//     ],
//     "care_effectiveness": {
//       "watering": "string",
//       "sunlight": "string",
//       "soil": "string"
//     },
//     "growth_suggestions": ["string"]
//   },

//   "growth_progress": {
//     "overall_status": "string",
//     "days_tracked": number,
//     "timeline": [
//       {
//         "date": "string",
//         "title": "string",
//         "status": "string"
//       }
//     ],
//     "chart": {
//       "labels": ["string"],
//       "height": [number],
//       "leaves": [number]
//     }
//   },

//   "routine": {
//     "routine_status": "string",
//     "maintenance_level": "string",
//     "today_task": "string",
//     "ai_tip": "string",
//     "timeline": [
//       {
//         "title": "string",
//         "subtitle": "string",
//         "isCompleted": boolean
//       }
//     ],
//     "upcoming_care": [
//       {
//         "title": "string",
//         "subtitle": "string",
//         "timeframe": "string",
//         "icon": "emoji"
//       }
//     ]
//   }
// }
// ''';
import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:aiplantidentifier/core/config.dart';
import 'package:aiplantidentifier/utils/app_Toast.dart';
import 'package:aiplantidentifier/utils/app_colors.dart';
import 'package:aiplantidentifier/views/mainscrens/mainscreen.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:image/image.dart' as img;
import '../../models/hyderation.dart';
import '../../providers/analyze.dart';

class PlantIdentificationScreen extends StatelessWidget {
  const PlantIdentificationScreen({super.key});

  static const Color _scaffoldBackgroundColor = const Color.fromARGB(
    205,
    255,
    255,
    255,
  );
  static const Color _appBarTitleColor = Color(0xFF2E7D32); // Dark Green

  @override
  Widget build(BuildContext context) {
    return Scaffold(
     // drawer: AnimatedAppDrawer(rootContext: context),
      drawer: TelegramStyleDrawer(rootContext: context,),
      backgroundColor: _scaffoldBackgroundColor,
      appBar: AppBar(
        elevation: 0,
        title: const Text(
          'AI Plant Identifier',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
        ),
        actions: [],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(
          horizontal: _getHorizontalPadding(context),
          vertical: 12.0,
        ),
        child: const PlantIdentificationModule(),
      ),
    );
  }

  static double _getHorizontalPadding(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width > 1200) return 48;
    if (width > 800) return 32;
    return 20;
  }
}

class PlantIdentificationModule extends StatefulWidget {
  const PlantIdentificationModule({super.key});

  @override
  State<PlantIdentificationModule> createState() =>
      _PlantIdentificationModuleState();
}

class _PlantIdentificationModuleState extends State<PlantIdentificationModule> {
  static const Color _primaryColor = Color(0xFF4CAF50); // Green
  static const Color _lightPrimaryColor = Color(0xFFC8E6C9); // Green 100
  static const Color _accentColor = Color(0xFF2E7D32); // Dark Green
  static const Color _cardBackgroundColor = Colors.white;
  static const Color _textColorPrimary = Color(0xFF333333);
  static const Color _textColorSecondary = Color(0xFF666666);
  static const Color _iconColorActive = _primaryColor;
  static const Color _iconColorInactive = Colors.grey;
  static const Color _errorColor = Color(0xFFD32F2F);
  static const Color _errorBackgroundColor = Color(0xFFFFEBEE);

  Uint8List? _selectedImageBytes;
  bool _isProcessing = false;
  String? _errorMessage;
  PlantIdentificationResult? _identificationResult;
  final ImagePicker _picker = ImagePicker();
  String? _selectedPlantType;
  bool _isImageProcessing = false;
  late final ScrollController _plantTypeScrollController;

  @override
  void initState() {
    super.initState();
    _plantTypeScrollController = ScrollController();
  }

  @override
  void dispose() {
    _plantTypeScrollController.dispose();
    super.dispose();
  }

  final List<Map<String, String>> plantTypes = [
    {'title': 'Indoor', 'image': 'images/indoorimg.png', 'type': 'indoor'},
    {'title': 'Outdoor', 'image': 'images/outdoorimg.png', 'type': 'outdoor'},
    {
      'title': 'Succulent',
      'image': 'images/Succulentimg.png',
      'type': 'succulent',
    },
    {
      'title': 'Flowering',
      'image': 'images/Floweringimg.png',
      'type': 'flowering',
    },
    {'title': 'vegetable', 'image': "images/vege.png", 'type': 'vegetable'},
    {'title': 'Herbs', 'image': "images/herbs.png", 'type': 'herbs'},
    {'title': 'Trees', 'image': 'images/tree.png', 'type': 'trees'},
    {'title': 'Shrub', 'image': 'images/shurub.png', 'type': 'Shrub'},
    {'title': 'Fern', 'image': 'images/fern.png', 'type': 'fern'},
    {'title': 'Others', 'image': 'images/othertype.png', 'type': 'Others'},
  ];
  Set<String> get _allowedPlantTypes {
    return plantTypes.map((e) => e['type']!.toLowerCase()).toSet();
  }

  void _scrollToSelectedPlantType(BuildContext context, bool isTablet) {
    if (_selectedPlantType == null) return;

    final int index = plantTypes.indexWhere(
      (e) => e['type']!.toLowerCase() == _selectedPlantType!.toLowerCase(),
    );

    if (index == -1) return;

    final double itemWidth = isTablet ? 140 : 100; // controls “4 visible”
    final double screenWidth = MediaQuery.of(context).size.width;

    final double targetOffset =
        (index * itemWidth) - (screenWidth / 2) + (itemWidth / 2);

    _plantTypeScrollController.animateTo(
      targetOffset.clamp(
        0.0,
        _plantTypeScrollController.position.maxScrollExtent,
      ),
      duration: const Duration(milliseconds: 350),
      curve: Curves.easeOutCubic,
    );
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final screenWidth = MediaQuery.of(context).size.width;
        final screenHeight = MediaQuery.of(context).size.height;
        final isTablet = screenWidth > 800;
        final isLargeTablet = screenWidth > 1200;

        return SingleChildScrollView(
          child: Stack(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildPlantTypeSection(context, isTablet),

                  const SizedBox(height: 20),

                  _buildImagePreviewSection(context, screenWidth, isTablet),

                  const SizedBox(height: 12),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "Position the leaf inside the frame",
                        style: TextStyle(
                          color: Colors.black87,
                          fontSize: isTablet ? 16 : 14,
                        ),
                      ),
                      SizedBox(width: isTablet ? 12 : 8),
                      Icon(
                        Icons.eco,
                        color: AppColors.primaryColor,
                        size: isTablet ? 24 : 20,
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  _buildImagePickerButtons(context, isTablet),

                  const SizedBox(height: 16),

                  _buildIdentifyButton(context, isTablet),

                  if (_errorMessage != null) ...[
                    const SizedBox(height: 12),
                    _buildErrorMessage(),
                  ],

                  if (_identificationResult != null) ...[
                    const SizedBox(height: 16),
                    _buildResultsCard(),
                  ],

                  const SizedBox(height: 24),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildPlantTypeSection(BuildContext context, bool isTablet) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'Select Your Plant type',
          style: TextStyle(
            fontSize: isTablet ? 18 : 16,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),

        const SizedBox(height: 16),

        SizedBox(
          height: isTablet ? 180 : 140,
          child: ListView.builder(
            controller: _plantTypeScrollController, // ✅ important
            scrollDirection: Axis.horizontal,
            itemCount: plantTypes.length,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            itemBuilder: (context, index) {
              final item = plantTypes[index];

              return SizedBox(
                width: isTablet ? 140 : 100, // ✅ ~4 visible
                child: _buildPlantTypeCard(
                  item['title']!,
                  item['image']!,
                  item['type']!,
                  context,
                  isTablet,
                  (type) {
                    setState(() {
                      _selectedPlantType = type.toLowerCase();
                    });

                    _scrollToSelectedPlantType(context, isTablet);
                  },
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildImagePreviewSection(
    BuildContext context,
    double screenWidth,
    bool isTablet,
  ) {
    final imageSize = _getImagePreviewSize(screenWidth, isTablet);

    return Center(
      child:
          _selectedImageBytes != null
              ? _buildSelectedImagePreview(imageSize)
              : _buildPlaceholderPreview(imageSize),
    );
  }

  double _getImagePreviewSize(double screenWidth, bool isTablet) {
    if (screenWidth > 1200) return 320;
    if (screenWidth > 800) return 280;
    if (screenWidth > 600) return 260;
    return 220;
  }

  Widget _buildSelectedImagePreview(double size) {
    return ConstrainedBox(
      constraints: BoxConstraints(
        minWidth: size,
        minHeight: size,
        maxWidth: size,
        maxHeight: size,
      ),
      child: AspectRatio(
        aspectRatio: 1,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(15),
          child: Image.memory(_selectedImageBytes!, fit: BoxFit.cover),
        ),
      ),
    );
  }

  Widget _buildPlaceholderPreview(double size) {
    return ConstrainedBox(
      constraints: BoxConstraints(
        minWidth: size,
        minHeight: size,
        maxWidth: size,
        maxHeight: size,
      ),
      child: AspectRatio(
        aspectRatio: 1,
        child: Container(
          decoration: BoxDecoration(
            color: const Color(0xFFE8F5E9),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Stack(
            children: [
              Positioned(
                top: 20,
                left: 20,
                child: _buildCornerBracket(true, true),
              ),
              Positioned(
                top: 20,
                right: 20,
                child: _buildCornerBracket(true, false),
              ),
              Positioned(
                bottom: 20,
                left: 20,
                child: _buildCornerBracket(false, true),
              ),
              Positioned(
                bottom: 20,
                right: 20,
                child: _buildCornerBracket(false, false),
              ),
              Center(
                child:
                    _isImageProcessing
                        ? const SizedBox(
                          width: 48,
                          height: 48,
                          child: CircularProgressIndicator(
                            strokeWidth: 3,
                            valueColor: AlwaysStoppedAnimation(
                              Color(0xFF2D5F3F),
                            ),
                          ),
                        )
                        : Icon(
                          Icons.camera_alt,
                          size: 56,
                          color: const Color(0xFF2D5F3F).withOpacity(0.4),
                        ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildImagePickerButtons(BuildContext context, bool isTablet) {
    final buttonHeight = isTablet ? 56.0 : 48.0;
    final fontSize = isTablet ? 16.0 : 14.0;

    return Row(
      children: [
        Expanded(
          child: _buildImageButton(
            onPressed: _takePhoto,
            icon: Icons.camera_alt,
            label: 'Camera',
            height: buttonHeight,
            fontSize: fontSize,
          ),
        ),
        SizedBox(width: isTablet ? 16 : 12),
        Expanded(
          child: _buildImageButton(
            onPressed: _pickImageFromGallery,
            icon: Icons.photo_library,
            label: 'Gallery',
            height: buttonHeight,
            fontSize: fontSize,
          ),
        ),
      ],
    );
  }

  Widget _buildImageButton({
    required VoidCallback onPressed,
    required IconData icon,
    required String label,
    required double height,
    required double fontSize,
  }) {
    return OutlinedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, size: fontSize + 2),
      label: Text(label, style: TextStyle(fontSize: fontSize)),
      style: ButtonStyle(
        backgroundColor: WidgetStateProperty.resolveWith<Color>((states) {
          if (states.contains(WidgetState.pressed)) {
            return AppColors.primaryColor;
          }
          return AppColors.galaryColor;
        }),
        foregroundColor: WidgetStateProperty.resolveWith<Color>((states) {
          if (states.contains(WidgetState.pressed)) {
            return Colors.white;
          }
          return const Color(0xFF2D5F3F);
        }),
        side: WidgetStateProperty.all(BorderSide.none),
        padding: WidgetStateProperty.all(
          EdgeInsets.symmetric(vertical: height / 3),
        ),
        shape: WidgetStateProperty.all(
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        ),
      ),
    );
  }

  Widget _buildIdentifyButton(BuildContext context, bool isTablet) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed:
            _selectedImageBytes != null && !_isProcessing
                ? () {
                  _identifyPlant(isTablet);
                }
                : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color.fromARGB(255, 34, 84, 52),
          disabledBackgroundColor: Colors.green.shade300,
          disabledForegroundColor: Colors.white70,
          padding: EdgeInsets.symmetric(
            vertical: MediaQuery.of(context).size.width > 800 ? 14 : 12,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(25),
          ),
        ),
        child:
            _isProcessing
                ? SizedBox(
                  height: 24,
                  width: 24,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: AppColors.primarySwatch,
                  ),
                )
                : Text(
                  'Identify Plant',
                  style: TextStyle(
                    fontSize: MediaQuery.of(context).size.width > 800 ? 18 : 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
      ),
    );
  }

  Widget _buildErrorMessage() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: _errorBackgroundColor,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: _errorColor.withAlpha((0.7 * 255).toInt())),
      ),
      child: Row(
        children: [
          Icon(Icons.error_outline, color: _errorColor, size: 22),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              _errorMessage!,
              style: TextStyle(
                color: _errorColor,
                fontWeight: FontWeight.w500,
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResultsCard() {
    return Card(
      elevation: 3.0,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.0)),
      color: _cardBackgroundColor,
      child: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Plant Identification Results',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: _accentColor,
              ),
            ),
            const SizedBox(height: 5),

            _buildInfoRow(
              Icons.nature_outlined,
              'Species',
              _identificationResult!.species,
              valueWeight: FontWeight.w600,
            ),
            _buildInfoRow(
              Icons.nature_outlined,
              'Plant Type',
              _identificationResult!.plant_type ?? "Unknown",
              valueWeight: FontWeight.w600,
            ),
            _buildInfoRow(
              Icons.health_and_safety_outlined,
              'Health',
              _identificationResult!.healthStatus,
              valueColor: _getHealthStatusColor(
                _identificationResult!.healthStatus,
              ),
              valueWeight: FontWeight.w600,
            ),
            _buildInfoRow(
              Icons.verified_user_outlined,
              'Confidence',
              '${(_identificationResult!.confidence * 100).toStringAsFixed(1)}%',
              valueWeight: FontWeight.w500,
            ),
            if (_identificationResult!.commonName != null)
              _buildInfoRow(
                Icons.label_outlined,
                'Common Name',
                _identificationResult!.commonName!,
              ),
            Divider(height: 36, thickness: 0.8, color: Colors.grey.shade200),

            Text(
              'Plant Characteristics:',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
                color: _textColorPrimary,
              ),
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              alignment: WrapAlignment.start,
              children: [
                if (_identificationResult!.scientificName != null)
                  _buildMetricCard(
                    'Scientific Name',
                    _identificationResult!.scientificName!,
                    Icons.science_outlined,
                  ),
                if (_identificationResult!.family != null)
                  _buildMetricCard(
                    'Family',
                    _identificationResult!.family!,
                    Icons.family_restroom_outlined,
                  ),
                if (_identificationResult!.nativeRegion != null)
                  _buildMetricCard(
                    'Native Region',
                    _identificationResult!.nativeRegion!,
                    Icons.public_outlined,
                  ),
                if (_identificationResult!.waterNeeds != null)
                  _buildMetricCard(
                    'Water Needs',
                    '${_formatScore(_identificationResult!.waterNeeds)}/10',
                    Icons.water_drop_outlined,
                  ),
                if (_identificationResult!.sunlightNeeds != null)
                  _buildMetricCard(
                    'Sunlight Needs',
                    '${_formatScore(_identificationResult!.sunlightNeeds)}/10',
                    Icons.wb_sunny_outlined,
                  ),
                if (_identificationResult!.growthRate != null)
                  _buildMetricCard(
                    'Growth Rate',
                    '${_formatScore(_identificationResult!.growthRate)}/10',
                    Icons.trending_up_outlined,
                  ),
                if (_identificationResult!.toxicityLevel != null)
                  _buildMetricCard(
                    'Toxicity',
                    '${_formatScore(_identificationResult!.toxicityLevel)}/10',
                    Icons.warning_amber_outlined,
                  ),
                if (_identificationResult!.bloomTime != null)
                  _buildMetricCard(
                    'Bloom Time',
                    _identificationResult!.bloomTime!,
                    Icons.calendar_today_outlined,
                  ),
                if (_identificationResult!.soilType != null)
                  _buildMetricCard(
                    'Soil Type',
                    _identificationResult!.soilType!,
                    Icons.terrain_outlined,
                  ),
              ],
            ),

            Divider(height: 36, thickness: 0.8, color: Colors.grey.shade200),

            Text(
              'Description:',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 17,
                color: _textColorPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _identificationResult!.description,
              style: TextStyle(
                color: _textColorSecondary,
                fontSize: 15,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Care Tips:',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 17,
                color: _textColorPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children:
                  _identificationResult!.careTips
                      .map(
                        (tip) => Padding(
                          padding: const EdgeInsets.symmetric(vertical: 6.0),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Icon(
                                Icons.check_circle_outline,
                                color: _primaryColor,
                                size: 20,
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  tip,
                                  style: TextStyle(
                                    color: _textColorSecondary,
                                    fontSize: 15,
                                    height: 1.5,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      )
                      .toList(),
            ),
          ],
        ),
      ),
    );
  }

  // Widget _buildResultsCard(
  //   BuildContext context,
  //   bool isTablet,
  //   bool isLargeTablet,
  // ) {
  //   return Card(
  //     elevation: 3.0,
  //     margin: EdgeInsets.zero,
  //     shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.0)),
  //     color: _cardBackgroundColor,
  //     child: Padding(
  //       padding: EdgeInsets.all(isTablet ? 20.0 : 16.0),
  //       child: Column(
  //         crossAxisAlignment: CrossAxisAlignment.start,
  //         children: [
  //           Text(
  //             'Plant Identification Results',
  //             style: Theme.of(context).textTheme.titleLarge?.copyWith(
  //               fontWeight: FontWeight.bold,
  //               color: _accentColor,
  //               fontSize: isTablet ? 20 : 18,
  //             ),
  //           ),
  //           const SizedBox(height: 12),
  //           _buildInfoRow(
  //             Icons.nature_outlined,
  //             'Species',
  //             _identificationResult!.species,
  //             valueWeight: FontWeight.w600,
  //           ),
  //           _buildInfoRow(
  //             Icons.health_and_safety_outlined,
  //             'Health',
  //             _identificationResult!.healthStatus,
  //             valueColor: _getHealthStatusColor(
  //               _identificationResult!.healthStatus,
  //             ),
  //             valueWeight: FontWeight.w600,
  //           ),
  //           _buildInfoRow(
  //             Icons.verified_user_outlined,
  //             'Confidence',
  //             '${(_identificationResult!.confidence * 100).toStringAsFixed(1)}%',
  //             valueWeight: FontWeight.w500,
  //           ),
  //           if (_identificationResult!.commonName != null)
  //             _buildInfoRow(
  //               Icons.label_outlined,
  //               'Common Name',
  //               _identificationResult!.commonName!,
  //             ),
  //           Divider(height: 32, thickness: 0.8, color: Colors.grey.shade200),
  //           Text(
  //             'Plant Characteristics:',
  //             style: TextStyle(
  //               fontWeight: FontWeight.bold,
  //               fontSize: isTablet ? 18 : 16,
  //               color: _textColorPrimary,
  //             ),
  //           ),
  //           const SizedBox(height: 16),
  //           _buildCharacteristicsGrid(context, isTablet, isLargeTablet),
  //           Divider(height: 32, thickness: 0.8, color: Colors.grey.shade200),
  //           Text(
  //             'Description:',
  //             style: TextStyle(
  //               fontWeight: FontWeight.bold,
  //               fontSize: isTablet ? 18 : 16,
  //               color: _textColorPrimary,
  //             ),
  //           ),
  //           const SizedBox(height: 12),
  //           Text(
  //             _identificationResult!.description,
  //             style: TextStyle(
  //               color: _textColorSecondary,
  //               fontSize: isTablet ? 16 : 14,
  //               height: 1.6,
  //             ),
  //           ),
  //           const SizedBox(height: 20),
  //           Text(
  //             'Care Tips:',
  //             style: TextStyle(
  //               fontWeight: FontWeight.bold,
  //               fontSize: isTablet ? 18 : 16,
  //               color: _textColorPrimary,
  //             ),
  //           ),
  //           const SizedBox(height: 12),
  //           _buildCareTips(isTablet),
  //         ],
  //       ),
  //     ),
  //   );
  // }

  Widget _buildCharacteristicsGrid(
    BuildContext context,
    bool isTablet,
    bool isLargeTablet,
  ) {
    final itemsPerRow = isLargeTablet ? 3 : (isTablet ? 2 : 1);

    final characteristics = [
      if (_identificationResult!.scientificName != null)
        _CharacteristicItem(
          'Scientific Name',
          _identificationResult!.scientificName!,
          Icons.science_outlined,
        ),
      if (_identificationResult!.family != null)
        _CharacteristicItem(
          'Family',
          _identificationResult!.family!,
          Icons.family_restroom_outlined,
        ),
      if (_identificationResult!.nativeRegion != null)
        _CharacteristicItem(
          'Native Region',
          _identificationResult!.nativeRegion!,
          Icons.public_outlined,
        ),
      if (_identificationResult!.waterNeeds != null)
        _CharacteristicItem(
          'Water Needs',
          '${_formatScore(_identificationResult!.waterNeeds)}/10',
          Icons.water_drop_outlined,
        ),
      if (_identificationResult!.sunlightNeeds != null)
        _CharacteristicItem(
          'Sunlight Needs',
          '${_formatScore(_identificationResult!.sunlightNeeds)}/10',
          Icons.wb_sunny_outlined,
        ),
      if (_identificationResult!.growthRate != null)
        _CharacteristicItem(
          'Growth Rate',
          '${_formatScore(_identificationResult!.growthRate)}/10',
          Icons.trending_up_outlined,
        ),
      if (_identificationResult!.toxicityLevel != null)
        _CharacteristicItem(
          'Toxicity',
          '${_formatScore(_identificationResult!.toxicityLevel)}/10',
          Icons.warning_amber_outlined,
        ),
      if (_identificationResult!.bloomTime != null)
        _CharacteristicItem(
          'Bloom Time',
          _identificationResult!.bloomTime!,
          Icons.calendar_today_outlined,
        ),
      if (_identificationResult!.soilType != null)
        _CharacteristicItem(
          'Soil Type',
          _identificationResult!.soilType!,
          Icons.terrain_outlined,
        ),
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: itemsPerRow,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 1.2,
      ),
      itemCount: characteristics.length,
      itemBuilder: (context, index) {
        final item = characteristics[index];
        return _buildMetricCard(item.title, item.value, item.icon);
      },
    );
  }

  Widget _buildCareTips(bool isTablet) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children:
          _identificationResult!.careTips
              .map(
                (tip) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(
                        Icons.check_circle_outline,
                        color: _primaryColor,
                        size: isTablet ? 24 : 20,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          tip,
                          style: TextStyle(
                            color: _textColorSecondary,
                            fontSize: isTablet ? 16 : 14,
                            height: 1.6,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              )
              .toList(),
    );
  }

  Widget _buildCornerBracket(bool isTop, bool isLeft) {
    return SizedBox(
      width: 30,
      height: 30,
      child: CustomPaint(
        painter: CornerBracketPainter(
          isTop: isTop,
          isLeft: isLeft,
          color: const Color(0xFF2D5F3F),
        ),
      ),
    );
  }

  Widget _buildInfoRow(
    IconData icon,
    String label,
    String value, {
    Color? valueColor,
    FontWeight? valueWeight,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: _iconColorActive, size: 22),
          const SizedBox(width: 12),
          Text(
            '$label: ',
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              color: _textColorPrimary,
              fontSize: 15,
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontSize: 15,
                color: valueColor ?? _textColorSecondary,
                fontWeight: valueWeight ?? FontWeight.normal,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMetricCard(String title, String value, IconData iconData) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      decoration: BoxDecoration(
        color: _lightPrimaryColor.withAlpha((0.28 * 255).toInt()),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: _lightPrimaryColor.withAlpha((0.7 * 255).toInt()),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Icon(iconData, size: 18, color: _primaryColor),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 12,
                    color: _accentColor,
                    fontWeight: FontWeight.w600,
                  ),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
              color: _textColorPrimary,
            ),
            overflow: TextOverflow.ellipsis,
            maxLines: 2,
          ),
        ],
      ),
    );
  }

  String _formatScore(double? score) {
    return score?.toStringAsFixed(1) ?? 'N/A';
  }

  Color _getHealthStatusColor(String healthStatus) {
    switch (healthStatus.toLowerCase()) {
      case 'healthy':
        return Colors.green.shade600;
      case 'moderate':
        return Colors.orange.shade700;
      case 'unhealthy':
        return Colors.red.shade700;
      case 'dying':
        return Colors.red.shade900;
      default:
        return _textColorSecondary;
    }
  }

  Future<void> _pickAndProcessImage(ImageSource source) async {
    if (_isImageProcessing) return;

    try {
      setState(() {
        _isImageProcessing = true;
        _errorMessage = null;
      });

      final XFile? pickedFile = await _picker.pickImage(source: source);
      if (pickedFile == null) {
        _stopImageLoader();
        return;
      }

      final bytes = await File(pickedFile.path).readAsBytes();
      final compressedBytes = await compute(compressInIsolate, bytes);

      if (!mounted) return;

      setState(() {
        _selectedImageBytes = compressedBytes;
        _identificationResult = null;
        _errorMessage = null;
        _isImageProcessing = false;
      });

      debugPrint(
        '📷 Image size: ${(compressedBytes.lengthInBytes / 1024).toStringAsFixed(1)} KB',
      );
    } catch (e, stack) {
      debugPrint('❌ Image pick failed: $e');
      debugPrint('📌 Stack trace:\n$stack');

      if (mounted) {
        setState(() {
          _isImageProcessing = false;
          _errorMessage = 'Failed to load image. Please try again.';
        });
      }

      AppToast.error("Image pick failed");
    }
  }

  void _stopImageLoader() {
    if (mounted) {
      setState(() {
        _isImageProcessing = false;
      });
    }
  }

  Future<void> _pickImageFromGallery() async {
    await _pickAndProcessImage(ImageSource.gallery);
  }

  Future<void> _takePhoto() async {
    await _pickAndProcessImage(ImageSource.camera);
  }

  DateTime? _lastRequestTime;
  DateTime? _lastGeminiCallTime;
  Timer? _geminiDebounceTimer;

  static const Duration _geminiThrottleDuration = Duration(seconds: 20);
  static const Duration _geminiDebounceDuration = Duration(milliseconds: 800);

  Future<void> _identifyPlant(bool isTablet) async {
    if (_isProcessing) return;
    if (_selectedImageBytes == null) return;

    if (_lastRequestTime != null &&
        DateTime.now().difference(_lastRequestTime!) <
            const Duration(seconds: 10)) {
      setState(() {
        _errorMessage = 'Please wait a few seconds before trying again.';
      });
      return;
    }

    _lastRequestTime = DateTime.now();

    setState(() {
      _isProcessing = true;
      _errorMessage = null;
      _identificationResult = null;
    });

    final String base64Image = base64Encode(_selectedImageBytes!);
    final String mimeType = _getMimeType(_selectedImageBytes!);

    try {
      final response = await http
          .post(
            Uri.parse('https://api.openai.com/v1/chat/completions'),
            headers: {
              'Authorization': 'Bearer $apiKey',
              'Content-Type': 'application/json',
            },
            body: jsonEncode({
              "model": "gpt-4o",
              "messages": [
                {
                  "role": "user",
                  "content": [
                    {"type": "text", "text": _buildPrompt()},
                    {
                      "type": "image_url",
                      "image_url": {
                        "url": "data:$mimeType;base64,$base64Image",
                        "detail": "auto",
                      },
                    },
                  ],
                },
              ],
              "max_completion_tokens": 5000,
            }),
          )
          .timeout(const Duration(seconds: 45));

      if (response.statusCode == 429) {
        throw Exception('RATE_LIMIT');
      }
      if (response.statusCode == 400) {
        debugPrint("Error: ${response.toString()}");
        throw Exception('OpenAI failed');
      }
      if (response.statusCode != 200) {
        throw Exception('OpenAI failed');
      }

      _handleAiResponse(response.body, isTablet);
    } catch (openAiError) {
      if (openAiError.toString().contains('RATE_LIMIT')) {
        setState(() {
          _errorMessage =
              'Too many requests. Please wait a few seconds and try again.';
        });
        return;
      }

      debugPrint('OpenAI failed → switching to Gemini: $openAiError');
      await _tryGeminiIdentification(base64Image, mimeType, isTablet);
    } finally {
      if (mounted) {
        setState(() {
          _isProcessing = false;
        });
      }
    }
  }

  Future<void> _tryGeminiIdentification(
    String base64Image,
    String mimeType,
    bool isTablet,
  ) async {
    try {
      if (_lastGeminiCallTime != null &&
          DateTime.now().difference(_lastGeminiCallTime!) <
              _geminiThrottleDuration) {
        setState(() {
          _errorMessage = 'Please wait a few seconds before retrying.';
        });
        return;
      }

      if (_geminiDebounceTimer?.isActive ?? false) {
        return;
      }
      _geminiDebounceTimer = Timer(_geminiDebounceDuration, () {});
      _lastGeminiCallTime = DateTime.now();

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
                    {"text": _buildPrompt()},
                    {
                      "inline_data": {
                        "mime_type": mimeType,
                        "data": base64Image,
                      },
                    },
                  ],
                },
              ],
              "generationConfig": {"temperature": 0.2, "maxOutputTokens": 6000},
            }),
          )
          .timeout(const Duration(seconds: 90));

      if (response.statusCode == 429) {
        throw Exception('RATE_LIMIT');
      }
      if (response.statusCode == 400) {
        debugPrint("Gemini Error: ${response.body}");
        throw Exception('Gemini failed');
      }
      if (response.statusCode != 200) {
        debugPrint("Gemini Error: ${response.body}");
        throw Exception('Gemini failed');
      }

      final decoded = jsonDecode(response.body);
      final content = decoded['candidates'][0]['content']['parts'][0]['text'];
      _handleCleanedContent(content, isTablet);
    } catch (error) {
      debugPrint("Gemini Error: ${error.toString()}");
      if (mounted) {
        setState(() {
          _errorMessage =
              'Both OpenAI and Gemini failed. Please try again later.';
        });
      }
    }
  }

  String _buildPrompt() {
    return """Analyze this plant image thoroughly.

IMPORTANT OUTPUT RULES (MANDATORY):
- Return ONLY valid JSON
- Do NOT include markdown, explanations, or comments
- Do NOT include line breaks inside string values
- All string values MUST be single-line
- Escape quotes properly
- If unsure, keep text short and simple
- If a value cannot be determined, return null
- Arrays must always be arrays, not strings

PLANT TYPE CLASSIFICATION (CRITICAL):
- You MUST classify the plant into ONE of the following types ONLY:
  [indoor, outdoor, succulent, flowering, vegetable, herbs, trees, shrub, fern, others]
- Choose the BEST matching type based ONLY on the image
- If the type cannot be confidently determined, use "others"


Return a comprehensive analysis inferred ONLY from the image and general botanical knowledge.

CORE ANALYSIS:
- Plant species (scientific name if possible)
- Health status (healthy/moderate/unhealthy/dying)
- Confidence score (0-1)
- Detailed description (single line, max 300 characters)
- 3-5 personalized care tips (single-line items)

PLANT CHARACTERISTICS:
- Common name
- Scientific name
- Plant family
- Native region
- Category (houseplant, tree, herb, etc.)
- Growth habit (upright, bushy, creeping, etc.)
- Natural habitat
- Leaf shape
- Growth pattern
- Best use (indoor decor, medicinal, air purification, etc.)
- Benefits (array of short items)

ENVIRONMENT & CARE DATA:
- Water needs (0-10)
- Water notes
- Sunlight needs (0-10)
- Sunlight notes
- Growth rate (0-10)
- Toxicity level (0-10)
- Bloom time (if applicable)
- Preferred soil type
- Temperature range
- Temperature notes
- Humidity level
- Humidity notes
- Fertilizer frequency
- Fertilizer notes
- Common issues (array)

UI INSIGHTS FOR HEALTH DASHBOARD:
- Health summary (overall label + short message)
- Pattern insights (watering, sunlight, or growth-related patterns)
- Care effectiveness (status of watering, sunlight, soil)
- Suggestions to improve growth (actionable, concise)

PLANT GROWTH PROGRESS DATA:
Generate progress data inferred from the current condition and typical growth behavior of the plant.
Do NOT use fixed dates or hardcoded values.
All values must be logically consistent and dynamically generated.
- Growth duration must reflect realistic biological growth for the identified plant species
- Dynamically choose time units such as days, weeks, or months based on actual plant growth speed
- Fast-growing plants should favor days or weeks, slow-growing plants should favor weeks or months
- Growth stages must represent real horticultural development stages such as seedling, acclimation, vegetative growth, branching, flowering, or maturity
- Timeline date labels must be relative (for example Day X, Week Y, Month Z) and chosen dynamically
- Timeline events must align logically with the total days_tracked value
- Growth chart trends must be biologically plausible, showing gradual growth and slowing near maturity

Progress data must include:
- Overall growth status label
- Total estimated days tracked (integer)
- Growth timeline events (chronological, concise)
- Growth chart data showing trends over time

ROUTINE & REMINDER DATA (FOR DAILY CARE UI):
Generate routine data suitable for a plant care dashboard.
This data must be consistent with the analysis above and inferred logically.
Rules:
- Keep text short and UI-friendly
- Do NOT repeat long explanations
- Tasks must be actionable and realistic
- Dates must be relative, not fixed calendar dates

Generate:
- routine_status: must be one of [Healthy, Attention, Critical]
- maintenance_level: one of [Low Maintenance, Medium Maintenance, High Maintenance]
- today_task: a single most important task for today
- ai_tip: one concise helpful tip (max 120 characters)

Routine timeline:
- 2-4 routine timeline items
- Each item must include title, subtitle, and isCompleted boolean

Upcoming care:
- 2-3 upcoming care items
- Each item must include: title, subtitle, timeframe, icon
- The "icon" field MUST be a single emoji character
- Use only emojis such as ☀️ 💧 🌱 🍃 🧪
- Do NOT return words for icon
- Do NOT return null or empty values

Return ONLY a valid JSON object in this EXACT structure:
{
  "species": "string",
  "health_status": "string",
  "confidence": number,
    "plant_type": "string",
  "description": "string",
  "care_tips": ["string"],
  "common_name": "string",
  "scientific_name": "string",
  "family": "string",
  "native_region": "string",
  "category": "string",
  "growth_habit": "string",
  "natural_habitat": "string",
  "leaf_shape": "string",
  "growth_pattern": "string",
  "best_for": "string",
  "benefits": ["string"],
  "water_needs": number,
  "water_notes": "string",
  "sunlight_needs": number,
  "sunlight_notes": "string",
  "growth_rate": number,
  "toxicity_level": number,
  "bloom_time": "string",
  "soil_type": "string",
  "temperature_range": "string",
  "temperature_notes": "string",
  "humidity_level": "string",
  "humidity_notes": "string",
  "fertilizer_frequency": "string",
  "fertilizer_notes": "string",
  "common_issues": ["string"],
  "ui_insights": {
    "health_summary": {
      "overall_health": "string",
      "message": "string"
    },
    "pattern_insights": [
      {
        "type": "string",
        "icon": "string",
        "message": "string"
      }
    ],
    "care_effectiveness": {
      "watering": "string",
      "sunlight": "string",
      "soil": "string"
    },
    "growth_suggestions": ["string"]
  },
  "growth_progress": {
    "overall_status": "string",
    "days_tracked": number,
    "timeline": [
      {
        "date": "string",
        "title": "string",
        "status": "string"
      }
    ],
    "chart": {
      "labels": ["string"],
      "height": [number],
      "leaves": [number]
    }
  },
  "routine": {
    "routine_status": "string",
    "maintenance_level": "string",
    "today_task": "string",
    "ai_tip": "string",
    "timeline": [
      {
        "title": "string",
        "subtitle": "string",
        "isCompleted": boolean
      }
    ],
    "upcoming_care": [
      {
        "title": "string",
        "subtitle": "string",
        "timeframe": "string",
        "icon": "emoji"
      }
    ]
  }
}""";
  }

  void _handleAiResponse(String body, bool isTablet) {
    final jsonResponse = jsonDecode(body);
    debugPrint("AI Response: $jsonResponse");
    final content = jsonResponse['choices'][0]['message']['content'];
    _handleCleanedContent(content, isTablet);
  }

  void _handleCleanedContent(String content, bool isTablet) {
    String cleaned = content.trim();
    debugPrint("Cleaned Content-Raw: $cleaned");

    if (cleaned.startsWith('```')) {
      cleaned = cleaned.replaceAll(RegExp(r'```(json)?'), '').trim();
    }

    debugPrint("Cleaned Content: $cleaned");

    final Map<String, dynamic> resultJson = jsonDecode(cleaned);
    debugPrint("Parsed JSON: $resultJson");

    final String aiPlantType =
        (resultJson['plant_type'] as String?)?.toLowerCase() ?? 'others';

    final double aiPlantTypeConfidence =
        (resultJson['plant_type_confidence'] as num?)?.toDouble() ?? 0.0;

    debugPrint(
      "AI Plant Type → $aiPlantType (confidence: $aiPlantTypeConfidence)",
    );

    if (mounted) {
      setState(() {
        final String normalizedAiType = aiPlantType.toLowerCase();

        _selectedPlantType =
            _allowedPlantTypes.contains(normalizedAiType)
                ? normalizedAiType
                : 'others';

        WidgetsBinding.instance.addPostFrameCallback((_) {
          _scrollToSelectedPlantType(context, isTablet);
        });

        _identificationResult = PlantIdentificationResult.fromJson(resultJson);
      });
    }

    final provider = Provider.of<PlantIdentificationProvider>(
      context,
      listen: false,
    );

    provider.saveIdentification(
      _identificationResult!.species,
      _selectedImageBytes!,
      cleaned,

      plantType: aiPlantType,

      healthStatus: _identificationResult!.healthStatus,
    );
  }

  String _getMimeType(Uint8List bytes) {
    if (bytes.length >= 8) {
      if (bytes[0] == 0xFF && bytes[1] == 0xD8) return 'image/jpeg';
      if (bytes[0] == 0x89 &&
          bytes[1] == 0x50 &&
          bytes[2] == 0x4E &&
          bytes[3] == 0x47) {
        return 'image/png';
      }
    }
    return 'image/jpeg';
  }

  Widget _buildPlantTypeCard(
    String label,
    String imagePath,
    String type,
    BuildContext context,
    bool isTablet,
    final Function(String)? onPlantTypeSelected,
  ) {
    final isSelected = _selectedPlantType?.toLowerCase() == type.toLowerCase();

    return GestureDetector(
      onTap: () => onPlantTypeSelected?.call(type),
      child: Card(
        elevation: isSelected ? 4 : 2,
        color:
            isSelected
                ? PlantIdentificationScreen._appBarTitleColor
                : Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: AspectRatio(
                aspectRatio: 1,
                child: Padding(
                  padding: const EdgeInsets.all(6),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: Image.asset(imagePath, fit: BoxFit.cover),
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
              child: Text(
                label,
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: isTablet ? 13 : 12,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                  color: isSelected ? Colors.white : Colors.black87,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CharacteristicItem {
  final String title;
  final String value;
  final IconData icon;

  _CharacteristicItem(this.title, this.value, this.icon);
}

class CornerBracketPainter extends CustomPainter {
  final bool isTop;
  final bool isLeft;
  final Color color;

  CornerBracketPainter({
    required this.isTop,
    required this.isLeft,
    required this.color,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint =
        Paint()
          ..color = color
          ..strokeWidth = 3
          ..style = PaintingStyle.stroke
          ..strokeCap = StrokeCap.round;

    final path = Path();

    if (isTop && isLeft) {
      path.moveTo(size.width, 0);
      path.lineTo(0, 0);
      path.lineTo(0, size.height);
    } else if (isTop && !isLeft) {
      path.moveTo(0, 0);
      path.lineTo(size.width, 0);
      path.lineTo(size.width, size.height);
    } else if (!isTop && isLeft) {
      path.moveTo(0, 0);
      path.lineTo(0, size.height);
      path.lineTo(size.width, size.height);
    } else {
      path.moveTo(0, size.height);
      path.lineTo(size.width, size.height);
      path.lineTo(size.width, 0);
    }

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// Image Compression Functions

Future<Uint8List> compressImageTo150KB(Uint8List originalBytes) async {
  img.Image? image = img.decodeImage(originalBytes);
  if (image == null) return originalBytes;

  if (image.width > 1024) {
    image = img.copyResize(image, width: 1024);
  }

  int quality = 90;
  Uint8List compressed;

  do {
    compressed = Uint8List.fromList(img.encodeJpg(image, quality: quality));
    quality -= 5;
  } while (compressed.lengthInBytes > 150 * 1024 && quality > 40);

  return compressed;
}

Uint8List compressImageIsolate(Uint8List originalBytes) {
  img.Image? image = img.decodeImage(originalBytes);
  if (image == null) return originalBytes;

  if (image.width > 1024) {
    image = img.copyResize(image, width: 1024);
  }

  int quality = 90;
  Uint8List compressed;

  do {
    compressed = Uint8List.fromList(img.encodeJpg(image, quality: quality));
    quality -= 5;
  } while (compressed.lengthInBytes > 150 * 1024 && quality > 40);

  return compressed;
}

Future<Uint8List> compressImageBelow60KB(Uint8List originalBytes) async {
  img.Image? image = img.decodeImage(originalBytes);
  if (image == null) return originalBytes;

  int quality = 95;
  Uint8List compressed = Uint8List.fromList(
    img.encodeJpg(image, quality: quality),
  );

  while (compressed.lengthInBytes > 60 * 1024 && quality > 30) {
    quality -= 3;
    compressed = Uint8List.fromList(img.encodeJpg(image, quality: quality));
  }

  debugPrint(
    '[IMG_COMPRESS] final=${compressed.lengthInBytes ~/ 1024}KB '
    'quality=$quality '
    'size=${image.width}x${image.height}',
  );

  return compressed;
}

Uint8List compressInIsolate(Uint8List bytes) {
  final image = img.decodeImage(bytes);
  if (image == null) return bytes;

  int quality = 90;
  Uint8List result = bytes;

  while (quality >= 20) {
    result = Uint8List.fromList(img.encodeJpg(image, quality: quality));

    if (result.lengthInBytes <= 150 * 1024) {
      break;
    }
    quality -= 10;
  }

  return result;
}
