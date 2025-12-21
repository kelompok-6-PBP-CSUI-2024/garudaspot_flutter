// lib/schedule/screens/match_detail.dart

import 'package:flutter/material.dart';
import 'model/match.dart';

class MatchDetailPage extends StatelessWidget {
  final Match match;

  const MatchDetailPage({super.key, required this.match});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, // <--- BACKGROUND HALAMAN PUTIH
      appBar: AppBar(
        title: Text(
          "${match.homeTeam} vs ${match.awayTeam}",
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white, // <--- APPBAR PUTIH
        foregroundColor: Colors.black, // <--- TEXT/ICON HITAM
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // --- Bagian Header Score ---
            Container(
              color: Colors.grey[100], // Menggunakan grey yg lebih soft agar menyatu dengan putih
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  Text(match.category, style: const TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Home
                      Expanded(
                        child: Column(
                          children: [
                            Text(
                              match.homeTeam,
                              textAlign: TextAlign.center,
                              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      ),
                      // Score
                      Column(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            decoration: BoxDecoration(
                              color: Colors.red[900],
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              "${match.homeScore ?? 0} - ${match.awayScore ?? 0}",
                              style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ],
                      ),
                      // Away
                      Expanded(
                        child: Column(
                          children: [
                            Text(
                              match.awayTeam,
                              textAlign: TextAlign.center,
                              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.location_on, size: 16, color: Colors.grey),
                      const SizedBox(width: 4),
                      Text(match.location, style: const TextStyle(color: Colors.grey)),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.calendar_today, size: 16, color: Colors.grey),
                      const SizedBox(width: 4),
                      Text(
                        match.matchDate.toLocal().toString().split(' ')[0], 
                        style: const TextStyle(color: Colors.grey)
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),
            const Text("Match Stats", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),

            // --- Bagian Statistik ---
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Column(
                children: [
                  _buildStatRow("Shots", match.shotsHome, match.shotsAway),
                  _buildStatRow("Shots on Target", match.shotsOnTargetHome, match.shotsOnTargetAway),
                  _buildStatRow("Possession (%)", match.possessionHome, match.possessionAway),
                  _buildStatRow("Passes", match.passesHome, match.passesAway),
                  _buildStatRow("Pass Accuracy (%)", match.passAccuracyHome, match.passAccuracyAway),
                  _buildStatRow("Fouls", match.foulsHome, match.foulsAway),
                  _buildStatRow("Yellow Cards", match.yellowCardsHome, match.yellowCardsAway, isCard: true, color: Colors.yellow[700]),
                  _buildStatRow("Red Cards", match.redCardsHome, match.redCardsAway, isCard: true, color: Colors.red),
                  _buildStatRow("Corners", match.cornersHome, match.cornersAway),
                  _buildStatRow("Offsides", match.offsidesHome, match.offsidesAway),
                ],
              ),
            ),
            const SizedBox(height: 30),
            
            // --- Lineup & Review (Optional) ---
            if (match.review != null && match.review!.isNotEmpty)
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text("Match Review", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    Text(match.review!),
                  ],
                ),
              )
          ],
        ),
      ),
    );
  }

  Widget _buildStatRow(String label, int? homeVal, int? awayVal, {bool isCard = false, Color? color}) {
    int h = homeVal ?? 0;
    int a = awayVal ?? 0;
    int total = h + a;
    
    // Mencegah pembagian dengan nol
    double homePct = total == 0 ? 0.5 : h / total;
    
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Angka Home
              SizedBox(
                width: 30, 
                child: Text("$h", textAlign: TextAlign.center, style: const TextStyle(fontWeight: FontWeight.bold))
              ),
              
              // Label
              Expanded(
                child: Text(
                  label, 
                  textAlign: TextAlign.center, 
                  style: const TextStyle(color: Colors.grey, fontSize: 12)
                )
              ),
              
              // Angka Away
              SizedBox(
                width: 30, 
                child: Text("$a", textAlign: TextAlign.center, style: const TextStyle(fontWeight: FontWeight.bold))
              ),
            ],
          ),
          const SizedBox(height: 6),
          // Bar Visualisasi
          if (!isCard) 
            Row(
              children: [
                Expanded(
                  flex: (homePct * 100).toInt(),
                  child: Container(
                    height: 8, 
                    decoration: BoxDecoration(
                      color: Colors.red[900],
                      borderRadius: const BorderRadius.only(topLeft: Radius.circular(4), bottomLeft: Radius.circular(4)),
                    ),
                  ),
                ),
                const SizedBox(width: 2), // Sedikit gap di tengah
                Expanded(
                  flex: ((1 - homePct) * 100).toInt(),
                  child: Container(
                    height: 8, 
                    decoration: BoxDecoration(
                      color: Colors.grey[300], // Warna abu lebih terang agar kontras dengan putih
                      borderRadius: const BorderRadius.only(topRight: Radius.circular(4), bottomRight: Radius.circular(4)),
                    ),
                  ),
                ),
              ],
            )
          else
            // Khusus kartu
             Row(
               mainAxisAlignment: MainAxisAlignment.center,
               children: [
                 Icon(Icons.style, color: color, size: 16),
               ],
             ) 
        ],
      ),
    );
  }
}