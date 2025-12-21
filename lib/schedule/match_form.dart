// lib/schedule/screens/match_form.dart

import 'package:flutter/material.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:provider/provider.dart';
import 'dart:convert';
import 'model/match.dart'; 

class MatchFormPage extends StatefulWidget {
  // Parameter opsional untuk mode Edit
  final Match? match;

  const MatchFormPage({super.key, this.match});

  @override
  State<MatchFormPage> createState() => _MatchFormPageState();
}

class _MatchFormPageState extends State<MatchFormPage> {
  final _formKey = GlobalKey<FormState>();

  // --- Controllers: Basic Info ---
  final _homeTeamController = TextEditingController();
  final _awayTeamController = TextEditingController();
  final _locationController = TextEditingController();
  final _dateController = TextEditingController();

  // --- Controllers: Score ---
  final _homeScoreController = TextEditingController();
  final _awayScoreController = TextEditingController();

  // --- Controllers: Stats ---
  final _shotsHome = TextEditingController();
  final _shotsAway = TextEditingController();
  final _possessionHome = TextEditingController();
  final _possessionAway = TextEditingController();
  final _passesHome = TextEditingController();
  final _passesAway = TextEditingController();
  final _foulsHome = TextEditingController();
  final _foulsAway = TextEditingController();
  final _yellowHome = TextEditingController();
  final _yellowAway = TextEditingController();
  final _redHome = TextEditingController();
  final _redAway = TextEditingController();
  
  // === 1. TAMBAHAN CONTROLLER BARU ===
  final _cornersHome = TextEditingController();
  final _cornersAway = TextEditingController();
  final _offsidesHome = TextEditingController();
  final _offsidesAway = TextEditingController();

  // State Variables
  String _category = 'Friendly Match';
  DateTime? _selectedDate;

  final List<String> _categories = [
    'Friendly Match',
    'FIFA Matchday A',
    'FIFA Matchday B',
    'AFF Championship',
    'AFC Qualifiers',
    'AFC Cup',
    'World Cup Qualifiers',
    'World Cup',
    'Other'
  ];

  @override
  void initState() {
    super.initState();
    // LOGIC EDIT: Jika widget.match ada, isi controller dengan data lama
    if (widget.match != null) {
      final m = widget.match!;
      
      _homeTeamController.text = m.homeTeam;
      _awayTeamController.text = m.awayTeam;
      _locationController.text = m.location;
      
      // Set Date
      _selectedDate = m.matchDate;
      _dateController.text = "${m.matchDate.year}-${m.matchDate.month.toString().padLeft(2,'0')}-${m.matchDate.day.toString().padLeft(2,'0')}";

      // Set Category
      if (_categories.contains(m.category)) {
        _category = m.category;
      } else {
        _category = _categories[0];
      }

      // Helper untuk convert int? ke String
      String str(int? val) => val?.toString() ?? '';

      _homeScoreController.text = str(m.homeScore);
      _awayScoreController.text = str(m.awayScore);

      // Isi Controller Stats
      _shotsHome.text = str(m.shotsHome);
      _shotsAway.text = str(m.shotsAway);
      _possessionHome.text = str(m.possessionHome);
      _possessionAway.text = str(m.possessionAway);
      _passesHome.text = str(m.passesHome);
      _passesAway.text = str(m.passesAway);
      _foulsHome.text = str(m.foulsHome);
      _foulsAway.text = str(m.foulsAway);
      _yellowHome.text = str(m.yellowCardsHome);
      _yellowAway.text = str(m.yellowCardsAway);
      _redHome.text = str(m.redCardsHome);
      _redAway.text = str(m.redCardsAway);
      
      // === 2. ISI DATA EDIT ===
      _cornersHome.text = str(m.cornersHome);
      _cornersAway.text = str(m.cornersAway);
      _offsidesHome.text = str(m.offsidesHome);
      _offsidesAway.text = str(m.offsidesAway);
    }
  }

