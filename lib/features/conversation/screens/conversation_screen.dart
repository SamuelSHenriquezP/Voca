import 'package:flutter/material.dart';
import '../../../core/storage/local_storage_service.dart';
import '../../../core/theme/voca_typography.dart';
import '../../../core/utils/audio_tts_service.dart';
import '../../../core/utils/haptic_feedback_utils.dart';
import '../../../core/utils/sound_effects.dart';
import '../../../core/widgets/bouncy_tap.dart';
import '../../../core/widgets/voca_button.dart';
import '../models/chat_message.dart';
import '../widgets/coach_tip_card.dart';
import '../widgets/harmonic_spectrum_visualizer.dart';
import '../widgets/npc_avatar_card.dart';
import '../widgets/scenario_selector_sheet.dart';
import '../widgets/speech_bubble.dart';
import '../widgets/voice_controls.dart';

class DialogueTurn {
  final String npcPrompt;
  final String suggestedUserResponse;
  final String hintContext;
  final String coachGrammarTip;
  final String coachPronunciationTip;
  final String npcReply;

  const DialogueTurn({
    required this.npcPrompt,
    required this.suggestedUserResponse,
    required this.hintContext,
    required this.coachGrammarTip,
    required this.coachPronunciationTip,
    required this.npcReply,
  });
}

class ConversationScreen extends StatefulWidget {
  final String personaName;
  final String personaRole;

  const ConversationScreen({
    super.key,
    this.personaName = 'Officer Miller',
    this.personaRole = 'Airport Customs Inspection',
  });

  @override
  State<ConversationScreen> createState() => _ConversationScreenState();
}

class _ConversationScreenState extends State<ConversationScreen> {
  final ScrollController _scrollController = ScrollController();
  bool _isUserRecording = false;
  bool _isNpcSpeaking = false;
  String _statusText = 'Ready to converse';

  int _currentTurnIndex = 0;
  String _currentGrammarTip = 'Use natural modal formulas like "Could I get..." or "I\'ll be staying...".';
  String _currentPronunciationTip = 'Maintain smooth connected speech rhythm.';
  int _currentFluencyScore = 92;

  late ScenarioItem _activeScenario;
  late List<ChatMessage> _messages;

