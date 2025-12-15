  // homepage.dart
  import 'package:flutter/material.dart';
  import 'package:carousel_slider/carousel_slider.dart';
  import 'package:shared_preferences/shared_preferences.dart';
  import 'profile_helper.dart';

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
    final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

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
        image: 'assets/images/color.png',
        page: ColorsPage(),
      ),
    ];

    Map<String, double> _categoryProgress = {
      'greetings': 0.0,
      'animals': 0.0,
      'colors': 0.0,
    };

    int _currentCategoryIndex = 0;

    static const int _levelsPerCategory = 3;

    @override
    void initState() {
      super.initState();
      _loadProgress();
    }

    int? _asInt(dynamic v) {
      if (v is int) return v;
      if (v is num) return v.toInt();
      return int.tryParse(v?.toString() ?? '');
    }

    double _asDouble(dynamic v) {
      if (v is double) return v;
      if (v is num) return v.toDouble();
      return double.tryParse(v?.toString() ?? '') ?? 0.0;
    }

    /// Progress per category = sum(bestScorePerLevel) / (levels * 100).
    /// Uses existing fields: category, level, score.
    Future<void> _loadProgress() async {
      try {
        final prefs = await SharedPreferences.getInstance();
        final profileId = prefs.getString('selectedProfileId');
        if (profileId == null) return;

        final progressDocs = await ProfileHelper.getProgress(profileId);

        // bestScoreByCategory[cat][level] = best score (0..100) for that level
        final Map<String, Map<int, double>> bestScoreByCategory = {};

        for (final doc in progressDocs) {
          final cat = (doc['category'] ?? '').toString().toLowerCase();
          if (cat.isEmpty) continue;
          if (!_categoryProgress.containsKey(cat)) continue;

          final level = _asInt(doc['level']);
          if (level == null || level < 1 || level > _levelsPerCategory) continue;

          final score = _asDouble(doc['score']).clamp(0.0, 100.0);

          bestScoreByCategory.putIfAbsent(cat, () => {});
          final prev = bestScoreByCategory[cat]![level] ?? 0.0;
          if (score > prev) bestScoreByCategory[cat]![level] = score;
        }

        final Map<String, double> newProgress = {
          'greetings': 0.0,
          'animals': 0.0,
          'colors': 0.0,
        };

        for (final cat in newProgress.keys) {
          final levelMap = bestScoreByCategory[cat] ?? {};

          double sum = 0.0;
          for (int level = 1; level <= _levelsPerCategory; level++) {
            sum += (levelMap[level] ?? 0.0); // missing levels count as 0
          }

          final maxTotal = _levelsPerCategory * 100.0; // 3 * 100
          newProgress[cat] = (sum / maxTotal).clamp(0.0, 1.0);
        }

        if (mounted) setState(() => _categoryProgress = newProgress);
      } catch (e) {
        print('Error loading progress for HomePage: $e');
      }
    }

    // Called by Header: refresh progress, then open the drawer.
    Future<void> refreshProgressAndOpenDrawer() async {
      await _loadProgress();
      if (!mounted) return;
      _scaffoldKey.currentState?.openEndDrawer();
    }

Widget _buildProgressDrawer() {
  return Drawer(
    child: SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Progress',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            _progressTile('Basic Greetings', 'greetings'),
            const SizedBox(height: 6),
            _progressTile('Animals', 'animals'),
            const SizedBox(height: 6),
            _progressTile('Colors', 'colors'),
            const SizedBox(height: 24), // instead of Spacer()
            ListTile(
              contentPadding: const EdgeInsets.only(right: 0),
              title: const SizedBox.shrink(),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: const [
                  Text(
                    'Logout',
                    style: TextStyle(
                      color: Colors.red,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  SizedBox(width: 8),
                  Icon(Icons.logout, color: Colors.red),
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
              if (key == 'greetings') {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => BasicGreetingsPage()),
                );
              }
              if (key == 'animals') {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => AnimalPage()),
                );
              }
              if (key == 'colors') {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => ColorsPage()),
                );
              }
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
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
        key: _scaffoldKey,
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
                  _Header(onOpenProgressDrawer: refreshProgressAndOpenDrawer),
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CarouselSlider.builder(
                          itemCount: categories.length,
                          itemBuilder: (context, index, _) =>
                              CategoryCard(category: categories[index]),
                          options: CarouselOptions(
                            height: 210,
                            enlargeCenterPage: true,
                            viewportFraction: 0.58,
                            enableInfiniteScroll: false,
                            onPageChanged: (idx, reason) =>
                                setState(() => _currentCategoryIndex = idx),
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
    final Future<void> Function() onOpenProgressDrawer;

    const _Header({required this.onOpenProgressDrawer});

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
          setState(() => _avatar =
              ProfileHelper.normalizeAvatarPath(profile['avatar']));
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
                      : const SizedBox(width: 40, height: 40),
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
              onTap: () async {
                await widget.onOpenProgressDrawer();
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
