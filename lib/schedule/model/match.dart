// lib/schedule/models/match.dart

import 'dart:convert';

Match matchFromJson(String str) => Match.fromJson(json.decode(str));

String matchToJson(Match data) => json.encode(data.toJson());

class Match {
    String id;
    String homeTeam;
    String awayTeam;
    DateTime matchDate;
    String location;
    String category;
    
    // UBAH KE int? (Boleh Null) agar tidak error jika data kosong
    int? homeScore;
    int? awayScore;
    
    // String? untuk data yang mungkin kosong
    String? homeCode;
    String? awayCode;
    String? categoryImageUrl;
    String? lineup; // Ubah dynamic jadi String? jika isinya teks panjang
    String? review; // Ubah dynamic jadi String? jika isinya teks panjang

    // SEMUA STATS DIUBAH KE int?
    int? shotsHome;
    int? shotsAway;
    int? shotsOnTargetHome;
    int? shotsOnTargetAway;
    int? possessionHome;
    int? possessionAway;
    int? passesHome;
    int? passesAway;
    int? passAccuracyHome;
    int? passAccuracyAway;
    int? foulsHome;
    int? foulsAway;
    int? yellowCardsHome;
    int? yellowCardsAway;
    int? redCardsHome;
    int? redCardsAway;
    int? offsidesHome;
    int? offsidesAway;
    int? cornersHome;
    int? cornersAway;

    Match({
        required this.id,
        required this.homeTeam,
        required this.awayTeam,
        required this.matchDate,
        required this.location,
        required this.category,
        this.homeScore,       // Hapus 'required'
        this.awayScore,       // Hapus 'required'
        this.homeCode,
        this.awayCode,
        this.categoryImageUrl,
        this.lineup,
        this.review,
        this.shotsHome,
        this.shotsAway,
        this.shotsOnTargetHome,
        this.shotsOnTargetAway,
        this.possessionHome,
        this.possessionAway,
        this.passesHome,
        this.passesAway,
        this.passAccuracyHome,
        this.passAccuracyAway,
        this.foulsHome,
        this.foulsAway,
        this.yellowCardsHome,
        this.yellowCardsAway,
        this.redCardsHome,
        this.redCardsAway,
        this.offsidesHome,
        this.offsidesAway,
        this.cornersHome,
        this.cornersAway,
    });

    factory Match.fromJson(Map<String, dynamic> json) => Match(
        id: json["id"],
        homeTeam: json["home_team"],
        awayTeam: json["away_team"],
        matchDate: DateTime.parse(json["match_date"]),
        location: json["location"],
        category: json["category"],
        
        // JSON score bisa null, jadi langsung assign saja
        homeScore: json["home_score"],
        awayScore: json["away_score"],
        
        homeCode: json["home_code"],
        awayCode: json["away_code"],
        categoryImageUrl: json["category_image_url"],
        lineup: json["lineup"],
        review: json["review"],
        
        // Stats juga bisa null
        shotsHome: json["shots_home"],
        shotsAway: json["shots_away"],
        shotsOnTargetHome: json["shots_on_target_home"],
        shotsOnTargetAway: json["shots_on_target_away"],
        possessionHome: json["possession_home"],
        possessionAway: json["possession_away"],
        passesHome: json["passes_home"],
        passesAway: json["passes_away"],
        passAccuracyHome: json["pass_accuracy_home"],
        passAccuracyAway: json["pass_accuracy_away"],
        foulsHome: json["fouls_home"],
        foulsAway: json["fouls_away"],
        yellowCardsHome: json["yellow_cards_home"],
        yellowCardsAway: json["yellow_cards_away"],
        redCardsHome: json["red_cards_home"],
        redCardsAway: json["red_cards_away"],
        offsidesHome: json["offsides_home"],
        offsidesAway: json["offsides_away"],
        cornersHome: json["corners_home"],
        cornersAway: json["corners_away"],
    );

    Map<String, dynamic> toJson() => {
        "id": id,
        "home_team": homeTeam,
        "away_team": awayTeam,
        "match_date": matchDate.toIso8601String(),
        "location": location,
        "category": category,
        "home_score": homeScore,
        "away_score": awayScore,
        "home_code": homeCode,
        "away_code": awayCode,
        "category_image_url": categoryImageUrl,
        "lineup": lineup,
        "review": review,
        "shots_home": shotsHome,
        "shots_away": shotsAway,
        "shots_on_target_home": shotsOnTargetHome,
        "shots_on_target_away": shotsOnTargetAway,
        "possession_home": possessionHome,
        "possession_away": possessionAway,
        "passes_home": passesHome,
        "passes_away": passesAway,
        "pass_accuracy_home": passAccuracyHome,
        "pass_accuracy_away": passAccuracyAway,
        "fouls_home": foulsHome,
        "fouls_away": foulsAway,
        "yellow_cards_home": yellowCardsHome,
        "yellow_cards_away": yellowCardsAway,
        "red_cards_home": redCardsHome,
        "red_cards_away": redCardsAway,
        "offsides_home": offsidesHome,
        "offsides_away": offsidesAway,
        "corners_home": cornersHome,
        "corners_away": cornersAway,
    };
}