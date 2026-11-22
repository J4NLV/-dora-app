import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../models/user_model.dart';

/// Custom exception for Firebase service errors.
class FirebaseServiceException implements Exception {
  final String message;
  FirebaseServiceException(this.message);

  @override
  String toString() => message;
}

class FirebaseService {
  /// Singleton service to manage Firebase operations
  /// Handles authentication, Firestore references, and connection state
  // Singleton pattern
  FirebaseService._();
  static final FirebaseService instance = FirebaseService._();

  // Firebase instances
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Current user
  User? _currentUser;

  /// Initialize Firebase
  /// Should be called once during app startup
  Future<void> initialize() async {
    try {
      // Enable offline persistence for Firestore
      _firestore.settings = const Settings(
        persistenceEnabled: true,
        cacheSizeBytes: Settings.CACHE_SIZE_UNLIMITED,
      );

      // Check if user is already signed in
      _currentUser = _auth.currentUser;

      if (kDebugMode) {
        print('Firebase initialized successfully');
        if (_currentUser != null) {
          print('User already signed in: ${currentUserId}');
        } else {
          print('No user signed in');
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error initializing Firebase: $e');
      }
      throw FirebaseServiceException('Error al inicializar Firebase.');
    }
  }

  /// Sign in anonymously
  /// Creates a unique user ID for this device
  Future<User?> signInAnonymously() async {
    try {
      final userCredential = await _auth.signInAnonymously();
      _currentUser = userCredential.user;
      
      if (_currentUser != null) {
        // Check if user profile exists, if not create one
        final userDoc = await usersCollection.doc(_currentUser!.uid).get();
        if (!userDoc.exists) {
          // Create guest user profile
          final guestUser = UserModel.guest(_currentUser!.uid);
          await usersCollection.doc(_currentUser!.uid).set(guestUser.toFirestore());
          
          if (kDebugMode) {
            print('Created guest user profile: ${_currentUser!.uid}');
          }
        }
      }
      
      if (kDebugMode) {
        print('Signed in anonymously: ${_currentUser?.uid}');
      }
      
      return _currentUser;
    } catch (e) {
      if (kDebugMode) {
        print('Error signing in anonymously: $e');
      }
      throw FirebaseServiceException('Error al iniciar sesión de forma anónima.');
    }
  }

  /// Sign out current user
  Future<void> signOut() async {
    try {
      // Sign out from Google if signed in with Google
      try {
        await GoogleSignIn().signOut();
      } catch (e) {
        // Ignore if not signed in with Google
        if (kDebugMode) {
          print('Google sign out error (may not be signed in with Google): $e');
        }
      }
      
      // Sign out from Firebase Auth
      await _auth.signOut();
      
      // Clear current user
      _currentUser = null;
      
      if (kDebugMode) {
        print('User signed out successfully');
        print('Current user after signout: ${_auth.currentUser}');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error during sign out: $e');
      }
      rethrow;
    }
  }

  /// Sign up with email and password
  /// Creates a new user account and user profile
  Future<User?> signUpWithEmail({
    required String email,
    required String password,
    required String username,
  }) async {
    try {
      // Create user account first (so we are authenticated to check username)
      final userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      _currentUser = userCredential.user;

      if (_currentUser != null) {
        try {
          // Check if username is available
          await _checkUsernameAvailability(username);

          // Create user profile in Firestore
          final userModel = UserModel.initial(
            userId: _currentUser!.uid,
            email: email,
            username: username,
          );
          await usersCollection.doc(_currentUser!.uid).set(userModel.toFirestore());

          if (kDebugMode) {
            print('User signed up and profile created: ${_currentUser?.uid}');
          }
        } catch (e) {
          // If Firestore write fails or username taken, delete the auth user
          if (kDebugMode) {
            print('Error creating profile or username taken, deleting auth user: $e');
          }
          await _currentUser!.delete();
          _currentUser = null;
          if (e is FirebaseServiceException) {
            rethrow;
          }
          throw FirebaseServiceException('Error al crear el perfil de usuario. Inténtalo de nuevo.');
        }
      }

      return _currentUser;
    } on FirebaseAuthException catch (e) {
      throw FirebaseServiceException(e.message ?? 'Error al registrarse.');
    } catch (e) {
      if (kDebugMode) {
        print('Error signing up: $e');
      }
      rethrow;
    }
  }

  /// Sign in with email and password
  Future<User?> signInWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      final userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      _currentUser = userCredential.user;

      if (kDebugMode) {
        print('User signed in: ${_currentUser?.uid}');
      }

      return _currentUser;
    } on FirebaseAuthException catch (e) {
      throw FirebaseServiceException(e.message ?? 'Error al iniciar sesión.');
    } catch (e) {
      if (kDebugMode) {
        print('Error signing in: $e');
      }
      rethrow;
    }
  }

  /// Sign in with Google
  Future<User?> signInWithGoogle() async {
    try {
      // Trigger the Google Sign-In flow
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();

      if (googleUser == null) {
        // User canceled the sign-in
        return null;
      }

      // Obtain the auth details from the request
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

      // Create a new credential
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // Sign in to Firebase with the Google credential
      final userCredential = await _auth.signInWithCredential(credential);
      _currentUser = userCredential.user;

      if (_currentUser != null) {
        // Check if user profile exists, if not create one
        final userDoc = await usersCollection.doc(_currentUser!.uid).get();
        if (!userDoc.exists) {
          // Generate temporary username from email
          final username = _currentUser!.email?.split('@')[0] ?? 'usuario_${_currentUser!.uid.substring(0, 8)}';
          
          final userModel = UserModel.initial(
            userId: _currentUser!.uid,
            email: _currentUser!.email ?? '',
            username: username,
            isProfileComplete: false, // New Google users need to complete profile
          ).copyWith(photoUrl: _currentUser!.photoURL);
          
          await usersCollection.doc(_currentUser!.uid).set(userModel.toFirestore());
        }

        if (kDebugMode) {
          print('User signed in with Google: ${_currentUser?.uid}');
        }
      }

      return _currentUser;
    } catch (e) {
      if (kDebugMode) {
        print('Error signing in with Google: $e');
        if (e.toString().contains('10') || e.toString().contains('12500')) {
           print('HINT: This is likely a SHA-1 fingerprint mismatch. Check your firebase console.');
        }
      }
      throw FirebaseServiceException('Error al iniciar sesión con Google: $e');
    }
  }

  /// Complete user profile setup
  Future<void> completeProfile(String username) async {
    try {
      final userId = currentUserId;
      if (userId == null) {
        throw FirebaseServiceException('Usuario no autenticado');
      }

      // Get current user data to check if they already have a username
      final userDoc = await usersCollection.doc(userId).get();
      String? currentUsername;
      if (userDoc.exists) {
        final data = userDoc.data() as Map<String, dynamic>?;
        currentUsername = data?['username'] as String?;
      }

      // Only check availability if username is different from current
      if (username != currentUsername) {
        await _checkUsernameAvailability(username);
      }

      // Use set with merge to handle both new and existing documents
      await usersCollection.doc(userId).set({
        'username': username,
        'isProfileComplete': true,
        'lastActive': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      if (kDebugMode) {
        print('User profile completed: $username');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error completing profile: $e');
      }
      rethrow;
    }
  }

  /// Check if user profile is complete
  Future<bool> checkProfileCompletion() async {
    try {
      final userId = currentUserId;
      if (userId == null) return false;

      final doc = await usersCollection.doc(userId).get();
      if (!doc.exists) return false;

      final data = doc.data() as Map<String, dynamic>;
      
      // First check if isProfileComplete field exists and is true
      final isProfileComplete = data['isProfileComplete'];
      if (isProfileComplete == true) {
        return true;
      }
      
      // For legacy users without isProfileComplete field, check if they have a valid username
      // If the field is explicitly false, they need to complete profile
      if (isProfileComplete == null) {
        final username = data['username'] as String?;
        // Consider profile complete if username exists and is not empty/temporary
        if (username != null && 
            username.isNotEmpty && 
            !username.startsWith('usuario_') &&
            !username.startsWith('Invitado_')) {
          return true;
        }
      }
      
      return false;
    } catch (e) {
      if (kDebugMode) {
        print('Error checking profile completion: $e');
      }
      return false;
    }
  }

  /// Reset password
  Future<void> resetPassword(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
      if (kDebugMode) {
        print('Password reset email sent to: $email');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error sending password reset email: $e');
      }
      throw FirebaseServiceException('Error al enviar el correo electrónico de restablecimiento de contraseña.');
    }
  }

  /// Check if username is available
  Future<void> _checkUsernameAvailability(String username) async {
    try {
      final querySnapshot = await usersCollection
          .where('username', isEqualTo: username)
          .limit(1)
          .get();
      if (querySnapshot.docs.isNotEmpty) {
        throw FirebaseServiceException('El nombre de usuario ya está en uso');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error checking username availability: $e');
      }
      rethrow;
    }
  }

  /// Update user profile
  Future<void> updateUserProfile({
    String? username,
    String? photoUrl,
  }) async {
    try {
      final userId = currentUserId;
      if (userId == null) {
        throw FirebaseServiceException('Usuario no autenticado');
      }

      final updates = <String, dynamic>{};
      
      if (username != null) {
        // Check if username is available
        final currentUser = await usersCollection.doc(userId).get();
        final currentUsername = (currentUser.data() as Map<String, dynamic>?)?['username'];
        
        if (username != currentUsername) {
          await _checkUsernameAvailability(username);
        }
        updates['username'] = username;
      }

      if (photoUrl != null) {
        updates['photoUrl'] = photoUrl;
      }

      if (updates.isNotEmpty) {
        updates['lastActive'] = FieldValue.serverTimestamp();
        await usersCollection.doc(userId).set(updates, SetOptions(merge: true));

        if (kDebugMode) {
          print('User profile updated: $updates');
        }
      }
    } on FirebaseServiceException {
      rethrow;
    } catch (e) {
      if (kDebugMode) {
        print('Error updating user profile: $e');
      }
      throw FirebaseServiceException('Error al actualizar el perfil de usuario.');
    }
  }

  /// Delete user account and all associated data
  /// This is a permanent action that cannot be undone.
  /// NOTE: This operation performs multiple deletions and may be slow.
  /// For a more robust solution, consider using a Firebase Cloud Function 
  /// triggered on user deletion, which can handle cleanup more reliably.
  Future<void> deleteAccount() async {
    final userId = currentUserId;
    if (userId == null) {
      throw FirebaseServiceException('Usuario no autenticado');
    }

    if (kDebugMode) {
      print('Starting account deletion for user: $userId');
    }

    try {
      // Step 1: Delete all associated Firestore data.
      // We run these deletions in parallel to improve performance.
      // This can still fail if Firestore security rules prevent some deletions
      // (e.g., modifying data related to other users).
      final deletions = <Future<void>>[];
      
      // Queries for data to be deleted
      final queries = [
        // Friend relationships
        friendsCollection.where('userId', isEqualTo: userId),
        friendsCollection.where('friendId', isEqualTo: userId),
        // Friend requests
        friendRequestsCollection.where('senderId', isEqualTo: userId),
        friendRequestsCollection.where('receiverId', isEqualTo: userId),
        // Practice history
        practiceHistoryCollection.where('userId', isEqualTo: userId),
      ];

      // Add batch deletion tasks for each query
      for (final query in queries) {
        deletions.add(_deleteQueryBatch(query));
      }
      
      // Also delete the main user and player documents in a separate batch
      final mainDocBatch = _firestore.batch();
      mainDocBatch.delete(usersCollection.doc(userId));
      mainDocBatch.delete(playersCollection.doc(userId));
      deletions.add(mainDocBatch.commit());
      
      // Wait for all deletion tasks to complete.
      await Future.wait(deletions);

      if (kDebugMode) {
        print('Deleted all Firestore data for user: $userId');
      }

      // Step 2: Delete the Firebase Auth user account.
      // This should be the last step, as it revokes all permissions.
      await _auth.currentUser?.delete();
      if (kDebugMode) {
        print('Deleted Firebase Auth account');
      }

      // Step 3: Clean up local state by signing out.
      await signOut();

      if (kDebugMode) {
        print('Account deletion completed successfully');
      }
    } on FirebaseAuthException catch (e) {
      if (kDebugMode) {
        print('Firebase Auth error during account deletion: ${e.code} - ${e.message}');
      }
      
      if (e.code == 'requires-recent-login') {
        throw FirebaseServiceException(
          'Por seguridad, debes iniciar sesión nuevamente antes de eliminar tu cuenta.'
        );
      }
      
      throw FirebaseServiceException(
        'Error al eliminar la cuenta de autenticación: ${e.message}'
      );
    } catch (e) {
      if (kDebugMode) {
        print('Error during account deletion: $e');
      }
      
      if (e is FirebaseServiceException) {
        rethrow;
      }
      
      throw FirebaseServiceException(
        'Ocurrió un error al eliminar la cuenta. Esto puede deberse a un problema de red o a las reglas de seguridad de Firestore. Por favor, inténtalo de nuevo.'
      );
    }
  }

  /// Deletes all documents matching a query in batches of 500.
  Future<void> _deleteQueryBatch(Query query) async {
    final Query limitedQuery = query.limit(500);
    
    while (true) {
      final QuerySnapshot snapshot = await limitedQuery.get();
      
      if (snapshot.docs.isEmpty) {
        break; // No more documents to delete.
      }
      
      final WriteBatch batch = _firestore.batch();
      for (final DocumentSnapshot doc in snapshot.docs) {
        batch.delete(doc.reference);
      }
      
      // Commit the batch of deletions.
      await batch.commit();
    }
  }

  /// Get current user ID
  /// Returns null if not authenticated
  String? get currentUserId {
    return _currentUser?.uid ?? _auth.currentUser?.uid;
  }

  /// Check if user is authenticated
  bool get isAuthenticated {
    return currentUserId != null;
  }

  /// Get reference to players collection
  CollectionReference get playersCollection {
    return _firestore.collection('players');
  }

  /// Get reference to users collection
  CollectionReference get usersCollection {
    return _firestore.collection('users');
  }

  /// Get reference to friends collection
  CollectionReference get friendsCollection {
    return _firestore.collection('friends');
  }

  /// Get reference to friend requests collection
  CollectionReference get friendRequestsCollection {
    return _firestore.collection('friendRequests');
  }

  /// Get reference to current player's document
  /// Throws if user is not authenticated
  DocumentReference get currentPlayerDoc {
    final userId = currentUserId;
    if (userId == null) {
      throw FirebaseServiceException('Usuario no autenticado');
    }
    return playersCollection.doc(userId);
  }

  /// Get reference to practice history collection
  CollectionReference get practiceHistoryCollection {
    return _firestore.collection('practice_history');
  }

  /// Get practice history for current user
  Query get currentUserPracticeHistory {
    final userId = currentUserId;
    if (userId == null) {
      throw FirebaseServiceException('Usuario no autenticado');
    }
    return practiceHistoryCollection
        .where('userId', isEqualTo: userId)
        .orderBy('date', descending: true);
  }

  /// Check if Firestore is available (online or cached)
  Future<bool> checkConnection() async {
    try {
      await _firestore
          .collection('_connection_test')
          .doc('test')
          .get(const GetOptions(source: Source.server));
      return true;
    } catch (e) {
      return false;
    }
  }
}
