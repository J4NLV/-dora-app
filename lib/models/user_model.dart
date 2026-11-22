import 'package:cloud_firestore/cloud_firestore.dart';

/// Data model for user profile
/// Handles serialization to/from Firestore
class UserModel {
  final String userId;
  final String username;
  final String email;
  final String? photoUrl;
  final DateTime createdAt;
  final bool isGuest;
  final DateTime lastActive;
  final bool isProfileComplete;

  const UserModel({
    required this.userId,
    required this.username,
    required this.email,
    this.photoUrl,
    required this.createdAt,
    required this.isGuest,
    required this.lastActive,
    this.isProfileComplete = true,
  });

  /// Create default user for a new account
  factory UserModel.initial({
    required String userId,
    required String email,
    required String username,
    bool isGuest = false,
    bool isProfileComplete = true,
  }) {
    final now = DateTime.now();
    return UserModel(
      userId: userId,
      username: username,
      email: email,
      photoUrl: null,
      createdAt: now,
      isGuest: isGuest,
      lastActive: now,
      isProfileComplete: isProfileComplete,
    );
  }

  /// Create guest user
  factory UserModel.guest(String userId) {
    final now = DateTime.now();
    return UserModel(
      userId: userId,
      username: 'Invitado_${userId.substring(0, 8)}',
      email: '',
      photoUrl: null,
      createdAt: now,
      isGuest: true,
      lastActive: now,
      isProfileComplete: true, // Guests don't need setup
    );
  }

  /// Convert to Firestore document
  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'username': username,
      'email': email,
      'photoUrl': photoUrl,
      'createdAt': Timestamp.fromDate(createdAt),
      'isGuest': isGuest,
      'lastActive': Timestamp.fromDate(lastActive),
      'isProfileComplete': isProfileComplete,
    };
  }

  /// Create from Firestore document
  factory UserModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return UserModel.fromMap(data, doc.id);
  }

  /// Create from Map
  factory UserModel.fromMap(Map<String, dynamic> map, String userId) {
    return UserModel(
      userId: userId,
      username: map['username'] as String? ?? '',
      email: map['email'] as String? ?? '',
      photoUrl: map['photoUrl'] as String?,
      createdAt: (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      isGuest: map['isGuest'] as bool? ?? false,
      lastActive: (map['lastActive'] as Timestamp?)?.toDate() ?? DateTime.now(),
      isProfileComplete: map['isProfileComplete'] as bool? ?? true, // Default to true for existing users
    );
  }

  /// Create a copy with updated fields
  UserModel copyWith({
    String? userId,
    String? username,
    String? email,
    String? photoUrl,
    DateTime? createdAt,
    bool? isGuest,
    DateTime? lastActive,
    bool? isProfileComplete,
  }) {
    return UserModel(
      userId: userId ?? this.userId,
      username: username ?? this.username,
      email: email ?? this.email,
      photoUrl: photoUrl ?? this.photoUrl,
      createdAt: createdAt ?? this.createdAt,
      isGuest: isGuest ?? this.isGuest,
      lastActive: lastActive ?? this.lastActive,
      isProfileComplete: isProfileComplete ?? this.isProfileComplete,
    );
  }

  @override
  String toString() {
    return 'UserModel(userId: $userId, username: $username, email: $email, isGuest: $isGuest, isProfileComplete: $isProfileComplete)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is UserModel &&
        other.userId == userId &&
        other.username == username &&
        other.email == email &&
        other.isProfileComplete == isProfileComplete;
  }

  @override
  int get hashCode {
    return userId.hashCode ^ username.hashCode ^ email.hashCode ^ isProfileComplete.hashCode;
  }
}
