class Player {
  final int id;
  final String name;
  final String fname;
  final String lname;
  final String photoUrl;
  final String club;
  final String? birthDate;
  final int? heightCm;
  final List<String> positions;
  final String roleTag;
  final int caps;
  final int goals;
  final int assists;

  Player({
    required this.id,
    required this.name,
    required this.fname,
    required this.lname,
    required this.photoUrl,
    required this.club,
    required this.birthDate,
    required this.heightCm,
    required this.positions,
    required this.roleTag,
    required this.caps,
    required this.goals,
    required this.assists,
  });

  factory Player.fromJson(Map<String, dynamic> json) {
    int? _toInt(dynamic v) {
      if (v == null) return null;
      if (v is int) return v;
      if (v is String) return int.tryParse(v);
      return null;
    }

    return Player(
      id: _toInt(json['id']) ?? 0,
      name: json['name'] ?? '',
      fname: json['fname'] ?? '',
      lname: json['lname'] ?? '',
      photoUrl: json['photo_url'] ?? '',
      club: json['club'] ?? '',
      birthDate: json['birth_date'],
      heightCm: _toInt(json['height_cm']),
      positions: json['positions'] != null
          ? List<String>.from(json['positions'])
          : [],
      roleTag: json['role_tag'] ?? '',
      caps: _toInt(json['caps']) ?? 0,
      goals: _toInt(json['goals']) ?? 0,
      assists: _toInt(json['assists']) ?? 0,
    );
  }
}
