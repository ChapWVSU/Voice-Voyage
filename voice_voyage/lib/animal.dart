import 'package:flutter/material.dart';
import 'gameplay.dart';

class AnimalPage extends StatefulWidget {
  const AnimalPage({super.key});

  @override
  State<AnimalPage> createState() => _AnimalPageState();
}

class _AnimalPageState extends State<AnimalPage> {
  final PageController _pageController = PageController(viewportFraction: 0.8);
  int _currentPage = 0;

  @override
  void dispose() {
    _pageController.dispose();
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
                      "Learn About Animals",
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
                            "Let your child learn the different kind of animals, "
                            "such as farm animals and wild animals. ",
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
                            "How to differentiate and describe animals. ",
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

                    Expanded(
                      child: Column(
                        children: [
                          Flexible(
                            child: PageView(
                              physics: const BouncingScrollPhysics(),
                              controller: _pageController,
                              onPageChanged: (i) => setState(() => _currentPage = i),
                              children: [
                                Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 20),
                                  child: _buildTappableCard(
                                    context,
                                    assetImagePath: 'assets/images/1.png',
                                    bannerText: "Animals",
                                    title: "The Farm Animals",
                                    subtitle: "Level 1: Know the Farm Animals",
                                    levelNumber: 1,
                                    targetWord: "Cow",
                                    prompt: "Can you name this farm animal?",
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 20),
                                  child: _buildTappableCard(
                                    context,
                                    assetImagePath: 'assets/images/2.1.png',
                                    bannerText: "Animals",
                                    title: "The Wild Animals",
                                    subtitle: "Level 2: Discover the jungle",
                                    levelNumber: 2,
                                    targetWord: "Lion",
                                    prompt: "Can you name this wild animal?",
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 20),
                                  child: _buildTappableCard(
                                    context,
                                    assetImagePath: 'assets/images/3.png',
                                    bannerText: "Animals",
                                    title: "Let's Differerntiate",
                                    subtitle: "Level 3: Do i know the animal?",
                                    levelNumber: 3,
                                    targetWord: "Animal",
                                    prompt: "Can you identify this animal?",
                                  ),
                                ),
                              ],
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
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => GameplayScreen(
              levelNumber: levelNumber,
              targetWord: targetWord,
              prompt: prompt,
              backgroundImagePath: 'assets/images/1.png',
              characterImagePath: 'assets/images/1.png',
              currentStars: 0,
              category: 'animals',
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

  // Card widget using Image.asset and errorBuilder fallback
  Widget _greetingCard({
    required String assetImagePath,
    required String bannerText,
    required String title,
    required String subtitle,
  }) {
    return SizedBox(
      width: 300,
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
                    height: 260,
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
