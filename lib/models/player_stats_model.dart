import 'package:cloud_firestore/cloud_firestore.dart';

/// Data model for player statistics
class PlayerStatsModel {
  final String userId;
  final int streakDays;
  final int doracoins;
  final List<String> inventory;
  final int currentPracticeLevel;
  // Campos de personalización
  final String? equippedHair;
  final String? equippedGlasses;
  final String? equippedHat;
  
  final DateTime lastUpdated;
  final DateTime createdAt;

  const PlayerStatsModel({
    required this.userId,
    required this.streakDays,
    required this.doracoins,
    required this.inventory,
    required this.currentPracticeLevel,
    this.equippedHair,
    this.equippedGlasses,
    this.equippedHat,
    required this.lastUpdated,
    required this.createdAt,
  });

  /// Create default stats for a new user
  factory PlayerStatsModel.initial(String userId) {
    final now = DateTime.now();
    return PlayerStatsModel(
      userId: userId,
      streakDays: 0,
      doracoins: 0,
      inventory: const [],
      currentPracticeLevel: 1,
      lastUpdated: now,
      createdAt: now,
    );
  }

  /// Convert to Firestore document
  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'streakDays': streakDays,
      'doracoins': doracoins,
      'inventory': inventory,
      'currentPracticeLevel': currentPracticeLevel,
      'equippedHair': equippedHair,
      'equippedGlasses': equippedGlasses,
      'equippedHat': equippedHat,
      'lastUpdated': Timestamp.fromDate(lastUpdated),
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  /// Create from Firestore document
  factory PlayerStatsModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return PlayerStatsModel.fromMap(data, doc.id);
  }

  /// Create from Map
  factory PlayerStatsModel.fromMap(Map<String, dynamic> map, String userId) {
    return PlayerStatsModel(
      userId: userId,
      streakDays: map['streakDays'] as int? ?? 0,
      doracoins: map['doracoins'] as int? ?? 0,
      inventory: List<String>.from(map['inventory'] as List? ?? []),
      currentPracticeLevel: map['currentPracticeLevel'] as int? ?? 0,
      equippedHair: map['equippedHair'] as String?,
      equippedGlasses: map['equippedGlasses'] as String?,
      equippedHat: map['equippedHat'] as String?,
      lastUpdated: (map['lastUpdated'] as Timestamp?)?.toDate() ?? DateTime.now(),
      createdAt: (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }
}
