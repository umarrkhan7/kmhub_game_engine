class Player {
  String name;
  String uid;
  int xp;
  int coins;
  int streak;
  int level;
  int gamesPlayed;
  List<String> badges;

  Player({
    this.name = 'PLAYER ONE',
    this.uid = '',
    this.xp = 0,
    this.coins = 100,
    this.streak = 0,
    this.level = 1,
    this.gamesPlayed = 0,
    this.badges = const ['🎮 Newcomer'],
  });

  int get xpToNextLevel => (level + 1) * 500;
  double get xpProgress => xp / xpToNextLevel;

  void addXP(int amount) {
    xp += amount;
    if (xp >= xpToNextLevel) {
      xp -= xpToNextLevel;
      level++;
    }
  }

  void addCoins(int amount) {
    coins += amount;
  }
}