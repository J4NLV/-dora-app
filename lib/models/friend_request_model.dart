import 'package:cloud_firestore/cloud_firestore.dart';

/// Data model for friend requests
/// Handles serialization to/from Firestore
class FriendRequestModel {
  final String requestId;
  final String fromUserId;
  final String fromUsername;
  final String? fromPhotoUrl;
  final String toUserId;
  final FriendRequestStatus status;
  final DateTime createdAt;

  const FriendRequestModel({
    required this.requestId,
    required this.fromUserId,
    required this.fromUsername,
    this.fromPhotoUrl,
    required this.toUserId,
    required this.status,
    required this.createdAt,
  });

  /// Convert to Firestore document
  Map<String, dynamic> toFirestore() {
    return {
      'fromUserId': fromUserId,
      'fromUsername': fromUsername,
      'fromPhotoUrl': fromPhotoUrl,
      'toUserId': toUserId,
      'status': status.name,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  /// Create from Firestore document
  factory FriendRequestModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return FriendRequestModel.fromMap(data, doc.id);
  }

  /// Create from Map
  factory FriendRequestModel.fromMap(Map<String, dynamic> map, String requestId) {
    return FriendRequestModel(
      requestId: requestId,
      fromUserId: map['fromUserId'] as String,
      fromUsername: map['fromUsername'] as String? ?? '',
      fromPhotoUrl: map['fromPhotoUrl'] as String?,
      toUserId: map['toUserId'] as String,
      status: FriendRequestStatus.fromString(map['status'] as String? ?? 'pending'),
      createdAt: (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  /// Create a copy with updated fields
  FriendRequestModel copyWith({
    String? requestId,
    String? fromUserId,
    String? fromUsername,
    String? fromPhotoUrl,
    String? toUserId,
    FriendRequestStatus? status,
    DateTime? createdAt,
  }) {
    return FriendRequestModel(
      requestId: requestId ?? this.requestId,
      fromUserId: fromUserId ?? this.fromUserId,
      fromUsername: fromUsername ?? this.fromUsername,
      fromPhotoUrl: fromPhotoUrl ?? this.fromPhotoUrl,
      toUserId: toUserId ?? this.toUserId,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  String toString() {
    return 'FriendRequestModel(requestId: $requestId, from: $fromUsername, to: $toUserId, status: ${status.name})';
  }
}

/// Status of a friend request
enum FriendRequestStatus {
  pending,
  accepted,
  rejected;

  static FriendRequestStatus fromString(String value) {
    switch (value.toLowerCase()) {
      case 'pending':
        return FriendRequestStatus.pending;
      case 'accepted':
        return FriendRequestStatus.accepted;
      case 'rejected':
        return FriendRequestStatus.rejected;
      default:
        return FriendRequestStatus.pending;
    }
  }
}
