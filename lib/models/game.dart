class Game {
  final int id;
  final String date;
  final Team homeTeam;
  final Team awayTeam;
  final int? homeScore;
  final int? awayScore;
  final String status;
  final Map<String, dynamic>? prediction;

  Game({
    required this.id,
    required this.date,
    required this.homeTeam,
    required this.awayTeam,
    this.homeScore,
    this.awayScore,
    required this.status,
    this.prediction,
  });

  factory Game.fromJson(Map<String, dynamic> json) {
    return Game(
      id: json['id'],
      date: json['date'],
      homeTeam: Team.fromJson(json['home_team']),
      awayTeam: Team.fromJson(json['away_team']),
      homeScore: json['home_score'],
      awayScore: json['away_score'],
      status: json['status'],
      prediction: json['prediction'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'date': date,
      'home_team': homeTeam.toJson(),
      'away_team': awayTeam.toJson(),
      'home_score': homeScore,
      'away_score': awayScore,
      'status': status,
      'prediction': prediction,
    };
  }
}
