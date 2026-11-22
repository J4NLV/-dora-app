import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import '../models/user_model.dart';
import '../models/player_stats_model.dart';
import 'firebase_service.dart';

/// Service to manage user profile and data
class UserService {
  // Singleton pattern
  UserService._();
  static final UserService instance = UserService._();

  final FirebaseService _firebaseService = FirebaseService.instance;

  /// Create user profile
  Future<void> createUserProfile(UserModel user) async {
    try {
      await _firebaseService.usersCollection
          .doc(user.userId)
          .set(user.toFirestore());

      if (kDebugMode) {
        print('User profile created: ${user.userId}');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error creating user profile: $e');
      }
      rethrow;
    }
  }

  /// Get user profile
  Future<UserModel?> getUserProfile(String userId) async {
    try {
      final doc = await _firebaseService.usersCollection.doc(userId).get();
      if (doc.exists) {
        return UserModel.fromFirestore(doc);
      }
      return null;
    } catch (e) {
      if (kDebugMode) {
        print('Error getting user profile: $e');
      }
      return null;
    }
  }

  /// Get current user profile
  Future<UserModel?> getCurrentUserProfile() async {
    final userId = _firebaseService.currentUserId;
    if (userId == null) return null;
    return getUserProfile(userId);
  }

  /// Update username
  Future<void> updateUsername(String newUsername) async {
    try {
      await _firebaseService.updateUserProfile(username: newUsername);

      if (kDebugMode) {
        print('Username updated to: $newUsername');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error updating username: $e');
      }
      rethrow;
    }
  }

  /// Update profile photo URL
  Future<void> updateProfilePhoto(String photoUrl) async {
    try {
      await _firebaseService.updateUserProfile(photoUrl: photoUrl);

      if (kDebugMode) {
        print('Profile photo updated');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error updating profile photo: $e');
      }
      rethrow;
    }
  }

  /// Reset all user data (for new account creation)
  /// This will create initial player stats
  Future<void> resetUserData(String userId) async {
    try {
      // For new users, just create initial player stats
      // No need to query for friends/requests that don't exist yet
      final initialStats = PlayerStatsModel.initial(userId);
      await _firebaseService.playersCollection.doc(userId).set(
        initialStats.toFirestore(),
      );

      if (kDebugMode) {
        print('User data initialized for: $userId');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error initializing user data: $e');
      }
      rethrow;
    }
  }

  /// Update last active timestamp
  Future<void> updateLastActive() async {
    try {
      final userId = _firebaseService.currentUserId;
      if (userId == null) return;

      await _firebaseService.usersCollection.doc(userId).update({
        'lastActive': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      if (kDebugMode) {
        print('Error updating last active: $e');
      }
      // Don't rethrow - this is not critical
    }
  }
}
