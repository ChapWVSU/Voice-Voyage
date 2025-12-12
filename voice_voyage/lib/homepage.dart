// homepage.dart
import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
// import 'dictionary.dart';
// import 'store.dart';
// import 'settings.dart';
import 'animal.dart';
import 'basic_greetings.dart';
import 'colors.dart';

class Category {
  final String title;
  final Color color;
  final Color bg;
  final String image;
  final Widget page;

  const Category({
    required this.title,
    required this.color,
    required this.bg,
    required this.image,
    required this.page,
  });
}

// -------------------- Home Page --------------------
class HomePage extends StatelessWidget {
  const HomePage({super.key});

  final List<Category> categories = const [
    Category(
      title: 'Basic Greetings',
      color: Color(0xFFFFA726),
      bg: Color(0xFFFFF59D),
      image: 'assets/images/carouselbus.gif',
      page: BasicGreetingsPage(),
    ),
    Category(
      title: 'Animals',
      color: Color(0xFFEC407A),
      bg: Color(0xFFF8BBD0),
      image: 'assets/images/animalscarousel.png',
      page: AnimalPage(),
    ),
    Category(
      title: 'Colors',
      color: Color(0xFF42A5F5),
      bg: Color(0xFFBBDEFB),
      image: 'assets/images/carouselbus.gif',
      page: ColorsPage(),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/images/bg.png'),
                fit: BoxFit.cover,
              ),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0xFF9C27B0),
                  Color(0xFF7B1FA2),
                  Color(0xFF6A1B9A),
                ],
              ),
            ),
          ),
          SafeArea(
            child: Column(
              children: [
                const _Header(),
                Expanded(
                  child: CarouselSlider.builder(
                    itemCount: categories.length,
                    itemBuilder: (context, index, _) =>
                        CategoryCard(category: categories[index]),
                    options: CarouselOptions(
                      height: 240,
                      enlargeCenterPage: true,
                      viewportFraction: 0.58,
                      enableInfiniteScroll: false,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// -------------------- Header Widget --------------------
class _Header extends StatelessWidget {
  const _Header();

@override
Widget build(BuildContext context) {
  return Padding(
    padding: const EdgeInsets.all(16),
    child: Row(
      children: [
        // Making the sun image clickable using GestureDetector
        GestureDetector(
          onTap: () {
            // Navigate back to the profile page when the sun image is clicked
            Navigator.pushReplacementNamed(context, '/profile');
          },
          child: _IconBox(
            color: const Color(0xFF00BCD4),
            child: Image.asset('assets/images/head sun.png'), // Sun Image
          ),
        ),
        const Spacer(),
        const Text(
          'Basic Speech',
          style: TextStyle(
            color: Colors.white,
            fontSize: 30,
            fontWeight: FontWeight.bold,
          ),
        ),
        const Icon(Icons.arrow_drop_down, color: Colors.white, size: 28),
        const Spacer(),
        _IconBox(
          color: Colors.white24,
          child: const Icon(Icons.search, color: Colors.white),
        ),
        const SizedBox(width: 12),
        _IconBox(
          color: Colors.white24,
          child: const Icon(Icons.menu, color: Colors.white),
        ),
      ],
    ),
  );
}
}

// -------------------- Icon Box --------------------
class _IconBox extends StatelessWidget {
  final Color color;
  final Widget child;

  const _IconBox({required this.color, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(12),
      ),
      child: child,
    );
  }
}

// -------------------- Category Card --------------------
class CategoryCard extends StatelessWidget {
  final Category category;

  const CategoryCard({super.key, required this.category});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => category.page),
        );
      },
      child: Card(
        color: category.color,
        margin: EdgeInsets.zero,
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        child: Padding(
          padding: const EdgeInsets.all(6),
          child: Column(
            children: [
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: category.bg,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: Image.asset(
                      category.image,
                      fit: BoxFit.cover,
                      width: double.infinity,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Text(
                category.title,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 25,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
