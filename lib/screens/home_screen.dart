import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/game.dart';
import '../models/player.dart';
import '../widgets/game_card.dart';
import 'category_screen.dart';
import 'game_screen.dart';
import 'profile_screen.dart';
import 'challenge_screen.dart';
class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with TickerProviderStateMixin {
  List<Game> allGames = [];
  List<Game> filteredGames = [];
  String searchQuery = '';
  String selectedCategory = 'All';
  String selectedTab = 'Featured';
  final Player player = Player();

  late TabController _tabController;
  final TextEditingController _searchController = TextEditingController();

  final List<Map<String, String>> categories = [
    {'name': 'All', 'icon': '🎯'},
    {'name': 'Action', 'icon': '⚔️'},
    {'name': 'Racing', 'icon': '🏎️'},
    {'name': 'Puzzle', 'icon': '🧩'},
    {'name': 'Adventure', 'icon': '🗺️'},
    {'name': 'Sports', 'icon': '⚽'},
    {'name': 'Multiplayer', 'icon': '👥'},
    {'name': 'Casual', 'icon': '🎲'},
    {'name': 'Strategy', 'icon': '♟️'},
    {'name': 'Shooting', 'icon': '🎯'},
  ];

  final List<String> tabs = [
    'Featured', 'Trending', 'New', 'Multiplayer', 'All'
  ];

  final List<String> featuredTitles = [
    'Temple Run 2', 'Moto X3M', 'Agar.io', 'Minecraft Classic',
    'Basketball Stars', 'Kingdom Rush', 'Krunker.io', 'Subway Surfers',
    '2048', '8 Ball Pool', 'Fireboy & Watergirl', 'Fortnite',
  ];
  final List<String> trendingTitles = [
    'Subway Surfers', 'Slope', 'Agar.io', 'Slither.io', 'Skribbl.io',
    'Drift Hunters', 'Cut the Rope', 'Bubble Shooter', 'Krunker.io',
    'Among Us Online', 'Basketball Stars', 'Fortnite',
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: tabs.length, vsync: this);
    _tabController.addListener(() {
      if (!_tabController.indexIsChanging) {
        setState(() {
          selectedTab = tabs[_tabController.index];
          _applyFilters();
        });
      }
    });
    _loadGames();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadGames() async {
    final String jsonStr =
        await rootBundle.loadString('assets/games.json');
    final List<dynamic> data = json.decode(jsonStr);
    setState(() {
      allGames = data.map((e) => Game.fromJson(e)).toList();
      _applyFilters();
    });
  }

  void _applyFilters() {
    List<Game> result = List.from(allGames);

    // Tab filter
    if (selectedTab == 'Featured') {
      result = result.where((g) => featuredTitles.contains(g.title)).toList();
    } else if (selectedTab == 'Trending') {
      result = result.where((g) => trendingTitles.contains(g.title)).toList();
    } else if (selectedTab == 'New') {
      result = result.where((g) => g.isNew).toList();
    } else if (selectedTab == 'Multiplayer') {
      result = result.where((g) => g.category == 'Multiplayer').toList();
    }

    // Category filter
    if (selectedCategory != 'All') {
      result = result.where((g) => g.category == selectedCategory).toList();
    }

    // Search filter
    if (searchQuery.isNotEmpty) {
      final q = searchQuery.toLowerCase();
      result = result
          .where((g) =>
              g.title.toLowerCase().contains(q) ||
              g.category.toLowerCase().contains(q) ||
              g.source.toLowerCase().contains(q))
          .toList();
    }

    setState(() => filteredGames = result);
  }

  int _getCategoryCount(String cat) {
    if (cat == 'All') return allGames.length;
    return allGames.where((g) => g.category == cat).length;
  }

