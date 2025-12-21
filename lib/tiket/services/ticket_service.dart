import 'dart:convert';

import 'package:garudaspot_flutter/tiket/models/ticket_match.dart';
import 'package:http/http.dart' as http;
import 'package:pbp_django_auth/pbp_django_auth.dart';

class TicketMatchPayload {
  TicketMatchPayload({
    required this.team1,
    required this.team2,
    required this.imgTeam1,
    required this.imgTeam2,
    required this.dateIso,
    this.imgCup,
    this.place,
  });

  final String team1;
  final String team2;
  final String imgTeam1;
  final String imgTeam2;
  final String dateIso; // YYYY-MM-DD
  final String? imgCup;
  final String? place;

  Map<String, String> toFormPayload() {
    return {
      'team1': team1,
      'team2': team2,
      'img_team1': imgTeam1,
      'img_team2': imgTeam2,
      'img_cup': imgCup ?? '',
      'place': place ?? '',
      'date': dateIso,
    };
  }

  Map<String, dynamic> toJsonPayload() {
    return {
      'team1': team1,
      'team2': team2,
      'img_team1': imgTeam1,
      'img_team2': imgTeam2,
      'img_cup': imgCup,
      'place': place,
      'date': dateIso,
    };
  }
}

class TicketLinkPayload {
  TicketLinkPayload({
    required this.vendor,
    required this.vendorLink,
    required this.price,
    required this.imgVendor,
  });

  final String vendor;
  final String vendorLink;
  final int price;
  final String imgVendor;

  Map<String, String> toFormPayload() {
    return {
      'vendor': vendor,
      'vendor_link': vendorLink,
      'price': price.toString(),
      'img_vendor': imgVendor,
    };
  }

  Map<String, dynamic> toJsonPayload() {
    return {
      'vendor': vendor,
      'vendor_link': vendorLink,
      'price': price,
      'img_vendor': imgVendor,
    };
  }
}

class TicketApiService {
  TicketApiService({
    http.Client? client,
    this.baseUrl = _defaultBaseUrl,
  }) : _client = client ?? http.Client();

  static const String _defaultBaseUrl = 'https://hasanul-muttaqin-garudaspot.pbp.cs.ui.ac.id';

  final http.Client _client;
  final String baseUrl;

  Uri _uri(String path) => Uri.parse('$baseUrl$path');

  Future<List<TicketMatch>> fetchMatches() async {
    final res = await _client.get(
      _uri('/tickets/json/'),
      headers: const {'Accept': 'application/json'},
    );
    if (res.statusCode != 200) {
      throw Exception('Failed to load tickets (${res.statusCode})');
    }
    final dynamic data = json.decode(res.body);
    if (data is List) {
      return data.map((e) => TicketMatch.fromJson(e as Map<String, dynamic>)).toList();
    }
    return [];
  }

  Future<TicketMatch> fetchMatchDetail(String matchUuid) async {
    final res = await _client.get(
      _uri('/tickets/json/$matchUuid/'),
      headers: const {'Accept': 'application/json'},
    );
    if (res.statusCode != 200) {
      throw Exception('Failed to load ticket detail (${res.statusCode})');
    }
    final dynamic data = json.decode(res.body);
    if (data is Map<String, dynamic>) {
      return TicketMatch.fromJson(data);
    }
    throw Exception('Unexpected detail response');
  }

  Future<bool> createMatch({
    required CookieRequest request,
    required TicketMatchPayload payload,
    bool asJson = false,
  }) async {
    try {
      await request.post(
        "$baseUrl/tickets/create/",
        asJson ? payload.toJsonPayload() : payload.toFormPayload(),
      );
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<bool> updateMatch({
    required CookieRequest request,
    required String matchUuid,
    required TicketMatchPayload payload,
    bool asJson = false,
  }) async {
    try {
      await request.post(
        "$baseUrl/tickets/edit/$matchUuid/",
        asJson ? payload.toJsonPayload() : payload.toFormPayload(),
      );
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<bool> deleteMatch({
    required CookieRequest request,
    required String matchUuid,
  }) async {
    try {
      await request.post(
        "$baseUrl/tickets/delete/$matchUuid/",
        {},
      );
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<bool> createLink({
    required CookieRequest request,
    required String matchUuid,
    required TicketLinkPayload payload,
    bool asJson = false,
  }) async {
    try {
      await request.post(
        "$baseUrl/tickets/link/create/$matchUuid/",
        asJson ? payload.toJsonPayload() : payload.toFormPayload(),
      );
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<bool> deleteLink({
    required CookieRequest request,
    required String linkUuid,
  }) async {
    try {
      await request.post(
        "$baseUrl/tickets/link/delete/$linkUuid/",
        {},
      );
      return true;
    } catch (_) {
      return false;
    }
  }
}
