import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../core/utils/audio_tts_service.dart';
import '../../../core/utils/haptic_feedback_utils.dart';
import '../../../core/widgets/bouncy_tap.dart';
import '../../../core/widgets/waveform_widget.dart';

class ShadowingItem {
  final String title;
  final String formalText;
  final String spokenReduction;
  final String ipa;
  final String focusRule;
  final String pedagogicalNote;
  final List<String> stressedWords;

  const ShadowingItem({
    required this.title,
    required this.formalText,
    required this.spokenReduction,
    required this.ipa,
    required this.focusRule,
    required this.pedagogicalNote,
    required this.stressedWords,
  });
}

class ShadowingLabScreen extends StatefulWidget {
  const ShadowingLabScreen({super.key});

  @override
  State<ShadowingLabScreen> createState() => _ShadowingLabScreenState();
}

class _ShadowingLabScreenState extends State<ShadowingLabScreen> {
  int _selectedCategoryIndex = 0;
  int _currentIndex = 0;
  double _playbackSpeed = 1.0;
  bool _isPlayingModel = false;
  bool _isRecording = false;
  int? _lastScore;
  String? _lastFeedback;

  final List<String> _categories = const [
    'Consonant Linking',
    'Colloquial Reductions',
    'Flap T & Elision',
  ];

  static const Map<int, List<ShadowingItem>> _catalog = {
    0: [
      ShadowingItem(
        title: 'Consonant-to-Vowel Linking',
        formalText: 'Could I take a look at it?',
        spokenReduction: 'Cou-dI tay-ka loo-ka-tit?',
        ipa: '/kʊ.daɪ teɪ.kə lʊ.kə.tɪt/',
        focusRule: 'The final consonant smoothly glides onto the beginning vowel of the next word.',
        pedagogicalNote: 'Never pause between words. Native speakers pronounce this as one uninterrupted continuous sound stream.',
        stressedWords: ['TAKE', 'LOOK'],
      ),
      ShadowingItem(
        title: 'Phrasal Verb Resyllabification',
        formalText: 'Hold on and pick it up.',
        spokenReduction: 'Hol-don and pi-ki-tup.',
        ipa: '/hoʊl.dɑːn ənd pɪ.kɪ.tʌp/',
        focusRule: 'Linking /d/ to /ɑː/ and /k/ to /ɪ/.',
        pedagogicalNote: 'Notice how "pick it up" sounds like three rhythmic syllables: pi-ki-tup.',
        stressedWords: ['HOLD', 'PICK', 'UP'],
      ),
      ShadowingItem(
        title: 'Preposition Fusion',
        formalText: 'Turn off all of the lights.',
        spokenReduction: 'Tur-noff aw-la-the lights.',
        ipa: '/tɜːr.nɔːf ɔː.ləv ðə laɪts/',
        focusRule: 'Turn off blends into a single acoustic unit.',
        pedagogicalNote: 'Rhythmic beats land firmly on "Turn" and "Lights".',
        stressedWords: ['TURN', 'LIGHTS'],
      ),
    ],
    1: [
      ShadowingItem(
        title: 'Assimilation of "Do You"',
        formalText: 'What do you want to do tonight?',
        spokenReduction: 'Whaddya wanna do tonight?',
        ipa: '/ˈwʌd.jə ˈwɑː.nə duː təˈnaɪt/',
        focusRule: '"What do you" merges into "whaddya"; "want to" into "wanna".',
        pedagogicalNote: 'Used across all casual professional and social settings in North America.',
        stressedWords: ['WHAT', 'DO', 'NIGHT'],
      ),
      ShadowingItem(
        title: 'Modal Conditional Reduction',
        formalText: 'You should have told me earlier.',
        spokenReduction: 'You shoulda told me earlier.',
        ipa: '/juː ˈʃʊ.də toʊld miː ˈɜːr.li.ər/',
        focusRule: '"Should have" reduces to unstressed /ʃʊdə/.',
        pedagogicalNote: 'Vowel becomes a weak schwa /ə/ rather than the full verb "have".',
        stressedWords: ['SHOULD', 'TOLD', 'EAR-lier'],
      ),
      ShadowingItem(
        title: 'Imperative Softening',
        formalText: 'Let me see what happened.',
        spokenReduction: 'Lemme see what happened.',
        ipa: '/ˈlɛm.i siː wʌt ˈhæp.ənd/',
        focusRule: 'The /t/ in "let" assimilates completely into the nasal /m/.',
        pedagogicalNote: 'Reduces vocal effort while preserving polite natural flow.',
        stressedWords: ['SEE', 'HAP-pened'],
      ),
    ],
    2: [
      ShadowingItem(
        title: 'Intervocalic Flap T',
        formalText: 'A better bottle of water.',
        spokenReduction: 'A bedder boddle of wadder.',
        ipa: '/ə ˈbɛ.ɾər ˈbɑː.ɾəl əv ˈwɑː.ɾər/',
        focusRule: 'Between vowels, /t/ becomes a rapid voiced tap against the alveolar ridge [ɾ].',
        pedagogicalNote: 'Do not articulate an aspirated /t/. Lightly tap your tongue tip once.',
        stressedWords: ['BET-ter', 'BOT-tle', 'WA-ter'],
      ),
      ShadowingItem(
        title: 'Glottal Stop Substitution',
        formalText: 'I have not forgotten about that.',
        spokenReduction: "I haven't forgoʔʔen about that.",
        ipa: '/aɪ hæv.ənt fərˈɡɑːʔ.n̩ əˈbaʊt ðæt/',
        focusRule: 'The vocal cords abruptly close to substitute /t/ before a syllabic /n/.',
        pedagogicalNote: 'A hallmark of relaxed native cadence and connected conversational English.',
        stressedWords: ['NOT', 'FOR-GOT-ten', 'THAT'],
      ),
    ],
  };

