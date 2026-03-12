class Game {
  final String title;
  final String url;
  final String category;
  final String icon;
  final String source;
  final bool isHot;
  final bool isNew;

  Game({
    required this.title,
    required this.url,
    required this.category,
    this.icon = '🎮',
    this.source = '',
    this.isHot = false,
    this.isNew = false,
  });

  factory Game.fromJson(Map<String, dynamic> json) {
    return Game(
      title: json['title'] ?? '',
      url: json['url'] ?? '',
      category: json['category'] ?? 'Casual',
      icon: json['icon'] ?? '🎮',
      source: json['source'] ?? '',
      isHot: json['isHot'] ?? false,
      isNew: json['isNew'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'url': url,
      'category': category,
      'icon': icon,
      'source': source,
      'isHot': isHot,
      'isNew': isNew,
    };
  }
}