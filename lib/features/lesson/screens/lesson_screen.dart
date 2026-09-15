import 'package:confetti/confetti.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../core/theme/voca_colors.dart';
import '../../../core/theme/voca_typography.dart';
import '../../../core/utils/sound_effects.dart';
import '../../../core/widgets/voca_button.dart';
import '../models/exercise.dart';
import '../widgets/action_drawer.dart';
import '../widgets/exercise_header.dart';
import '../widgets/picture_choice_drill.dart';
import '../widgets/scramble_drill.dart';
import '../widgets/shadowing_drill.dart';

class LessonScreen extends StatefulWidget {
  final String lessonTitle;
  final VoidCallback? onCompleted;

  const LessonScreen({
    super.key,
    this.lessonTitle = 'Level 1-3: Food & Drinks',
    this.onCompleted,
  });

  @override
  State<LessonScreen> createState() => _LessonScreenState();
}

class _LessonScreenState extends State<LessonScreen> {
  late ConfettiController _confettiController;
  int _currentIndex = 0;
  int _hearts = 5;
  DrawerState _drawerState = DrawerState.standard;
  bool _shakeScreen = false;

  // Exercise 1: Scramble
  final List<String> _selectedScrambleWords = [];

  // Exercise 2: Picture Choice
  String? _selectedPictureOptionId;

  // Exercise 3: Shadowing
  bool _isShadowingRecorded = false;

  late final List<ExerciseModel> _exercises;

  @override
  void initState() {
    super.initState();
    _confettiController = ConfettiController(duration: const Duration(seconds: 3));

    _exercises = const [
      ExerciseModel(
        id: 'ex_scramble',
        type: DrillType.sentenceScramble,
        prompt: 'Arrange the words to say:',
        subtitle: '"Could I please have a cup of coffee?"',
        targetSentenceWords: ['Could', 'I', 'please', 'have', 'a', 'cup', 'of', 'coffee?'],
        bankWords: ['have', 'coffee?', 'Could', 'tea', 'cup', 'I', 'please', 'of', 'a', 'water'],
      ),
      ExerciseModel(
        id: 'ex_choice',
        type: DrillType.pictureChoice,
        prompt: 'Which of these means "The Check / Bill"?',
        subtitle: 'Tap the matching card with proper pronunciation',
        pictureOptions: [
          PictureChoiceOption(
            id: 'opt_menu',
            label: 'The Menu',
            emoji: '📜',
            audioPhonetic: '/ðə ˈmɛn.juː/',
            isCorrect: false,
          ),
          PictureChoiceOption(
            id: 'opt_bill',
            label: 'The Bill / Check',
            emoji: '🧾',
            audioPhonetic: '/ðə tʃɛk/',
            isCorrect: true,
          ),
          PictureChoiceOption(
            id: 'opt_waiter',
            label: 'The Waiter',
            emoji: '🧑‍🍳',
            audioPhonetic: '/ðə ˈweɪ.tər/',
            isCorrect: false,
          ),
          PictureChoiceOption(
            id: 'opt_fork',
            label: 'The Cutlery',
            emoji: '🍴',
            audioPhonetic: '/ˈkʌt.lər.i/',
            isCorrect: false,
          ),
        ],
      ),
      ExerciseModel(
        id: 'ex_shadow',
        type: DrillType.shadowing,
        prompt: 'Speak this sentence out loud:',
        targetSpeechText: '"Excuse me, could we get the check, please?"',
        phoneticTokens: ['[ik-SKYOOS mee]', '[kood wee get]', '[thuh chek]', '[pleez]'],
        expectedAccentTip: 'Soft link between "could we" -> sounds like "kood-wee".',
      ),
    ];
  }

  @override
  void dispose() {
    _confettiController.dispose();
    super.dispose();
  }

  bool get _isCheckEnabled {
    final currentEx = _exercises[_currentIndex];
    switch (currentEx.type) {
      case DrillType.sentenceScramble:
        return _selectedScrambleWords.isNotEmpty;
      case DrillType.pictureChoice:
        return _selectedPictureOptionId != null;
      case DrillType.shadowing:
        return _isShadowingRecorded;
    }
  }

