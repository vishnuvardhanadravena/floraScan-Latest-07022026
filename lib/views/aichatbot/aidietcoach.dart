import 'dart:convert';
// Explicitly import Uint8List
import 'package:aiplantidentifier/core/config.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:flutter_markdown/flutter_markdown.dart'; // Import flutter_markdown

// Assuming your config.dart looks like this:
// core/config.dart
// const String geminiApiKey = "YOUR_GEMINI_API_KEY";

class AIPlantIdentifierScreen extends StatefulWidget {
  final VoidCallback onClose;

  const AIPlantIdentifierScreen({super.key, required this.onClose});

  @override
  State<AIPlantIdentifierScreen> createState() =>
      _AIPlantIdentifierScreenState();
}

class _AIPlantIdentifierScreenState extends State<AIPlantIdentifierScreen> {
  final TextEditingController _controller = TextEditingController();
  final List<Map<String, dynamic>> messages = [];
  final ScrollController _scrollController = ScrollController();
  bool _isLoading = false;
  bool _showTypingIndicator = false;
  Uint8List? _selectedImageBytesForNextMessage; // Renamed for clarity

  @override
  void initState() {
    super.initState();
    _addWelcomeMessage();
  }

  void _addWelcomeMessage() {
    setState(() {
      messages.add({
        "role": "bot",
        "text":
            "Hello! I'm your Plant Identification Assistant. You can send me a photo of a plant or describe it, and I'll help identify it!",
        "timestamp": DateTime.now(),
      });
    });
    _scrollToBottom();
  }

  Future<String> getPlantIdentificationResponse(
    String? userInput,
    Uint8List? imageBytes,
  ) async {
    if (apiKey.isEmpty) {
      return "API key not configured.";
    }

    String promptText = "";

    if (imageBytes != null && userInput != null && userInput.isNotEmpty) {
      promptText = """
You are a friendly, human-like plant expert chatbot.

CRITICAL RULES (MUST FOLLOW):
- You ONLY talk about plants.
- If the image or text is NOT related to a plant, politely refuse and ask for a plant image or plant question.
- If a plant has already been identified earlier in this conversation:
  - Treat follow-up messages like "tell me more", "how to grow", "watering?", "sunlight?" as questions about THE SAME plant.
  - Do NOT identify a new plant again unless the user provides a NEW plant image or clearly names a DIFFERENT plant.
  - Do NOT reset or change the plant context.

IMAGE HANDLING:
- Carefully look at the provided image.
- If it does NOT show a plant, politely explain you only support plant images.
- If it DOES show a plant:
  - Identify the plant naturally (only once).
  - Remember this plant for future messages unless changed.

USER MESSAGE:
"$userInput"

RESPONSE REQUIREMENTS (ALWAYS INCLUDE):
- Common name and scientific name (naturally, not like a report)
- Key characteristics in simple, conversational language
- How to grow the plant
- Required environment (light, water, soil, climate)
- Care tips only if relevant to the user's question

STYLE:
- Sound like a real human chatting
- Avoid robotic or textbook tone
- Avoid unnecessary bullet points

Do NOT answer anything unrelated to plants.
""";
    } else if (imageBytes != null) {
      promptText = """
You are a friendly, human-like plant expert chatbot.

CRITICAL RULES:
- You ONLY talk about plants.
- If the image does NOT show a plant, politely refuse and ask for a plant image.
- If a plant was already identified earlier, do NOT identify again unless this is a different plant.

IMAGE HANDLING:
- Look at the image carefully.
- If it shows a plant:
  - Identify it naturally (only once).
  - Remember this plant for follow-up questions.

RESPONSE REQUIREMENTS (ALWAYS INCLUDE):
- Common name and scientific name
- What makes the plant recognizable
- How to grow the plant
- Required environment (sunlight, water, soil, temperature)
- Keep the tone warm and human

Do not provide information unrelated to plants.
""";
    } else if (userInput != null && userInput.isNotEmpty) {
      promptText = """
You are a friendly, human-like plant expert chatbot.

CRITICAL RULES:
- You ONLY answer plant-related questions.
- If the message is NOT about plants, politely refuse and ask for a plant image or plant question.
- If the message is vague (example: "tell me more", "explain", "care tips"):
  - Assume the user is asking about the previously identified plant.
  - Do NOT invent or switch plants.

USER MESSAGE:
"$userInput"

IF THE MESSAGE IS ABOUT A PLANT:
- Respond naturally like a human chatting
- Identify the plant only if needed
- Mention common and scientific names casually
- Explain characteristics simply
- Explain how to grow the plant
- Describe the required environment (light, water, soil, climate)
- Give care tips only if helpful

Avoid robotic or textbook-style responses.
""";
    } else {
      return "Please provide a plant image or a plant-related question 🌱";
    }

    try {
      final response = await http.post(
        Uri.parse("https://api.openai.com/v1/chat/completions"),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $apiKey',
        },
        body: jsonEncode({
          "model": "gpt-4o-mini",
          "messages": [
            {
              "role": "system",
              "content":
                  "You are a botany expert assistant that identifies plants accurately.",
            },
            {
              "role": "user",
              "content": [
                {"type": "text", "text": promptText},
                if (imageBytes != null)
                  {
                    "type": "image_url",
                    "image_url": {
                      "url":
                          "data:image/jpeg;base64,${base64Encode(imageBytes)}",
                    },
                  },
              ],
            },
          ],
          "temperature": 0.7,
          "max_tokens": 1024,
        }),
      );

      if (response.statusCode == 200) {
        final decodedBody = utf8.decode(
          response.bodyBytes,
          allowMalformed: false,
        );

        debugPrint('🟢 Full OpenAI response (UTF-8):');
        debugPrint(decodedBody);

        final Map<String, dynamic> data =
            json.decode(decodedBody) as Map<String, dynamic>;

        final dynamic text = data['choices']?[0]?['message']?['content'];

        debugPrint('🟡 Extracted content: $text');

        if (text != null && text.toString().trim().isNotEmpty) {
          debugPrint('✅ Final text returned:\n$text');
          return text.toString();
        } else {
          debugPrint('⚠️ Content is null or empty');
        }
      } else {
        final errorBody = utf8.decode(response.bodyBytes);
        debugPrint('❌ OpenAI error ${response.statusCode}: $errorBody');
      }
    } catch (_) {
      // Handle error silently and fallback to Gemini
    }

