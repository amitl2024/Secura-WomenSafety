import 'package:flutter/material.dart';
import 'package:ai_women_safety/data/services/gemini_services.dart';
import 'package:ai_women_safety/data/services/emotional_support_service.dart';
import 'package:ai_women_safety/data/services/location_service.dart';
import 'package:ai_women_safety/data/services/admin_panel_service.dart';
import 'package:ai_women_safety/data/services/emergency_contact_service.dart';
import 'package:ai_women_safety/data/services/sms_service.dart';
import 'package:ai_women_safety/data/models/emergency_contact.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:telephony/telephony.dart';
import 'package:geolocator/geolocator.dart';
import 'dart:async';
import 'package:ai_women_safety/utils/logger_util.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class Message {
  final String text;
  final bool isUser;
  final DateTime timestamp;

  Message({required this.text, required this.isUser, DateTime? timestamp})
    : timestamp = timestamp ?? DateTime.now();
}

class _ChatScreenState extends State<ChatScreen> with TickerProviderStateMixin {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  List<Message> _messages = [
    Message(
      text:
          "Hi beautiful! 🌸 I'm Luna, your AI safety companion. How are you feeling today? I'm here to support you with anything you need - from safety tips to just having someone to talk to. 💜",
      isUser: false,
    ),
  ];

  bool _isLoading = false;
  bool _loadingHistory = false;
  String? _chatId;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final EmotionalSupportService _emotionalService = EmotionalSupportService();
  late AnimationController _typingAnimationController;
  late Animation<double> _typingAnimation;

  // Quick response suggestions for women's safety
  final List<String> _quickSuggestions = [
    "I need safety tips",
    "How to stay safe at night?",
    "Self-defense advice",
    "Emergency contacts help",
    "I feel unsafe",
    "Mental health support",
    "I'm feeling anxious",
    "Help me calm down",
    "Breathing exercise",
    "I need emotional support",
  ];

