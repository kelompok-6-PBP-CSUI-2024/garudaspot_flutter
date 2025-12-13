class Player {
  final int id;
  final String fname;
  final String lname;
  final String name;
  final String photoUrl;
  final String club;
  final int? age;
  final int? heightCm;
  final List<String> positions;
  final String roleTag;
  final int caps;
  final int goals;
  final int assists;

  Player({
    required this.id,
    required this.fname,
    required this.lname,
    required this.name,
    required this.photoUrl,
    required this.club,
    required this.age,
    required this.heightCm,
    required this.positions,
    required this.roleTag,
    required this.caps,
    required this.goals,
    required this.assists,
  });

factory Player.fromJson(Map<String, dynamic> json) {
  return Player(
    id: json['id'] ?? 0,
    name: json['name'] ?? '',

    fname: json['fname'] ?? '',
    lname: json['lname'] ?? '',

    photoUrl: json['photo_url'] ?? '',
    club: json['club'] ?? '',

    age: json['age'],
    heightCm: json['height_cm'],

    positions: json['positions'] != null
        ? List<String>.from(json['positions'])
        : [],

    roleTag: json['role_tag'] ?? '',

    caps: json['caps'] ?? 0,
    goals: json['goals'] ?? 0,
    assists: json['assists'] ?? 0,
  );
}

}
