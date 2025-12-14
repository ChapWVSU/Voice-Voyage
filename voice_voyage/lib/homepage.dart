// homepage.dart
import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'profile_helper.dart';
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
class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
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

  Map<String, double> _categoryProgress = {
    'greetings': 0.0,
    'animals': 0.0,
    'colors': 0.0,
  };

  int _currentCategoryIndex = 0;

  @override
  void initState() {
    super.initState();
    _loadProgress();
  }

  Future<void> _loadProgress() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final profileId = prefs.getString('selectedProfileId');
      if (profileId == null) return;

      final progressDocs = await ProfileHelper.getProgress(profileId);

      // group and compute average per category
      final Map<String, List<double>> buckets = {};
      for (var doc in progressDocs) {
        final cat = (doc['category'] ?? '').toString().toLowerCase();
        final sc = (doc['score'] is num) ? (doc['score'] as num).toDouble() : 0.0;
        if (cat.isEmpty) continue;
        buckets.putIfAbsent(cat, () => []).add(sc);
      }

      final newProgress = Map<String, double>.from(_categoryProgress);
      buckets.forEach((cat, scores) {
        final avg = scores.isEmpty ? 0.0 : scores.reduce((a, b) => a + b) / scores.length;
        if (newProgress.containsKey(cat)) newProgress[cat] = avg / 100.0;
      });

      if (mounted) setState(() => _categoryProgress = newProgress);
    } catch (e) {
      print('Error loading progress for HomePage: $e');
    }
  }

  Widget _buildProgressDrawer() {
    return Drawer(
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Progress', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              _progressTile('Basic Greetings', 'greetings'),
              const SizedBox(height: 8),
              _progressTile('Animals', 'animals'),
              const SizedBox(height: 8),
              _progressTile('Colors', 'colors'),
              const Spacer(),
              ListTile(
                contentPadding: const EdgeInsets.only(right: 0),
                title: const SizedBox.shrink(),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text('Logout', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold, fontSize: 16)),
                    const SizedBox(width: 8),
                    const Icon(Icons.logout, color: Colors.red),
                  ],
                ),
                onTap: () async {
                  final prefs = await SharedPreferences.getInstance();
                  await prefs.remove('userId');
                  await prefs.remove('userEmail');
                  await prefs.remove('selectedProfileId');
                  Navigator.pushReplacementNamed(context, '/login');
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _progressTile(String title, String key) {
    final pct = (_categoryProgress[key] ?? 0.0).clamp(0.0, 1.0);
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () {
            Navigator.pop(context); // close drawer
            if (key == 'greetings') Navigator.push(context, MaterialPageRoute(builder: (_) => BasicGreetingsPage()));
            if (key == 'animals') Navigator.push(context, MaterialPageRoute(builder: (_) => AnimalPage()));
            if (key == 'colors') Navigator.push(context, MaterialPageRoute(builder: (_) => ColorsPage()));
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                const SizedBox(height: 6),
                LinearProgressIndicator(value: pct, minHeight: 10),
                const SizedBox(height: 6),
                Text('${(pct * 100).toStringAsFixed(0)}%'),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      endDrawer: _buildProgressDrawer(),
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
                _Header(),
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CarouselSlider.builder(
                        itemCount: categories.length,
                        itemBuilder: (context, index, _) =>
                            CategoryCard(category: categories[index]),
                        options: CarouselOptions(
                          height: 300,
                          enlargeCenterPage: true,
                          viewportFraction: 0.58,
                          enableInfiniteScroll: false,
                          onPageChanged: (idx, reason) => setState(() => _currentCategoryIndex = idx),
                        ),
                      ),
                      const SizedBox(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(categories.length, (i) {
                          final active = i == _currentCategoryIndex;
                          return Container(
                            width: active ? 10 : 8,
                            height: active ? 10 : 8,
                            margin: const EdgeInsets.symmetric(horizontal: 4),
                            decoration: BoxDecoration(
                              color: active ? Colors.white : Colors.white54,
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
        ],
      ),
    );
  }
}

// -------------------- Header Widget --------------------
class _Header extends StatefulWidget {
  const _Header();

  @override
  State<_Header> createState() => _HeaderState();
}

class _HeaderState extends State<_Header> {
  String _avatar = '';

  @override
  void initState() {
    super.initState();
    _loadAvatar();
  }

  Future<void> _loadAvatar() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final profileId = prefs.getString('selectedProfileId');
      if (profileId == null) return;
      final profile = await ProfileHelper.getProfile(profileId);
      if (profile != null) {
        setState(() => _avatar = ProfileHelper.normalizeAvatarPath(profile['avatar']));
      }
    } catch (e) {
      print('Header avatar load error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          GestureDetector(
            onTap: () {
              Navigator.pushReplacementNamed(context, '/profile');
            },
            child: _IconBox(
              color: const Color(0xFF00BCD4),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: _avatar.isNotEmpty
                    ? Image.asset(
                        _avatar,
                        width: 40,
                        height: 40,
                        fit: BoxFit.cover,
                      )
                    : SizedBox(width: 40, height: 40),
              ),
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
          const SizedBox(width: 12),
          GestureDetector(
            onTap: () {
              Scaffold.of(context).openEndDrawer();
            },
            child: _IconBox(
              color: Colors.white24,
              child: const Icon(Icons.menu, color: Colors.white),
            ),
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
            mainAxisSize: MainAxisSize.min,
            children: [
              // image area: allow it to flex/shrink to available space
              Flexible(
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
