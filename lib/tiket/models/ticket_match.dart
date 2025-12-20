import 'dart:convert';

import 'ticket_link.dart';

class TicketMatch {
  const TicketMatch({
    this.id,
    required this.matchId,
    required this.team1,
    required this.team2,
    required this.imgTeam1,
    required this.imgTeam2,
    this.imgCup,
    this.place,
    required this.date,
    this.links = const [],
  });

  final int? id;
  final String matchId;
  final String team1;
  final String team2;
  final String imgTeam1;
  final String imgTeam2;
  final String? imgCup;
  final String? place;
  final DateTime date;
  final List<TicketLink> links;

  factory TicketMatch.fromJson(Map<String, dynamic> json) {
    return TicketMatch(
      id: _asInt(json['id']),
      matchId: json['match_id']?.toString() ?? '',
      team1: json['team1']?.toString() ?? '',
      team2: json['team2']?.toString() ?? '',
      imgTeam1: json['img_team1']?.toString() ?? '',
      imgTeam2: json['img_team2']?.toString() ?? '',
      imgCup: _asNullableString(json['img_cup']),
      place: _asNullableString(json['place']),
      date: _parseDate(json['date']),
      links: List.unmodifiable(_parseLinks(json['links'])),
    );
  }

  Map<String, dynamic> toJson({bool includeLinks = true}) {
    return {
      'id': id,
      'match_id': matchId,
      'team1': team1,
      'team2': team2,
      'img_team1': imgTeam1,
      'img_team2': imgTeam2,
      'img_cup': imgCup,
      'place': place,
      'date': _dateToIsoString(date),
      if (includeLinks) 'links': links.map((link) => link.toJson()).toList(),
    };
  }

  TicketMatch copyWith({
    int? id,
    String? matchId,
    String? team1,
    String? team2,
    String? imgTeam1,
    String? imgTeam2,
    String? imgCup,
    String? place,
    DateTime? date,
    List<TicketLink>? links,
  }) {
    return TicketMatch(
      id: id ?? this.id,
      matchId: matchId ?? this.matchId,
      team1: team1 ?? this.team1,
      team2: team2 ?? this.team2,
      imgTeam1: imgTeam1 ?? this.imgTeam1,
      imgTeam2: imgTeam2 ?? this.imgTeam2,
      imgCup: imgCup ?? this.imgCup,
      place: place ?? this.place,
      date: date ?? this.date,
      links: links ?? this.links,
    );
  }
}

TicketMatch ticketMatchFromJson(String str) =>
    TicketMatch.fromJson(json.decode(str) as Map<String, dynamic>);

List<TicketMatch> ticketMatchListFromJson(String str) {
  final dynamic data = json.decode(str);
  if (data is List) {
    return data.map((e) => TicketMatch.fromJson(e as Map<String, dynamic>)).toList();
  }
  return [];
}

String ticketMatchToJson(TicketMatch data, {bool includeLinks = true}) =>
    json.encode(data.toJson(includeLinks: includeLinks));

String ticketMatchListToJson(List<TicketMatch> data, {bool includeLinks = true}) => json
    .encode(data.map((match) => match.toJson(includeLinks: includeLinks)).toList());

List<TicketLink> _parseLinks(dynamic value) {
  if (value is List) {
    return value
        .whereType<Map<String, dynamic>>()
        .map(TicketLink.fromJson)
        .toList();
  }
  return const [];
}

int? _asInt(dynamic value) {
  if (value == null) return null;
  if (value is int) return value;
  return int.tryParse(value.toString());
}

DateTime _parseDate(dynamic value) {
  if (value is DateTime) return value;
  if (value is String && value.isNotEmpty) {
    return DateTime.tryParse(value) ?? DateTime.now();
  }
  return DateTime.now();
}

String _dateToIsoString(DateTime date) => date.toIso8601String().split('T').first;

String? _asNullableString(dynamic value) {
  if (value == null) return null;
  final stringValue = value.toString().trim();
  return stringValue.isEmpty ? null : stringValue;
}
