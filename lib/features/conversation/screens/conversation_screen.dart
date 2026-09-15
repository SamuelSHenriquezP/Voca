import 'package:flutter/material.dart';
import '../../../core/theme/voca_colors.dart';
import '../../../core/theme/voca_typography.dart';
import '../../../core/widgets/bouncy_tap.dart';
import '../../../core/widgets/waveform_widget.dart';
import '../models/chat_message.dart';
import '../widgets/coach_tip_card.dart';
import '../widgets/npc_avatar_card.dart';
import '../widgets/speech_bubble.dart';
import '../widgets/voice_controls.dart';

class ConversationScreen extends StatefulWidget {
  final String personaName;
  final String personaRole;
  final String personaEmoji;

  const ConversationScreen({
    super.key,
    this.personaName = 'Officer Miller',
    this.personaRole = 'Airport Customs Inspection',
    this.personaEmoji = '👮‍♂️',
  });

  @override
  State<ConversationScreen> createState() => _ConversationScreenState();
}

class _ConversationScreenState extends State<ConversationScreen> {
  final ScrollController _scrollController = ScrollController();
  bool _isUserRecording = false;
  bool _isNpcSpeaking = false;
  String _statusText = 'Ready to converse';

  final List<ChatMessage> _messages = [
    const ChatMessage(
      id: 'm1',
      text: 'Good afternoon. What is the primary purpose of your visit to the United States?',
      isUser: false,
      time: '14:02',
    ),
    const ChatMessage(
      id: 'm2',
      text: "I'm here for a vacation and visiting my family in Seattle.",
      isUser: true,
      time: '14:03',
      accuracyScore: 94,
    ),
    const ChatMessage(
      id: 'm3',
      text: 'Understood. How long do you plan on staying, and where will you be residing?',
      isUser: false,
      time: '14:03',
    ),
  ];

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

  void _handleToggleRecording() {
    setState(() {
      _isUserRecording = !_isUserRecording;
      if (_isUserRecording) {
        _statusText = 'Listening to you...';
      } else {
        _statusText = 'Evaluating speech...';
        // Add simulated user message
        Future.delayed(const Duration(milliseconds: 600), () {
          if (!mounted) return;
          setState(() {
            _messages.add(
              const ChatMessage(
                id: 'm4',
                text: "I will be staying for two weeks at my brother's house in Capitol Hill.",
                isUser: true,
                time: '14:04',
                accuracyScore: 91,
                coachGrammarTip: 'Great natural preposition: "at my brother\'s house".',
                coachPronunciationTip: 'Clear stress on "CA-pi-tol Hill".',
              ),
            );
            _statusText = 'NPC Thinking...';
            _scrollToBottom();
          });

          // Simulate NPC response
          Future.delayed(const Duration(milliseconds: 1400), () {
            if (!mounted) return;
            setState(() {
              _isNpcSpeaking = true;
              _statusText = 'Officer Speaking...';
              _messages.add(
                const ChatMessage(
                  id: 'm5',
                  text: 'Everything looks in order. Enjoy your stay in Seattle! Welcome to the US.',
                  isUser: false,
                  time: '14:04',
                ),
              );
              _scrollToBottom();
            });

            Future.delayed(const Duration(milliseconds: 2500), () {
              if (!mounted) return;
              setState(() {
                _isNpcSpeaking = false;
                _statusText = 'Conversation Cleared! 🌟';
              });
            });
          });
        });
      }
    });
  }

  void _handleHint() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(28),
            topRight: Radius.circular(28),
          ),
        ),
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.lightbulb_rounded, color: VocaColors.goldXp, size: 28),
                const SizedBox(width: 8),
                Text('Suggested Phrase', style: VocaTypography.heading2),
              ],
            ),
            const SizedBox(height: 14),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: VocaColors.purpleTint,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Text(
                '"I will be staying for two weeks at my brother\'s place in Seattle."',
                style: VocaTypography.bodyLarge.copyWith(color: VocaColors.primaryPurple),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              '💡 Tip: Customs officers look for concise, direct answers with specific durations and locations.',
              style: VocaTypography.bodySmall,
            ),
          ],
        ),
      ),
    );
  }

  void _handleSurrender() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: Text('Leave Boss Fight?', style: VocaTypography.heading2),
        content: Text(
          'You can resume this spoken conversation anytime from the level map.',
          style: VocaTypography.bodyMedium,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text('Keep Going', style: VocaTypography.buttonText.copyWith(color: VocaColors.primaryPurple)),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              Navigator.of(context).pop();
            },
            child: Text('Exit', style: VocaTypography.buttonText.copyWith(color: VocaColors.rubyRed)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: VocaColors.backgroundNeutral,
      body: Column(
        children: [
          // Immersive Deep Gradient Header (Midnight Purple to Neon Pink)
          Container(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 20),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Color(0xFF1E1035), // Midnight purple
                  Color(0xFF4A154B), // Deep berry
                  Color(0xFF6C5CE7), // Primary purple
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(32),
                bottomRight: Radius.circular(32),
              ),
            ),
            child: SafeArea(
              bottom: false,
              child: Column(
                children: [
                  // Top Navigation Row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      BouncyTap(
                        onTap: () => Navigator.of(context).pop(),
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.15),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.arrow_back_ios_new_rounded,
                            color: Colors.white,
                            size: 18,
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                        decoration: BoxDecoration(
                          color: VocaColors.accentPink.withOpacity(0.3),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: VocaColors.accentPink, width: 1.5),
                        ),
                        child: const Row(
                          children: [
                            Icon(Icons.mic_external_on_rounded, color: Colors.white, size: 16),
                            SizedBox(width: 6),
                            Text(
                              'VOICE BOSS BATTLE',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 11,
                                fontWeight: FontWeight.w900,
                                letterSpacing: 1.1,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.15),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.more_vert_rounded,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // NPC Persona Avatar & Status Card
                  NpcAvatarCard(
                    name: widget.personaName,
                    role: widget.personaRole,
                    avatarEmoji: widget.personaEmoji,
                    isSpeaking: _isNpcSpeaking,
                    statusText: _statusText,
                  ),

                  const SizedBox(height: 14),

                  // Live Waveform Visualizer
                  WaveformWidget(
                    isSpeaking: _isUserRecording || _isNpcSpeaking,
                    barColor: _isUserRecording ? VocaColors.accentPink : VocaColors.electricCyan,
                    barCount: 24,
                    maxHeight: 38,
                  ),
                ],
              ),
            ),
          ),

          // Dual-Channel Speech Transcript
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.symmetric(vertical: 12),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                return SpeechBubble(message: _messages[index]);
              },
            ),
          ),

          // Collapsible Silent Coach Tip Card
          const CoachTipCard(),

          // Bottom Floating Voice Controls
          VoiceControls(
            isSpeaking: _isNpcSpeaking,
            isRecording: _isUserRecording,
            onToggleRecording: _handleToggleRecording,
            onHint: _handleHint,
            onSurrender: _handleSurrender,
          ),
        ],
      ),
    );
  }
}
