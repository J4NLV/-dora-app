import 'package:cloud_firestore/cloud_firestore.dart';

/// Data model for practice history
/// Tracks individual practice sessions
class PracticeHistoryModel {
  final String id;
  final String userId;
  final DateTime date;
  final String practiceType;
  final int duration; // in seconds
  final int coinsEarned;
  final bool completed;

  const PracticeHistoryModel({
    required this.id,
    required this.userId,
    required this.date,
    required this.practiceType,
    required this.duration,
    required this.coinsEarned,
    required this.completed,
  });

  /// Convert to Firestore document
  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'date': Timestamp.fromDate(date),
      'practiceType': practiceType,
      'duration': duration,
      'coinsEarned': coinsEarned,
      'completed': completed,
    };
  }

  /// Create from Firestore document
  factory PracticeHistoryModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return PracticeHistoryModel(
      id: doc.id,
      userId: data['userId'] as String,
      date: (data['date'] as Timestamp).toDate(),
      practiceType: data['practiceType'] as String,
      duration: data['duration'] as int,
      coinsEarned: data['coinsEarned'] as int,
      completed: data['completed'] as bool? ?? false,
    );
  }

  /// Create from Map with ID
  factory PracticeHistoryModel.fromMap(Map<String, dynamic> map, String id) {
    return PracticeHistoryModel(
      id: id,
      userId: map['userId'] as String,
      date: (map['date'] as Timestamp).toDate(),
      practiceType: map['practiceType'] as String,
      duration: map['duration'] as int,
      coinsEarned: map['coinsEarned'] as int,
      completed: map['completed'] as bool? ?? false,
    );
  }

  @override
  String toString() {
    return 'PracticeHistoryModel(id: $id, practiceType: $practiceType, date: $date, completed: $completed)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is PracticeHistoryModel &&
        other.id == id &&
        other.userId == userId &&
        other.practiceType == practiceType;
  }

  @override
  int get hashCode {
    return id.hashCode ^ userId.hashCode ^ practiceType.hashCode;
  }
}
