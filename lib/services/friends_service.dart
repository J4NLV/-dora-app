import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import '../models/user_model.dart';
import '../models/friend_request_model.dart';
import 'firebase_service.dart';

/// Service to manage friend relationships and requests
class FriendsService {
  // Singleton pattern
  FriendsService._();
  static final FriendsService instance = FriendsService._();

  final FirebaseService _firebaseService = FirebaseService.instance;

  /// Search users by username
  /// Returns list of users matching the search query
  Future<List<UserModel>> searchUsers(String query) async {
    try {
      if (query.isEmpty) return [];

      final currentUserId = _firebaseService.currentUserId;
      if (currentUserId == null) {
        throw Exception('User not authenticated');
      }

      // Search for users with username starting with query
      final querySnapshot = await _firebaseService.usersCollection
          .where('username', isGreaterThanOrEqualTo: query)
          .where('username', isLessThan: query + 'z')
          .limit(20)
          .get();

      final users = querySnapshot.docs
          .map((doc) => UserModel.fromFirestore(doc))
          .where((user) => user.userId != currentUserId) // Exclude current user
          .toList();

      return users;
    } catch (e) {
      if (kDebugMode) {
        print('Error searching users: $e');
      }
      return [];
    }
  }

  /// Get user by ID
  Future<UserModel?> getUserById(String userId) async {
    try {
      final doc = await _firebaseService.usersCollection.doc(userId).get();
      if (doc.exists) {
        return UserModel.fromFirestore(doc);
      }
      return null;
    } catch (e) {
      if (kDebugMode) {
        print('Error getting user: $e');
      }
      return null;
    }
  }

  /// Send friend request
  Future<void> sendFriendRequest(String toUserId) async {
    try {
      final currentUserId = _firebaseService.currentUserId;
      if (currentUserId == null) {
        throw Exception('User not authenticated');
      }

      // Check if request already exists
      final existingRequest = await _firebaseService.friendRequestsCollection
          .where('fromUserId', isEqualTo: currentUserId)
          .where('toUserId', isEqualTo: toUserId)
          .where('status', isEqualTo: 'pending')
          .limit(1)
          .get();

      if (existingRequest.docs.isNotEmpty) {
        throw Exception('Ya enviaste una solicitud a este usuario');
      }

      // Check if already friends
      final areFriends = await checkIfFriends(toUserId);
      if (areFriends) {
        throw Exception('Ya son amigos');
      }

      // Get current user info
      final currentUser = await _firebaseService.usersCollection.doc(currentUserId).get();
      final currentUserData = currentUser.data() as Map<String, dynamic>?;

      // Create friend request
      final request = FriendRequestModel(
        requestId: '',
        fromUserId: currentUserId,
        fromUsername: currentUserData?['username'] ?? '',
        fromPhotoUrl: currentUserData?['photoUrl'],
        toUserId: toUserId,
        status: FriendRequestStatus.pending,
        createdAt: DateTime.now(),
      );

      await _firebaseService.friendRequestsCollection.add(request.toFirestore());

      if (kDebugMode) {
        print('Friend request sent to: $toUserId');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error sending friend request: $e');
      }
      rethrow;
    }
  }

  /// Accept friend request
  Future<void> acceptFriendRequest(String requestId) async {
    try {
      final currentUserId = _firebaseService.currentUserId;
      if (currentUserId == null) {
        throw Exception('User not authenticated');
      }

      // Get request
      final requestDoc = await _firebaseService.friendRequestsCollection.doc(requestId).get();
      if (!requestDoc.exists) {
        throw Exception('Solicitud no encontrada');
      }

      final request = FriendRequestModel.fromFirestore(requestDoc);

      // Update request status
      await _firebaseService.friendRequestsCollection.doc(requestId).update({
        'status': 'accepted',
      });

      // Create friendship (bidirectional)
      final batch = FirebaseFirestore.instance.batch();

      // Add friend for current user
      final friendDoc1 = _firebaseService.friendsCollection.doc();
      batch.set(friendDoc1, {
        'userId': currentUserId,
        'friendId': request.fromUserId,
        'createdAt': FieldValue.serverTimestamp(),
      });

      // Add friend for the other user
      final friendDoc2 = _firebaseService.friendsCollection.doc();
      batch.set(friendDoc2, {
        'userId': request.fromUserId,
        'friendId': currentUserId,
        'createdAt': FieldValue.serverTimestamp(),
      });

      await batch.commit();

      if (kDebugMode) {
        print('Friend request accepted: $requestId');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error accepting friend request: $e');
      }
      rethrow;
    }
  }