  void _showAIToast(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg,
            style: const TextStyle(
                color: Colors.white, fontWeight: FontWeight.w700)),
        backgroundColor: const Color(0xFF131828),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
          side: const BorderSide(color: Color(0xFF7209B7)),
        ),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF060812),
      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) => [
          // ---- APP BAR ----
          SliverAppBar(
            backgroundColor: const Color(0xFF0D1224),
            elevation: 0,
            floating: true,
            snap: true,
            title: FittedBox(
              fit: BoxFit.scaleDown,
              child: Row(
              children: [
                RichText(
                  
                  text: const TextSpan(
                    style: TextStyle(
                      fontWeight: FontWeight.w900,
                      fontSize: 20,
                      letterSpacing: 2,
                    ),
                    children: [
                      TextSpan(
                          text: 'ARCADE',
                          style: TextStyle(color: Color(0xFF00F5D4))),
                      TextSpan(
                          text: 'HUB',
                          style: TextStyle(color: Color(0xFFF72585))),
                    ],
                  ),
                ),
              ],
            )),
            actions: [
              // Streak
              Container(
                margin: const EdgeInsets.symmetric(vertical: 12, horizontal: 4),
                padding: const EdgeInsets.symmetric(horizontal: 8),
                decoration: BoxDecoration(
                  color: const Color(0xFF131828),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Center(
                  child: Text(
                    '🔥 ${player.streak}',
                    style: const TextStyle(
                        color: Color(0xFFFF6B35),
                        fontWeight: FontWeight.w800,
                        fontSize: 12),
                  ),
                ),
              ),
              // XP
              Container(
                margin: const EdgeInsets.symmetric(vertical: 12, horizontal: 4),
                padding: const EdgeInsets.symmetric(horizontal: 8),
                decoration: BoxDecoration(
                  color: const Color(0xFF131828),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                      color: const Color(0xFF00F5D4).withOpacity(0.2)),
                ),
                child: Center(
                  child: Text(
                    '⚡ ${player.xp} XP',
                    style: const TextStyle(
                        color: Color(0xFF00F5D4),
                        fontWeight: FontWeight.w800,
                        fontSize: 11),
                  ),
                ),
              ),
              // Coins
              Container(
                margin: const EdgeInsets.symmetric(vertical: 12, horizontal: 4),
                padding: const EdgeInsets.symmetric(horizontal: 8),
                decoration: BoxDecoration(
                  color: const Color(0xFF131828),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                      color: const Color(0xFFFFD700).withOpacity(0.2)),
                ),
                child: Center(
                  child: Text(
                    '🪙 ${player.coins}',
                    style: const TextStyle(
                        color: Color(0xFFFFD700),
                        fontWeight: FontWeight.w800,
                        fontSize: 11),
                  ),
                ),
              ),
              // Profile icon
              Builder(
                builder: (btnContext) => IconButton(
                  icon: const Icon(Icons.account_circle_outlined,
                      color: Color(0xFF8892B0), size: 24),
                  onPressed: () => Navigator.push(
                    btnContext,
                    MaterialPageRoute(
                        builder: (_) => const ProfileScreen()),
                  ),
                ),
              ),
            ],
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(1),
              child: Container(
                  height: 1,
                  color: const Color(0xFF00F5D4).withOpacity(0.15)),
            ),
          ),
        ],
        body: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ---- SEARCH BAR ----
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
                    child: TextField(
                      controller: _searchController,
                      style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                          fontSize: 14),
                      decoration: InputDecoration(
                        hintText: 'Search games...',
                        hintStyle: const TextStyle(
                            color: Color(0xFF8892B0), fontSize: 13),
                        prefixIcon: const Icon(Icons.search,
                            color: Color(0xFF8892B0), size: 20),
                        filled: true,
                        fillColor: const Color(0xFF0D1224),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(50),
                          borderSide: BorderSide(
                              color:
                                  const Color(0xFF00F5D4).withOpacity(0.2)),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(50),
                          borderSide: BorderSide(
                              color:
                                  const Color(0xFF00F5D4).withOpacity(0.15)),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(50),
                          borderSide: const BorderSide(
                              color: Color(0xFF00F5D4), width: 1.5),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 12),
                      ),
                      onChanged: (val) {
                        searchQuery = val;
                        _applyFilters();
                      },
                    ),
                  ),

                  // ---- DAILY CHALLENGE ----
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            const Color(0xFFF72585).withOpacity(0.15),
                            const Color(0xFF7209B7).withOpacity(0.15),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                            color:
                                const Color(0xFFF72585).withOpacity(0.3)),
                      ),
                      child: Row(
                        children: [
                          const Text('🏆', style: TextStyle(fontSize: 30)),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  '⚡ DAILY CHALLENGE',
                                  style: TextStyle(
                                    color: Color(0xFFF72585),
                                    fontSize: 9,
                                    fontWeight: FontWeight.w800,
                                    letterSpacing: 1.5,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                const Text(
                                  'Speed Racer Sprint',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w800,
                                    fontSize: 14,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                const Text(
                                  'Beat Moto X3M under 5 mins!',
                                  style: TextStyle(
                                      color: Color(0xFF8892B0),
                                      fontSize: 11),
                                ),
                              ],
                            ),
                          ),
                          Column(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFFFD700)
                                      .withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(6),
                                  border: Border.all(
                                      color: const Color(0xFFFFD700)
                                          .withOpacity(0.3)),
                                ),
                                child: const Text(
                                  '🪙 +200',
                                  style: TextStyle(
                                      color: Color(0xFFFFD700),
                                      fontWeight: FontWeight.w800,
                                      fontSize: 11),
                                ),
                              ),
                              const SizedBox(height: 6),
                              ElevatedButton(
                                onPressed: () {
                                  final moto = allGames.firstWhere(
                                      (g) => g.title == 'Moto X3M',
                                      orElse: () => allGames.first);
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (_) => GameScreen(
                                            game: moto,
                                            player: player)),
                                  );
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFFF72585),
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 12, vertical: 6),
                                  minimumSize: Size.zero,
                                  shape: RoundedRectangleBorder(
                                      borderRadius:
                                          BorderRadius.circular(8)),
                                ),
                                child: const Text(
                                  'PLAY',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w800,
                                    fontSize: 11,
                                    letterSpacing: 1,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),

                  // ---- AI GAME MASTER ----
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            const Color(0xFF7209B7).withOpacity(0.12),
                            const Color(0xFF00F5D4).withOpacity(0.06),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                            color:
                                const Color(0xFF7209B7).withOpacity(0.3)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 3),
                            decoration: BoxDecoration(
                              color:
                                  const Color(0xFF7209B7).withOpacity(0.2),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                  color: const Color(0xFF7209B7)
                                      .withOpacity(0.4)),
                            ),
                            child: const Text(
                              '🤖 AI POWERED',
                              style: TextStyle(
                                color: Color(0xFFB48EFF),
                                fontSize: 9,
                                fontWeight: FontWeight.w800,
                                letterSpacing: 1.5,
                              ),
                            ),
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            'AI Game Master',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w800,
                              fontSize: 15,
                            ),
                          ),
                          const SizedBox(height: 4),
                          const Text(
                            'Trivia host, AI storytelling & live quiz battles!',
                            style: TextStyle(
                                color: Color(0xFF8892B0), fontSize: 11),
                          ),
                          const SizedBox(height: 10),
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: [
                              _aiBtn('🧠 AI Trivia',
                                  () => _showAIToast('🤖 AI Trivia starting! +50 XP on completion')),
                              _aiBtn('📖 Story Mode',
                                  () => _showAIToast('📖 AI Storytelling Mode launching...')),
                              _aiBtn('⚔️ Quiz Battle',
                                  () => _showAIToast('⚔️ Finding opponent for Live Quiz Battle...')),
                              _aiBtn('🎲 Turn-Based',
                                  () => _showAIToast('🎲 Turn-Based Challenge loading...')),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),

                  // ---- CATEGORY CHIPS ----
                  SizedBox(
                    height: 38,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: categories.length,
                      separatorBuilder: (_, __) =>
                          const SizedBox(width: 8),
                      itemBuilder: (context, i) {
                        final cat = categories[i];
                        final isSelected =
                            selectedCategory == cat['name'];
                        return GestureDetector(
                          onTap: () {
                            setState(() {
                              selectedCategory = cat['name']!;
                              _applyFilters();
                            });
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? const Color(0xFF00F5D4)
                                      .withOpacity(0.15)
                                  : const Color(0xFF0D1224),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: isSelected
                                    ? const Color(0xFF00F5D4)
                                    : const Color(0xFF00F5D4)
                                        .withOpacity(0.15),
                              ),
                            ),
                            child: Row(
                              children: [
                                Text(cat['icon']!,
                                    style:
                                        const TextStyle(fontSize: 13)),
                                const SizedBox(width: 5),
                                Text(
                                  '${cat['name']} (${_getCategoryCount(cat['name']!)})',
                                  style: TextStyle(
                                    color: isSelected
                                        ? const Color(0xFF00F5D4)
                                        : const Color(0xFF8892B0),
                                    fontSize: 11,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 12),

                  // ---- TABS ----
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(
                      color: const Color(0xFF0D1224),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                          color:
                              const Color(0xFF00F5D4).withOpacity(0.12)),
                    ),
                    child: TabBar(
                      controller: _tabController,
                      isScrollable: true,
                      indicatorColor: const Color(0xFF00F5D4),
                      indicatorSize: TabBarIndicatorSize.label,
                      labelColor: const Color(0xFF00F5D4),
                      unselectedLabelColor: const Color(0xFF8892B0),
                      labelStyle: const TextStyle(
                          fontWeight: FontWeight.w700, fontSize: 12),
                      tabs: tabs.map((t) => Tab(text: t)).toList(),
                    ),
                  ),
                  const SizedBox(height: 14),

                  // ---- SECTION HEADER ----
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Row(
                      children: [
                        Container(
                          width: 4,
                          height: 18,
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [
                                Color(0xFF00F5D4),
                                Color(0xFFF72585)
                              ],
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                            ),
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          selectedCategory == 'All'
                              ? selectedTab
                              : '$selectedCategory Games',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w800,
                            fontSize: 14,
                            letterSpacing: 0.5,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: const Color(0xFF131828),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            '${filteredGames.length} games',
                            style: const TextStyle(
                                color: Color(0xFF8892B0),
                                fontSize: 10),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                ],
              ),
            ),

            // ---- GAMES GRID ----
            filteredGames.isEmpty
                ? const SliverToBoxAdapter(
                    child: Center(
                      child: Padding(
                        padding: EdgeInsets.all(40),
                        child: Column(
                          children: [
                            Text('🎮',
                                style: TextStyle(fontSize: 48)),
                            SizedBox(height: 12),
                            Text(
                              'No games found.\nTry a different search or category!',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                  color: Color(0xFF8892B0),
                                  fontSize: 13),
                            ),
                          ],
                        ),
                      ),
                    ),
                  )
                : SliverPadding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 30),
                    sliver: SliverGrid(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          final game = filteredGames[index];
                          return GameCard(
                            game: game,
                            onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => GameScreen(
                                    game: game, player: player),
                              ),
                            ),
                          );
                        },
                        childCount: filteredGames.length,
                      ),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        crossAxisSpacing: 12,
                        mainAxisSpacing: 12,
                        childAspectRatio: 0.82,
                      ),
                    ),
                  ),
          ],
        ),
      ),

      // ---- BOTTOM NAV ----
      bottomNavigationBar: Builder(
        builder: (navContext) => Container(
        decoration: BoxDecoration(
          color: const Color(0xFF0D1224),
          border: Border(
              top: BorderSide(
                  color: const Color(0xFF00F5D4).withOpacity(0.12))),
        ),
        child: BottomNavigationBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          selectedItemColor: const Color(0xFF00F5D4),
          unselectedItemColor: const Color(0xFF8892B0),
          selectedLabelStyle: const TextStyle(
              fontWeight: FontWeight.w700, fontSize: 10),
          type: BottomNavigationBarType.fixed,
          items: const [
            BottomNavigationBarItem(
                icon: Icon(Icons.home_outlined),
                activeIcon: Icon(Icons.home),
                label: 'Home'),
            BottomNavigationBarItem(
                icon: Icon(Icons.sports_esports_outlined),
                activeIcon: Icon(Icons.sports_esports),
                label: 'Games'),
            BottomNavigationBarItem(
                icon: Icon(Icons.leaderboard_outlined),
                activeIcon: Icon(Icons.leaderboard),
                label: 'Ranks'),
            BottomNavigationBarItem(
                icon: Icon(Icons.person_outline),
                activeIcon: Icon(Icons.person),
                label: 'Profile'),
          ],
          onTap: (i) {
            if (i == 3) {
              Navigator.push(
                navContext,
                MaterialPageRoute(
                    builder: (_) => const ProfileScreen()),
              );
            }
            if(i==2)
            {
              Navigator.push(context, MaterialPageRoute(builder: (_) => const ChallengeScreen()));
            }
            
          },
        ),
      ),
      ),
    );
  }

  Widget _aiBtn(String label, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding:
            const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: const Color(0xFF7209B7).withOpacity(0.15),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
              color: const Color(0xFF7209B7).withOpacity(0.35)),
        ),
        child: Text(
          label,
          style: const TextStyle(
            color: Color(0xFFB48EFF),
            fontWeight: FontWeight.w700,
            fontSize: 11,
          ),
        ),
      ),
    );
  }
}