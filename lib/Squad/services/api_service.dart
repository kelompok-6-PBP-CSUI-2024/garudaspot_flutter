import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/player.dart';

class ApiService {
  // GANTI SESUAI DEVICE
static const String baseUrl =
    'http://127.0.0.1:8000/squad/api/players/';

  // Android Emulator
  // HP asli → http://IP_LAPTOP:8000/...
  // iOS simulator → http://127.0.0.1:8000/...

static Future<List<Player>> fetchPlayers() async {
  final response = await http.get(
    Uri.parse(baseUrl),
    headers: {'Accept': 'application/json'},
  );

  final List data = json.decode(response.body);
  return data.map((e) => Player.fromJson(e)).toList();
}
}