    final geminiText = await getGeminiResponse(promptText, imageBytes);
    if (geminiText != null && geminiText.isNotEmpty) {
      return geminiText;
    }

    return "Unable to identify the plant at the moment. Please try again later.";
  }

  Future<String?> getGeminiResponse(
    String promptText,
    Uint8List? imageBytes,
  ) async {
    try {
      final List<Map<String, dynamic>> parts = [];

      parts.add({"text": promptText});

      if (imageBytes != null) {
        parts.add({
          "inlineData": {
            "mimeType": "image/jpeg",
            "data": base64Encode(imageBytes),
          },
        });
      }

      final body = jsonEncode({
        "contents": [
          {"parts": parts},
        ],
      });

      final response = await http.post(
        Uri.parse(
          "https://generativelanguage.googleapis.com/v1beta/models/"
          "gemini-2.5-flash-lite-preview-09-2025:generateContent"
          "?key=$geminiApiKey",
        ),
        headers: {"Content-Type": "application/json"},
        body: body,
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data["candidates"]?[0]?["content"]?["parts"]?[0]?["text"];
      }
    } catch (e) {}

    return null;
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 70,
      maxWidth: 1024,
    );

    if (pickedFile != null) {
      final bytes = await pickedFile.readAsBytes();
      setState(() {
        _selectedImageBytesForNextMessage = bytes;
      });
    }
  }

  void sendMessage() async {
    final userInput = _controller.text.trim();
    final Uint8List? imageToSend = _selectedImageBytesForNextMessage;

    if (userInput.isEmpty && imageToSend == null) return;

    HapticFeedback.lightImpact();

    setState(() {
      messages.add({
        "role": "user",
        "text": userInput.isNotEmpty ? userInput : null,
        "imageBytes": imageToSend,
        "timestamp": DateTime.now(),
      });

      _controller.clear();
      _isLoading = true;
      _showTypingIndicator = true;
      _selectedImageBytesForNextMessage = null;
    });

    _scrollToBottom();

    final botReply = await getPlantIdentificationResponse(
      userInput.isNotEmpty ? userInput : null,
      imageToSend,
    );

    await Future.delayed(Duration(milliseconds: 300 + botReply.length * 10));

    setState(() {
      messages.add({
        "role": "bot",
        "text": botReply,
        "timestamp": DateTime.now(),
      });
      _isLoading = false;
      _showTypingIndicator = false;
    });

    _scrollToBottom();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Widget _buildMessageBubble(Map<String, dynamic> message) {
    final isUser = message['role'] == 'user';
    final timestamp = message['timestamp'] as DateTime;
    final timeString =
        '${timestamp.hour}:${timestamp.minute.toString().padLeft(2, '0')}';

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        mainAxisAlignment:
            isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment:
            isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          if (!isUser)
            Padding(
              padding: const EdgeInsets.only(right: 8.0),
              child: CircleAvatar(
                backgroundColor: Colors.green[100],
                child: Image.asset("images/app_logo.png",height: 50),
               // child: const Icon(Icons.eco, color: Colors.green, size: 20),
              ),
            ),
          Flexible(
            child: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: isUser ? Colors.green : Colors.grey[200],
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(isUser ? 16 : 4),
                  topRight: Radius.circular(isUser ? 16 : 16),
                  bottomLeft: Radius.circular(isUser ? 16 : 16),
                  bottomRight: Radius.circular(isUser ? 4 : 16),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (message['imageBytes'] != null)
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.memory(
                        message['imageBytes'],
                        width: MediaQuery.of(context).size.width * 0.6,
                        fit: BoxFit.cover,
                      ),
                    ),

                  if (message['imageBytes'] != null && message['text'] != null)
                    const SizedBox(height: 8),

                  if (message['text'] != null)
                    isUser
                        ? Text(
                          message['text'],
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                          ),
                        )
                        : MarkdownBody(data: message['text'],
                        styleSheet: MarkdownStyleSheet(
                          p: const TextStyle(color: Colors.black),
                          h1: const TextStyle(color: Colors.black),
                          h2: const TextStyle(color: Colors.black),
                          h3: const TextStyle(color: Colors.black),
                          h4: const TextStyle(color: Colors.black),
                          h5: const TextStyle(color: Colors.black),
                          h6: const TextStyle(color: Colors.black),
                          strong: const TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                          ),
                          em: const TextStyle(color: Colors.black),
                          a: const TextStyle(color: Colors.black),
                        ),
                        selectable: true),
                ],
              ),
            ),
          ),
          if (isUser)
            Padding(
              padding: const EdgeInsets.only(left: 8.0),
              child: CircleAvatar(
                backgroundColor: Colors.green[50],
                child: Icon(
                  Icons.person_outline,
                  color: Colors.green[700],
                  size: 20,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildTypingIndicator() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Padding(
            padding: const EdgeInsets.only(
              right: 8.0,
              bottom: 0,
            ), // Adjusted padding
            child: CircleAvatar(
              backgroundColor: Colors.green[100],
              child: const Icon(Icons.eco, color: Colors.green, size: 20),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 12,
            ), // Adjusted padding
            decoration: BoxDecoration(
              color: Colors.grey[200], // Matched bot bubble color
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(18),
                topRight: Radius.circular(18),
                bottomRight: Radius.circular(18),
                bottomLeft: Radius.circular(4),
              ),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                TypingDot(delay: 0),
                SizedBox(width: 5),
                TypingDot(delay: 200),
                SizedBox(width: 5),
                TypingDot(delay: 400),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // @override
  // Widget build(BuildContext context) {
  //   return Scaffold(
  //     backgroundColor: Colors.white, // Lighter background
  //     appBar: AppBar(
  //       title: const Text(
  //         "Plant AI Assistant",
  //         // style: TextStyle(fontWeight: FontWeight.w500),
  //       ),
  //       // backgroundColor: Colors.green,
  //       // foregroundColor: Colors.white,
  //       elevation: 1,
  //       // centerTitle: true,
  //       leading: IconButton(
  //         iconSize: 20,
  //         icon: const Icon(Icons.arrow_back),
  //         onPressed: widget.onClose,
  //       ),
  //       actions: [
  //         IconButton(
  //           icon: const Icon(Icons.info_outline_rounded),
  //           onPressed: () {
  //             showDialog(
  //               context: context,
  //               builder:
  //                   (context) => AlertDialog(
  //                     title: const Text("About Plant AI"),
  //                     content: const Text(
  //                       "This AI assistant helps identify plants from photos or descriptions. "
  //                       "For critical plant identification (e.g., edible vs. poisonous), always confirm with a human expert.",
  //                     ),
  //                     actions: [
  //                       TextButton(
  //                         onPressed: () => Navigator.pop(context),
  //                         child: const Text(
  //                           "OK",
  //                           style: TextStyle(color: Colors.green),
  //                         ),
  //                       ),
  //                     ],
  //                   ),
  //             );
  //           },
  //         ),
  //       ],
  //     ),
  //     body: Column(
  //       children: [
  //         Expanded(
  //           child: ListView.builder(
  //             controller: _scrollController,
  //             padding: const EdgeInsets.all(16),
  //             itemCount: messages.length + (_showTypingIndicator ? 1 : 0),
  //             itemBuilder: (context, index) {
  //               if (index == messages.length && _showTypingIndicator) {
  //                 return _buildTypingIndicator();
  //               }
  //               if (index < messages.length) {
  //                 return _buildMessageBubble(messages[index]);
  //               }
  //               return const SizedBox.shrink();
  //             },
  //           ),
  //         ),
  //         SafeArea(
  //           top: false,
  //           child: Padding(
  //             padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
  //             child: Row(
  //               children: [
  //                 Expanded(
  //                   child: Card(
  //                     elevation: 12,
  //                     shadowColor: Colors.black54,
  //                     shape: RoundedRectangleBorder(
  //                       borderRadius: BorderRadius.circular(40),
  //                     ),
  //                     clipBehavior: Clip.antiAlias,
  //                     child: Padding(
  //                       padding: const EdgeInsets.symmetric(
  //                         horizontal: 12,
  //                         vertical: 6,
  //                       ),
  //                       child: Row(
  //                         crossAxisAlignment: CrossAxisAlignment.end,
  //                         children: [
  //                           IconButton(
  //                             icon: Icon(
  //                               Icons.camera_alt,
  //                               color: Colors.green.shade600,
  //                             ),
  //                             onPressed: _pickImage,
  //                           ),

  // Expanded(
  //   child: TextField(
  //     controller: _controller,
  //     minLines: 1,
  //     maxLines: 5,
  //     keyboardType: TextInputType.multiline,
  //     textInputAction: TextInputAction.send,
  //     onSubmitted: (_) => sendMessage(),
  //     style: const TextStyle(
  //       color: Colors.black,
  //       fontSize: 16,
  //     ),
  //     decoration: InputDecoration(
  //       hintText:
  //           _selectedImageBytesForNextMessage != null
  //               ? "Add a caption (optional)"
  //               : "Describe or ask...",
  //       hintStyle: TextStyle(
  //         color: Colors.grey.shade400,
  //       ),

  //       filled: false,
  //       fillColor: Colors.transparent,

  //       border: InputBorder.none,
  //       enabledBorder: InputBorder.none,
  //       focusedBorder: InputBorder.none,
  //       disabledBorder: InputBorder.none,
  //       errorBorder: InputBorder.none,
  //       focusedErrorBorder: InputBorder.none,

  //       isDense: true,
  //       contentPadding: const EdgeInsets.symmetric(
  //         vertical: 12,
  //       ),
  //     ),
  //   ),
  // ),

  //                           /// SEND
  //                           Container(
  //                             margin: const EdgeInsets.only(left: 4),
  //                             decoration: const BoxDecoration(
  //                               color: Colors.green,
  //                               shape: BoxShape.circle,
  //                             ),
  //                             child: IconButton(
  //                               icon:
  //                                   _isLoading
  //                                       ? const SizedBox(
  //                                         width: 16,
  //                                         height: 16,
  //                                         child: CircularProgressIndicator(
  //                                           strokeWidth: 2.5,
  //                                           valueColor: AlwaysStoppedAnimation(
  //                                             Colors.white,
  //                                           ),
  //                                         ),
  //                                       )
  //                                       : const Icon(
  //                                         Icons.send_rounded,
  //                                         color: Colors.white,
  //                                         size: 22,
  //                                       ),
  //                               onPressed: _isLoading ? null : sendMessage,
  //                             ),
  //                           ),
  //                         ],
  //                       ),
  //                     ),
  //                   ),
  //                 ),
  //               ],
  //             ),
  //           ),
  //         ),
  //       ],
  //     ),
  //   );
  // }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("Plant AI Assistant"),
        elevation: 1,
        leading: IconButton(
          iconSize: 20,
          icon: const Icon(Icons.arrow_back),
          onPressed: widget.onClose,
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline_rounded),
            onPressed: () {
              showDialog(
                context: context,
                builder:
                    (context) => AlertDialog(
                      title: const Text("About Plant AI"),
                      content: const Text(
                        "This AI assistant helps identify plants from photos or descriptions. "
                        "For critical plant identification (e.g., edible vs. poisonous), "
                        "always confirm with a human expert.",
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text(
                            "OK",
                            style: TextStyle(color: Colors.green),
                          ),
                        ),
                      ],
                    ),
              );
            },
          ),
        ],
      ),

      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(16),
              itemCount: messages.length + (_showTypingIndicator ? 1 : 0),
              itemBuilder: (context, index) {
                if (index == messages.length && _showTypingIndicator) {
                  return _buildTypingIndicator();
                }
                if (index < messages.length) {
                  return _buildMessageBubble(messages[index]);
                }
                return const SizedBox.shrink();
              },
            ),
          ),

          if (_selectedImageBytesForNextMessage != null)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Stack(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.memory(
                        _selectedImageBytesForNextMessage!,
                        width: 120,
                        height: 120,
                        fit: BoxFit.cover,
                      ),
                    ),
                    Positioned(
                      top: 6,
                      right: 6,
                      child: GestureDetector(
                        onTap: () {
                          setState(() {
                            _selectedImageBytesForNextMessage = null;
                          });
                        },
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: const BoxDecoration(
                            color: Colors.black54,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.close,
                            color: Colors.white,
                            size: 16,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

          /// INPUT BAR
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
              child: Row(
                children: [
                  Expanded(
                    child: Card(
                      elevation: 12,
                      shadowColor: Colors.black54,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(40),
                      ),
                      clipBehavior: Clip.antiAlias,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            IconButton(
                              icon: Icon(
                                Icons.camera_alt,
                                color: Colors.green.shade600,
                              ),
                              onPressed: _pickImage,
                            ),

                            Expanded(
                              child: TextField(
                                controller: _controller,
                                minLines: 1,
                                maxLines: 5,
                                keyboardType: TextInputType.multiline,
                                textInputAction: TextInputAction.send,
                                onSubmitted: (_) => sendMessage(),
                                style: const TextStyle(
                                  fontSize: 16,
                                ),
                                decoration: InputDecoration(
                                  hintText:
                                      _selectedImageBytesForNextMessage != null
                                          ? "Add a caption (optional)"
                                          : "Describe or ask...",
                                  hintStyle: TextStyle(
                                    color: Colors.grey.shade400,
                                  ),

                                  filled: false,
                                  fillColor: Colors.transparent,

                                  border: InputBorder.none,
                                  enabledBorder: InputBorder.none,
                                  focusedBorder: InputBorder.none,
                                  disabledBorder: InputBorder.none,
                                  errorBorder: InputBorder.none,
                                  focusedErrorBorder: InputBorder.none,

                                  isDense: true,
                                  contentPadding: const EdgeInsets.symmetric(
                                    vertical: 12,
                                  ),
                                ),
                              ),
                            ),

                            /// SEND BUTTON
                            Container(
                              margin: const EdgeInsets.only(left: 4),
                              decoration: const BoxDecoration(
                                color: Colors.green,
                                shape: BoxShape.circle,
                              ),
                              child: IconButton(
                                icon:
                                    _isLoading
                                        ? const SizedBox(
                                          width: 16,
                                          height: 16,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2.5,
                                            valueColor: AlwaysStoppedAnimation(
                                              Colors.white,
                                            ),
                                          ),
                                        )
                                        : const Icon(
                                          Icons.send_rounded,
                                          color: Colors.white,
                                          size: 22,
                                        ),
                                onPressed: _isLoading ? null : sendMessage,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class TypingDot extends StatefulWidget {
  final int delay;
  const TypingDot({super.key, required this.delay});

  @override
  TypingDotState createState() => TypingDotState();
}

class TypingDotState extends State<TypingDot>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    )..repeat(reverse: true);

    _animation = Tween<double>(begin: 0.3, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInQuad),
    ); // Smoother curve

    Future.delayed(Duration(milliseconds: widget.delay), () {
      if (mounted) _controller.forward();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _animation,
      child: Container(
        width: 7,
        height: 7,
        decoration: BoxDecoration(
          color: Colors.grey[600], // Darker grey for better contrast
          shape: BoxShape.circle,
        ),
      ),
    );
  }
}
