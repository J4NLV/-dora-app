import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import '../services/firebase_service.dart';
import '../models/player_stats_model.dart';

class PlayerState {
  final int streakDays;
  final int doracoins;
  final int currentPracticeLevel;
  final List<String> completedLessons;
  // Nuevos campos para personalización
  final String? equippedHair;
  final String? equippedGlasses;
  final String? equippedHat;
  final List<String> inventory; // Para saber qué items posee

  const PlayerState({
    required this.streakDays,
    required this.doracoins,
    required this.currentPracticeLevel,
    this.completedLessons = const [],
    this.equippedHair,
    this.equippedGlasses,
    this.equippedHat,
    this.inventory = const [],
  });

  PlayerState copyWith({
    int? streakDays,
    int? doracoins,
    int? currentPracticeLevel,
    List<String>? completedLessons,
    String? equippedHair,
    String? equippedGlasses,
    String? equippedHat,
    List<String>? inventory,
  }) {
    return PlayerState(
      streakDays: streakDays ?? this.streakDays,
      doracoins: doracoins ?? this.doracoins,
      currentPracticeLevel: currentPracticeLevel ?? this.currentPracticeLevel,
      completedLessons: completedLessons ?? this.completedLessons,
      equippedHair: equippedHair ?? this.equippedHair,
      equippedGlasses: equippedGlasses ?? this.equippedGlasses,
      equippedHat: equippedHat ?? this.equippedHat,
      inventory: inventory ?? this.inventory,
    );
  }
}

class PlayerStateNotifier extends ChangeNotifier {
  PlayerState _playerState = const PlayerState(
    streakDays: 0,
    doracoins: 0,
    currentPracticeLevel: 1,
    completedLessons: [],
    inventory: [],
  );

  bool _isLoading = true;
  String? _error;
  StreamSubscription<DocumentSnapshot>? _statsSubscription;
  final FirebaseService _firebaseService = FirebaseService.instance;

  PlayerState get playerState => _playerState;
  bool get isLoading => _isLoading;
  String? get error => _error;

  /// Initialize the notifier by loading data from Firebase
  Future<void> initialize() async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      if (!_firebaseService.isAuthenticated) {
        _isLoading = false;
        notifyListeners();
        return;
      }

      await _loadInitialData();
      _listenToStatsChanges();

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = 'Error initializing player state: $e';
      _isLoading = false;
      notifyListeners();
      if (kDebugMode) {
        print(_error);
      }
    }
  }

  /// Load initial player stats from Firestore
  Future<void> _loadInitialData() async {
    try {
      final doc = await _firebaseService.currentPlayerDoc.get();

      if (doc.exists) {
        final stats = PlayerStatsModel.fromFirestore(doc);
        _updateLocalStateFromModel(stats);
      } else {
        final userId = _firebaseService.currentUserId!;
        final initialStats = PlayerStatsModel.initial(userId);
        await _firebaseService.currentPlayerDoc.set(initialStats.toFirestore());
        _updateLocalStateFromModel(initialStats);
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error loading initial data: $e');
      }
      rethrow;
    }
  }

  void _updateLocalStateFromModel(PlayerStatsModel stats) {
    _playerState = PlayerState(
      streakDays: stats.streakDays,
      doracoins: stats.doracoins,
      currentPracticeLevel: stats.currentPracticeLevel,
      completedLessons: stats.completedLessons,
      inventory: stats.inventory,
      equippedHair: stats.equippedHair,
      equippedGlasses: stats.equippedGlasses,
      equippedHat: stats.equippedHat,
    );
  }

  /// Listen to real-time changes in Firestore
  void _listenToStatsChanges() {
    _statsSubscription = _firebaseService.currentPlayerDoc
        .snapshots()
        .listen((snapshot) {
      if (snapshot.exists) {
        final stats = PlayerStatsModel.fromFirestore(snapshot);
        _updateLocalStateFromModel(stats);
        notifyListeners();
      }
    }, onError: (error) {
      _error = 'Error listening to stats changes: $error';
      notifyListeners();
      if (kDebugMode) {
        print(_error);
      }
    });
  }

  /// Save current state to Firestore
  Future<void> _saveToFirestore() async {
    try {
      final userId = _firebaseService.currentUserId;
      if (userId == null) return;

      await _firebaseService.currentPlayerDoc.update({
        'streakDays': _playerState.streakDays,
        'doracoins': _playerState.doracoins,
        'inventory': _playerState.inventory,
        'completedLessons': _playerState.completedLessons,
        'currentPracticeLevel': _playerState.currentPracticeLevel,
        'equippedHair': _playerState.equippedHair,
        'equippedGlasses': _playerState.equippedGlasses,
        'equippedHat': _playerState.equippedHat,
        'lastUpdated': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      if (kDebugMode) {
        print('Error saving to Firestore: $e');
      }
    }
  }

  // --- Actions ---

  void completeLesson(String lessonId) {
    if (!_playerState.completedLessons.contains(lessonId)) {
      final updated = List<String>.from(_playerState.completedLessons)..add(lessonId);
      _playerState = _playerState.copyWith(completedLessons: updated);
      notifyListeners();
      _saveToFirestore();
    }
  }

  void equipItem({String? hair, String? glasses, String? hat}) {
    _playerState = _playerState.copyWith(
      equippedHair: hair ?? _playerState.equippedHair,
      equippedGlasses: glasses ?? _playerState.equippedGlasses,
      equippedHat: hat ?? _playerState.equippedHat,
    );
    notifyListeners();
    _saveToFirestore();
  }

  void updateStreak(int newStreak) {
    _playerState = _playerState.copyWith(streakDays: newStreak);
    notifyListeners();
    _saveToFirestore();
  }

  void addDoracoins(int amount) {
    _playerState = _playerState.copyWith(
      doracoins: _playerState.doracoins + amount,
    );
    notifyListeners();
    _saveToFirestore();
  }

  void spendDoracoins(int amount) {
    if (_playerState.doracoins >= amount) {
      _playerState = _playerState.copyWith(
        doracoins: _playerState.doracoins - amount,
      );
      notifyListeners();
      _saveToFirestore();
    }
  }
  
  void addToInventory(String itemId) {
    if (!_playerState.inventory.contains(itemId)) {
      final newInventory = List<String>.from(_playerState.inventory)..add(itemId);
      _playerState = _playerState.copyWith(inventory: newInventory);
      notifyListeners();
      _saveToFirestore();
    }
  }

  void reset() {
    _statsSubscription?.cancel();
    _statsSubscription = null;
    _playerState = const PlayerState(
      streakDays: 0,
      doracoins: 0,
      currentPracticeLevel: 1,
      completedLessons: [],
      inventory: [],
    );
    _isLoading = true;
    _error = null;
    notifyListeners();
  }

  @override
  void dispose() {
    _statsSubscription?.cancel();
    super.dispose();
  }
}
