import 'dart:async';
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import '../models/game.dart';
import '../models/player.dart';
import '../services/firebase_service.dart';

class GameScreen extends StatefulWidget {
  final Game game;
  final Player player;

  const GameScreen({Key? key, required this.game, required this.player})
      : super(key: key);

  @override
  State<GameScreen> createState() => GameScreenState();
}

class GameScreenState extends State<GameScreen> with WidgetsBindingObserver {
  late final WebViewController controller;
  bool isLoading = true;
  Timer? pointTimer;
  int currentPoints = 0;
  int secondsPlayed = 0;
  bool sessionSaved = false;

  static const bg      = Color(0xFF0A1A0F);
  static const surface = Color(0xFF122A1A);
  static const card    = Color(0xFF0D2015);
  static const primary = Color(0xFF3A9A5C);
  static const olive   = Color(0xFFA8C878);
  static const dark    = Color(0xFF1F5C35);
  static const muted   = Color(0xFF7AAF8A);

  static const int secondsPerPoint = 10;
  static const int xpPerPoint = 5;
  static const int coinsPerMinute = 3;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    setupWebView();
    startTimer();
  }

  void setupWebView() {
    controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setUserAgent(
          'Mozilla/5.0 (Linux; Android 11; Pixel 5) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/90.0.4430.91 Mobile Safari/537.36')
      ..setNavigationDelegate(NavigationDelegate(
        onPageStarted: (u) => setState(() => isLoading = true),
        onPageFinished: (u) => setState(() => isLoading = false),
      ))
      ..loadRequest(Uri.parse(widget.game.url));
  }

  void startTimer() {
    pointTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) { timer.cancel(); return; }
      setState(() {
        secondsPlayed++;
        if (secondsPlayed % secondsPerPoint == 0) currentPoints++;
      });
    });
  }

  Future<void> stopAndSave() async {
    if (sessionSaved) return;
    sessionSaved = true;
    pointTimer?.cancel();
    if (currentPoints > 0 && FirebaseService.isLoggedIn) {
      await FirebaseService.saveScore(gameTitle: widget.game.title, score: currentPoints);
      final int xpEarned     = currentPoints * xpPerPoint;
      final int coinsEarned  = (secondsPlayed ~/ 60) * coinsPerMinute;
      if (xpEarned > 0 || coinsEarned > 0) {
        await FirebaseService.addXPAndCoins(xp: xpEarned, coins: coinsEarned);
      }
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused) {
      pointTimer?.cancel();
    } else if (state == AppLifecycleState.resumed) {
      if (!sessionSaved) startTimer();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    stopAndSave();
    pointTimer?.cancel();
    super.dispose();
  }

  String get formattedTime {
    final mins = (secondsPlayed ~/ 60).toString().padLeft(2, '0');
    final secs = (secondsPlayed % 60).toString().padLeft(2, '0');
    return '$mins:$secs';
  }

  int get secondsToNextPoint => secondsPerPoint - (secondsPlayed % secondsPerPoint);

  @override
  Widget build(BuildContext context) {
    return PopScope(
      onPopInvoked: (didPop) async {
        if (didPop) await stopAndSave();
      },
      child: Scaffold(
        backgroundColor: bg,
        appBar: AppBar(
          backgroundColor: surface,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios, color: Color(0xFFA8C878), size: 18),
            onPressed: () async {
              await stopAndSave();
              if (context.mounted) showSummaryAndPop();
            },
          ),
          title: Row(
            children: [
              Text(widget.game.icon, style: const TextStyle(fontSize: 18)),
              const SizedBox(width: 8),
              Flexible(
                child: Text(
                  widget.game.title,
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 15),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          actions: [
            Container(
              margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 4),
              padding: const EdgeInsets.symmetric(horizontal: 10),
              decoration: BoxDecoration(
                color: olive.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: olive.withOpacity(0.3)),
              ),
              child: Center(
                child: Text(
                  '🏆 $currentPoints pts',
                  style: const TextStyle(color: Color(0xFFA8C878), fontWeight: FontWeight.w800, fontSize: 12),
                ),
              ),
            ),
            Container(
              margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 4),
              padding: const EdgeInsets.symmetric(horizontal: 10),
              decoration: BoxDecoration(
                color: primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: primary.withOpacity(0.25)),
              ),
              child: Center(
                child: Text(
                  '⏱ $formattedTime',
                  style: const TextStyle(color: Color(0xFF3A9A5C), fontWeight: FontWeight.w800, fontSize: 12),
                ),
              ),
            ),
            IconButton(
              icon: Icon(Icons.refresh, color: muted, size: 20),
              onPressed: () => controller.reload(),
            ),
          ],
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(3),
            child: Stack(
              children: [
                Container(height: 3, color: card),
                AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  height: 3,
                  width: MediaQuery.of(context).size.width *
                      ((secondsPerPoint - secondsToNextPoint) / secondsPerPoint),
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Color(0xFF3A9A5C), Color(0xFFA8C878)],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        body: Stack(
          children: [
            WebViewWidget(controller: controller),
            if (isLoading)
              Container(
                color: bg,
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(widget.game.icon, style: const TextStyle(fontSize: 64)),
                      const SizedBox(height: 24),
                      CircularProgressIndicator(color: primary, strokeWidth: 2.5),
                      const SizedBox(height: 16),
                      Text(
                        'Loading ${widget.game.title}...',
                        style: TextStyle(color: muted, fontSize: 14, fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                ),
              ),
            if (!isLoading)
              Positioned(
                bottom: 16,
                left: 16,
                right: 16,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  decoration: BoxDecoration(
                    color: surface.withOpacity(0.95),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: olive.withOpacity(0.2)),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      hudItem('🏆', '$currentPoints', 'POINTS'),
                      Container(width: 1, height: 30, color: olive.withOpacity(0.15)),
                      hudItem('⏱', formattedTime, 'TIME'),
                      Container(width: 1, height: 30, color: olive.withOpacity(0.15)),
                      hudItem('⚡', '+${currentPoints * xpPerPoint}', 'XP'),
                      Container(width: 1, height: 30, color: olive.withOpacity(0.15)),
                      hudItem('⏳', '${secondsToNextPoint}s', 'NEXT PT'),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  void showSummaryAndPop() {
    if (currentPoints == 0) {
      Navigator.pop(context);
      return;
    }
    final xpEarned    = currentPoints * xpPerPoint;
    final coinsEarned = (secondsPlayed ~/ 60) * coinsPerMinute;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        backgroundColor: surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(color: olive.withOpacity(0.25)),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(widget.game.icon, style: const TextStyle(fontSize: 52)),
            const SizedBox(height: 12),
            const Text(
              'SESSION COMPLETE!',
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900,
                  fontSize: 16, letterSpacing: 1.5),
            ),
            const SizedBox(height: 6),
            Text(widget.game.title, style: TextStyle(color: muted, fontSize: 12)),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: card,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: primary.withOpacity(0.15)),
              ),
              child: Column(
                children: [
                  summaryRow('🏆 Score', '$currentPoints points', olive),
                  const SizedBox(height: 10),
                  summaryRow('⏱ Time Played', formattedTime, primary),
                  const SizedBox(height: 10),
                  summaryRow('⚡ XP Earned', '+$xpEarned XP', primary),
                  const SizedBox(height: 10),
                  summaryRow('🪙 Coins Earned', '+$coinsEarned coins', olive),
                ],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '10 seconds of play = 1 point',
              style: TextStyle(color: muted.withOpacity(0.6), fontSize: 10),
            ),
            const SizedBox(height: 16),
            GestureDetector(
              onTap: () {
                Navigator.pop(ctx);
                Navigator.pop(context);
              },
              child: Container(
                width: double.infinity,
                height: 48,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF3A9A5C), Color(0xFF1F5C35)],
                  ),
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [BoxShadow(color: primary.withOpacity(0.35), blurRadius: 12)],
                ),
                child: const Center(
                  child: Text(
                    'BACK TO HOME',
                    style: TextStyle(color: Colors.white,
                        fontWeight: FontWeight.w900, fontSize: 13, letterSpacing: 1.5),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget hudItem(String icon, String value, String label) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(icon, style: const TextStyle(fontSize: 14)),
        const SizedBox(height: 2),
        Text(value, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 12)),
        Text(label, style: TextStyle(color: muted, fontSize: 8, letterSpacing: 0.5)),
      ],
    );
  }

  Widget summaryRow(String label, String value, Color color) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: TextStyle(color: muted, fontSize: 12)),
        Text(value, style: TextStyle(color: color, fontWeight: FontWeight.w800, fontSize: 13)),
      ],
    );
  }
}