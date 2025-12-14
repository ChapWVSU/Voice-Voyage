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
                            ),
                          ),
                          const SizedBox(height: 20),
                          const Text(
                            "Let your child learn the basics of greetings, "
                            "the different types of greetings, and when to use them.",
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.black87,
                              height: 1.4,
                            ),
                          ),
                          const SizedBox(height: 20),
                          const Text(
                            "Level Goals",
                            style: TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            "Learn how to speak polite greetings in a variety of situations.",
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.black87,
                              height: 1.4,
                            ),
                          ),
                          const SizedBox(height: 20),
                          const Text(
                            "Progress",
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 6),
                          const Text(
                            "Level 1 of 3",
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.black87,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(width: 40),

                    // PageView for the three cards
                    Expanded(
                      child: Column(
                          children: [
                            SizedBox(
                              height: 360,
                              child: CarouselSlider.builder(
                                itemCount: 3,
                                itemBuilder: (context, index, realIndex) {
                                  final items = [
                                    _buildTappableCard(
                                      context,
                                      assetImagePath: 'assets/images/Hello.gif',
                                      bannerText: "Basic Greetings",
                                      title: "Let's Greet!",
                                      subtitle: "Level 1: The basics of greeting",
                                      levelNumber: 1,
                                      targetWord: "Hello",
                                      prompt: "Can you say 'Hello' to your friend?",
                                    ),
                                    _buildTappableCard(
                                      context,
                                      assetImagePath: 'assets/images/Helloo.gif',
                                      bannerText: "Basic Greetings",
                                      title: "How to Greet Your Parents?",
                                      subtitle: "Level 2: Greeting your parents",
                                      levelNumber: 2,
                                      targetWord: "Good morning, Mom and Dad",
                                      prompt: "Can you greet your parents with 'Good morning, Mom and Dad'?",
                                    ),
                                    _buildTappableCard(
                                      context,
                                      assetImagePath: 'assets/images/bus.gif',
                                      bannerText: "Basic Greetings",
                                      title: "How to Greet in School?",
                                      subtitle: "Level 3: Let's greet your teacher and friends",
                                      levelNumber: 3,
                                      targetWord: "Hello everyone",
                                      prompt: "Can you greet your class with 'Hello everyone'?",
                                    ),
                                  ];
                                  return Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 20),
                                    child: items[index],
                                  );
                                },
                                options: CarouselOptions(
                                  height: 360,
                                  viewportFraction: 0.85,
                                  enableInfiniteScroll: false,
                                  enlargeCenterPage: true,
                                  onPageChanged: (i, reason) => setState(() => _currentPage = i),
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
                                margin: const EdgeInsets.symmetric(horizontal: 6),
                                decoration: BoxDecoration(
                                  color: active ? const Color(0xFF00A5FF) : Colors.grey.shade300,
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
  Widget _buildTappableCard(
    BuildContext context, {
    required String assetImagePath,
    required String bannerText,
    required String title,
    required String subtitle,
    required int levelNumber,
    required String targetWord,
    required String prompt,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => GameplayScreen(
                levelNumber: levelNumber,
                targetWord: targetWord,
                prompt: prompt,
                backgroundImagePath: 'assets/images/Hello.gif',
                characterImagePath: 'assets/images/Hello.gif',
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
      ),
    );
  }

  // Card widget using Image.asset and errorBuilder fallback
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
          // IMAGE + GREEN BANNER
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
                // Image.asset automatically animates GIFs.
                ClipRRect(
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(12),
                    topRight: Radius.circular(12),
                  ),
                  child: Image.asset(
                    assetImagePath,
                    height: 240,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      // Friendly fallback if asset not found
                      return Container(
                        height: 150,
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
                              style: TextStyle(color: Colors.grey),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),

                // Green banner
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 12),
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
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 12),

          // Title
          Text(
            title,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              height: 1.2,
            ),
          ),

          const SizedBox(height: 6),

          // Subtitle
          Text(
            subtitle,
            style: const TextStyle(
              fontSize: 11,
              color: Colors.black54,
              height: 1.3,
            ),
          ),

          const SizedBox(height: 12),
        ],
      ),
    );
  }
}