  /// Reject friend request
  Future<void> rejectFriendRequest(String requestId) async {
    try {
      await _firebaseService.friendRequestsCollection.doc(requestId).update({
        'status': 'rejected',
      });

      if (kDebugMode) {
        print('Friend request rejected: $requestId');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error rejecting friend request: $e');
      }
      rethrow;
    }
  }

  /// Get list of friends for current user
  Future<List<UserModel>> getFriends() async {
    try {
      final currentUserId = _firebaseService.currentUserId;
      if (currentUserId == null) {
        throw Exception('User not authenticated');
      }

      // Get friend IDs
      final friendsSnapshot = await _firebaseService.friendsCollection
          .where('userId', isEqualTo: currentUserId)
          .get();

      final friendIds = friendsSnapshot.docs
          .map((doc) => (doc.data() as Map<String, dynamic>)['friendId'] as String)
          .toList();

      if (friendIds.isEmpty) return [];

      // Get friend user data
      final friends = <UserModel>[];
      for (final friendId in friendIds) {
        final user = await getUserById(friendId);
        if (user != null) {
          friends.add(user);
        }
      }

      return friends;
    } catch (e) {
      if (kDebugMode) {
        print('Error getting friends: $e');
      }
      return [];
    }
  }

  /// Get pending friend requests (received)
  Stream<List<FriendRequestModel>> getPendingRequests() {
    final currentUserId = _firebaseService.currentUserId;
    if (currentUserId == null) {
      return Stream.value([]);
    }

    return _firebaseService.friendRequestsCollection
        .where('toUserId', isEqualTo: currentUserId)
        .where('status', isEqualTo: 'pending')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => FriendRequestModel.fromFirestore(doc))
            .toList());
  }

  /// Get sent friend requests
  Future<List<FriendRequestModel>> getSentRequests() async {
    try {
      final currentUserId = _firebaseService.currentUserId;
      if (currentUserId == null) {
        throw Exception('User not authenticated');
      }

      final snapshot = await _firebaseService.friendRequestsCollection
          .where('fromUserId', isEqualTo: currentUserId)
          .where('status', isEqualTo: 'pending')
          .orderBy('createdAt', descending: true)
          .get();

      return snapshot.docs
          .map((doc) => FriendRequestModel.fromFirestore(doc))
          .toList();
    } catch (e) {
      if (kDebugMode) {
        print('Error getting sent requests: $e');
      }
      return [];
    }
  }

  /// Check if users are friends
  Future<bool> checkIfFriends(String otherUserId) async {
    try {
      final currentUserId = _firebaseService.currentUserId;
      if (currentUserId == null) return false;

      final snapshot = await _firebaseService.friendsCollection
          .where('userId', isEqualTo: currentUserId)
          .where('friendId', isEqualTo: otherUserId)
          .limit(1)
          .get();

      return snapshot.docs.isNotEmpty;
    } catch (e) {
      if (kDebugMode) {
        print('Error checking friendship: $e');
      }
      return false;
    }
  }

  /// Check if friend request exists
  Future<FriendRequestModel?> getPendingRequestTo(String otherUserId) async {
    try {
      final currentUserId = _firebaseService.currentUserId;
      if (currentUserId == null) return null;

      final snapshot = await _firebaseService.friendRequestsCollection
          .where('fromUserId', isEqualTo: currentUserId)
          .where('toUserId', isEqualTo: otherUserId)
          .where('status', isEqualTo: 'pending')
          .limit(1)
          .get();

      if (snapshot.docs.isNotEmpty) {
        return FriendRequestModel.fromFirestore(snapshot.docs.first);
      }
      return null;
    } catch (e) {
      if (kDebugMode) {
        print('Error checking pending request: $e');
      }
      return null;
    }
  }

  /// Remove friend
  Future<void> removeFriend(String friendId) async {
    try {
      final currentUserId = _firebaseService.currentUserId;
      if (currentUserId == null) {
        throw Exception('User not authenticated');
      }

      // Remove friendship (bidirectional)
      final batch = FirebaseFirestore.instance.batch();

      // Remove friend for current user
      final friendship1 = await _firebaseService.friendsCollection
          .where('userId', isEqualTo: currentUserId)
          .where('friendId', isEqualTo: friendId)
          .limit(1)
          .get();

      if (friendship1.docs.isNotEmpty) {
        batch.delete(friendship1.docs.first.reference);
      }

      // Remove friend for the other user
      final friendship2 = await _firebaseService.friendsCollection
          .where('userId', isEqualTo: friendId)
          .where('friendId', isEqualTo: currentUserId)
          .limit(1)
          .get();

      if (friendship2.docs.isNotEmpty) {
        batch.delete(friendship2.docs.first.reference);
      }

      await batch.commit();

      if (kDebugMode) {
        print('Friend removed: $friendId');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error removing friend: $e');
      }
      rethrow;
    }
  }
}
