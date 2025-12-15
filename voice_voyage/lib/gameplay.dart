import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'profile_helper.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:http/http.dart' as http;
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

class GameplayScreen extends StatefulWidget {
  final int levelNumber;
  final String targetWord; // kept for compatibility (not used)
  final String prompt; // kept for compatibility (not used)
  final String backgroundImagePath;
  final String characterImagePath;
  final int currentStars;
  final String category; // e.g. 'greetings', 'animals', 'colors'

  const GameplayScreen({
    Key? key,
    required this.levelNumber,
    required this.targetWord,
    required this.prompt,
    required this.backgroundImagePath,
    required this.characterImagePath,
    required this.currentStars,
    required this.category,
  }) : super(key: key);

  @override
  State<GameplayScreen> createState() => _GameplayScreenState();
}

class _PhraseStep {
  final String referenceText; // what Azure grades against
  final String promptText; // what you show on screen
  final String successMessage;

  const _PhraseStep({
    required this.referenceText,
    required this.promptText,
    required this.successMessage,
  });
}

class _GameplayScreenState extends State<GameplayScreen>
    with SingleTickerProviderStateMixin {
  // UI state
  bool isRecording = false;
  bool showFeedback = false;
  bool showLevelComplete = false;
  bool isCorrect = false;
  String feedbackMessage = "";

  // Animation
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  // Recorder
  late FlutterSoundRecorder _recorder;
  bool _recorderReady = false;
  String? _audioFilePath;

  // Azure
  static const String _speechKey =
      "7iyT7N6LiE2S99igEjCvt3NHZEy8xCfPsxQLzN60sZcEqGn4F5HKJQQJ99BKAC3pKaRXJ3w3AAAYACOGzpew";
  static const String _region = "eastasia";
  static const String _language = "en-US";

  // Scores (shown in UI)
  double accuracyScore = 0.0;
  double fluencyScore = 0.0;
  double pronScore = 0.0;

  // User name
  final String userName = "Bensoy";

  // Level script (3 phrases per level)
  late final List<_PhraseStep> _steps;
  int _stepIndex = 0;

  _PhraseStep get _currentStep => _steps[_stepIndex];

  @override
  void initState() {
    super.initState();

    // Pick script by category + level
    _steps = _getStepsForLevel(widget.category, widget.levelNumber, userName);

    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.1).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _recorder = FlutterSoundRecorder();
    _initializeRecorder();
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _recorder.closeRecorder();
    super.dispose();
  }

  List<_PhraseStep> _getStepsForLevel(String category, int level, String name) {
    // Animals (3 levels)
    if (category == 'animals') {
      switch (level) {
        case 1:
          return const [
            _PhraseStep(
              referenceText: "Cow",
              promptText: "Can you say “Cow”?",
              successMessage: "Great job!",
            ),
            _PhraseStep(
              referenceText: "Pig",
              promptText: "Now say “Pig”",
              successMessage: "Well done!",
            ),
            _PhraseStep(
              referenceText: "Chicken",
              promptText: "Now say “Chicken”",
              successMessage: "Awesome!",
            ),
          ].map((s) => _PhraseStep(
                referenceText: s.referenceText,
                promptText: s.promptText,
                successMessage: "${s.successMessage} $name!",
              )).toList();

        case 2:
          return const [
            _PhraseStep(
              referenceText: "Lion",
              promptText: "Can you say “Lion”?",
              successMessage: "Roar-some!",
            ),
            _PhraseStep(
              referenceText: "Tiger",
              promptText: "Now say “Tiger”",
              successMessage: "Great job!",
            ),
            _PhraseStep(
              referenceText: "Elephant",
              promptText: "Now say “Elephant”",
              successMessage: "Excellent!",
            ),
          ].map((s) => _PhraseStep(
                referenceText: s.referenceText,
                promptText: s.promptText,
                successMessage: "${s.successMessage} $name!",
              )).toList();

        case 3:
          return const [
            _PhraseStep(
              referenceText: "Farm animal",
              promptText: "Can you say “Farm animal”?",
              successMessage: "Nice!",
            ),
            _PhraseStep(
              referenceText: "Wild animal",
              promptText: "Now say “Wild animal”",
              successMessage: "Good job!",
            ),
            _PhraseStep(
              referenceText: "I can name the animals",
              promptText: "Now say “I can name the animals”",
              successMessage: "You did it!",
            ),
          ].map((s) => _PhraseStep(
                referenceText: s.referenceText,
                promptText: s.promptText,
                successMessage: "${s.successMessage} $name!",
              )).toList();

        default:
          return [
            _PhraseStep(
              referenceText: "Animal",
              promptText: "Can you say “Animal”?",
              successMessage: "Good job, $name!",
            ),
          ];
      }
    }

    // Colors (3 levels)
    if (category == 'colors') {
      switch (level) {
        case 1:
          return [
            _PhraseStep(
              referenceText: "Red",
              promptText: "Can you say “Red”?",
              successMessage: "Great job, $name!",
            ),
            _PhraseStep(
              referenceText: "Blue",
              promptText: "Now say “Blue”",
              successMessage: "Well done, $name!",
            ),
            _PhraseStep(
              referenceText: "Yellow",
              promptText: "Now say “Yellow”",
              successMessage: "Awesome, $name!",
            ),
          ];

        case 2:
          return [
            _PhraseStep(
              referenceText: "Green",
              promptText: "Can you say “Green”?",
              successMessage: "Nice, $name!",
            ),
            _PhraseStep(
              referenceText: "Orange",
              promptText: "Now say “Orange”",
              successMessage: "Great job, $name!",
            ),
            _PhraseStep(
              referenceText: "Purple",
              promptText: "Now say “Purple”",
              successMessage: "Excellent, $name!",
            ),
          ];

        case 3:
          return [
            _PhraseStep(
              referenceText: "Rainbow",
              promptText: "Can you say “Rainbow”?",
              successMessage: "Amazing, $name!",
            ),
            _PhraseStep(
              referenceText: "I see colors",
              promptText: "Now say “I see colors”",
              successMessage: "Good job, $name!",
            ),
            _PhraseStep(
              referenceText: "I can name the colors",
              promptText: "Now say “I can name the colors”",
              successMessage: "You did it, $name!",
            ),
          ];

        default:
          return [
            _PhraseStep(
              referenceText: "Color",
              promptText: "Can you say “Color”?",
              successMessage: "Good job, $name!",
            ),
          ];
      }
    }

    // Greetings (your existing 3 levels)
    switch (level) {
      case 1:
        return [
          _PhraseStep(
            referenceText: "Hello",
            promptText: "Can you say “Hello” to your friend?",
            successMessage: "Very good, $name!",
          ),
          _PhraseStep(
            referenceText: "Hello friend",
            promptText: "Can you say “Hello friend”?",
            successMessage: "Well done, $name!",
          ),
          _PhraseStep(
            referenceText: "Hello friend, how are you?",
            promptText: "Can you say “Hello friend, how are you?”",
            successMessage: "You’re amazing, $name!",
          ),
        ];

      case 2:
        return [
          _PhraseStep(
            referenceText: "Good morning, Mom",
            promptText: "At home, can you say: “Good morning, Mom”?",
            successMessage: "Nice greeting, $name!",
          ),
          _PhraseStep(
            referenceText: "Good morning, Dad",
            promptText: "Now try: “Good morning, Dad”",
            successMessage: "Great job, $name!",
          ),
          _PhraseStep(
            referenceText: "Good morning, Mom and Dad",
            promptText: "Now say: “Good morning, Mom and Dad”",
            successMessage: "Perfect, $name!",
          ),
        ];

      case 3:
        return [
          _PhraseStep(
            referenceText: "Good morning, Teacher",
            promptText: "In school, say: “Good morning, Teacher”",
            successMessage: "So polite, $name!",
          ),
          _PhraseStep(
            referenceText: "Good morning, everyone",
            promptText: "Now greet the class: “Good morning, everyone”",
            successMessage: "Awesome, $name!",
          ),
          _PhraseStep(
            referenceText: "Good morning, Teacher. Good morning, everyone",
            promptText:
                "Try both: “Good morning, Teacher. Good morning, everyone”",
            successMessage: "You did it, $name!",
          ),
        ];

      default:
        return [
          _PhraseStep(
            referenceText: "Hello",
            promptText: "Can you say “Hello”?",
            successMessage: "Good job, $name!",
          ),
        ];
    }
  }

  Future<void> _initializeRecorder() async {
    final micStatus = await Permission.microphone.request();
    if (micStatus != PermissionStatus.granted) {
      print("❌ Microphone permission denied: $micStatus");
      return;
    }
    await _recorder.openRecorder();
    _recorderReady = true;
    print("✅ Recorder ready");
  }

  Future<String> _getTempFilePath() async {
    final dir = await getTemporaryDirectory();
    return p.join(dir.path, 'rec_${DateTime.now().millisecondsSinceEpoch}.wav');
  }

  void _startRecording() async {
    if (!_recorderReady || isRecording || showLevelComplete) return;

    setState(() {
      isRecording = true;
      showFeedback = false;
    });

    final path = await _getTempFilePath();
    _audioFilePath = path;

    print("🎙 START recording -> $path");
    await _recorder.startRecorder(
      toFile: path,
      codec: Codec.pcm16WAV,
      sampleRate: 16000,
      numChannels: 1,
    );
  }

  void _stopRecordingAndAnalyze() async {
    if (!isRecording) return;

    setState(() {
      isRecording = false;
    });

    await _recorder.stopRecorder();
    print("⏹️ Recording stopped");

    if (_audioFilePath == null) {
      _showFeedback(false);
      return;
    }

    await _sendToAzurePronunciationAssessment();
    await _cleanupAudioFile();
  }

  double _readScoreFromNBest(Map<String, dynamic> nBest0, String key) {
    final pa = nBest0['PronunciationAssessment'];
    if (pa is Map && pa[key] != null) {
      final v = pa[key];
      if (v is num) return v.toDouble();
    }
    final v2 = nBest0[key];
    if (v2 is num) return v2.toDouble();
    return 0.0;
  }

  Future<void> _sendToAzurePronunciationAssessment() async {
    final path = _audioFilePath;
    if (path == null) {
      _showFeedback(false);
      return;
    }

    final file = File(path);
    if (!await file.exists()) {
      print("❌ Audio file does not exist");
      _showFeedback(false);
      return;
    }

    try {
      final token = await _getAzureAccessToken();
      if (token == null) {
        _showFeedback(false);
        return;
      }

      final pronAssessmentJson = jsonEncode({
        "ReferenceText": _currentStep.referenceText.trim(),
        "GradingSystem": "HundredMark",
        "Granularity": "FullText",
        "Dimension": "Comprehensive",
      });
      final pronAssessmentBase64 =
          base64Encode(utf8.encode(pronAssessmentJson));

      final uri = Uri.parse(
        "https://$_region.stt.speech.microsoft.com/speech/recognition/conversation/cognitiveservices/v1"
        "?language=$_language&format=detailed&scenario=pronunciation",
      );

      final response = await http.post(
        uri,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'audio/wav; codecs=audio/pcm; samplerate=16000',
          'Pronunciation-Assessment': pronAssessmentBase64,
          'Accept': 'application/json',
        },
        body: await file.readAsBytes(),
      );

      print("📡 Azure status: ${response.statusCode}");
      print("📡 Azure body: ${response.body}");

      if (response.statusCode != 200) {
        if (!mounted) return;
        setState(() {
          accuracyScore = 0.0;
          fluencyScore = 0.0;
          pronScore = 0.0;
        });
        _showFeedback(false);
        return;
      }

      final data = jsonDecode(response.body);
      final List nBest = (data['NBest'] ?? []) as List;

      if (nBest.isEmpty) {
        if (!mounted) return;
        setState(() {
          accuracyScore = 0.0;
          fluencyScore = 0.0;
          pronScore = 0.0;
        });
        _showFeedback(false);
        return;
      }

      final Map<String, dynamic> nBest0 =
          Map<String, dynamic>.from(nBest[0] as Map);

      final acc = _readScoreFromNBest(nBest0, 'AccuracyScore');
      final flu = _readScoreFromNBest(nBest0, 'FluencyScore');
      final pro = _readScoreFromNBest(nBest0, 'PronScore');

      final passed = acc >= 70.0;

      if (!mounted) return;
      setState(() {
        accuracyScore = acc;
        fluencyScore = flu;
        pronScore = pro;
      });

      _showFeedback(passed);
    } catch (e) {
      print("❌ Error calling Azure: $e");
      if (!mounted) return;
      setState(() {
        accuracyScore = 0.0;
        fluencyScore = 0.0;
        pronScore = 0.0;
      });
      _showFeedback(false);
    }
  }

  Future<String?> _getAzureAccessToken() async {
    try {
      final uri = Uri.parse(
        "https://$_region.api.cognitive.microsoft.com/sts/v1.0/issueToken",
      );
      final response = await http.post(
        uri,
        headers: {
          'Ocp-Apim-Subscription-Key': _speechKey,
          'Content-type': 'application/x-www-form-urlencoded',
          'Content-Length': '0',
        },
      );
      if (response.statusCode == 200) return response.body.trim();
      print("❌ Token request failed: ${response.statusCode} ${response.body}");
      return null;
    } catch (e) {
      print("❌ Error getting token: $e");
      return null;
    }
  }

  Future<void> _cleanupAudioFile() async {
    final path = _audioFilePath;
    _audioFilePath = null;
    if (path == null) return;
    try {
      final f = File(path);
      if (await f.exists()) {
        await f.delete();
        print("🗑️ Temp audio deleted");
      }
    } catch (e) {
      print("Cleanup error: $e");
    }
  }

  void _showFeedback(bool correct) {
    if (!mounted) return;

    setState(() {
      isCorrect = correct;
      showFeedback = true;
      feedbackMessage = correct ? _currentStep.successMessage : "Try again!";
    });

    Future.delayed(const Duration(seconds: 2), () {
      if (!mounted) return;

      setState(() {
        showFeedback = false;
      });

      if (!correct) return;

      if (_stepIndex < _steps.length - 1) {
        setState(() {
          _stepIndex++;
        });
      } else {
        setState(() {
          showLevelComplete = true;
        });
        _saveProgress();
      }
    });
  }

  Future<void> _saveProgress() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final profileId = prefs.getString('selectedProfileId');
      if (profileId == null) {
        print('No selectedProfileId found; skipping saveProgress');
        return;
      }

      await ProfileHelper.saveProgress(
        profileId: profileId,
        category: widget.category,
        level: widget.levelNumber,
        score: accuracyScore,
      );
      print(
          'Progress saved: $profileId ${widget.category} level ${widget.levelNumber} -> $accuracyScore');
    } catch (e) {
      print('Error saving progress in gameplay: $e');
    }
  }

  void _playPromptAudio() {
    print('🔊 Play: "${_currentStep.referenceText}"');
  }

  void _onLevelCompleteOkay() {
    if (!mounted) return;
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(widget.backgroundImagePath, fit: BoxFit.cover),
          ),
          SafeArea(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: IconButton(
                          icon: const Icon(Icons.arrow_back,
                              color: Colors.black87),
                          onPressed: () => Navigator.pop(context),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 24),
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.5),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Text(
                    showLevelComplete
                        ? "Level Complete!"
                        : _currentStep.promptText,
                    style: const TextStyle(
                      fontSize: 25,
                      fontWeight: FontWeight.w900,
                      color: Color.fromARGB(221, 0, 0, 0),
                      height: 1.3,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                const Spacer(),
                const Spacer(),
                Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 40, vertical: 40),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _buildControlButton(
                        icon: Icons.play_arrow,
                        color: Colors.green,
                        onPressed: _playPromptAudio,
                      ),
                      const SizedBox(width: 40),
                      GestureDetector(
                        onTapDown: (_) => _startRecording(),
                        onTapUp: (_) => _stopRecordingAndAnalyze(),
                        onTapCancel: () => _stopRecordingAndAnalyze(),
                        child: AnimatedBuilder(
                          animation: _pulseAnimation,
                          builder: (context, child) {
                            return Transform.scale(
                              scale: isRecording ? _pulseAnimation.value : 1.0,
                              child: Container(
                                width: 80,
                                height: 80,
                                decoration: BoxDecoration(
                                  color: isRecording ? Colors.red : Colors.white,
                                  shape: BoxShape.circle,
                                  boxShadow: [
                                    BoxShadow(
                                      color: (isRecording
                                              ? Colors.red
                                              : Colors.grey)
                                          .withOpacity(0.3),
                                      blurRadius: 15,
                                      spreadRadius: 2,
                                    ),
                                  ],
                                ),
                                child: Icon(
                                  Icons.mic,
                                  size: 40,
                                  color: isRecording
                                      ? Colors.white
                                      : Colors.grey[700],
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          if (showFeedback)
            Positioned.fill(
              child: Container(
                color: Colors.black.withOpacity(0.3),
                child: Center(
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 40),
                    padding: const EdgeInsets.all(32),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          isCorrect ? Icons.check_circle : Icons.refresh,
                          size: 80,
                          color: isCorrect ? Colors.green : Colors.orange,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          feedbackMessage,
                          style: const TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Accuracy: ${accuracyScore.toStringAsFixed(1)}',
                          style: const TextStyle(fontSize: 16),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),

          if (showLevelComplete)
            Positioned.fill(
              child: Container(
                color: Colors.black.withOpacity(0.3),
                child: Center(
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 40),
                    padding: const EdgeInsets.all(32),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.star,
                            size: 80, color: Colors.orange),
                        const SizedBox(height: 16),
                        Text(
                          "Lvl ${widget.levelNumber} complete",
                          style: const TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          "Good job, $userName!",
                          style: const TextStyle(
                            fontSize: 22,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          "Reward: 10 candies",
                          style: TextStyle(
                              fontSize: 18, color: Colors.purple),
                        ),
                        const SizedBox(height: 24),
                        ElevatedButton(
                          onPressed: _onLevelCompleteOkay,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 32,
                              vertical: 12,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: const Text(
                            "Okay",
                            style: TextStyle(fontSize: 18, color: Colors.white),
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

  Widget _buildControlButton({
    required IconData icon,
    required Color color,
    required VoidCallback onPressed,
  }) {
    return Container(
      width: 60,
      height: 60,
      decoration: BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: IconButton(
        icon: Icon(icon, size: 32),
        color: color,
        onPressed: onPressed,
      ),
    );
  }
}
