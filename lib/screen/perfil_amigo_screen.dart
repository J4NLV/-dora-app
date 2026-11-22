import 'package:flutter/material.dart';
import '../models/user_model.dart';
import '../models/player_stats_model.dart';
import '../services/user_service.dart';
import '../services/friends_service.dart';
import '../services/firebase_service.dart';

class PerfilAmigoScreen extends StatefulWidget {
  final String friendId;

  const PerfilAmigoScreen({Key? key, required this.friendId}) : super(key: key);

  @override
  State<PerfilAmigoScreen> createState() => _PerfilAmigoScreenState();
}

class _PerfilAmigoScreenState extends State<PerfilAmigoScreen> {
  final _userService = UserService.instance;
  final _friendsService = FriendsService.instance;
  final _firebaseService = FirebaseService.instance;

  UserModel? _friendUser;
  PlayerStatsModel? _friendStats;
  bool _isLoading = true;
  bool _isFriend = false;
  bool _hasPendingRequest = false;

  @override
  void initState() {
    super.initState();
    _loadFriendData();
  }

  Future<void> _loadFriendData() async {
    setState(() => _isLoading = true);

    try {
      // Load friend user data
      final user = await _friendsService.getUserById(widget.friendId);
      
      // Load friend stats
      final statsDoc = await _firebaseService.playersCollection
          .doc(widget.friendId)
          .get();
      
      PlayerStatsModel? stats;
      if (statsDoc.exists) {
        stats = PlayerStatsModel.fromFirestore(statsDoc);
      }

      // Check friendship status
      final areFriends = await _friendsService.checkIfFriends(widget.friendId);
      final pendingRequest = await _friendsService.getPendingRequestTo(widget.friendId);

      setState(() {
        _friendUser = user;
        _friendStats = stats;
        _isFriend = areFriends;
        _hasPendingRequest = pendingRequest != null;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al cargar perfil: ${e.toString()}')),
        );
      }
    }
  }

  Future<void> _sendFriendRequest() async {
    try {
      await _friendsService.sendFriendRequest(widget.friendId);
      setState(() => _hasPendingRequest = true);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('¡Solicitud enviada!')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString().replaceAll('Exception: ', ''))),
        );
      }
    }
  }

  Future<void> _removeFriend() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Eliminar amigo'),
        content: const Text('¿Estás seguro de que quieres eliminar a este amigo?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        await _friendsService.removeFriend(widget.friendId);
        setState(() => _isFriend = false);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Amigo eliminado')),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error: ${e.toString()}')),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF7B5BA3),
      appBar: AppBar(
        backgroundColor: const Color(0xFF5B3A82),
        foregroundColor: Colors.white,
        title: Text(
          _isFriend ? '• Amigo' : 'Perfil',
          style: const TextStyle(fontWeight: FontWeight.w900),
        ),
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: Colors.white),
            )
          : _friendUser == null
              ? const Center(
                  child: Text(
                    'Usuario no encontrado',
                    style: TextStyle(color: Colors.white, fontSize: 18),
                  ),
                )
              : SafeArea(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Profile header
                        _buildHeader(),
                        const SizedBox(height: 20),

                        // Action button
                        _buildActionButton(),
                        const SizedBox(height: 30),

                        // Streak card
                        if (_friendStats != null) _buildStreakCard(),
                        if (_friendStats != null) const SizedBox(height: 20),

                        // Doracoins card
                        if (_friendStats != null) _buildDoracoinsCard(),
                      ],
                    ),
                  ),
                ),
    );
  }

  Widget _buildHeader() {
    return Column(
      children: [
        // Profile photo
        CircleAvatar(
          radius: 60,
          backgroundColor: const Color(0xFF5B3A82),
          backgroundImage: _friendUser!.photoUrl != null
              ? NetworkImage(_friendUser!.photoUrl!)
              : null,
          child: _friendUser!.photoUrl == null
              ? Text(
                  _friendUser!.username.isNotEmpty
                      ? _friendUser!.username[0].toUpperCase()
                      : '?',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 48,
                    fontWeight: FontWeight.w900,
                  ),
                )
              : null,
        ),
        const SizedBox(height: 10),

        // Username
        Text(
          _friendUser!.username,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.w900,
          ),
        ),
        if (_friendUser!.isGuest)
          const Text(
            'Usuario invitado',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
      ],
    );
  }

  Widget _buildActionButton() {
    if (_isFriend) {
      return ElevatedButton.icon(
        onPressed: _removeFriend,
        icon: const Icon(Icons.person_remove),
        label: const Text(
          'Eliminar amigo',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFFE53935),
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
    } else if (_hasPendingRequest) {
      return ElevatedButton.icon(
        onPressed: null,
        icon: const Icon(Icons.schedule),
        label: const Text(
          'Solicitud enviada',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.grey,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
    } else {
      return ElevatedButton.icon(
        onPressed: _sendFriendRequest,
        icon: const Icon(Icons.person_add),
        label: const Text(
          'Agregar amigo',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF5B3A82),
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
    }
  }

  Widget _buildStreakCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF5B3A82),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white, width: 3),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        children: [
          // Dora image
          Expanded(
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      image: const DecorationImage(
                        image: AssetImage('assets/dora_base.png'),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Dora',
                    style: TextStyle(color: Colors.white70, fontSize: 16),
                  ),
                ],
              ),
            ),
          ),

          // Streak days
          Expanded(
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE53935),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '${_friendStats!.streakDays}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 36,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    'Días de racha',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDoracoinsCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF5B3A82),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white, width: 3),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.monetization_on,
            color: Color(0xFFFFD700),
            size: 40,
          ),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Doracoins',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                '${_friendStats!.doracoins}',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 32,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
