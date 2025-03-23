class Team {
  final int id;
  final String name;
  final String abbr;
  final String conference;
  final String division;

  Team({
    required this.id,
    required this.name,
    required this.abbr,
    required this.conference,
    required this.division,
  });

  factory Team.fromJson(Map<String, dynamic> json) {
    return Team(
      id: json['id'],
      name: json['name'],
      abbr: json['abbr'],
      conference: json['conference'],
      division: json['division'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'abbr': abbr,
      'conference': conference,
      'division': division,
    };
  }
}
