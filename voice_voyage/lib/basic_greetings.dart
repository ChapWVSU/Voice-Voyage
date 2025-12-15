import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'gameplay.dart';

class BasicGreetingsPage extends StatefulWidget {
  const BasicGreetingsPage({super.key});

  @override
  State<BasicGreetingsPage> createState() => _BasicGreetingsPageState();
}

class _BasicGreetingsPageState extends State<BasicGreetingsPage> {
  int _currentPage = 0;

  // Line-height presets (multiplier of fontSize)
  static const double _lhTight = 1.05;
  static const double _lhTightest = 1.0;

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(
                      Icons.arrow_back,
                      color: Color(0xFF00A5FF),
                    ),
                    onPressed: () => Navigator.pop(context),
                  ),
                  const SizedBox(width: 8),
                  const Expanded(
                    child: Text(
                      "Learn About Greetings",
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF00A5FF),
                        height: _lhTightest,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Left content column
                    SizedBox(
                      width: 330,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "3 Level Course",
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w700,
                              height: _lhTight,
                            ),
                          ),
                          const SizedBox(height: 20),
                          const Text(
                            "Let your child learn the basics of greetings, "
                            "the different types of greetings, and when to use them.",
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.black87,
                              height: _lhTight,
                            ),
                          ),
                          const SizedBox(height: 20),
                          const Text(
                            "Level Goals",
                            style: TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.w700,
                              height: _lhTight,
                            ),
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            "Learn how to speak polite greetings in a variety of situations.",
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.black87,
                              height: _lhTight,
                            ),
                          ),
                          const SizedBox(height: 20),
                          const Text(
                            "Progress",
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              height: _lhTight,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            "Level ${_currentPage + 1} of 3",
                            style: const TextStyle(
                              fontSize: 14,
                              color: Colors.black87,
                              height: _lhTight,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(width: 40),

                    // Carousel for the three cards
                    Expanded(
                      child: Column(
                        children: [
                          SizedBox(
                            height: 206,
                            child: CarouselSlider.builder(
                              itemCount: 3,
                              itemBuilder: (context, index, realIndex) {
                                final items = [
                                  _buildTappableCard(
                                    context: context,
                                    assetImagePath: 'assets/images/Hello.gif',
                                    bannerText: "Basic Greetings",
                                    title: "Let's Greet!",
                                    subtitle:
                                        "Level 1: The basics of greeting",
                                    levelNumber: 1,
                                    targetWord: "Hello",
                                    prompt:
                                        "Can you say 'Hello' to your friend?",
                                    backgroundImagePath:
                                        'assets/images/Hello.gif',
                                    characterImagePath:
                                        'assets/images/Hello.gif',
                                  ),
                                  _buildTappableCard(
                                    context: context,
                                    assetImagePath: 'assets/images/Helloo.gif',
                                    bannerText: "Basic Greetings",
                                    title: "How to Greet Your Parents?",
                                    subtitle: "Level 2: Greeting your parents",
                                    levelNumber: 2,
                                    targetWord: "Good morning, Mom and Dad",
                                    prompt:
                                        "Can you greet your parents with 'Good morning, Mom and Dad'?",
                                    backgroundImagePath:
                                        'assets/images/Helloo.gif',
                                    characterImagePath:
                                        'assets/images/Helloo.gif',
                                  ),
                                  _buildTappableCard(
                                    context: context,
                                    assetImagePath: 'assets/images/bus.gif',
                                    bannerText: "Basic Greetings",
                                    title: "How to Greet in School?",
                                    subtitle:
                                        "Level 3: Let's greet your teacher and friends",
                                    levelNumber: 3,
                                    targetWord: "Good morning, everyone",
                                    prompt:
                                        "Can you greet your class with 'Good morning, everyone'?",
                                    backgroundImagePath: 'assets/images/bus.gif',
                                    characterImagePath: 'assets/images/bus.gif',
                                  ),
                                ];

                                return Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 20),
                                  child: items[index],
                                );
                              },
                              options: CarouselOptions(
                                height: 286,
                                viewportFraction: 0.85,
                                enableInfiniteScroll: false,
                                enlargeCenterPage: true,
                                onPageChanged: (i, reason) =>
                                    setState(() => _currentPage = i),
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: List.generate(3, (i) {
                              final active = i == _currentPage;
                              return Container(
                                width: active ? 10 : 8,
                                height: active ? 10 : 8,
                                margin:
                                    const EdgeInsets.symmetric(horizontal: 6),
                                decoration: BoxDecoration(
                                  color: active
                                      ? const Color(0xFF00A5FF)
                                      : Colors.grey.shade300,
                                  shape: BoxShape.circle,
                                ),
                              );
                            }),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Tappable card that navigates to GameplayScreen
  Widget _buildTappableCard({
    required BuildContext context,
    required String assetImagePath,
    required String bannerText,
    required String title,
    required String subtitle,
    required int levelNumber,
    required String targetWord,
    required String prompt,
    required String backgroundImagePath,
    required String characterImagePath,
  }) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => GameplayScreen(
              levelNumber: levelNumber,
              targetWord: targetWord,
              prompt: prompt,
              backgroundImagePath: backgroundImagePath,
              characterImagePath: characterImagePath,
              currentStars: 0,
              category: 'greetings',
            ),
          ),
        );
      },
      child: _greetingCard(
        assetImagePath: assetImagePath,
        bannerText: bannerText,
        title: title,
        subtitle: subtitle,
      ),
    );
  }

  // Card widget (image auto sizes to parent)
  Widget _greetingCard({
    required String assetImagePath,
    required String bannerText,
    required String title,
    required String subtitle,
  }) {
    return SizedBox(
      width: double.infinity,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x22000000),
                  blurRadius: 6,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(12),
                    topRight: Radius.circular(12),
                  ),
                  child: AspectRatio(
                    aspectRatio: 16 / 7,
                    child: SizedBox.expand(
                      child: Image.asset(
                        assetImagePath,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            color: Colors.grey.shade200,
                            alignment: Alignment.center,
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: const [
                                Icon(
                                  Icons.broken_image,
                                  size: 36,
                                  color: Colors.grey,
                                ),
                                SizedBox(height: 6),
                                Text(
                                  'Image not found',
                                  style: TextStyle(
                                    color: Colors.grey,
                                    height: _lhTight,
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                ),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 3),
                  decoration: const BoxDecoration(
                    color: Color(0xff4caf50),
                    borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(12),
                      bottomRight: Radius.circular(12),
                    ),
                  ),
                  child: Text(
                    bannerText,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                      fontSize: 16,
                      height: _lhTight,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          Text(
            title,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              height: _lhTight,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: const TextStyle(
              fontSize: 11,
              color: Colors.black54,
              height: _lhTight,
            ),
          ),
          const SizedBox(height: 10),
        ],
      ),
    );
  }
}
