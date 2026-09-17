import 'package:confetti/confetti.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../core/theme/voca_colors.dart';
import '../../../core/utils/sound_effects.dart';
import '../../../core/widgets/celebration_dialog.dart';
import '../../../core/storage/local_storage_service.dart';
import '../models/exercise.dart';
import '../models/tactical_card.dart';
import '../widgets/action_drawer.dart';
import '../widgets/cloze_fill_drill.dart';
import '../widgets/exercise_header.dart';
import '../widgets/picture_choice_drill.dart';
import '../widgets/scramble_drill.dart';
import '../widgets/shadowing_drill.dart';
import '../widgets/syllable_stress_drill.dart';
import '../widgets/tactical_cards_bar.dart';

class LessonScreen extends StatefulWidget {
  final String lessonTitle;
  final List<ExerciseModel>? customExercises;
  final VoidCallback? onCompleted;

  const LessonScreen({
    super.key,
    this.lessonTitle = 'Nivel 1-1: Saludos y Presentaciones',
    this.customExercises,
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

  // Tactical Perk Cards States
  bool _isShieldActive = false;
  bool _isDoubleXpActive = false;
  final Set<String> _disabledClozeOptions = {};
  final Set<String> _disabledPictureOptionIds = {};

  // Exercise 1: Scramble
  final List<String> _selectedScrambleWords = [];

  // Exercise 2: Cloze Fill
  String? _selectedClozeAnswer;

  // Exercise 3: Syllable Stress
  int? _selectedSyllableIndex;

  // Exercise 4: Picture Choice
  String? _selectedPictureOptionId;

  // Exercise 5: Shadowing
  bool _isShadowingRecorded = false;

  late final List<ExerciseModel> _exercises;

  @override
  void initState() {
    super.initState();
    _confettiController = ConfettiController(duration: const Duration(seconds: 3));

    if (widget.customExercises != null && widget.customExercises!.isNotEmpty) {
      _exercises = widget.customExercises!;
    } else {
      _exercises = const [
        ExerciseModel(
          id: 'ex_scramble',
          type: DrillType.sentenceScramble,
          prompt: 'Arrange the words to say:',
          subtitle: '"Hello, nice to meet you, my name is Alex."',
          trickTip: 'Consejo: En inglés natural, decir "Nice to meet you" es el saludo amigable por excelencia.',
          targetSentenceWords: ['Hello,', 'nice', 'to', 'meet', 'you,', 'my', 'name', 'is', 'Alex.'],
          bankWords: ['nice', 'Alex.', 'is', 'Hello,', 'goodbye', 'to', 'meet', 'my', 'coffee', 'you,', 'name'],
        ),
        ExerciseModel(
          id: 'ex_cloze',
          type: DrillType.clozeFill,
          prompt: 'Completa con la forma correcta del verbo "to be":',
          subtitle: 'Presente simple para presentaciones',
          trickTip: 'Regla: Con "My name" (tercera persona singular "it"), siempre usamos "is".',
          clozePrefix: 'Hi! My name',
          clozeSuffix: 'Emma. What is your name?',
          clozeOptions: ['is', 'are', 'am', 'be'],
          correctClozeAnswer: 'is',
        ),
        ExerciseModel(
          id: 'ex_stress',
          type: DrillType.syllableStress,
          prompt: 'Toca la sílaba con mayor acento:',
          subtitle: '¿Dónde recae el énfasis de la palabra?',
          trickTip: 'El acento en "WELCOME" recae con fuerza en la primera sílaba: /ˈwɛl.kəm/.',
          ipaPhonetic: '/ˈwɛl.kəm/',
          syllables: ['WEL', 'COME'],
          correctSyllableIndex: 0,
        ),
        ExerciseModel(
          id: 'ex_choice',
          type: DrillType.pictureChoice,
          prompt: '¿Cómo respondes cordialmente a "Nice to meet you"?',
          subtitle: 'Selecciona la respuesta conversacional adecuada',
          pictureOptions: [
            PictureChoiceOption(
              id: 'opt_meet_too',
              label: 'Nice to meet you too!',
              audioPhonetic: '/naɪs tuː miːt juː tuː/',
              isCorrect: true,
            ),
            PictureChoiceOption(
              id: 'opt_bye',
              label: 'Goodbye, see you!',
              audioPhonetic: '/ɡʊdˈbaɪ siː juː/',
              isCorrect: false,
            ),
            PictureChoiceOption(
              id: 'opt_no',
              label: 'No, thank you.',
              audioPhonetic: '/noʊ θæŋk juː/',
              isCorrect: false,
            ),
            PictureChoiceOption(
              id: 'opt_what',
              label: 'What is this?',
              audioPhonetic: '/wʌt ɪz ðɪs/',
              isCorrect: false,
            ),
          ],
        ),
        ExerciseModel(
          id: 'ex_shadow',
          type: DrillType.shadowing,
          prompt: 'Pronuncia esta frase en voz alta:',
          targetSpeechText: '"Hello! It is wonderful to meet you. My name is Alex."',
          phoneticTokens: ['[heh-LOH]', '[it iz]', '[WUHN-der-ful]', '[to meet yoo]', '[my naym iz AL-eks]'],
          expectedAccentTip: 'Enlaza con suavidad "It is" -> suena fluido como "it-iz".',
        ),
      ];
    }
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
      case DrillType.clozeFill:
        return _selectedClozeAnswer != null;
      case DrillType.syllableStress:
        return _selectedSyllableIndex != null;
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
      case DrillType.clozeFill:
        isCorrect = _selectedClozeAnswer == currentEx.correctClozeAnswer;
        break;
      case DrillType.syllableStress:
        isCorrect = _selectedSyllableIndex == currentEx.correctSyllableIndex;
        break;
      case DrillType.pictureChoice:
        final selectedOpt = currentEx.pictureOptions.firstWhere(
          (o) => o.id == _selectedPictureOptionId,
          orElse: () => currentEx.pictureOptions.first,
        );
        isCorrect = selectedOpt.isCorrect;
        break;
      case DrillType.shadowing:
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
      if (_isShieldActive) {
        TacticalCard.use(TacticalCardType.shield);
        setState(() {
          _isShieldActive = false;
          _drawerState = DrawerState.error;
        });
        _showPerkMessage('🛡️ ¡Escudo activado! Tu corazón ha sido protegido del error.');
      } else {
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
  }

  void _showPerkMessage(String message, {bool isError = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: const TextStyle(fontWeight: FontWeight.w600, color: Colors.white, fontSize: 13),
        ),
        backgroundColor: isError ? const Color(0xFFE11D48) : const Color(0xFF0F172A),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  void _onUseShield() {
    if (_isShieldActive) {
      setState(() => _isShieldActive = false);
      _showPerkMessage('🛡️ Escudo desactivado.');
      return;
    }
    final count = TacticalCard.getCount(TacticalCardType.shield);
    if (count <= 0) {
      _showPerkMessage('No tienes cartas de Escudo disponibles. ¡Gana más al completar lecciones!', isError: true);
      return;
    }
    setState(() => _isShieldActive = true);
    _showPerkMessage('🛡️ ¡Escudo activado! Tu próximo error no costará corazones.');
  }

  void _onUseClue() {
    final count = TacticalCard.getCount(TacticalCardType.clue);
    if (count <= 0) {
      _showPerkMessage('No tienes cartas de Pista disponibles. ¡Gana más al completar lecciones!', isError: true);
      return;
    }

    final currentEx = _exercises[_currentIndex];
    bool applied = false;

    switch (currentEx.type) {
      case DrillType.sentenceScramble:
        final currentLen = _selectedScrambleWords.length;
        if (currentLen < currentEx.targetSentenceWords.length) {
          final nextWord = currentEx.targetSentenceWords[currentLen];
          setState(() {
            _selectedScrambleWords.add(nextWord);
          });
          applied = true;
          _showPerkMessage('💡 ¡Pista aplicada! Se colocó la palabra "$nextWord".');
        } else {
          _showPerkMessage('Ya has colocado todas las palabras de la oración.');
        }
        break;

      case DrillType.clozeFill:
        final wrongOptions = currentEx.clozeOptions
            .where((opt) => opt != currentEx.correctClozeAnswer && !_disabledClozeOptions.contains(opt))
            .take(2)
            .toList();
        if (wrongOptions.isNotEmpty) {
          setState(() {
            _disabledClozeOptions.addAll(wrongOptions);
            if (_selectedClozeAnswer != null && wrongOptions.contains(_selectedClozeAnswer)) {
              _selectedClozeAnswer = null;
            }
          });
          applied = true;
          _showPerkMessage('💡 ¡Pista 50/50! Se descartaron ${wrongOptions.length} opciones erróneas.');
        } else {
          _showPerkMessage('Ya no quedan opciones incorrectas por descartar.');
        }
        break;

      case DrillType.pictureChoice:
        final wrongOptions = currentEx.pictureOptions
            .where((opt) => !opt.isCorrect && !_disabledPictureOptionIds.contains(opt.id))
            .take(2)
            .toList();
        if (wrongOptions.isNotEmpty) {
          setState(() {
            _disabledPictureOptionIds.addAll(wrongOptions.map((o) => o.id));
            if (_selectedPictureOptionId != null && _disabledPictureOptionIds.contains(_selectedPictureOptionId)) {
              _selectedPictureOptionId = null;
            }
          });
          applied = true;
          _showPerkMessage('💡 ¡Pista 50/50! Opciones incorrectas descartadas.');
        } else {
          _showPerkMessage('Ya no quedan opciones incorrectas por descartar.');
        }
        break;

      case DrillType.syllableStress:
        setState(() {
          _selectedSyllableIndex = currentEx.correctSyllableIndex;
        });
        applied = true;
        _showPerkMessage('💡 ¡Pista aplicada! Sílaba acentuada seleccionada.');
        break;

      case DrillType.shadowing:
        setState(() {
          _isShadowingRecorded = true;
        });
        applied = true;
        _showPerkMessage('💡 ¡Pronunciación validada con éxito!');
        break;
    }

    if (applied) {
      TacticalCard.use(TacticalCardType.clue);
    }
  }

  void _onUseSkip() {
    final count = TacticalCard.getCount(TacticalCardType.skip);
    if (count <= 0) {
      _showPerkMessage('No tienes cartas de Salto disponibles. ¡Gana más al completar lecciones!', isError: true);
      return;
    }
    TacticalCard.use(TacticalCardType.skip);
    _showPerkMessage('⏭️ ¡Pregunta saltada sin penalización!');
    _onContinue();
  }

  void _onUseDoubleXp() {
    if (_isDoubleXpActive) {
      _showPerkMessage('⚡ El multiplicador 2x XP ya está activo para esta lección.');
      return;
    }
    final count = TacticalCard.getCount(TacticalCardType.doubleXp);
    if (count <= 0) {
      _showPerkMessage('No tienes cartas de 2x XP disponibles. ¡Gana más al completar lecciones!', isError: true);
      return;
    }
    TacticalCard.use(TacticalCardType.doubleXp);
    setState(() => _isDoubleXpActive = true);
    _showPerkMessage('⚡ ¡2x XP activado! Ganarás el doble de experiencia al finalizar.');
  }

  void _onContinue() {
    if (_currentIndex < _exercises.length - 1) {
      setState(() {
        _currentIndex++;
        _drawerState = DrawerState.standard;
        _selectedScrambleWords.clear();
        _selectedClozeAnswer = null;
        _selectedSyllableIndex = null;
        _selectedPictureOptionId = null;
        _isShadowingRecorded = false;
        _disabledClozeOptions.clear();
        _disabledPictureOptionIds.clear();
      });
    } else {
      // Completed all drills!
      final totalXp = _isDoubleXpActive ? 50 : 25;
      LocalStorageService().addXp(totalXp);
      SoundEffects.playCelebration();
      _confettiController.play();
      _showCompletionDialog(totalXp);
    }
  }

  void _onGotIt() {
    setState(() {
      _drawerState = DrawerState.standard;
    });
  }

  void _showCompletionDialog(int xpGained) {
    CelebrationDialog.show(
      context,
      title: 'LESSON COMPLETED!',
      subtitle: _isDoubleXpActive ? 'Speech reinforced • 2x XP Boost applied!' : 'Speech rhythm & vocabulary reinforced',
      xpEarned: xpGained,
      accuracyPercent: 96,
      streakDays: LocalStorageService().getStreak(),
      characterId: 'alex',
      onContinue: () {
        if (widget.onCompleted != null) {
          widget.onCompleted!();
        } else {
          Navigator.of(context).pop();
        }
      },
    );
  }

  String _getCorrectAnswer(ExerciseModel currentEx) {
    switch (currentEx.type) {
      case DrillType.sentenceScramble:
        return currentEx.targetSentenceWords.join(' ');
      case DrillType.clozeFill:
        return currentEx.correctClozeAnswer;
      case DrillType.syllableStress:
        return (currentEx.syllables.isNotEmpty &&
                currentEx.correctSyllableIndex < currentEx.syllables.length)
            ? currentEx.syllables[currentEx.correctSyllableIndex]
            : '';
      case DrillType.pictureChoice:
        final correct = currentEx.pictureOptions.where((o) => o.isCorrect);
        return correct.isNotEmpty ? correct.first.label : '';
      case DrillType.shadowing:
        return currentEx.targetSpeechText;
    }
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
      case DrillType.clozeFill:
        drillBody = ClozeFillDrill(
          exercise: currentEx,
          selectedAnswer: _selectedClozeAnswer,
          disabledOptions: _disabledClozeOptions,
          onAnswerSelected: (ans) {
            setState(() => _selectedClozeAnswer = ans);
          },
        );
        break;
      case DrillType.syllableStress:
        drillBody = SyllableStressDrill(
          exercise: currentEx,
          selectedIndex: _selectedSyllableIndex,
          onIndexSelected: (idx) {
            setState(() => _selectedSyllableIndex = idx);
          },
        );
        break;
      case DrillType.pictureChoice:
        drillBody = PictureChoiceDrill(
          exercise: currentEx,
          selectedOptionId: _selectedPictureOptionId,
          disabledOptionIds: _disabledPictureOptionIds,
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

          // Roguelike Tactical Support Cards Bar
          TacticalCardsBar(
            isShieldActive: _isShieldActive,
            isDoubleXpActive: _isDoubleXpActive,
            onUseShield: _onUseShield,
            onUseClue: _onUseClue,
            onUseSkip: _onUseSkip,
            onUseDoubleXp: _onUseDoubleXp,
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
            correctAnswer: _getCorrectAnswer(currentEx),
            tip: currentEx.trickTip.isNotEmpty
                ? currentEx.trickTip
                : 'Focus on native rhythm and clear vowel intonation.',
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