  static final Map<String, List<DialogueTurn>> _scenarioScripts = {
    'jfk_customs': const [
      DialogueTurn(
        npcPrompt: 'Good afternoon. What is the primary purpose of your visit to the United States?',
        suggestedUserResponse: 'I will be staying for two weeks for vacation and visiting family in Seattle.',
        hintContext: 'State your duration and purpose clearly without over-explaining.',
        coachGrammarTip: 'Excellent use of future intention: "I will be staying for...".',
        coachPronunciationTip: 'Clear stress on "two WEEKS" and "va-CA-tion".',
        npcReply: 'Understood. And where exactly will you be residing during your stay in Seattle?',
      ),
      DialogueTurn(
        npcPrompt: 'Understood. And where exactly will you be residing during your stay in Seattle?',
        suggestedUserResponse: "I'll be staying at my brother's house in Capitol Hill.",
        hintContext: "Use natural prepositions of place: 'at my brother's house in [neighborhood]'.",
        coachGrammarTip: 'Great natural contraction "I\'ll be" instead of stiff formal syntax.',
        coachPronunciationTip: 'Smooth cadence on "CA-pi-tol Hill".',
        npcReply: 'Do you have any commercial merchandise, fresh agriculture, or currency exceeding ten thousand dollars to declare?',
      ),
      DialogueTurn(
        npcPrompt: 'Do you have any commercial merchandise, fresh agriculture, or currency exceeding ten thousand dollars to declare?',
        suggestedUserResponse: 'No, I have nothing to declare, officer.',
        hintContext: 'Standard polite customs formula used by native travelers.',
        coachGrammarTip: 'Accurate negative quantifier: "nothing to declare".',
        coachPronunciationTip: 'Polite downward intonation on the final cadence.',
        npcReply: 'Everything looks in order. Enjoy your stay in Seattle! Welcome to the United States.',
      ),
    ],
    'coffee_barista': const [
      DialogueTurn(
        npcPrompt: 'Hey there! What can I craft for you today from the espresso bar?',
        suggestedUserResponse: 'Could I get a flat white with oat milk, extra hot, to go please?',
        hintContext: 'Polite modal "Could I get..." is the gold standard in modern coffee shops.',
        coachGrammarTip: 'Flawless ordering: drink type + milk modifier + temperature + destination.',
        coachPronunciationTip: 'Smooth connected speech: "Could I" -> /kʊ.daɪ/.',
        npcReply: 'You got it! Any pastry or avocado sourdough toast to pair with that today?',
      ),
      DialogueTurn(
        npcPrompt: 'You got it! Any pastry or avocado sourdough toast to pair with that today?',
        suggestedUserResponse: 'Just an almond croissant if you have any fresh ones left.',
        hintContext: 'Casual conversational softener "just" + polite conditional.',
        coachGrammarTip: 'Polite conversational conditional: "if you have... left".',
        coachPronunciationTip: 'Silent "l" in "almond" (/ˈɑː.mənd/).',
        npcReply: "Last one just pulled from the oven! That'll be nine-fifty. Paying with card or contactless?",
      ),
      DialogueTurn(
        npcPrompt: "That'll be nine-fifty. Paying with card or contactless?",
        suggestedUserResponse: "I'll tap with Apple Pay. Keep the change as a tip!",
        hintContext: 'Quick modern payment idiom: "Keep the change".',
        coachGrammarTip: 'Idiomatic: "I\'ll tap with..." and "Keep the change".',
        coachPronunciationTip: 'Crisp bilabial stop on "Apple Pay".',
        npcReply: 'Appreciate it so much! Your flat white and warm pastry are ready at the counter. Have a wonderful morning!',
      ),
    ],
    'tech_interview': const [
      DialogueTurn(
        npcPrompt: 'Welcome. Could you summarize a challenging engineering deadlock you resolved recently?',
        suggestedUserResponse: 'In my previous role, we hit severe latency bottlenecks which I mitigated via distributed caching.',
        hintContext: 'STAR method: Situation, Action, and Technical impact.',
        coachGrammarTip: 'Strong engineering action verbs: "mitigated", "distributed".',
        coachPronunciationTip: 'Clear primary stress on "dis-TRI-bu-ted CA-ching".',
        npcReply: 'Solid technical mitigation. How did you handle architectural pushback from the senior team?',
      ),
      DialogueTurn(
        npcPrompt: 'Solid technical mitigation. How did you handle architectural pushback from the senior team?',
        suggestedUserResponse: 'I presented telemetry benchmarks during sprint planning, demonstrating a forty percent drop in latency.',
        hintContext: 'Data-driven persuasion and collaborative alignment.',
        coachGrammarTip: 'Effective participle clause: "demonstrating a forty percent drop".',
        coachPronunciationTip: 'Rhythmic cadence on "te-LE-me-try BENCH-marks".',
        npcReply: 'That data-driven mindset is crucial here. What area of our distributed system are you most excited to scale?',
      ),
      DialogueTurn(
        npcPrompt: 'That data-driven mindset is crucial here. What area of our distributed system are you most excited to scale?',
        suggestedUserResponse: 'I thrive at optimizing event-driven pipelines and ensuring ninety-nine point nine percent uptime under peak load.',
        hintContext: 'Show ambition connected to reliability and scale.',
        coachGrammarTip: 'Sophisticated engineering collocations: "event-driven pipelines", "peak load".',
        coachPronunciationTip: 'Precise decimal pronunciation: "ninety-nine point nine".',
        npcReply: 'You have both the depth and communication skills we need. We would love to make you an offer. Welcome aboard!',
      ),
    ],
    'hotel_concierge': const [
      DialogueTurn(
        npcPrompt: 'Good evening. Welcome to The Crosby. May I request your reservation confirmation details?',
        suggestedUserResponse: 'Good evening! I have a reservation under Rivera for three nights, and was hoping for a high-floor room.',
        hintContext: 'State your booking name and courteous preference using "was hoping for".',
        coachGrammarTip: 'Past continuous as a polite conversational softener.',
        coachPronunciationTip: 'Soft liaison: "un-der Ri-ve-ra".',
        npcReply: 'A pleasure, Mr. Rivera. I have placed you on our top terrace suite. Would you like complimentary late check-out on Sunday?',
      ),
      DialogueTurn(
        npcPrompt: 'A pleasure, Mr. Rivera. I have placed you on our top terrace suite. Would you like complimentary late check-out on Sunday?',
        suggestedUserResponse: 'That would be fantastic! Would one PM be possible without any surcharge?',
        hintContext: 'Polite conditional affirmation with specific timing.',
        coachGrammarTip: 'Modal conditional: "That would be fantastic".',
        coachPronunciationTip: 'Clear vowel in "surcharge" (/ˈsɝː.tʃɑːrdʒ/).',
        npcReply: 'Arranged with our compliments. May my team reserve a table at an exceptional local bistro for you tonight?',
      ),
      DialogueTurn(
        npcPrompt: 'Arranged with our compliments. May my team reserve a table at an exceptional local bistro for you tonight?',
        suggestedUserResponse: "We'd love an authentic Italian trattoria within walking distance, please.",
        hintContext: 'Specify cuisine preference and distance.',
        coachGrammarTip: 'Natural contraction "We\'d love" (we would love).',
        coachPronunciationTip: 'Authentic double consonant: "trat-to-ri-a".',
        npcReply: "I have confirmed a private booth at Emilio's just two blocks away. Here are your keys, enjoy a splendid evening!",
      ),
    ],
    'alex_free_chat': const [
      DialogueTurn(
        npcPrompt: "Hey there! I'm Alex. So great to meet you! How has your day been treating you so far?",
        suggestedUserResponse: 'Hey Alex! My day has been pretty good, just practicing my spoken English and learning new idioms.',
        hintContext: 'Friendly opener with conversational present continuous.',
        coachGrammarTip: 'Natural conversational filler and adverb: "pretty good", "just practicing".',
        coachPronunciationTip: 'Casual native reduction: "pretty good" -> /prɪ.ti ɡʊd/.',
        npcReply: "Love that dedication! Spoken English is all about rhythm. What's the biggest hurdle you face when speaking?",
      ),
      DialogueTurn(
        npcPrompt: "Love that dedication! Spoken English is all about rhythm. What's the biggest hurdle you face when speaking?",
        suggestedUserResponse: 'Sometimes native speakers talk so fast with connected speech, so catching words in real time takes focus.',
        hintContext: 'Express honest linguistic challenges using terms like "connected speech".',
        coachGrammarTip: 'Subordinate clause with causal "so catching...".',
        coachPronunciationTip: 'Linking: "con-nec-ted speech".',
        npcReply: 'Spot on! Even native speakers blend sounds constantly. What topic do you enjoy chatting about most?',
      ),
      DialogueTurn(
        npcPrompt: 'Spot on! Even native speakers blend sounds constantly. What topic do you enjoy chatting about most?',
        suggestedUserResponse: 'I really enjoy discussing new technology, traveling the world, and trying authentic local foods.',
        hintContext: 'Rule of three with parallel gerund forms.',
        coachGrammarTip: 'Parallel grammatical structure in lists: discussing, traveling, trying.',
        coachPronunciationTip: 'Rhythmic stress: tech-NOL-o-gy, TRAV-el-ing, FOODS.',
        npcReply: "You're expressing yourself with remarkable cadence and natural flow! Keep building that muscle memory!",
      ),
    ],
  };