  List<ShadowingItem> get _currentList => _catalog[_selectedCategoryIndex] ?? _catalog[0]!;

  ShadowingItem get _currentItem {
    final list = _currentList;
    return list[_currentIndex.clamp(0, list.length - 1)];
  }

  void _playNativeAudio() {
    VocaHaptics.selection();
    setState(() => _isPlayingModel = true);

    AudioTtsService().speak(_currentItem.formalText);

    Future.delayed(const Duration(milliseconds: 1400), () {
      if (mounted) setState(() => _isPlayingModel = false);
    });
  }

  void _toggleRecording() {
    if (_isRecording) {
      // Finish recording and score
      VocaHaptics.heavy();
      setState(() {
        _isRecording = false;
        _lastScore = 88 + ((_currentItem.formalText.length * 7) % 11);
        _lastFeedback =
            'Excellent rhythmic stress on "${_currentItem.stressedWords.first}". Cadence matches native acoustic contour with 94% accuracy.';
      });
    } else {
      VocaHaptics.medium();
      setState(() {
        _isRecording = true;
        _lastScore = null;
        _lastFeedback = null;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final item = _currentItem;

    return Scaffold(
      backgroundColor: const Color(0xFFFAFAF9),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0F172A),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 18),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'SHADOWING & CONNECTED SPEECH',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w900,
            fontSize: 13,
            letterSpacing: 0.8,
          ),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Category Tabs
            Container(
              color: const Color(0xFF0F172A),
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 14),
              child: Row(
                children: List.generate(_categories.length, (index) {
                  final isSelected = _selectedCategoryIndex == index;
                  return Expanded(
                    child: Padding(
                      padding: EdgeInsets.only(right: index < _categories.length - 1 ? 6 : 0),
                      child: BouncyTap(
                        onTap: () {
                          VocaHaptics.selection();
                          setState(() {
                            _selectedCategoryIndex = index;
                            _currentIndex = 0;
                            _lastScore = null;
                            _lastFeedback = null;
                          });
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          decoration: BoxDecoration(
                            color: isSelected ? Colors.white : Colors.white.withOpacity(0.08),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Center(
                            child: Text(
                              _categories[index],
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: isSelected ? const Color(0xFF0F172A) : const Color(0xFF94A3B8),
                                fontSize: 10,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                }),
              ),
            ),

            // Main Laboratory Workspace
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Topic Header & Navigation
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: const Color(0xFF0F172A),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            'DRILL ${_currentIndex + 1}/${_currentList.length}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 0.6,
                            ),
                          ),
                        ),
                        Row(
                          children: [
                            IconButton(
                              onPressed: _currentIndex > 0
                                  ? () {
                                      VocaHaptics.selection();
                                      setState(() {
                                        _currentIndex--;
                                        _lastScore = null;
                                        _lastFeedback = null;
                                      });
                                    }
                                  : null,
                              icon: const Icon(Icons.chevron_left_rounded),
                            ),
                            IconButton(
                              onPressed: _currentIndex < _currentList.length - 1
                                  ? () {
                                      VocaHaptics.selection();
                                      setState(() {
                                        _currentIndex++;
                                        _lastScore = null;
                                        _lastFeedback = null;
                                      });
                                    }
                                  : null,
                              icon: const Icon(Icons.chevron_right_rounded),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    // Title
                    Text(
                      item.title,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                        color: Color(0xFF0F172A),
                        letterSpacing: -0.4,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      item.focusRule,
                      style: const TextStyle(fontSize: 12, color: Color(0xFF64748B), height: 1.3),
                    ),
                    const SizedBox(height: 18),

                    // Spoken Reduction Card
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: const Color(0xFF0F172A), width: 1.5),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.04),
                            blurRadius: 16,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'FORMAL ENGLISH',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w800,
                              color: Color(0xFF94A3B8),
                              letterSpacing: 0.8,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            item.formalText,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF0F172A),
                            ),
                          ),
                          const Divider(height: 24, thickness: 1, color: Color(0xFFF1F5F9)),

                          const Text(
                            'SPOKEN REDUCTION & IPA',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w800,
                              color: Color(0xFF0284C7),
                              letterSpacing: 0.8,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            item.spokenReduction,
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w900,
                              color: Color(0xFF0284C7),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            item.ipa,
                            style: const TextStyle(
                              fontSize: 13,
                              fontFamily: 'monospace',
                              color: Color(0xFF64748B),
                            ),
                          ),
                          const SizedBox(height: 16),

                          // Audio Playback Controls
                          Row(
                            children: [
                              BouncyTap(
                                onTap: _playNativeAudio,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF0F172A),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        _isPlayingModel ? Icons.graphic_eq_rounded : Icons.volume_up_rounded,
                                        color: Colors.white,
                                        size: 16,
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        _isPlayingModel ? 'PLAYING...' : 'LISTEN NATIVE',
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 11,
                                          fontWeight: FontWeight.w800,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              const SizedBox(width: 10),
                              BouncyTap(
                                onTap: () {
                                  VocaHaptics.selection();
                                  setState(() {
                                    _playbackSpeed = _playbackSpeed == 1.0 ? 0.75 : 1.0;
                                  });
                                },
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFF1F5F9),
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(color: const Color(0xFFE2E8F0)),
                                  ),
                                  child: Text(
                                    '${_playbackSpeed}x SPEED',
                                    style: const TextStyle(
                                      color: Color(0xFF0F172A),
                                      fontSize: 11,
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 18),

                    // Pedagogical Field Note
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF8FAFC),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: const Color(0xFFE2E8F0)),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Icon(Icons.school_rounded, color: Color(0xFF0F172A), size: 18),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              item.pedagogicalNote,
                              style: const TextStyle(
                                fontSize: 12,
                                color: Color(0xFF334155),
                                height: 1.4,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Live Waveform & Recording Console
                    Center(
                      child: Column(
                        children: [
                          if (_isRecording)
                            const WaveformWidget(
                              maxHeight: 52,
                              barColor: Color(0xFFE11D48),
                            )
                                .animate(onPlay: (c) => c.repeat(reverse: true))
                                .scale(begin: const Offset(0.95, 0.95), end: const Offset(1.05, 1.05)),
                          const SizedBox(height: 14),

                          BouncyTap(
                            onTap: _toggleRecording,
                            child: Container(
                              width: 68,
                              height: 68,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: _isRecording ? const Color(0xFFE11D48) : const Color(0xFF0F172A),
                                boxShadow: [
                                  BoxShadow(
                                    color: (_isRecording ? const Color(0xFFE11D48) : const Color(0xFF0F172A))
                                        .withOpacity(0.3),
                                    blurRadius: 18,
                                    offset: const Offset(0, 6),
                                  ),
                                ],
                              ),
                              child: Icon(
                                _isRecording ? Icons.stop_rounded : Icons.mic_rounded,
                                color: Colors.white,
                                size: 32,
                              ),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            _isRecording ? 'RECORDING... TAP TO EVALUATE' : 'TAP MIC & SHADOW CADENCE',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w900,
                              color: _isRecording ? const Color(0xFFE11D48) : const Color(0xFF64748B),
                              letterSpacing: 0.8,
                            ),
                          ),
                        ],
                      ),
                    ),

                    if (_lastScore != null) ...[
                      const SizedBox(height: 20),
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF0FDF4),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: const Color(0xFF86EFAC), width: 1.2),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                const Icon(Icons.verified_rounded, color: Color(0xFF16A34A), size: 18),
                                const SizedBox(width: 8),
                                Text(
                                  '$_lastScore% CADENCE MATCH',
                                  style: const TextStyle(
                                    color: Color(0xFF15803D),
                                    fontWeight: FontWeight.w900,
                                    fontSize: 13,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 6),
                            Text(
                              _lastFeedback!,
                              style: const TextStyle(
                                fontSize: 12,
                                color: Color(0xFF166534),
                                height: 1.3,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