  @override
  void initState() {
    super.initState();
    _typingAnimationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _typingAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _typingAnimationController,
        curve: Curves.easeInOut,
      ),
    );
  }

  @override
  void dispose() {
    _typingAnimationController.dispose();
    _scrollController.dispose();
    _controller.dispose();
    super.dispose();
  }

  void _sendMessage([String? predefinedText]) async {
    final text = predefinedText ?? _controller.text.trim();
    if (text.isEmpty) return;

    // Check for special commands
    if (text.toLowerCase().contains('breathing exercise') ||
        text.toLowerCase().contains('help me calm down')) {
      _showBreathingExercise();
      return;
    }

    // Check if user needs immediate support (emergency situation)
    if (_emotionalService.needsImmediateSupport(text)) {
      _handleEmergencyMessage(text);
    }

    setState(() {
      _messages.add(Message(text: text, isUser: true));
      _isLoading = true;
    });

    if (predefinedText == null) {
      _controller.clear();
    }
    _scrollToBottom();

    _typingAnimationController.repeat();

    try {
      if (_chatId == null) {
        _chatId = await _createChatSession(initialPrompt: text);
      }
      await _saveMessage(text: text, isUser: true);

      // For emergency messages, use a pre-defined emergency response
      final reply =
          _emotionalService.needsImmediateSupport(text)
              ? _emotionalService.getEmergencySupportMessage()
              : await fetchGeminiReply(text);
      _typingAnimationController.stop();

      setState(() {
        _messages.add(Message(text: reply, isUser: false));
        _isLoading = false;
      });

      await _saveMessage(text: reply, isUser: false);
      await _updateChatUpdatedAt();
    } catch (e, stackTrace) {
      AppLogger.error("Error sending message", e, stackTrace);
      _typingAnimationController.stop();
      setState(() {
        _messages.add(
          Message(
            text:
                "I'm sorry, I'm having trouble connecting right now. Please try again in a moment. 💜",
            isUser: false,
          ),
        );
        _isLoading = false;
      });
    }
    _scrollToBottom();
  }

  // Chat session management methods
  Future<String> _createChatSession({required String initialPrompt}) async {
    final user = _auth.currentUser;
    if (user == null) return '';

    final chatRef =
        _firestore.collection('users').doc(user.uid).collection('chats').doc();

    final title =
        initialPrompt.length > 30
            ? '${initialPrompt.substring(0, 30)}...'
            : initialPrompt;

    await chatRef.set({
      'title': title,
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    });

    return chatRef.id;
  }

  Future<void> _saveMessage({
    required String text,
    required bool isUser,
  }) async {
    final user = _auth.currentUser;
    if (user == null || _chatId == null) return;

    await _firestore
        .collection('users')
        .doc(user.uid)
        .collection('chats')
        .doc(_chatId)
        .collection('messages')
        .add({
          'text': text,
          'isUser': isUser,
          'timestamp': FieldValue.serverTimestamp(),
        });
  }

  Future<void> _updateChatUpdatedAt() async {
    final user = _auth.currentUser;
    if (user == null || _chatId == null) return;

    await _firestore
        .collection('users')
        .doc(user.uid)
        .collection('chats')
        .doc(_chatId)
        .update({'updatedAt': FieldValue.serverTimestamp()});
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

  void _showBreathingExercise() {
    final exercise = _emotionalService.getBreathingExercise();

    showDialog(
      context: context,
      barrierDismissible: true,
      builder:
          (context) => AlertDialog(
            backgroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            title: Row(
              children: [
                const Icon(Icons.favorite, color: Color(0xFF9C27B0), size: 24),
                const SizedBox(width: 8),
                Text(
                  exercise['name'],
                  style: const TextStyle(
                    color: Color(0xFF2D3748),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  exercise['description'],
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'Let\'s do this together:',
                  style: TextStyle(
                    color: Colors.grey[700],
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 12),
                ...exercise['steps']
                    .map<Widget>(
                      (step) => Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('• ', style: TextStyle(fontSize: 16)),
                            Expanded(
                              child: Text(
                                step,
                                style: TextStyle(
                                  color: Colors.grey[700],
                                  fontSize: 14,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                    .toList(),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFF9C27B0).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.info_outline,
                        color: Color(0xFF9C27B0),
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          exercise['benefit'],
                          style: const TextStyle(
                            color: Color(0xFF9C27B0),
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text(
                  'Close',
                  style: TextStyle(color: Color(0xFF9C27B0)),
                ),
              ),
            ],
          ),
    );
  }

  void _showChatHistory() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _buildChatHistorySheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xFFF8BBD0), // Soft Pink
              Color(0xFFCE93D8), // Lavender
              Color(0xFFFFF3E0), // Peach
              Color(0xFFB3E5FC), // Light Blue
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            stops: [0.0, 0.33, 0.66, 1.0],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              _buildModernHeader(),
              _buildQuickSuggestions(),
              Expanded(child: _buildChatArea()),
              _buildInputArea(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildModernHeader() {
    final width = MediaQuery.of(context).size.width;
    return Container(
      margin: EdgeInsets.fromLTRB(width * 0.05, 16, width * 0.05, 8),
      padding: EdgeInsets.all(width * 0.05),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.95),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          // AI Avatar
          Container(
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF9C27B0), Color(0xFF673AB7)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF9C27B0).withOpacity(0.3),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            padding: EdgeInsets.all(width * 0.03),
            child: const Icon(
              Icons.psychology_rounded,
              color: Colors.white,
              size: 26,
            ),
          ),
          SizedBox(width: width * 0.04),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Luna - AI Companion",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                    color: Color(0xFF2D3748),
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(
                        color: Color(0xFF4CAF50),
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      "Here to support you 💜",
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey[600],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          // History Button
          GestureDetector(
            onTap: _showChatHistory,
            child: Container(
              padding: EdgeInsets.all(width * 0.025),
              decoration: BoxDecoration(
                color: const Color(0xFF00BCD4).withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: const Color(0xFF00BCD4).withOpacity(0.2),
                ),
              ),
              child: const Icon(
                Icons.history,
                color: Color(0xFF00BCD4),
                size: 20,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickSuggestions() {
    if (_messages.length > 1) return const SizedBox.shrink();

    return Container(
      margin: const EdgeInsets.only(left: 20, right: 20, top: 0, bottom: 2),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 4, bottom: 8),
            child: Text(
              "Quick suggestions:",
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.white.withOpacity(0.9),
              ),
            ),
          ),
          SizedBox(
            height: 35,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: _quickSuggestions.length,
              itemBuilder: (context, index) {
                return Container(
                  margin: const EdgeInsets.only(right: 8),
                  child: _buildSuggestionChip(_quickSuggestions[index]),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  // Handle emergency messages by showing a confirmation dialog before sending alert
  void _handleEmergencyMessage(String message) async {
    // Show confirmation dialog before triggering SOS
    showDialog(
      context: context,
      barrierDismissible: false,
      builder:
          (context) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            title: const Row(
              children: [
                Icon(Icons.emergency, color: Colors.red, size: 28),
                SizedBox(width: 12),
                Text("Emergency Alert", style: TextStyle(color: Colors.red)),
              ],
            ),
            content: const Text(
              "I detected that you might be in danger. Would you like me to send an emergency alert with your location to your emergency contacts?",
              style: TextStyle(fontSize: 16),
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: const Text("Cancel"),
              ),
              ElevatedButton(
                onPressed: () async {
                  Navigator.pop(context);
                  _sendEmergencyAlert();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  "Send Alert",
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
    );
  }

  // Send emergency alert to contacts and admin panel
  Future<void> _sendEmergencyAlert() async {
    try {
      _showSnackBar("Sending emergency alert...", Colors.orange);

      // Check SMS permissions first
      bool hasSmsPermission = await checkSmsPermissions();
      if (!hasSmsPermission) {
        _showSnackBar(
          "SMS permission required. Please grant SMS permission to send emergency alerts.",
          Colors.red,
        );
        return;
      }

      // Get current location
      Position? position = await LocationService.getCurrentLocation();
      if (position == null) {
        // Try to refresh location once more
        position = await LocationService.refreshLocation();
        if (position == null) {
          String errorMessage =
              await LocationService.getLocationStatusMessage();
          _showSnackBar(
            "Could not get your location. $errorMessage",
            Colors.red,
          );
          return;
        }
      }

      // Create location string directly from the position
      String locationString =
          "📍 Current Location:\n"
          "Latitude: ${position.latitude.toStringAsFixed(6)}\n"
          "Longitude: ${position.longitude.toStringAsFixed(6)}\n"
          "Accuracy: ${position.accuracy.toStringAsFixed(1)}m\n"
          "Time: ${DateTime.fromMillisecondsSinceEpoch(position.timestamp.millisecondsSinceEpoch).toString().substring(0, 19)}";

      // Create Google Maps URL with better compatibility
      String googleMapsUrl =
          "https://www.google.com/maps/search/?api=1&query=${position.latitude},${position.longitude}";

      // Send alert to admin panel
      try {
        await AdminPanelService.sendEmergencyAlertToPolice(
          position: position,
          locationString: locationString,
          googleMapsUrl: googleMapsUrl,
          additionalInfo: "Emergency alert from chatbot - User in danger",
        );
      } catch (e, stackTrace) {
        AppLogger.error("Failed to send alert to admin panel", e, stackTrace);
      }

      // Fetch emergency contacts
      List<EmergencyContact> contacts =
          await EmergencyContactService.getEmergencyContactsOnce();

      // Send SMS to each contact using the emergency alert SMS service
      if (contacts.isNotEmpty) {
        int successCount = 0;
        int totalContacts = contacts.length;

        for (final contact in contacts) {
          if (contact.phoneNumber.isNotEmpty) {
            try {
              await sendEmergencyAlertSMS(
                contact.phoneNumber,
                "User",
                locationString,
                googleMapsUrl,
              );
              successCount++;
            } catch (e, stackTrace) {
              AppLogger.error(
                'Failed to send SMS to ${contact.name}',
                e,
                stackTrace,
              );
              // Continue with other contacts even if one fails
            }
          }
        }

        if (successCount > 0) {
          _showSnackBar(
            "Emergency alert sent to $successCount out of $totalContacts contacts!",
            Colors.green,
          );
        } else {
          _showSnackBar(
            "Failed to send emergency alert to any contacts. Please check SMS permissions.",
            Colors.red,
          );
        }
      } else {
        _showSnackBar(
          "No emergency contacts found. Please add emergency contacts first.",
          Colors.red,
        );
      }
    } catch (e, stackTrace) {
      AppLogger.error("Error sending emergency alert", e, stackTrace);
      _showSnackBar("Error sending emergency alert: $e", Colors.red);
    }
  }

  // Show snackbar notification
  void _showSnackBar(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            color == Colors.red
                ? const Icon(Icons.error, color: Colors.white, size: 20)
                : color == Colors.green
                ? const Icon(Icons.check_circle, color: Colors.white, size: 20)
                : const Icon(Icons.info, color: Colors.white, size: 20),
            const SizedBox(width: 8),
            Text(message),
          ],
        ),
        backgroundColor: color,
        duration: const Duration(seconds: 3),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }

  // Check SMS permissions
  Future<bool> checkSmsPermissions() async {
    final Telephony telephony = Telephony.instance;
    final bool? hasPermission = await telephony.requestSmsPermissions;
    return hasPermission == true;
  }

  Widget _buildSuggestionChip(String text) {
    return GestureDetector(
      onTap: () => _sendMessage(text),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.9),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Text(
          text,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: Color(0xFF9C27B0),
          ),
        ),
      ),
    );
  }

  Widget _buildChatArea() {
    return Container(
      margin: const EdgeInsets.only(left: 20, right: 20, top: 3),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.7),
        borderRadius: BorderRadius.circular(20),
      ),
      child: ListView.builder(
        controller: _scrollController,
        padding: const EdgeInsets.all(16),
        itemCount: _messages.length + (_isLoading ? 1 : 0),
        itemBuilder: (context, index) {
          if (index == _messages.length && _isLoading) {
            return _buildTypingIndicator();
          }
          return _buildMessageBubble(_messages[index]);
        },
      ),
    );
  }

  Widget _buildMessageBubble(Message message) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment:
            message.isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!message.isUser) ...[
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF9C27B0), Color(0xFF673AB7)],
                ),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF9C27B0).withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: const Icon(Icons.favorite, color: Colors.white, size: 18),
            ),
            const SizedBox(width: 12),
          ],
          Flexible(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
              decoration: BoxDecoration(
                color:
                    message.isUser
                        ? const Color(0xFF9C27B0)
                        : Colors.white.withOpacity(0.95),
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(20),
                  topRight: const Radius.circular(20),
                  bottomLeft: Radius.circular(message.isUser ? 20 : 6),
                  bottomRight: Radius.circular(message.isUser ? 6 : 20),
                ),
                boxShadow: [
                  BoxShadow(
                    color:
                        message.isUser
                            ? const Color(0xFF9C27B0).withOpacity(0.3)
                            : Colors.black.withOpacity(0.1),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
                border:
                    !message.isUser
                        ? Border.all(
                          color: const Color(0xFF9C27B0).withOpacity(0.1),
                          width: 1,
                        )
                        : null,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    message.text,
                    style: TextStyle(
                      color:
                          message.isUser
                              ? Colors.white
                              : const Color(0xFF2D3748),
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                      height: 1.4,
                    ),
                  ),
                  if (!message.isUser) ...[
                    const SizedBox(height: 8),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.favorite,
                          color: Color(0xFF9C27B0),
                          size: 12,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'Luna',
                          style: TextStyle(
                            color: const Color(0xFF9C27B0).withOpacity(0.7),
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ),
          if (message.isUser) ...[
            const SizedBox(width: 12),
            CircleAvatar(
              radius: 18,
              backgroundColor: const Color(0xFF9C27B0).withOpacity(0.1),
              child: const Icon(
                Icons.person,
                color: Color(0xFF9C27B0),
                size: 18,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildTypingIndicator() {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF9C27B0), Color(0xFF673AB7)],
              ),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.psychology_rounded,
              color: Colors.white,
              size: 16,
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: AnimatedBuilder(
              animation: _typingAnimation,
              builder: (context, child) {
                return Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      "Luna is typing",
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 14,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                    const SizedBox(width: 8),
                    SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          Colors.grey[400]!,
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInputArea() {
    return Container(
      margin: const EdgeInsets.all(20),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.95),
        borderRadius: BorderRadius.circular(25),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _controller,
              decoration: InputDecoration(
                hintText: "Share what's on your mind...",
                hintStyle: TextStyle(color: Colors.grey[500], fontSize: 15),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(vertical: 5),
              ),
              style: const TextStyle(fontSize: 15, color: Color(0xFF2D3748)),
              onSubmitted: (_) => _sendMessage(),
              textInputAction: TextInputAction.send,
            ),
          ),
          const SizedBox(width: 12),
          GestureDetector(
            onTap: _sendMessage,
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF9C27B0), Color(0xFF673AB7)],
                ),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF9C27B0).withOpacity(0.3),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: const Icon(
                Icons.send_rounded,
                color: Colors.white,
                size: 20,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChatHistorySheet() {
    return Container(
      height: MediaQuery.of(context).size.height * 0.7,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                const Text(
                  "Past Conversations",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2D3748),
                  ),
                ),
                const Spacer(),
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: const Icon(Icons.close, color: Colors.grey),
                ),
              ],
            ),
          ),
          Expanded(
            child:
                _loadingHistory
                    ? const Center(child: CircularProgressIndicator())
                    : _buildChatHistoryList(),
          ),
        ],
      ),
    );
  }

  Widget _buildChatHistoryList() {
    final user = _auth.currentUser;
    if (user == null)
      return const Center(child: Text("Please log in to see chat history"));

    return StreamBuilder<QuerySnapshot>(
      stream:
          _firestore
              .collection('users')
              .doc(user.uid)
              .collection('chats')
              .orderBy('updatedAt', descending: true)
              .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Center(
            child: Text(
              "No previous conversations",
              style: TextStyle(color: Colors.grey),
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          itemCount: snapshot.data!.docs.length,
          itemBuilder: (context, index) {
            final doc = snapshot.data!.docs[index];
            final data = doc.data() as Map<String, dynamic>;

            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: BorderRadius.circular(12),
              ),
              child: Dismissible(
                key: Key(doc.id),
                direction: DismissDirection.endToStart,
                background: Container(
                  decoration: BoxDecoration(
                    color: Colors.red,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: const EdgeInsets.only(right: 20),
                  alignment: Alignment.centerRight,
                  child: const Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.delete, color: Colors.white, size: 24),
                      SizedBox(height: 4),
                      Text(
                        'Delete',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                confirmDismiss: (direction) => _showDeleteConfirmation(context),
                onDismissed: (direction) => _deleteChatHistory(doc.id),
                child: ListTile(
                  contentPadding: const EdgeInsets.all(16),
                  leading: const CircleAvatar(
                    backgroundColor: Color(0xFF9C27B0),
                    child: Icon(Icons.chat, color: Colors.white, size: 20),
                  ),
                  title: Text(
                    data['title'] ?? 'Untitled Chat',
                    style: const TextStyle(fontWeight: FontWeight.w600),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  subtitle: Text(
                    _formatDate(data['updatedAt']?.toDate()),
                    style: TextStyle(color: Colors.grey[600], fontSize: 12),
                  ),
                  trailing: PopupMenuButton<String>(
                    icon: Icon(
                      Icons.more_vert,
                      color: Colors.grey[600],
                      size: 20,
                    ),
                    onSelected: (value) {
                      if (value == 'delete') {
                        _showDeleteConfirmation(context).then((confirmed) {
                          if (confirmed == true) {
                            _deleteChatHistory(doc.id);
                          }
                        });
                      }
                    },
                    itemBuilder:
                        (context) => [
                          const PopupMenuItem<String>(
                            value: 'delete',
                            child: Row(
                              children: [
                                Icon(Icons.delete, color: Colors.red, size: 18),
                                SizedBox(width: 8),
                                Text(
                                  'Delete Chat',
                                  style: TextStyle(color: Colors.red),
                                ),
                              ],
                            ),
                          ),
                        ],
                  ),
                  onTap: () => _loadChatHistory(doc.id),
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _loadChatHistory(String chatId) async {
    Navigator.pop(context); // Close bottom sheet
    setState(() {
      _loadingHistory = true;
      _chatId = chatId;
    });

    try {
      final user = _auth.currentUser;
      if (user == null) return;

      final messagesQuery =
          await _firestore
              .collection('users')
              .doc(user.uid)
              .collection('chats')
              .doc(chatId)
              .collection('messages')
              .orderBy('timestamp')
              .get();

      final messages =
          messagesQuery.docs.map((doc) {
            final data = doc.data();
            return Message(
              text: data['text'] ?? '',
              isUser: data['isUser'] ?? false,
              timestamp: data['timestamp']?.toDate() ?? DateTime.now(),
            );
          }).toList();

      setState(() {
        _messages = messages;
        _loadingHistory = false;
      });

      _scrollToBottom();
    } catch (e, stackTrace) {
      AppLogger.error("Error loading chat history", e, stackTrace);
      setState(() {
        _loadingHistory = false;
      });
    }
  }

  String _formatDate(DateTime? date) {
    if (date == null) return '';
    final now = DateTime.now();
    final diff = now.difference(date);

    if (diff.inDays == 0) {
      return 'Today';
    } else if (diff.inDays == 1) {
      return 'Yesterday';
    } else if (diff.inDays < 7) {
      return '${diff.inDays} days ago';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }

  Future<bool?> _showDeleteConfirmation(BuildContext context) {
    return showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Row(
            children: [
              Icon(
                Icons.warning_amber_rounded,
                color: Colors.orange[600],
                size: 24,
              ),
              const SizedBox(width: 8),
              const Text(
                'Delete Chat',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          content: const Text(
            'Are you sure you want to delete this conversation? This action cannot be undone.',
            style: TextStyle(fontSize: 15),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text(
                'Cancel',
                style: TextStyle(
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(true),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text(
                'Delete',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
            ),
          ],
        );
      },
    );
  }

  Future<void> _deleteChatHistory(String chatId) async {
    try {
      final user = _auth.currentUser;
      if (user == null) return;

      final chatRef = _firestore
          .collection('users')
          .doc(user.uid)
          .collection('chats')
          .doc(chatId);

      // Delete all messages in the chat
      final messagesQuery = await chatRef.collection('messages').get();
      final batch = _firestore.batch();

      for (final doc in messagesQuery.docs) {
        batch.delete(doc.reference);
      }

      // Delete the chat document itself
      batch.delete(chatRef);

      await batch.commit();

      // If the current chat is being deleted, reset to initial state
      if (_chatId == chatId) {
        setState(() {
          _chatId = null;
          _messages = [
            Message(
              text:
                  "Hi beautiful! 🌸 I'm Luna, your AI safety companion. How are you feeling today? I'm here to support you with anything you need - from safety tips to just having someone to talk to. 💜",
              isUser: false,
            ),
          ];
        });
      }

      // Show success message
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Row(
              children: [
                Icon(Icons.check_circle, color: Colors.white, size: 20),
                SizedBox(width: 8),
                Text('Chat deleted successfully'),
              ],
            ),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 2),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        );
      }
    } catch (e) {
      // Show error message
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Row(
              children: [
                Icon(Icons.error, color: Colors.white, size: 20),
                SizedBox(width: 8),
                Text('Failed to delete chat. Please try again.'),
              ],
            ),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        );
      }
    }
  }
}
