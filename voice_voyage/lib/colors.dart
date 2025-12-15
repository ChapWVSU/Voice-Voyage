import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'gameplay.dart';

class ColorsPage extends StatefulWidget {
  const ColorsPage({super.key});

  @override
  State<ColorsPage> createState() => _ColorsPageState();
}

class _ColorsPageState extends State<ColorsPage> {
  int _currentPage = 0;

  // Reduced line height
  static const double _lhTight = 0.95;
  static const double _lhTightest = 0.90;

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
                      "Learn About Colors",
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
                            "Let your child learn the different kinds of colors, "
                            "such as the primary colors or the colors found in a rainbow.",
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
                            "How to identify different colors.",
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
                                    assetImagePath: 'assets/images/1.png',
                                    bannerText: "Colors",
                                    title: "The First Three Colors",
                                    subtitle: "Level 1: Primary Colors",
                                    levelNumber: 1,
                                    targetWord: "Red",
                                    prompt: "Can you say “Red”?",
                                  ),
                                  _buildTappableCard(
                                    context: context,
                                    assetImagePath: 'assets/images/2.1.png',
                                    bannerText: "Colors",
                                    title: "Color Combination!",
                                    subtitle: "Level 2: Secondary Colors",
                                    levelNumber: 2,
                                    targetWord: "Green",
                                    prompt: "Can you say “Green”?",
                                  ),
                                  _buildTappableCard(
                                    context: context,
                                    assetImagePath: 'assets/images/3.png',
                                    bannerText: "Colors",
                                    title: "Rainbow Colors",
                                    subtitle: "Level 3: Colors in a rainbow",
                                    levelNumber: 3,
                                    targetWord: "Rainbow",
                                    prompt: "Can you say “Rainbow”?",
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

  Widget _buildTappableCard({
    required BuildContext context,
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
              backgroundImagePath: assetImagePath,
              characterImagePath: assetImagePath,
              currentStars: 0,
              category: 'colors',
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
                                Icon(Icons.broken_image,
                                    size: 36, color: Colors.grey),
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
