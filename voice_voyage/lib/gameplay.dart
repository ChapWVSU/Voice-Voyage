import 'package:flutter/material.dart';

class GameplayScreen extends StatefulWidget {
  final int levelNumber;
  final String targetWord; // e.g., "Hello"
  final String prompt; // e.g., "Can you say \"Hello\" to your friend?"
  final String backgroundImagePath; // Path to your background PNG
  final String characterImagePath; // Path to your character PNG
  final int currentStars; // User's current rating/stars

  const GameplayScreen({
    Key? key,
    required this.levelNumber,
    required this.targetWord,
    required this.prompt,
    required this.backgroundImagePath,
    required this.characterImagePath, // if may characters
    required this.currentStars,
  }) : super(key: key);

  @override
  State<GameplayScreen> createState() => _GameplayScreenState();
}

class _GameplayScreenState extends State<GameplayScreen>
    with SingleTickerProviderStateMixin {
  bool isRecording = false;
  bool showFeedback = false;
  String feedbackMessage = "";
  bool isCorrect = false;

  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();

    // Animation for microphone button pulse effect
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.1).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  // TODO: Initialize speech recognition here
  void _initializeSpeechRecognition() {
    // Set up speech recognition package
    // Configure language (e.g., 'en-US')
    // Set up listeners
  }

  // TODO: Start recording pronunciation
  void _startRecording() async {
    setState(() {
      isRecording = true;
      showFeedback = false;
    });

    // TODO: Start listening for speech input
    // Example:
    // await speechRecognizer.listen();
  }

  // TODO: Stop recording and analyze pronunciation
  void _stopRecordingAndAnalyze() async {
    setState(() {
      isRecording = false;
    });

    // TODO: Stop listening
    // await speechRecognizer.stop();

    // TODO: Get the recognized text
    // String recognizedText = ... ;

    // TODO: Call your pronunciation analysis function here
    // Example:
    // bool pronunciationCorrect = await analyzePronunciation(
    //   targetWord: widget.targetWord,
    //   recognizedText: recognizedText,
    //   audioData: audioData, // if you need audio analysis
    // );

    // TODO: Calculate accuracy score (0-100)
    // int accuracyScore = ... ;

    // Mock result for demonstration
    bool pronunciationCorrect = true; // Replace with actual result
    int accuracyScore = 85; // Replace with actual score

    _showFeedback(pronunciationCorrect, accuracyScore);
  }

  void _showFeedback(bool correct, int score) {
    setState(() {
      isCorrect = correct;
      showFeedback = true;

      if (correct) {
        if (score >= 90) {
          feedbackMessage = "Perfect! 🌟";
        } else if (score >= 75) {
          feedbackMessage = "Great job! 👏";
        } else {
          feedbackMessage = "Good try! 😊";
        }
      } else {
        feedbackMessage = "Try again! 💪";
      }
    });

    // TODO: Update user progress/stars in database
    // if (correct) {
    //   updateUserProgress(widget.levelNumber, score);
    // }

    // Auto-hide feedback after 2 seconds
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        setState(() {
          showFeedback = false;
        });
      }
    });
  }

  void _playPromptAudio() {
    // TODO: Play audio of the prompt/word
    // Example: audioPlayer.play('assets/audio/${widget.targetWord}.mp3');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background Image
          Positioned.fill(
            child: Image.asset(widget.backgroundImagePath, fit: BoxFit.cover),
          ),

          // Main Content
          SafeArea(
            child: Column(
              children: [
                // Top Bar
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Back Button
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
                          icon: const Icon(
                            Icons.arrow_back,
                            color: Colors.black87,
                          ),
                          onPressed: () => Navigator.pop(context),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                // Prompt Text
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
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          widget.prompt,
                          style: const TextStyle(
                            fontSize: 25,
                            fontWeight: FontWeight.w900,
                            color: Color.fromARGB(221, 0, 0, 0),
                            height: 1.3,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ],
                  ),
                ),

                const Spacer(),

                // Character Image
                // Image.asset(
                //   widget.characterImagePath,
                //   height: 280,
                //   fit: BoxFit.contain,
                // ),
                const Spacer(),

                // Control Buttons
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 40,
                    vertical: 40,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Play Button (prompt audio)
                      _buildControlButton(
                        icon: Icons.play_arrow,
                        color: Colors.green,
                        onPressed: _playPromptAudio,
                      ),

                      const SizedBox(width: 40),

                      // Microphone Button
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
                                  color: isRecording
                                      ? Colors.red
                                      : Colors.white,
                                  shape: BoxShape.circle,
                                  boxShadow: [
                                    BoxShadow(
                                      color:
                                          (isRecording
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

          // Feedback Overlay
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
