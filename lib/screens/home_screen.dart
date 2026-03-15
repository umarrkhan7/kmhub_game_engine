import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/game.dart';
import '../models/player.dart';
import '../widgets/game_card.dart';
import '../services/firebase_service.dart';
import 'category_screen.dart';
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
  final TextEditingController searchController = TextEditingController();

  final List<Map<String, String>> categories = [
    {'name': 'All',        'icon': '🎯'},
    {'name': 'Action',     'icon': '⚔️'},
    {'name': 'Racing',     'icon': '🏎️'},
    {'name': 'Puzzle',     'icon': '🧩'},
    {'name': 'Adventure',  'icon': '🗺️'},
    {'name': 'Sports',     'icon': '⚽'},
    {'name': 'Multiplayer','icon': '👥'},
    {'name': 'Casual',     'icon': '🎲'},
    {'name': 'Strategy',   'icon': '♟️'},
    {'name': 'Shooting',   'icon': '🎯'},
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
        setState(() {
          selectedTab = tabs[tabController.index];
          applyFilters();
        });
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
      final coins = result['coins'] ?? 50;
      final xp = result['xp'] ?? 20;
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          backgroundColor: const Color(0xFF0D1224),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
            side: BorderSide(color: const Color(0xFFFFD700).withOpacity(0.3)),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('🎁', style: TextStyle(fontSize: 52)),
              const SizedBox(height: 12),
              const Text('DAILY REWARD!',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w900,
                    fontSize: 18,
                    letterSpacing: 1.5,
                  )),
              const SizedBox(height: 6),
              Text(
                streak > 1 ? '🔥 $streak Day Streak!' : 'Welcome back!',
                style: const TextStyle(color: Color(0xFF8892B0), fontSize: 13),
              ),
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFF131828),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Column(children: [
                      const Text('🪙', style: TextStyle(fontSize: 28)),
                      const SizedBox(height: 4),
                      Text('+$coins Coins',
                          style: const TextStyle(
                              color: Color(0xFFFFD700),
                              fontWeight: FontWeight.w800,
                              fontSize: 13)),
                    ]),
                    Column(children: [
                      const Text('⚡', style: TextStyle(fontSize: 28)),
                      const SizedBox(height: 4),
                      Text('+$xp XP',
                          style: const TextStyle(
                              color: Color(0xFF00F5D4),
                              fontWeight: FontWeight.w800,
                              fontSize: 13)),
                    ]),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              Text(
                streak > 1
                    ? 'Longer streak = more coins! Keep it up!'
                    : 'Login daily to earn bonus coins!',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: const Color(0xFF8892B0).withOpacity(0.7),
                  fontSize: 11,
                ),
              ),
              const SizedBox(height: 16),
              GestureDetector(
                onTap: () => Navigator.pop(ctx),
                child: Container(
                  width: double.infinity,
                  height: 46,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFFFFD700), Color(0xFFFF9500)],
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Center(
                    child: Text('CLAIM REWARD',
                        style: TextStyle(
                          color: Color(0xFF060812),
                          fontWeight: FontWeight.w900,
                          fontSize: 13,
                          letterSpacing: 1.5,
                        )),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }
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

  void onBottomNavTap(int index) {
    if (index == 0) {
      setState(() => bottomNavIndex = 0);
    } else if (index == 1) {
      Navigator.push(context,
        MaterialPageRoute(builder: (ctx) => const ChallengeScreen()));
    } else if (index == 2) {
      Navigator.push(context,
        MaterialPageRoute(builder: (ctx) => const RanksScreen()));
    } else if (index == 3) {
      Navigator.push(context,
        MaterialPageRoute(builder: (ctx) => const ProfileScreen()));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF060812),
      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) => [
          buildAppBar(),
          buildSearchAndFilters(),
        ],
        body: buildGamesGrid(),
      ),
      bottomNavigationBar: buildBottomNav(),
    );
  }
  SliverAppBar buildAppBar() {
    return SliverAppBar(
      backgroundColor: const Color(0xFF0D1224),
      elevation: 0,
      floating: true,
      snap: true,
      automaticallyImplyLeading: false,
      title: Row(
        children: [
          RichText(
            text: const TextSpan(
              style: TextStyle(fontWeight: FontWeight.w900, fontSize: 22, letterSpacing: 2),
              children: [
                TextSpan(text: 'ARCADE', style: TextStyle(color: Color(0xFF00F5D4))),
                TextSpan(text: 'HUB',   style: TextStyle(color: Color(0xFFF72585))),
              ],
            ),
          ),
        ],
      ),
      actions: [
        StreamBuilder<DocumentSnapshot>(
          stream: FirebaseService.streamUserProfile(),
          builder: (context, snapshot) {
            int xp = 0;
            int coins = 0;
            int streak = 0;
            if (snapshot.hasData && snapshot.data!.exists) {
              final data = snapshot.data!.data() as Map<String, dynamic>;
              xp     = data['xp']     ?? 0;
              coins  = data['coins']  ?? 0;
              streak = data['streak'] ?? 0;
            }
            return Row(
              children: [
                statChip('🔥 $streak', const Color(0xFFFF6B35)),
                const SizedBox(width: 4),
                statChip('⚡ $xp XP', const Color(0xFF00F5D4)),
                const SizedBox(width: 4),
                statChip('🪙 $coins', const Color(0xFFFFD700)),
                const SizedBox(width: 8),
              ],
            );
          },
        ),
      ],
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(1),
        child: Container(height: 1, color: const Color(0xFF00F5D4).withOpacity(0.12)),
      ),
    );
  }

  Widget statChip(String label, Color color) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 12),
      padding: const EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(
        color: const Color(0xFF131828),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Center(
        child: Text(
          label,
          style: TextStyle(
            color: color,
            fontWeight: FontWeight.w800,
            fontSize: 11,
          ),
        ),
      ),
    );
  }
  SliverToBoxAdapter buildSearchAndFilters() {
    return SliverToBoxAdapter(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 14),

          // Search bar
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: TextField(
              controller: searchController,
              onChanged: (v) {
                setState(() => searchQuery = v);
                applyFilters();
              },
              style: const TextStyle(color: Colors.white, fontSize: 13),
              decoration: InputDecoration(
                hintText: 'Search games...',
                hintStyle: TextStyle(color: const Color(0xFF8892B0).withOpacity(0.5), fontSize: 13),
                prefixIcon: const Icon(Icons.search, color: Color(0xFF8892B0), size: 20),
                suffixIcon: searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.close, color: Color(0xFF8892B0), size: 18),
                        onPressed: () {
                          searchController.clear();
                          setState(() => searchQuery = '');
                          applyFilters();
                        },
                      )
                    : null,
                filled: true,
                fillColor: const Color(0xFF0D1224),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: const Color(0xFF00F5D4).withOpacity(0.12)),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: const Color(0xFF00F5D4).withOpacity(0.12)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Color(0xFF00F5D4), width: 1.5),
                ),
              ),
            ),
          ),
          const SizedBox(height: 14),
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
                  onTap: () {
                    setState(() => selectedCategory = cat['name']!);
                    applyFilters();
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    margin: const EdgeInsets.only(right: 8),
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: active
                          ? const Color(0xFF00F5D4).withOpacity(0.12)
                          : const Color(0xFF0D1224),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: active
                            ? const Color(0xFF00F5D4)
                            : const Color(0xFF00F5D4).withOpacity(0.1),
                      ),
                    ),
                    child: Row(
                      children: [
                        Text(cat['icon']!, style: const TextStyle(fontSize: 12)),
                        const SizedBox(width: 5),
                        Text(
                          cat['name']!,
                          style: TextStyle(
                            color: active ? const Color(0xFF00F5D4) : const Color(0xFF8892B0),
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
              indicatorColor: const Color(0xFF00F5D4),
              indicatorSize: TabBarIndicatorSize.label,
              labelColor: const Color(0xFF00F5D4),
              unselectedLabelColor: const Color(0xFF8892B0),
              labelStyle: const TextStyle(fontWeight: FontWeight.w700, fontSize: 12),
              tabs: tabs.map((t) => Tab(text: t)).toList(),
              padding: EdgeInsets.zero,
              tabAlignment: TabAlignment.start,
            ),
          ),
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Container(
                  width: 3,
                  height: 16,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF00F5D4), Color(0xFFF72585)],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  selectedCategory == 'All' ? selectedTab : '$selectedCategory Games',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                  decoration: BoxDecoration(
                    color: const Color(0xFF131828),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    '${filteredGames.length}',
                    style: const TextStyle(color: Color(0xFF8892B0), fontSize: 10),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
        ],
      ),
    );
  }
  Widget buildGamesGrid() {
    if (filteredGames.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('🎮', style: TextStyle(fontSize: 48)),
            SizedBox(height: 12),
            Text(
              'No games found',
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 16),
            ),
            SizedBox(height: 6),
            Text(
              'Try a different search or category',
              style: TextStyle(color: Color(0xFF8892B0), fontSize: 12),
            ),
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
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (ctx) => GameScreen(
                game: game,
                player: Player(
                  name: FirebaseService.currentName,
                  uid: FirebaseService.currentUid,
                ),
              ),
            ),
          ),
        );
      },
    );
  }
  Widget buildBottomNav() {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF0D1224),
        border: Border(
          top: BorderSide(color: const Color(0xFF00F5D4).withOpacity(0.12)),
        ),
      ),
      child: BottomNavigationBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        currentIndex: bottomNavIndex,
        selectedItemColor: const Color(0xFF00F5D4),
        unselectedItemColor: const Color(0xFF8892B0),
        selectedLabelStyle: const TextStyle(fontWeight: FontWeight.w800, fontSize: 10),
        unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.w500, fontSize: 10),
        type: BottomNavigationBarType.fixed,
        onTap: onBottomNavTap,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.sports_kabaddi_outlined),
            activeIcon: Icon(Icons.sports_kabaddi),
            label: 'Challenge',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.leaderboard_outlined),
            activeIcon: Icon(Icons.leaderboard),
            label: 'Ranks',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            activeIcon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}