  void _onCheckAnswer() {
    final currentEx = _exercises[_currentIndex];
    bool isCorrect = false;

    switch (currentEx.type) {
      case DrillType.sentenceScramble:
        final assembled = _selectedScrambleWords.join(' ');
        final target = currentEx.targetSentenceWords.join(' ');
        isCorrect = assembled == target;
        break;
      case DrillType.pictureChoice:
        final selectedOpt = currentEx.pictureOptions.firstWhere(
          (o) => o.id == _selectedPictureOptionId,
          orElse: () => currentEx.pictureOptions.first,
        );
        isCorrect = selectedOpt.isCorrect;
        break;
      case DrillType.shadowing:
        // Voice shadowing is simulated as successful once user records
        isCorrect = _isShadowingRecorded;
        break;
    }

    if (isCorrect) {
      SoundEffects.playSuccess();
      setState(() {
        _drawerState = DrawerState.success;
      });
    } else {
      SoundEffects.playError();
      setState(() {
        _drawerState = DrawerState.error;
        _shakeScreen = true;
        if (_hearts > 1) {
          _hearts--;
        }
      });
      Future.delayed(const Duration(milliseconds: 500), () {
        if (mounted) setState(() => _shakeScreen = false);
      });
    }
  }

  void _onContinue() {
    if (_currentIndex < _exercises.length - 1) {
      setState(() {
        _currentIndex++;
        _drawerState = DrawerState.standard;
        _selectedScrambleWords.clear();
        _selectedPictureOptionId = null;
        _isShadowingRecorded = false;
      });
    } else {
      // Completed all drills!
      SoundEffects.playCelebration();
      _confettiController.play();
      _showCompletionDialog();
    }
  }

  void _onGotIt() {
    setState(() {
      _drawerState = DrawerState.standard;
    });
  }

  void _showCompletionDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
        contentPadding: const EdgeInsets.all(24),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('🏆', style: TextStyle(fontSize: 64)),
            const SizedBox(height: 12),
            Text(
              'Lesson Completed!',
              style: VocaTypography.heading1.copyWith(fontSize: 24),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'You earned +15 XP and maintained your 14-day streak!',
              style: VocaTypography.bodyMedium.copyWith(color: VocaColors.textMuted),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            VocaButton(
              text: 'CLAIM REWARDS',
              variant: VocaButtonVariant.gold,
              isFullWidth: true,
              height: 52,
              onPressed: () {
                Navigator.of(ctx).pop();
                if (widget.onCompleted != null) {
                  widget.onCompleted!();
                } else {
                  Navigator.of(context).pop();
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final currentEx = _exercises[_currentIndex];
    final progress = (_currentIndex + 1) / _exercises.length;

    Widget drillBody;
    switch (currentEx.type) {
      case DrillType.sentenceScramble:
        drillBody = ScrambleDrill(
          exercise: currentEx,
          selectedWords: _selectedScrambleWords,
          onWordSelected: (word) {
            setState(() => _selectedScrambleWords.add(word));
          },
          onWordRemoved: (index) {
            setState(() => _selectedScrambleWords.removeAt(index));
          },
        );
        break;
      case DrillType.pictureChoice:
        drillBody = PictureChoiceDrill(
          exercise: currentEx,
          selectedOptionId: _selectedPictureOptionId,
          onOptionSelected: (option) {
            setState(() => _selectedPictureOptionId = option.id);
          },
        );
        break;
      case DrillType.shadowing:
        drillBody = ShadowingDrill(
          exercise: currentEx,
          onRecordingComplete: (isRec) {
            setState(() => _isShadowingRecorded = isRec);
          },
        );
        break;
    }

    Widget content = Scaffold(
      backgroundColor: VocaColors.backgroundNeutral,
      body: Column(
        children: [
          // Header
          ExerciseHeader(
            progress: progress,
            hearts: _hearts,
            onClose: () => Navigator.of(context).pop(),
          ),

          // Drill Content
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: drillBody,
            ),
          ),

          // Bottom Action Drawer
          ActionDrawer(
            state: _drawerState,
            isCheckEnabled: _isCheckEnabled,
            onCheck: _onCheckAnswer,
            onContinue: _onContinue,
            onGotIt: _onGotIt,
            correctAnswer: currentEx.type == DrillType.sentenceScramble
                ? currentEx.targetSentenceWords.join(' ')
                : 'The Bill / Check',
            tip: 'Focus on native rhythm and clear vowel intonation.',
          ),
        ],
      ),
    );

    // Shake animation on error
    if (_shakeScreen) {
      content = content.animate().shake(
            duration: const Duration(milliseconds: 400),
            curve: Curves.easeInOutCubic,
            hz: 4,
          );
    }

    return Stack(
      children: [
        content,
        Align(
          alignment: Alignment.topCenter,
          child: ConfettiWidget(
            confettiController: _confettiController,
            blastDirectionality: BlastDirectionality.explosive,
            shouldLoop: false,
            colors: const [
              VocaColors.primaryPurple,
              VocaColors.electricCyan,
              VocaColors.sunOrange,
              VocaColors.accentPink,
              VocaColors.emeraldGreen,
            ],
          ),
        ),
      ],
    );
  }
}