  @override
  void dispose() {
    _homeTeamController.dispose();
    _awayTeamController.dispose();
    _locationController.dispose();
    _dateController.dispose();
    _homeScoreController.dispose();
    _awayScoreController.dispose();
    
    // Dispose Stats
    _shotsHome.dispose(); _shotsAway.dispose();
    _possessionHome.dispose(); _possessionAway.dispose();
    _passesHome.dispose(); _passesAway.dispose();
    _foulsHome.dispose(); _foulsAway.dispose();
    _yellowHome.dispose(); _yellowAway.dispose();
    _redHome.dispose(); _redAway.dispose();
    
    // === 3. DISPOSE CONTROLLER BARU ===
    _cornersHome.dispose(); _cornersAway.dispose();
    _offsidesHome.dispose(); _offsidesAway.dispose();
    
    super.dispose();
  }

  Widget _buildStatRow(String label, TextEditingController homeCtrl, TextEditingController awayCtrl) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Expanded(
            child: TextFormField(
              controller: homeCtrl,
              keyboardType: TextInputType.number,
              textAlign: TextAlign.center,
              decoration: const InputDecoration(hintText: "0", isDense: true, border: OutlineInputBorder()),
            ),
          ),
          SizedBox(width: 100, child: Text(label, textAlign: TextAlign.center, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12))),
          Expanded(
            child: TextFormField(
              controller: awayCtrl,
              keyboardType: TextInputType.number,
              textAlign: TextAlign.center,
              decoration: const InputDecoration(hintText: "0", isDense: true, border: OutlineInputBorder()),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final request = context.watch<CookieRequest>();
    final isEdit = widget.match != null;
    final pageTitle = isEdit ? "Edit Match" : "Add New Match";

    return Scaffold(
      appBar: AppBar(
        title: Text(pageTitle),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ... (Bagian Basic Info sama seperti sebelumnya) ...
              const Text("Match Details", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),
              
              TextFormField(
                controller: _homeTeamController,
                decoration: const InputDecoration(labelText: "Home Team", border: OutlineInputBorder(), prefixIcon: Icon(Icons.flag)),
                validator: (v) => v!.isEmpty ? "Required" : null,
              ),
              const SizedBox(height: 12),

              TextFormField(
                controller: _awayTeamController,
                decoration: const InputDecoration(labelText: "Away Team", border: OutlineInputBorder(), prefixIcon: Icon(Icons.flag_outlined)),
                validator: (v) => v!.isEmpty ? "Required" : null,
              ),
              const SizedBox(height: 12),
              
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _homeScoreController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(labelText: "Home Score", border: OutlineInputBorder()),
                    ),
                  ),
                  const Padding(padding: EdgeInsets.symmetric(horizontal: 10), child: Text("-", style: TextStyle(fontSize: 24))),
                  Expanded(
                    child: TextFormField(
                      controller: _awayScoreController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(labelText: "Away Score", border: OutlineInputBorder()),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              TextFormField(
                controller: _locationController,
                decoration: const InputDecoration(labelText: "Location", border: OutlineInputBorder(), prefixIcon: Icon(Icons.location_on)),
                validator: (v) => v!.isEmpty ? "Required" : null,
              ),
              const SizedBox(height: 12),

              TextFormField(
                controller: _dateController,
                decoration: const InputDecoration(labelText: "Match Date", border: OutlineInputBorder(), prefixIcon: Icon(Icons.calendar_today)),
                readOnly: true,
                onTap: () async {
                  DateTime? pickedDate = await showDatePicker(
                    context: context,
                    initialDate: _selectedDate ?? DateTime.now(),
                    firstDate: DateTime(2000),
                    lastDate: DateTime(2100),
                  );
                  if (pickedDate != null) {
                    setState(() {
                      _selectedDate = pickedDate;
                      _dateController.text = "${pickedDate.year}-${pickedDate.month.toString().padLeft(2,'0')}-${pickedDate.day.toString().padLeft(2,'0')}";
                    });
                  }
                },
                validator: (v) => v!.isEmpty ? "Required" : null,
              ),
              const SizedBox(height: 12),

              DropdownButtonFormField<String>(
                value: _categories.contains(_category) ? _category : _categories[0],
                decoration: const InputDecoration(labelText: "Category", border: OutlineInputBorder(), prefixIcon: Icon(Icons.category)),
                items: _categories.map((String category) {
                  return DropdownMenuItem<String>(
                    value: category,
                    child: Text(category),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  setState(() {
                    _category = newValue!;
                  });
                },
              ),
              
              const SizedBox(height: 24),
              const Divider(thickness: 2),
              const SizedBox(height: 10),

              // ================= STATISTICS =================
              const Center(child: Text("Statistics (Optional)", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.grey))),
              const SizedBox(height: 10),
              
              const Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(child: Text("Home", textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.bold))),
                  SizedBox(width: 100, child: Text("Metric", textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.bold))),
                  Expanded(child: Text("Away", textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.bold))),
                ],
              ),
              
              _buildStatRow("Shots", _shotsHome, _shotsAway),
              _buildStatRow("Possession (%)", _possessionHome, _possessionAway),
              _buildStatRow("Passes", _passesHome, _passesAway),
              _buildStatRow("Fouls", _foulsHome, _foulsAway),
              _buildStatRow("Yellow Cards", _yellowHome, _yellowAway),
              _buildStatRow("Red Cards", _redHome, _redAway),
              
              // === 4. TAMBAHAN UI CORNERS & OFFSIDES ===
              _buildStatRow("Corners", _cornersHome, _cornersAway),
              _buildStatRow("Offsides", _offsidesHome, _offsidesAway),
              
              const SizedBox(height: 24),

              // ================= SUBMIT BUTTON =================
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red[900],
                    foregroundColor: Colors.white,
                  ),
                  onPressed: () async {
                    if (_formKey.currentState!.validate()) {
                      int? parseInt(String val) => val.isEmpty ? null : int.tryParse(val);

                      final payload = {
                        'home_team': _homeTeamController.text,
                        'away_team': _awayTeamController.text,
                        'location': _locationController.text,
                        'match_date': _dateController.text,
                        'category': _category,
                        'home_score': parseInt(_homeScoreController.text),
                        'away_score': parseInt(_awayScoreController.text),
                        
                        // Stats
                        'shots_home': parseInt(_shotsHome.text),
                        'shots_away': parseInt(_shotsAway.text),
                        'possession_home': parseInt(_possessionHome.text),
                        'possession_away': parseInt(_possessionAway.text),
                        'passes_home': parseInt(_passesHome.text),
                        'passes_away': parseInt(_passesAway.text),
                        'fouls_home': parseInt(_foulsHome.text),
                        'fouls_away': parseInt(_foulsAway.text),
                        'yellow_cards_home': parseInt(_yellowHome.text),
                        'yellow_cards_away': parseInt(_yellowAway.text),
                        'red_cards_home': parseInt(_redHome.text),
                        'red_cards_away': parseInt(_redAway.text),
                        
                        // === 5. KIRIM DATA BARU ===
                        'corners_home': parseInt(_cornersHome.text),
                        'corners_away': parseInt(_cornersAway.text),
                        'offsides_home': parseInt(_offsidesHome.text),
                        'offsides_away': parseInt(_offsidesAway.text),
                      };

                      final url = isEdit
                          ? "http://localhost:8000/schedule/api/match/edit/${widget.match!.id}/"
                          : "http://localhost:8000/schedule/api/match/add/";

                      final response = await request.postJson(
                        url,
                        jsonEncode(payload),
                      );

                      if (context.mounted) {
                        if (response['id'] != null || response['status'] == 'success') {
                          ScaffoldMessenger.of(context).showSnackBar(
                             SnackBar(content: Text(isEdit ? "Match updated!" : "Match saved!")),
                          );
                          Navigator.pop(context, true); 
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text("Gagal menyimpan data.")),
                          );
                        }
                      }
                    }
                  },
                  child: Text(
                    isEdit ? "Update Match" : "Save Match", 
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)
                  ),
                ),
              ),
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }
}