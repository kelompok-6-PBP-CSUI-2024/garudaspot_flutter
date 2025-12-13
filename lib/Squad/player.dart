import 'package:flutter/material.dart';
import 'models/player.dart';
import 'services/api_service.dart';
import 'widgets/player_card.dart';
import '../right_drawer.dart';
void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: SquadPage(),
    );
  }
}

class SquadPage extends StatefulWidget {
  const SquadPage({super.key});

  @override
  State<SquadPage> createState() => _SquadPageState();
}

class _SquadPageState extends State<SquadPage> {
  String? selectedRole;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      /// ===== END DRAWER (KANAN) =====
      endDrawer: const RightDrawer(),

      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            children: [
              const SizedBox(height: 16),

              /// ===== HEADER + DRAWER BUTTON =====
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const SizedBox(width: 40), // spacer kiri

                  Column(
                    children: const [
                      Text(
                        'SQUAD GARUDA',
                        style: TextStyle(
                          fontSize: 30,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 1.2,
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        'Skuad resmi tim nasional Indonesia',
                        style: TextStyle(
                          color: Colors.grey,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),

                  /// === OPEN END DRAWER ===
                  Builder(
                    builder: (context) {
                      return IconButton(
                        icon: const Icon(Icons.menu),
                        onPressed: () {
                          Scaffold.of(context).openEndDrawer();
                        },
                      );
                    },
                  ),
                ],
              ),

              const SizedBox(height: 20),

              /// ===== FILTER BUTTONS =====
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _filterBtn('GOALKEEPER'),
                  _filterBtn('DEFENDER'),
                  _filterBtn('MIDFIELDER'),
                  _filterBtn('ATTACKER'),
                ],
              ),

              const SizedBox(height: 20),

              /// ===== PLAYER LIST =====
              Expanded(
                child: FutureBuilder<List<Player>>(
                  future: ApiService.fetchPlayers(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState ==
                        ConnectionState.waiting) {
                      return const Center(
                        child: CircularProgressIndicator(),
                      );
                    }

                    if (snapshot.hasError) {
                      return Center(
                        child: Text(
                          snapshot.error.toString(),
                          style:
                              const TextStyle(color: Colors.red),
                        ),
                      );
                    }

                    if (!snapshot.hasData ||
                        snapshot.data!.isEmpty) {
                      return const Center(
                        child: Text("DATA KOSONG"),
                      );
                    }

                    List<Player> players = snapshot.data!;
                    if (selectedRole != null) {
                      players = players
                          .where(
                              (p) => p.roleTag == selectedRole)
                          .toList();
                    }

                    return ListView(
                      children: players
                          .map(
                            (p) => Center(
                              child: PlayerCard(player: p),
                            ),
                          )
                          .toList(),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// ===== FILTER BUTTON =====
  Widget _filterBtn(String role) {
    final bool active = selectedRole == role;

    return GestureDetector(
      onTap: () {
        setState(() {
          if (active) {
            selectedRole = null; // unfilter
          } else {
            selectedRole = role;
          }
        });
      },
      child: Column(
        children: [
          Text(
            role,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: active ? Colors.black : Colors.grey,
            ),
          ),
          const SizedBox(height: 4),
          if (active)
            Container(
              width: 20,
              height: 3,
              decoration: BoxDecoration(
                color: Colors.red,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
        ],
      ),
    );
  }
}
