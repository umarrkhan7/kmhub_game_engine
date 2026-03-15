import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/firebase_service.dart';
import '../models/game.dart';
import '../models/player.dart';
import 'game_screen.dart';
class ChallengeScreen extends StatefulWidget {
  const ChallengeScreen({Key? key}) : super(key: key);

  @override
  State<ChallengeScreen> createState() => _ChallengeScreenState();
}

class _ChallengeScreenState extends State<ChallengeScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _searchCtrl = TextEditingController();

  bool _isSearching = false;
  Map<String, dynamic>? _foundPlayer;
  String? _searchError;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchCtrl.dispose();
    super.dispose();
  }
  Future<void> _searchPlayer() async {
    final query = _searchCtrl.text.trim().toUpperCase();
    if (query.isEmpty) return;

    // Can't challenge yourself
    final myProfile = await FirebaseService.getUserProfile();
    if (myProfile != null && myProfile['gameId'] == query) {
      setState(() {
        _foundPlayer = null;
        _searchError = "That's your own Game ID! 😄";
      });
      return;
    }

    setState(() {
      _isSearching = true;
      _foundPlayer = null;
      _searchError = null;
    });

    final result = await FirebaseService.searchByGameId(query);

    setState(() {
      _isSearching = false;
      if (result != null) {
        _foundPlayer = result;
        _searchError = null;
      } else {
        _foundPlayer = null;
        _searchError = 'No player found with Game ID "$query"';
      }
    });
  }
  void _showSendChallengeDialog(Map<String, dynamic> opponent) {
    final List<Game> games = _getSampleGames();
    Game? selectedGame = games.first;
    final scoreCtrl = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => StatefulBuilder(
        builder: (ctx, setModalState) => Container(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom + 20,
            top: 20,
            left: 20,
            right: 20,
          ),
          decoration: BoxDecoration(
            color: const Color(0xFF0D1224),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
            border: Border.all(
                color: const Color(0xFF00F5D4).withOpacity(0.15)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: const Color(0xFF8892B0).withOpacity(0.3),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  const Text('⚔️', style: TextStyle(fontSize: 22)),
                  const SizedBox(width: 10),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('SEND CHALLENGE',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w900,
                            fontSize: 16,
                            letterSpacing: 1.5,
                          )),
                      Text(
                        'Challenging ${opponent['username']} · ${opponent['gameId']}',
                        style: const TextStyle(
                          color: Color(0xFF8892B0),
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 24),
              const Text('SELECT GAME',
                  style: TextStyle(
                    color: Color(0xFF8892B0),
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.5,
                  )),
              const SizedBox(height: 8),
              SizedBox(
                height: 44,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: games.length,
                  itemBuilder: (_, i) {
                    final g = games[i];
                    final selected = selectedGame?.title == g.title;
                    return GestureDetector(
                      onTap: () => setModalState(() => selectedGame = g),
                      child: Container(
                        margin: const EdgeInsets.only(right: 8),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 10),
                        decoration: BoxDecoration(
                          color: selected
                              ? const Color(0xFF00F5D4).withOpacity(0.12)
                              : const Color(0xFF131828),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: selected
                                ? const Color(0xFF00F5D4)
                                : const Color(0xFF00F5D4).withOpacity(0.1),
                          ),
                        ),
                        child: Row(
                          children: [
                            Text(g.icon,
                                style: const TextStyle(fontSize: 14)),
                            const SizedBox(width: 6),
                            Text(
                              g.title,
                              style: TextStyle(
                                color: selected
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
              const SizedBox(height: 20),
              const Text('YOUR SCORE TO BEAT',
                  style: TextStyle(
                    color: Color(0xFF8892B0),
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.5,
                  )),
              const SizedBox(height: 8),
              TextField(
                controller: scoreCtrl,
                keyboardType: TextInputType.number,
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w700),
                decoration: InputDecoration(
                  hintText: 'e.g. 4200',
                  hintStyle: TextStyle(
                      color: const Color(0xFF8892B0).withOpacity(0.4)),
                  prefixIcon: const Icon(Icons.emoji_events,
                      color: Color(0xFFFFD700), size: 18),
                  filled: true,
                  fillColor: const Color(0xFF131828),
                  contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 14),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                        color: const Color(0xFF00F5D4).withOpacity(0.12)),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                        color: const Color(0xFF00F5D4).withOpacity(0.12)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(
                        color: Color(0xFF00F5D4), width: 1.5),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                '⏰ Challenge expires in 24 hours',
                style: TextStyle(
                  color: const Color(0xFF8892B0).withOpacity(0.6),
                  fontSize: 10,
                ),
              ),
              const SizedBox(height: 24),
              GestureDetector(
                onTap: () async {
                  final scoreText = scoreCtrl.text.trim();
                  final score = int.tryParse(scoreText) ?? 0;
                  if (selectedGame == null || score <= 0) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      _snackBar('⚠️ Select a game and enter a valid score', false),
                    );
                    return;
                  }
                  Navigator.pop(ctx);
                  await FirebaseService.sendChallenge(
                    toUid: opponent['uid'],
                    toUsername: opponent['username'],
                    gameTitle: selectedGame!.title,
                    scoreToBeat: score,
                  );
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      _snackBar(
                          '⚔️ Challenge sent to ${opponent['username']}!', true),
                    );
                  }
                },
                child: Container(
                  width: double.infinity,
                  height: 52,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFFF72585), Color(0xFF7209B7)],
                    ),
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFFF72585).withOpacity(0.3),
                        blurRadius: 16,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('⚔️', style: TextStyle(fontSize: 16)),
                      SizedBox(width: 8),
                      Text(
                        'SEND CHALLENGE',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w900,
                          fontSize: 14,
                          letterSpacing: 1.5,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF060812),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0D1224),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios,
              color: Color(0xFF00F5D4), size: 18),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('CHALLENGES',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w800,
              fontSize: 16,
              letterSpacing: 2,
            )),
        bottom: TabBar(
          controller: _tabController,
          labelColor: const Color(0xFF00F5D4),
          unselectedLabelColor: const Color(0xFF8892B0),
          indicatorColor: const Color(0xFF00F5D4),
          indicatorWeight: 2,
          labelStyle: const TextStyle(
              fontWeight: FontWeight.w800, fontSize: 12, letterSpacing: 1),
          tabs: const [
            Tab(text: '🔍  FIND PLAYER'),
            Tab(text: '⚔️  INCOMING'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildFindPlayerTab(),
          _buildIncomingTab(),
        ],
      ),
    );
  }
  Widget _buildFindPlayerTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 8),

          // Info box
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: const Color(0xFF7209B7).withOpacity(0.08),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                  color: const Color(0xFF7209B7).withOpacity(0.2)),
            ),
            child: const Row(
              children: [
                Text('💡', style: TextStyle(fontSize: 18)),
                SizedBox(width: 10),
                // Expanded(
                //   child: Text(
                //     'Search any player using their Game ID (e.g. UMER#4821) and send them a challenge!',
                //     style: TextStyle(
                //       color: Color(0xFF8892B0),
                //       fontSize: 12,
                //     ),
                //   ),
                // ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Search field
          const Text('PLAYER GAME ID',
              style: TextStyle(
                color: Color(0xFF8892B0),
                fontSize: 10,
                fontWeight: FontWeight.w700,
                letterSpacing: 1.5,
              )),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _searchCtrl,
                  textCapitalization: TextCapitalization.characters,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1,
                  ),
                  onSubmitted: (_) => _searchPlayer(),
                  decoration: InputDecoration(
                    hintText: 'e.g. UMER#4821',
                    hintStyle: TextStyle(
                      color: const Color(0xFF8892B0).withOpacity(0.4),
                      fontWeight: FontWeight.w500,
                      letterSpacing: 0,
                    ),
                    prefixIcon: const Icon(Icons.search,
                        color: Color(0xFF8892B0), size: 20),
                    filled: true,
                    fillColor: const Color(0xFF0D1224),
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 14),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                          color: const Color(0xFF00F5D4).withOpacity(0.12)),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                          color: const Color(0xFF00F5D4).withOpacity(0.12)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(
                          color: Color(0xFF00F5D4), width: 1.5),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              GestureDetector(
                onTap: _searchPlayer,
                child: Container(
                  height: 52,
                  width: 52,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF00F5D4), Color(0xFF00B4CC)],
                    ),
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF00F5D4).withOpacity(0.25),
                        blurRadius: 10,
                      ),
                    ],
                  ),
                  child: _isSearching
                      ? const Center(
                          child: SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              color: Color(0xFF060812),
                              strokeWidth: 2,
                            ),
                          ),
                        )
                      : const Icon(Icons.search,
                          color: Color(0xFF060812), size: 22),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Error
          if (_searchError != null)
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFF72585).withOpacity(0.08),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                    color: const Color(0xFFF72585).withOpacity(0.2)),
              ),
              child: Row(
                children: [
                  const Text('❌', style: TextStyle(fontSize: 14)),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      _searchError!,
                      style: const TextStyle(
                          color: Color(0xFFF72585), fontSize: 12),
                    ),
                  ),
                ],
              ),
            ),
          if (_foundPlayer != null) _buildFoundPlayerCard(_foundPlayer!),
        ],
      ),
    );
  }

  Widget _buildFoundPlayerCard(Map<String, dynamic> player) {
    final xp = player['xp'] ?? 0;
    final level = player['level'] ?? 1;
    final wins = player['wins'] ?? 0;
    final gamesPlayed = player['gamesPlayed'] ?? 0;
    final badges = List<String>.from(player['badges'] ?? []);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            const Color(0xFF00F5D4).withOpacity(0.06),
            const Color(0xFF0D1224),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF00F5D4).withOpacity(0.2)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF00F5D4), Color(0xFF7209B7)],
                  ),
                  shape: BoxShape.circle,
                ),
                child: const Center(
                    child: Text('🎮', style: TextStyle(fontSize: 26))),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      player['username'] ?? 'Unknown',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                        fontSize: 17,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 3),
                      decoration: BoxDecoration(
                        color: const Color(0xFF00F5D4).withOpacity(0.08),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                            color:
                                const Color(0xFF00F5D4).withOpacity(0.3)),
                      ),
                      child: Text(
                        player['gameId'] ?? '',
                        style: const TextStyle(
                          color: Color(0xFF00F5D4),
                          fontWeight: FontWeight.w800,
                          fontSize: 11,
                          letterSpacing: 1,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: (player['isOnline'] == true)
                      ? Colors.green.withOpacity(0.12)
                      : Colors.grey.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 6,
                      height: 6,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: (player['isOnline'] == true)
                            ? Colors.green
                            : Colors.grey,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      (player['isOnline'] == true) ? 'Online' : 'Offline',
                      style: TextStyle(
                        color: (player['isOnline'] == true)
                            ? Colors.green
                            : Colors.grey,
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              _miniStat('LEVEL', '$level', const Color(0xFF00F5D4)),
              _miniStat('XP', '$xp', const Color(0xFFB48EFF)),
              _miniStat('WINS', '$wins', const Color(0xFFFFD700)),
              _miniStat('PLAYED', '$gamesPlayed', const Color(0xFFFF6B35)),
            ],
          ),

          if (badges.isNotEmpty) ...[
            const SizedBox(height: 12),
            Wrap(
              spacing: 6,
              children: badges
                  .take(3)
                  .map((b) => Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFD700).withOpacity(0.08),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                              color: const Color(0xFFFFD700).withOpacity(0.2)),
                        ),
                        child: Text(b,
                            style: const TextStyle(
                                color: Color(0xFFFFD700), fontSize: 10)),
                      ))
                  .toList(),
            ),
          ],
          const SizedBox(height: 16),
          GestureDetector(
            onTap: () => _showSendChallengeDialog(player),
            child: Container(
              width: double.infinity,
              height: 48,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFFF72585), Color(0xFF7209B7)],
                ),
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFFF72585).withOpacity(0.25),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('⚔️', style: TextStyle(fontSize: 16)),
                  const SizedBox(width: 8),
                  Text(
                    'CHALLENGE ${(player['username'] ?? '').toString().toUpperCase()}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w900,
                      fontSize: 13,
                      letterSpacing: 1,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
  Widget _buildIncomingTab() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseService.getIncomingChallenges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(color: Color(0xFF00F5D4)),
          );
        }

        final docs = snapshot.data?.docs ?? [];

        if (docs.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text('🛡️', style: TextStyle(fontSize: 56)),
                const SizedBox(height: 16),
                const Text(
                  'No Incoming Challenges',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                    fontSize: 18,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Challenge other players and they will\nappear here when they respond!',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: const Color(0xFF8892B0).withOpacity(0.7),
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: docs.length,
          itemBuilder: (_, i) {
            final data = docs[i].data() as Map<String, dynamic>;
            final challengeId = docs[i].id;
            return _buildChallengeCard(data, challengeId);
          },
        );
      },
    );
  }

  Widget _buildChallengeCard(Map<String, dynamic> data, String challengeId) {
    final fromUsername = data['fromUsername'] ?? 'Unknown';
    final gameTitle = data['gameTitle'] ?? 'Unknown Game';
    final scoreToBeat = data['scoreToBeat'] ?? 0;
    final expiresAt = (data['expiresAt'] as Timestamp?)?.toDate();
    final timeLeft = expiresAt != null
        ? expiresAt.difference(DateTime.now())
        : Duration.zero;
    final hoursLeft = timeLeft.inHours;

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF0D1224),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
            color: const Color(0xFFF72585).withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFFF72585), Color(0xFF7209B7)],
                  ),
                  shape: BoxShape.circle,
                ),
                child: const Center(
                    child: Text('⚔️', style: TextStyle(fontSize: 20))),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    RichText(
                      text: TextSpan(
                        style: const TextStyle(fontSize: 13),
                        children: [
                          TextSpan(
                            text: fromUsername,
                            style: const TextStyle(
                              color: Color(0xFFF72585),
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          const TextSpan(
                            text: ' challenged you!',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      hoursLeft > 0
                          ? '⏰ $hoursLeft hours left to respond'
                          : '⏰ Expiring soon!',
                      style: TextStyle(
                        color: hoursLeft > 6
                            ? const Color(0xFF8892B0)
                            : const Color(0xFFFF6B35),
                        fontSize: 10,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFF131828),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('GAME',
                          style: TextStyle(
                            color: Color(0xFF8892B0),
                            fontSize: 9,
                            letterSpacing: 1,
                          )),
                      const SizedBox(height: 2),
                      Text(
                        gameTitle,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  width: 1,
                  height: 36,
                  color: const Color(0xFF00F5D4).withOpacity(0.1),
                ),
                const SizedBox(width: 16),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    const Text('SCORE TO BEAT',
                        style: TextStyle(
                          color: Color(0xFF8892B0),
                          fontSize: 9,
                          letterSpacing: 1,
                        )),
                    const SizedBox(height: 2),
                    Text(
                      '$scoreToBeat',
                      style: const TextStyle(
                        color: Color(0xFFFFD700),
                        fontWeight: FontWeight.w900,
                        fontSize: 20,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: () => _acceptChallenge(data, challengeId),
                  child: Container(
                    height: 44,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF00F5D4), Color(0xFF00B4CC)],
                      ),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text('🎮', style: TextStyle(fontSize: 14)),
                        SizedBox(width: 6),
                        Text(
                          'ACCEPT & PLAY',
                          style: TextStyle(
                            color: Color(0xFF060812),
                            fontWeight: FontWeight.w900,
                            fontSize: 12,
                            letterSpacing: 1,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              GestureDetector(
                onTap: () => _declineChallenge(challengeId),
                child: Container(
                  height: 44,
                  width: 44,
                  decoration: BoxDecoration(
                    color: const Color(0xFFF72585).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                        color: const Color(0xFFF72585).withOpacity(0.3)),
                  ),
                  child: const Icon(Icons.close,
                      color: Color(0xFFF72585), size: 18),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
  Future<void> _acceptChallenge(
      Map<String, dynamic> data, String challengeId) async {
    // Mark as accepted
    await FirebaseFirestore.instance
        .collection('challenges')
        .doc(challengeId)
        .update({'status': 'accepted'});

    // Find the game and open it
    final games = _getSampleGames();
    final gameTitle = data['gameTitle'] ?? '';
    final game = games.firstWhere(
      (g) => g.title == gameTitle,
      orElse: () => games.first,
    );

    if (context.mounted) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => GameScreen(
            game: game,
            player: Player(
              name: FirebaseService.currentName,
              uid: FirebaseService.currentUid,
            ),
          ),
        ),
      );
    }
  }
  Future<void> _declineChallenge(String challengeId) async {
    await FirebaseFirestore.instance
        .collection('challenges')
        .doc(challengeId)
        .update({'status': 'declined'});

    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        _snackBar('Challenge declined', false),
      );
    }
  }
  Widget _miniStat(String label, String value, Color color) {
    return Expanded(
      child: Column(
        children: [
          Text(value,
              style: TextStyle(
                  color: color,
                  fontWeight: FontWeight.w800,
                  fontSize: 14)),
          const SizedBox(height: 2),
          Text(label,
              style: const TextStyle(
                  color: Color(0xFF8892B0),
                  fontSize: 8,
                  letterSpacing: 0.5)),
        ],
      ),
    );
  }

  SnackBar _snackBar(String msg, bool success) {
    return SnackBar(
      content: Text(msg,
          style: const TextStyle(
              color: Colors.white, fontWeight: FontWeight.w700)),
      backgroundColor: const Color(0xFF0D1224),
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
        side: BorderSide(
          color: success
              ? const Color(0xFF00F5D4)
              : const Color(0xFFF72585),
        ),
      ),
    );
  }

  List<Game> _getSampleGames() {
    return [
      Game(title: 'Moto X3M', url: 'https://poki.com/en/g/moto-x3m', icon: '🏍️', category: 'Racing', isHot: true),
      Game(title: 'Subway Surfers', url: 'https://poki.com/en/g/subway-surfers', icon: '🏃', category: 'Action', isHot: true),
      Game(title: '8 Ball Pool', url: 'https://www.miniclip.com/games/8-ball-pool', icon: '🎱', category: 'Sports'),
      Game(title: 'Chess', url: 'https://www.chess.com/play/online', icon: '♟️', category: 'Strategy'),
      Game(title: 'Knife Hit', url: 'https://poki.com/en/g/knife-hit', icon: '🔪', category: 'Casual'),
    ];
  }
}