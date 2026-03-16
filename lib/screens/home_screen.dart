import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/game.dart';
import '../models/player.dart';
import '../widgets/game_card.dart';
import '../services/firebase_service.dart';
import 'game_screen.dart';
import 'profile_screen.dart';
import 'challenge_screen.dart';
import 'rank_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);
  @override
  State<HomeScreen> createState() => HomeScreenState();
}

class HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  List<Game> allGames = [];
  List<Game> filteredGames = [];
  String searchQuery = '';
  String selectedCategory = 'All';
  String selectedTab = 'Featured';
  int bottomNavIndex = 0;

  late TabController tabController;
  final searchController = TextEditingController();

  static const bg      = Color(0xFF050A18);
  static const surface = Color(0xFF0D1F3C);
  static const primary = Color(0xFF0066FF);
  static const gold    = Color(0xFFFFD700);
  static const muted   = Color(0xFF8BA3CC);

  final List<Map<String, String>> categories = [
    {'name': 'All',         'icon': '🎯'},
    {'name': 'Action',      'icon': '⚔️'},
    {'name': 'Racing',      'icon': '🏎️'},
    {'name': 'Puzzle',      'icon': '🧩'},
    {'name': 'Adventure',   'icon': '🗺️'},
    {'name': 'Sports',      'icon': '⚽'},
    {'name': 'Multiplayer', 'icon': '👥'},
    {'name': 'Casual',      'icon': '🎲'},
    {'name': 'Strategy',    'icon': '♟️'},
    {'name': 'Shooting',    'icon': '🎯'},
  ];

  final List<String> tabs = ['Featured', 'Trending', 'New', 'Multiplayer', 'All'];

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
    tabController = TabController(length: tabs.length, vsync: this);
    tabController.addListener(() {
      if (!tabController.indexIsChanging) {
        setState(() { selectedTab = tabs[tabController.index]; applyFilters(); });
      }
    });
    loadGames();
    checkDailyReward();
  }

  @override
  void dispose() {
    tabController.dispose();
    searchController.dispose();
    super.dispose();
  }

  Future<void> checkDailyReward() async {
    final result = await FirebaseService.claimDailyReward();
    if (result['claimed'] == true && mounted) {
      final streak = result['streak'] ?? 1;
      final coins  = result['coins'] ?? 50;
      final xp     = result['xp'] ?? 20;
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          backgroundColor: surface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
            side: BorderSide(color: gold.withOpacity(0.35), width: 1.5),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('🎁', style: TextStyle(fontSize: 52)),
              const SizedBox(height: 12),
              const Text('DAILY REWARD!',
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900,
                    fontSize: 18, letterSpacing: 2)),
              const SizedBox(height: 6),
              Text(streak > 1 ? '🔥 $streak Day Streak!' : 'Welcome back!',
                style: const TextStyle(color: Color(0xFF8BA3CC), fontSize: 13)),
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: bg,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: primary.withOpacity(0.15)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    rewardItem('🪙', '+$coins', 'COINS', gold),
                    rewardItem('⚡', '+$xp', 'XP', primary),
                    if (streak > 1) rewardItem('🔥', '$streak', 'STREAK', Colors.orange),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              GestureDetector(
                onTap: () => Navigator.pop(ctx),
                child: Container(
                  width: double.infinity,
                  height: 48,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(colors: [Color(0xFFFFD700), Color(0xFFE6A800)]),
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [BoxShadow(color: gold.withOpacity(0.3), blurRadius: 12)],
                  ),
                  child: const Center(child: Text('CLAIM REWARD',
                    style: TextStyle(color: Color(0xFF050A18),
                        fontWeight: FontWeight.w900, fontSize: 13, letterSpacing: 1.5))),
                ),
              ),
            ],
          ),
        ),
      );
    }
  }

  Widget rewardItem(String icon, String value, String label, Color color) {
    return Column(
      children: [
        Text(icon, style: const TextStyle(fontSize: 26)),
        const SizedBox(height: 4),
        Text(value, style: TextStyle(color: color, fontWeight: FontWeight.w900, fontSize: 16)),
        Text(label, style: TextStyle(color: muted.withOpacity(0.7), fontSize: 9, letterSpacing: 1)),
      ],
    );
  }

  Future<void> loadGames() async {
    final String jsonStr = await rootBundle.loadString('assets/games.json');
    final List<dynamic> data = json.decode(jsonStr);
    setState(() {
      allGames = data.map((e) => Game.fromJson(e)).toList();
      applyFilters();
    });
  }

  void applyFilters() {
    List<Game> result = List.from(allGames);
    if (selectedTab == 'Featured') {
      result = result.where((g) => featuredTitles.contains(g.title)).toList();
    } else if (selectedTab == 'Trending') {
      result = result.where((g) => trendingTitles.contains(g.title)).toList();
    } else if (selectedTab == 'New') {
      result = result.where((g) => g.isNew).toList();
    } else if (selectedTab == 'Multiplayer') {
      result = result.where((g) => g.category == 'Multiplayer').toList();
    }
    if (selectedCategory != 'All') {
      result = result.where((g) => g.category == selectedCategory).toList();
    }
    if (searchQuery.isNotEmpty) {
      final q = searchQuery.toLowerCase();
      result = result.where((g) =>
        g.title.toLowerCase().contains(q) ||
        g.category.toLowerCase().contains(q)).toList();
    }
    setState(() => filteredGames = result);
  }

  void onNavTap(int index) {
    if (index == 0) {
      setState(() => bottomNavIndex = 0);
    } else if (index == 1) {
      Navigator.push(context, MaterialPageRoute(builder: (c) => const ChallengeScreen()));
    } else if (index == 2) {
      Navigator.push(context, MaterialPageRoute(builder: (c) => const RanksScreen()));
    } else if (index == 3) {
      Navigator.push(context, MaterialPageRoute(builder: (c) => const ProfileScreen()));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bg,
      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) => [
          buildAppBar(),
          buildFilters(),
        ],
        body: buildGrid(),
      ),
      bottomNavigationBar: buildBottomNav(),
    );
  }

  SliverAppBar buildAppBar() {
    return SliverAppBar(
      backgroundColor: surface,
      elevation: 0,
      floating: true,
      snap: true,
      automaticallyImplyLeading: false,
      title: RichText(
        text: const TextSpan(
          style: TextStyle(fontWeight: FontWeight.w900, fontSize: 22, letterSpacing: 2.5),
          children: [
            TextSpan(text: 'ARCADE', style: TextStyle(color: Color(0xFFFFD700))),
            TextSpan(text: 'HUB',    style: TextStyle(color: Color(0xFF0066FF))),
          ],
        ),
      ),
      actions: [
        StreamBuilder<DocumentSnapshot>(
          stream: FirebaseService.streamUserProfile(),
          builder: (context, snapshot) {
            int xp = 0; int coins = 0; int streak = 0;
            if (snapshot.hasData && snapshot.data!.exists) {
              final data = snapshot.data!.data() as Map<String, dynamic>;
              xp = data['xp'] ?? 0;
              coins = data['coins'] ?? 0;
              streak = data['streak'] ?? 0;
            }
            return Row(
              children: [
                statPill('🔥 $streak', Colors.orange),
                const SizedBox(width: 4),
                statPill('⚡ $xp', primary),
                const SizedBox(width: 4),
                statPill('🪙 $coins', gold),
                const SizedBox(width: 8),
              ],
            );
          },
        ),
      ],
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(1),
        child: Container(height: 1, color: gold.withOpacity(0.15)),
      ),
    );
  }

  Widget statPill(String label, Color color) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 13),
      padding: const EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.25)),
      ),
      child: Text(label, style: TextStyle(color: color, fontWeight: FontWeight.w800, fontSize: 11)),
    );
  }

  SliverToBoxAdapter buildFilters() {
    return SliverToBoxAdapter(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 14),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: TextField(
              controller: searchController,
              onChanged: (v) { setState(() => searchQuery = v); applyFilters(); },
              style: const TextStyle(color: Colors.white, fontSize: 13),
              decoration: InputDecoration(
                hintText: 'Search games...',
                hintStyle: TextStyle(color: muted.withOpacity(0.4), fontSize: 13),
                prefixIcon: const Icon(Icons.search, color: Color(0xFF8BA3CC), size: 20),
                suffixIcon: searchQuery.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.close, color: Color(0xFF8BA3CC), size: 18),
                      onPressed: () { searchController.clear(); setState(() => searchQuery = ''); applyFilters(); },
                    )
                  : null,
                filled: true,
                fillColor: surface,
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: primary.withOpacity(0.15))),
                enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: primary.withOpacity(0.15))),
                focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: gold.withOpacity(0.5), width: 1.5)),
              ),
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 36,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: categories.length,
              itemBuilder: (context, i) {
                final cat = categories[i];
                final active = selectedCategory == cat['name'];
                return GestureDetector(
                  onTap: () { setState(() => selectedCategory = cat['name']!); applyFilters(); },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    margin: const EdgeInsets.only(right: 8),
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      gradient: active ? const LinearGradient(
                        colors: [Color(0xFFFFD700), Color(0xFFE6A800)],
                      ) : null,
                      color: active ? null : surface,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: active ? Colors.transparent : primary.withOpacity(0.15),
                      ),
                      boxShadow: active ? [BoxShadow(color: gold.withOpacity(0.2), blurRadius: 8)] : null,
                    ),
                    child: Row(
                      children: [
                        Text(cat['icon']!, style: const TextStyle(fontSize: 12)),
                        const SizedBox(width: 5),
                        Text(cat['name']!,
                          style: TextStyle(
                            color: active ? const Color(0xFF050A18) : muted,
                            fontWeight: active ? FontWeight.w800 : FontWeight.w500,
                            fontSize: 11,
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
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: TabBar(
              controller: tabController,
              isScrollable: true,
              indicatorColor: gold,
              indicatorWeight: 2,
              indicatorSize: TabBarIndicatorSize.label,
              labelColor: gold,
              unselectedLabelColor: muted,
              labelStyle: const TextStyle(fontWeight: FontWeight.w800, fontSize: 12),
              tabs: tabs.map((t) => Tab(text: t)).toList(),
              padding: EdgeInsets.zero,
              tabAlignment: TabAlignment.start,
            ),
          ),
          const SizedBox(height: 10),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Container(
                  width: 3, height: 16,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFFFFD700), Color(0xFF0066FF)],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  selectedCategory == 'All' ? selectedTab : '$selectedCategory Games',
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 13),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                  decoration: BoxDecoration(
                    color: primary.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: primary.withOpacity(0.2)),
                  ),
                  child: Text('${filteredGames.length}',
                    style: const TextStyle(color: Color(0xFF8BA3CC), fontSize: 10)),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
        ],
      ),
    );
  }

  Widget buildGrid() {
    if (filteredGames.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('🎮', style: TextStyle(fontSize: 48)),
            const SizedBox(height: 12),
            const Text('No games found',
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 16)),
            const SizedBox(height: 6),
            Text('Try a different search or category',
              style: TextStyle(color: muted, fontSize: 12)),
          ],
        ),
      );
    }
    return GridView.builder(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 30),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 0.82,
      ),
      itemCount: filteredGames.length,
      itemBuilder: (context, index) {
        final game = filteredGames[index];
        return GameCard(
          game: game,
          onTap: () => Navigator.push(context, MaterialPageRoute(
            builder: (c) => GameScreen(
              game: game,
              player: Player(
                name: FirebaseService.currentName,
                uid: FirebaseService.currentUid,
              ),
            ),
          )),
        );
      },
    );
  }

  Widget buildBottomNav() {
    return Container(
      decoration: BoxDecoration(
        color: surface,
        border: Border(top: BorderSide(color: gold.withOpacity(0.15))),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.3), blurRadius: 20)],
      ),
      child: BottomNavigationBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        currentIndex: bottomNavIndex,
        selectedItemColor: gold,
        unselectedItemColor: muted,
        selectedLabelStyle: const TextStyle(fontWeight: FontWeight.w800, fontSize: 10),
        unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.w500, fontSize: 10),
        type: BottomNavigationBarType.fixed,
        onTap: onNavTap,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home_outlined),       activeIcon: Icon(Icons.home),            label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.sports_kabaddi_outlined), activeIcon: Icon(Icons.sports_kabaddi), label: 'Challenge'),
          BottomNavigationBarItem(icon: Icon(Icons.leaderboard_outlined), activeIcon: Icon(Icons.leaderboard),     label: 'Ranks'),
          BottomNavigationBarItem(icon: Icon(Icons.person_outline),       activeIcon: Icon(Icons.person),          label: 'Profile'),
        ],
      ),
    );
  }
}