  List<DialogueTurn> get _activeTurns =>
      _scenarioScripts[_activeScenario.id] ?? _scenarioScripts['alex_free_chat']!;

  DialogueTurn get _currentTurn {
    final turns = _activeTurns;
    return turns[_currentTurnIndex.clamp(0, turns.length - 1)];
  }

  @override
  void initState() {
    super.initState();
    _activeScenario = ScenarioSelectorSheet.scenarios.first;
    _initScenarioMessages();
  }

  void _initScenarioMessages() {
    _currentTurnIndex = 0;
    final turns = _activeTurns;
    final firstTurn = turns.first;

    _currentGrammarTip = firstTurn.coachGrammarTip;
    _currentPronunciationTip = firstTurn.coachPronunciationTip;
    _currentFluencyScore = 92;

    _messages = [
      ChatMessage(
        id: 'init_npc',
        text: firstTurn.npcPrompt,
        isUser: false,
        time: '14:00',
      ),
    ];

    // Speak initial NPC prompt natively
    Future.delayed(const Duration(milliseconds: 400), () {
      if (mounted) {
        AudioTtsService().speak(firstTurn.npcPrompt);
      }
    });
  }

  void _switchScenario(ScenarioItem scenario) {
    setState(() {
      _activeScenario = scenario;
      _initScenarioMessages();
      _statusText = 'Ready with ${scenario.personaName}';
    });
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

  void _handleToggleRecording() {
    if (_isNpcSpeaking) return;

    setState(() {
      _isUserRecording = !_isUserRecording;
      if (_isUserRecording) {
        _statusText = 'Listening to you... (Say phrase)';
      } else {
        _statusText = 'Evaluating speech rhythm...';
        _processUserTurn();
      }
    });
  }

  void _processUserTurn() {
    final turns = _activeTurns;
    final turn = _currentTurn;

    Future.delayed(const Duration(milliseconds: 500), () {
      if (!mounted) return;

      SoundEffects.playSuccess();
      VocaHaptics.medium();

      setState(() {
        _messages.add(
          ChatMessage(
            id: 'user_${DateTime.now().millisecondsSinceEpoch}',
            text: turn.suggestedUserResponse,
            isUser: true,
            time: '14:04',
            accuracyScore: (91 + (_currentTurnIndex * 3)).clamp(90, 98),
            coachGrammarTip: turn.coachGrammarTip,
            coachPronunciationTip: turn.coachPronunciationTip,
          ),
        );

        _currentGrammarTip = turn.coachGrammarTip;
        _currentPronunciationTip = turn.coachPronunciationTip;
        _currentFluencyScore = (92 + _currentTurnIndex * 3).clamp(90, 99);
        _statusText = '${_activeScenario.personaName} thinking...';
        _scrollToBottom();
      });

      // NPC response after natural conversational pause
      Future.delayed(const Duration(milliseconds: 1100), () {
        if (!mounted) return;

        setState(() {
          _isNpcSpeaking = true;
          _statusText = '${_activeScenario.personaName} speaking...';
          _messages.add(
            ChatMessage(
              id: 'npc_${DateTime.now().millisecondsSinceEpoch}',
              text: turn.npcReply,
              isUser: false,
              time: '14:05',
            ),
          );
          _scrollToBottom();
        });

        // Trigger native voice synthesis for NPC response
        AudioTtsService().speak(turn.npcReply);

        Future.delayed(const Duration(milliseconds: 2200), () {
          if (!mounted) return;

          setState(() {
            _isNpcSpeaking = false;
            _currentTurnIndex++;

            if (_currentTurnIndex >= turns.length) {
              _statusText = 'Dialogue Cleared!';
              _handleDialogueCompleted();
            } else {
              _statusText = 'Turn ${_currentTurnIndex + 1} of ${turns.length}: Speak your next response';
            }
          });
        });
      });
    });
  }

  void _handleDialogueCompleted() {
    LocalStorageService().addXp(35);
    SoundEffects.playCelebration();
    VocaHaptics.success();

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        contentPadding: const EdgeInsets.all(24),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 60,
              height: 60,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: Color(0xFFEEF2FF),
              ),
              child: const Icon(Icons.verified_rounded, size: 36, color: Color(0xFF4F46E5)),
            ),
            const SizedBox(height: 14),
            Text('Dialogue Mastered!', style: VocaTypography.heading1.copyWith(fontSize: 22)),
            const SizedBox(height: 6),
            Text(
              'You successfully completed all 3 spoken exchanges with ${_activeScenario.personaName}!\n+35 XP earned.',
              style: VocaTypography.bodyMedium.copyWith(color: const Color(0xFF64748B)),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            VocaButton(
              text: 'CONTINUE JOURNEY',
              variant: VocaButtonVariant.gold,
              isFullWidth: true,
              height: 48,
              onPressed: () {
                Navigator.of(ctx).pop();
              },
            ),
          ],
        ),
      ),
    );
  }

  void _handleHint() {
    final turn = _currentTurn;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(24),
            topRight: Radius.circular(24),
          ),
        ),
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.lightbulb_outline_rounded, color: Color(0xFFD97706), size: 24),
                const SizedBox(width: 8),
                Text('Suggested Spoken Phrase', style: VocaTypography.heading2),
              ],
            ),
            const SizedBox(height: 14),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFEEF2FF),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      turn.suggestedUserResponse,
                      style: VocaTypography.bodyLarge.copyWith(
                        color: const Color(0xFF4F46E5),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  BouncyTap(
                    onTap: () {
                      AudioTtsService().speak(turn.suggestedUserResponse);
                    },
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: const BoxDecoration(
                        color: Color(0xFF4F46E5),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.volume_up_rounded, color: Colors.white, size: 18),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                const Icon(Icons.info_outline_rounded, size: 14, color: Color(0xFF64748B)),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    turn.hintContext,
                    style: VocaTypography.bodySmall.copyWith(fontSize: 12),
                  ),
                ),
              ],
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
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text('Leave Session?', style: VocaTypography.heading2),
        content: Text(
          'You can resume this spoken conversation anytime from the level map.',
          style: VocaTypography.bodyMedium,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text('Keep Going', style: VocaTypography.buttonText.copyWith(color: const Color(0xFF4F46E5))),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              Navigator.of(context).pop();
            },
            child: Text('Exit', style: VocaTypography.buttonText.copyWith(color: const Color(0xFFDC2626))),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final turns = _activeTurns;
    final isCompleted = _currentTurnIndex >= turns.length;
    final turn = _currentTurn;

    return Scaffold(
      backgroundColor: const Color(0xFFFBFBFC),
      body: Column(
        children: [
          // Minimalist Obsidian Header
          Container(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
            decoration: const BoxDecoration(
              color: Color(0xFF0F172A),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(24),
                bottomRight: Radius.circular(24),
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
                        onTap: () {
                          if (Navigator.of(context).canPop()) {
                            Navigator.of(context).pop();
                          }
                        },
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

                      // Interactive Scenario Switcher Trigger Pill
                      BouncyTap(
                        onTap: () {
                          ScenarioSelectorSheet.show(
                            context,
                            selectedId: _activeScenario.id,
                            onSelect: _switchScenario,
                          );
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                          decoration: BoxDecoration(
                            color: _activeScenario.accentColor.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: _activeScenario.accentColor, width: 1.5),
                          ),
                          child: Row(
                            children: [
                              Icon(Icons.swap_horiz_rounded, color: _activeScenario.accentColor, size: 16),
                              const SizedBox(width: 6),
                              Text(
                                _activeScenario.title.toUpperCase(),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: 0.8,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      BouncyTap(
                        onTap: () {
                          ScenarioSelectorSheet.show(
                            context,
                            selectedId: _activeScenario.id,
                            onSelect: _switchScenario,
                          );
                        },
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.15),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.tune_rounded,
                            color: Colors.white,
                            size: 18,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // NPC Persona Avatar & Status Card
                  NpcAvatarCard(
                    name: _activeScenario.personaName,
                    role: _activeScenario.personaRole,
                    isSpeaking: _isNpcSpeaking,
                    statusText: _statusText,
                  ),

                  const SizedBox(height: 12),

                  // Animated Harmonic Spectrum Canvas (Multi-sine waves & sound particles)
                  HarmonicSpectrumVisualizer(
                    isSpeaking: _isUserRecording || _isNpcSpeaking,
                    primaryColor: _isUserRecording ? const Color(0xFFF43F5E) : _activeScenario.accentColor,
                    secondaryColor: const Color(0xFF38BDF8),
                    height: 44,
                  ),
                ],
              ),
            ),
          ),

          // Real-Time Speech Telemetry Bar
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: const BoxDecoration(
              color: Color(0xFFF1F5F9),
              border: Border(
                bottom: BorderSide(color: Color(0xFFE2E8F0), width: 1),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Row(
                  children: [
                    const Icon(Icons.sync_alt_rounded, size: 14, color: Color(0xFF0284C7)),
                    const SizedBox(width: 4),
                    Text(
                      'Turn ${(_currentTurnIndex + 1).clamp(1, turns.length)}/${turns.length}',
                      style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Color(0xFF334155)),
                    ),
                  ],
                ),
                const Text('•', style: TextStyle(color: Color(0xFFCBD5E1))),
                Row(
                  children: [
                    const Icon(Icons.graphic_eq_rounded, size: 14, color: Color(0xFF059669)),
                    const SizedBox(width: 4),
                    Text(
                      'Accuracy: $_currentFluencyScore%',
                      style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Color(0xFF334155)),
                    ),
                  ],
                ),
                const Text('•', style: TextStyle(color: Color(0xFFCBD5E1))),
                const Row(
                  children: [
                    Icon(Icons.verified_rounded, size: 14, color: Color(0xFF4F46E5)),
                    SizedBox(width: 4),
                    Text(
                      'Standard US',
                      style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Color(0xFF334155)),
                    ),
                  ],
                ),
              ],
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

          // Suggested Phrase Prompter Card (Preview & Quick Audio Pronunciation)
          if (!isCompleted) ...[
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: const Color(0xFFEEF2FF),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: const Color(0xFFC7D2FE), width: 1),
              ),
              child: Row(
                children: [
                  BouncyTap(
                    onTap: () {
                      VocaHaptics.selection();
                      AudioTtsService().speak(turn.suggestedUserResponse);
                    },
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: const BoxDecoration(
                        color: Color(0xFF4F46E5),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.volume_up_rounded, color: Colors.white, size: 14),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'YOUR TURN (RESPONSE):',
                          style: TextStyle(
                            fontSize: 9,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 0.7,
                            color: Colors.indigo.shade700,
                          ),
                        ),
                        Text(
                          '"${turn.suggestedUserResponse}"',
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF1E1B4B),
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],

          // Collapsible Silent Coach Tip Card with real feedback
          CoachTipCard(
            grammarTip: _currentGrammarTip,
            pronunciationTip: _currentPronunciationTip,
            fluencyScore: _currentFluencyScore,
          ),

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
