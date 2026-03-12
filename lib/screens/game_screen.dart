import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import '../models/game.dart';
import '../models/player.dart';

class GameScreen extends StatefulWidget {
  final Game game;
  final Player player;

  const GameScreen({Key? key, required this.game, required this.player})
      : super(key: key);

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  late final WebViewController _controller;
  bool _isLoading = true;
  bool _xpEarned = false;

  @override
  void initState() {
    super.initState();
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setUserAgent(
          'Mozilla/5.0 (Linux; Android 11; Pixel 5) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/90.0.4430.91 Mobile Safari/537.36')
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (_) => setState(() => _isLoading = true),
          onPageFinished: (_) => setState(() => _isLoading = false),
          onWebResourceError: (error) {
            debugPrint('WebView error: ${error.description}');
          },
        ),
      )
      ..loadRequest(Uri.parse(widget.game.url));
  }

  void _earnXP() {
    if (_xpEarned) return;
    setState(() => _xpEarned = true);
    widget.player.addXP(50);
    widget.player.addCoins(10);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: const [
            Text('⚡ +50 XP  🪙 +10 Coins earned!',
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    fontSize: 13)),
          ],
        ),
        backgroundColor: const Color(0xFF0D1224),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
          side: const BorderSide(color: Color(0xFF00F5D4)),
        ),
        duration: const Duration(seconds: 2),
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
          icon: const Icon(Icons.arrow_back_ios, color: Color(0xFF00F5D4), size: 18),
          onPressed: () => Navigator.pop(context),
        ),
        title: Row(
          children: [
            Text(
              widget.game.icon,
              style: const TextStyle(fontSize: 18),
            ),
            const SizedBox(width: 8),
            Flexible(
              child: Text(
                widget.game.title,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                  fontSize: 16,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        actions: [
          // XP Earn button
          GestureDetector(
            onTap: _earnXP,
            child: Container(
              margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 4),
              padding: const EdgeInsets.symmetric(horizontal: 10),
              decoration: BoxDecoration(
                color: _xpEarned
                    ? Colors.grey.withOpacity(0.2)
                    : const Color(0xFFFFD700).withOpacity(0.12),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: _xpEarned
                      ? Colors.grey.withOpacity(0.3)
                      : const Color(0xFFFFD700).withOpacity(0.4),
                ),
              ),
              child: Text(
                _xpEarned ? '✅ XP' : '⚡ +50 XP',
                style: TextStyle(
                  color: _xpEarned ? Colors.grey : const Color(0xFFFFD700),
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ),
          // Reload
          IconButton(
            icon: const Icon(Icons.refresh, color: Color(0xFF8892B0), size: 20),
            onPressed: () => _controller.reload(),
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(
            height: 1,
            color: const Color(0xFF00F5D4).withOpacity(0.15),
          ),
        ),
      ),
      body: Stack(
        children: [
          WebViewWidget(controller: _controller),
          if (_isLoading)
            Container(
              color: const Color(0xFF060812),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      widget.game.icon,
                      style: const TextStyle(fontSize: 64),
                    ),
                    const SizedBox(height: 24),
                    const SizedBox(
                      width: 36,
                      height: 36,
                      child: CircularProgressIndicator(
                        color: Color(0xFF00F5D4),
                        strokeWidth: 2.5,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Loading ${widget.game.title}...',
                      style: const TextStyle(
                        color: Color(0xFF8892B0),
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
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
}