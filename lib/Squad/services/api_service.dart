import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:pbp_django_auth/pbp_django_auth.dart';
import '../models/player.dart';

class ApiService {
  static const String baseUrl = "https://hasanul-muttaqin-garudaspot.pbp.cs.ui.ac.id";

  static Future<List<Player>> fetchPlayers() async {
    final url = Uri.parse("$baseUrl/squad/api/players/");
    final response = await http.get(url);

    if (response.statusCode != 200) {
      throw Exception("Failed to load players");
    }

    final List data = json.decode(response.body);
    return data.map((e) => Player.fromJson(e)).toList();
  }

  static Future<Player> fetchPlayerDetail(int id) async {
    final url = Uri.parse("$baseUrl/squad/api/players/$id/");
    final response = await http.get(url);

    if (response.statusCode != 200) {
      throw Exception("Failed to load player detail");
    }

    return Player.fromJson(json.decode(response.body));
  }

  // =========================
  // CREATE PLAYER (ADMIN)
  // =========================
static Future<Player> createPlayer({
  required CookieRequest request,
  required Map<String, String> data,
  bool isAdmin = false,
}) async {
  final payload = {
    ...data,
    "is_admin": isAdmin ? "true" : "false",
  };
  final res = await request.postJson(
    "$baseUrl/squad/api/players/create/",
    jsonEncode(payload),
  );

  return Player.fromJson(res);
}
  // =========================
  // UPDATE PLAYER (ADMIN)
  // =========================
static Future<Player> updatePlayer({
  required CookieRequest request,
  required int playerId,
  required Map<String, String> data,
  bool isAdmin = false,
}) async {
  final payload = {
    ...data,
    "is_admin": isAdmin ? "true" : "false",
  };
  final res = await request.postJson(
    "$baseUrl/squad/api/players/$playerId/edit/",
    jsonEncode(payload),
  );

  return Player.fromJson(res);
}
  // =========================
  // DELETE PLAYER (ADMIN)
  // =========================
static Future<void> deletePlayer({
  required CookieRequest request,
  required int playerId,
  bool isAdmin = false,
}) async {
  await request.postJson(
    "$baseUrl/squad/api/players/$playerId/delete/",
    jsonEncode({
      "is_admin": isAdmin ? "true" : "false",
    }),
  );
}
static Future<void> initCsrf(CookieRequest request) async {
  await request.get(
    "$baseUrl/squad/player/form/",
  );
}

}
