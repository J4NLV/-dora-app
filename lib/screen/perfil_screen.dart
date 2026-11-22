import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../state/player_state_notifier.dart';
import '../models/user_model.dart';
import '../services/user_service.dart';
import '../services/friends_service.dart';
import '../services/firebase_service.dart';
import '../widgets/dora_avatar.dart'; // Importar el Avatar
import 'editar_perfil_screen.dart';
import 'centro_de_ayuda_screen.dart';
import 'perfil_amigo_screen.dart';
import 'search_users_screen.dart';
import 'friend_requests_screen.dart';
import 'shop_screen.dart'; // Importar la tienda
import 'routes.dart';

class PerfilScreen extends StatefulWidget {
  const PerfilScreen({Key? key}) : super(key: key);

  @override
  State<PerfilScreen> createState() => _PerfilScreenState();
}

class _PerfilScreenState extends State<PerfilScreen> with SingleTickerProviderStateMixin {
  final _userService = UserService.instance;
  final _friendsService = FriendsService.instance;
  final _firebaseService = FirebaseService.instance;
  
  UserModel? _currentUser;
  List<UserModel> _friends = [];
  bool _isLoading = true;

  // Animation controller for entrance animations
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );

    _slideAnimation = Tween<Offset>(begin: const Offset(0, 0.1), end: Offset.zero).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOutCubic),
    );

    _loadUserData();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _loadUserData() async {
    // setState(() => _isLoading = true); // Commented out to prevent flickering on reload if data exists
    // Keep loading state if first load
    if (_currentUser == null) setState(() => _isLoading = true);
    
    try {
      final user = await _userService.getCurrentUserProfile();
      final friends = await _friendsService.getFriends();
      
      if (mounted) {
        setState(() {
          _currentUser = user;
          _friends = friends;
          _isLoading = false;
        });
        _animationController.forward();
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al cargar datos: ${e.toString()}')),
        );
      }
    }
  }

  Future<void> _handleLogout() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cerrar sesión'),
        content: const Text('¿Estás seguro de que quieres cerrar sesión?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Cerrar sesión'),
          ),
        ],
      ),
    );

    if (confirm == true && mounted) {
      final playerNotifier = context.read<PlayerStateNotifier>();
      playerNotifier.reset();
      await _firebaseService.signOut();
      
      if (mounted) {
        Navigator.of(context).pushNamedAndRemoveUntil(
          Routes.auth,
          (route) => false,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final playerState = context.watch<PlayerStateNotifier>();
    
    return Scaffold(
      backgroundColor: const Color(0xFF7B5BA3),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: Colors.white),
            )
          : SafeArea(
              child: RefreshIndicator(
                onRefresh: _loadUserData,
                child: FadeTransition(
                  opacity: _fadeAnimation,
                  child: SlideTransition(
                    position: _slideAnimation,
                    child: SingleChildScrollView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            _buildHeader(),
                            const SizedBox(height: 30),
                            // Streak card con evento onTap para ir a la Tienda
                            _AnimatedPressableCard(
                              onTap: () {
                                 Navigator.push(
                                   context, 
                                   MaterialPageRoute(builder: (context) => const ShopScreen())
                                 ).then((_) => _loadUserData());
                              },
                              child: _buildStreakCard(playerState),
                            ),
                            
                            const SizedBox(height: 20),
                            _AnimatedPressableCard(
                               onTap: () {}, // No action defined yet
                               child: _buildDoracoinsCard(playerState),
                            ),
                            const SizedBox(height: 30),
                            _buildFriendsSection(),
                            const SizedBox(height: 80), // Extra space for bottom nav
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
    );
  }

  Widget _buildHeader() {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            StreamBuilder<List>(
              stream: _friendsService.getPendingRequests(),
              builder: (context, snapshot) {
                final count = snapshot.data?.length ?? 0;
                return Stack(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.notifications, color: Colors.white, size: 30),
                      onPressed: () {
                        Navigator.pushNamed(context, Routes.friendRequests);
                      },
                    ),
                    if (count > 0)
                      Positioned(
                        right: 8,
                        top: 8,
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: const BoxDecoration(
                            color: Colors.red,
                            shape: BoxShape.circle,
                          ),
                          constraints: const BoxConstraints(
                            minWidth: 16,
                            minHeight: 16,
                          ),
                          child: Text(
                            '$count',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                  ],
                );
              },
            ),

            PopupMenuButton<String>(
              onSelected: (value) {
                switch (value) {
                  case 'account':
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const EditarPerfilScreen(),
                      ),
                    ).then((_) => _loadUserData());
                    break;
                  case 'help':
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const CentroDeAyudaScreen(),
                      ),
                    );
                    break;
                  case 'logout':
                    _handleLogout();
                    break;
                }
              },
              itemBuilder: (context) => [
                const PopupMenuItem(
                  value: 'account',
                  child: Row(
                    children: [
                      Icon(Icons.person_outline, color: Colors.black),
                      SizedBox(width: 8),
                      Text('Editar perfil'),
                    ],
                  ),
                ),
                const PopupMenuItem(
                  value: 'help',
                  child: Row(
                    children: [
                      Icon(Icons.help_outline, color: Colors.black),
                      SizedBox(width: 8),
                      Text('Centro de ayuda'),
                    ],
                  ),
                ),
                const PopupMenuItem(
                  value: 'logout',
                  child: Row(
                    children: [
                      Icon(Icons.exit_to_app, color: Colors.black),
                      SizedBox(width: 8),
                      Text('Cerrar sesión'),
                    ],
                  ),
                ),
              ],
              icon: const Icon(Icons.more_vert, color: Colors.white, size: 30),
              color: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
            ),
          ],
        ),

        const SizedBox(height: 10),
        // AVATAR CIRCULAR PRINCIPAL MEJORADO
        GestureDetector(
           onTap: () {
              Navigator.push(
                context, 
                MaterialPageRoute(builder: (context) => const ShopScreen())
              ).then((_) => _loadUserData());
           },
           child: Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: const Color(0xFF5B3A82),
              border: Border.all(color: Colors.white, width: 2),
            ),
            child: const Center(
              child: DoraAvatar(
                width: 115, 
                height: 115,
              ),
            ),
          ),
        ),
        const SizedBox(height: 10),

        Text(
          _currentUser?.username ?? 'Usuario',
          style: const TextStyle(
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.w900,
          ),
        ),
        if (_currentUser?.isGuest == true)
          const Text(
            'Modo invitado',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
      ],
    );
  }

  Widget _buildStreakCard(PlayerStateNotifier playerState) {
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
          Expanded(
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // AVATAR EN LA TARJETA "MI DORA"
                  Stack(
                    children: [
                      const DoraAvatar(width: 90, height: 90),
                      Positioned(
                        right: 0,
                        bottom: 0,
                        child: Container(
                          padding: const EdgeInsets.all(6),
                          decoration: const BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(color: Colors.black26, blurRadius: 4, offset: Offset(0,2))
                            ]
                          ),
                          child: const Icon(Icons.edit, size: 16, color: Color(0xFF5B3A82)),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Mi Dora',
                    style: TextStyle(color: Colors.white70, fontSize: 16),
                  ),
                ],
              ),
            ),
          ),

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
                      '${playerState.playerState.streakDays}',
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

  Widget _buildDoracoinsCard(PlayerStateNotifier playerState) {
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
                '${playerState.playerState.doracoins}',
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

  Widget _buildFriendsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Amigos',
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.w900,
              ),
            ),
            IconButton(
              icon: const Icon(Icons.search, color: Colors.white, size: 28),
              onPressed: () {
                Navigator.pushNamed(context, Routes.searchUsers)
                    .then((_) => _loadUserData());
              },
            ),
          ],
        ),
        const SizedBox(height: 15),

        _friends.isEmpty
            ? _AnimatedPressableCard(
                onTap: () {
                   Navigator.pushNamed(context, Routes.searchUsers)
                      .then((_) => _loadUserData());
                },
                child: _buildAddFriendsCard(),
              )
            : _buildFriendsGrid(),
      ],
    );
  }

  Widget _buildAddFriendsCard() {
    return Container(
      height: 150,
      decoration: BoxDecoration(
        color: const Color(0xFFE8CCDC),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF5B3A82), width: 3),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.15),
            blurRadius: 4,
            offset: const Offset(2, 2),
          ),
        ],
      ),
      child: const Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.person_add,
            size: 48,
            color: Color(0xFF5B3A82),
          ),
          SizedBox(height: 12),
          Text(
            'Agregar amigos',
            style: TextStyle(
              color: Color(0xFF5B3A82),
              fontSize: 18,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFriendsGrid() {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 0.8,
      ),
      itemCount: _friends.length,
      itemBuilder: (context, index) {
        final friend = _friends[index];
        return _buildFriendTile(friend);
      },
    );
  }

  Widget _buildFriendTile(UserModel friend) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => PerfilAmigoScreen(friendId: friend.userId),
          ),
        );
      },
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircleAvatar(
            radius: 36,
            backgroundColor: const Color(0xFF5B3A82),
            backgroundImage: friend.photoUrl != null
                ? NetworkImage(friend.photoUrl!)
                : null,
            child: friend.photoUrl == null
                ? Text(
                    friend.username.isNotEmpty
                        ? friend.username[0].toUpperCase()
                        : '?',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.w900,
                    ),
                  )
                : null,
          ),
          const SizedBox(height: 6),
          Text(
            friend.username,
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

// Helper Widget for Press Animations
class _AnimatedPressableCard extends StatefulWidget {
  final Widget child;
  final VoidCallback onTap;

  const _AnimatedPressableCard({required this.child, required this.onTap});

  @override
  State<_AnimatedPressableCard> createState() => _AnimatedPressableCardState();
}

class _AnimatedPressableCardState extends State<_AnimatedPressableCard> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  bool _isPressed = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
      lowerBound: 0.0,
      upperBound: 0.03, // Slight scale down
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) {
        setState(() => _isPressed = true);
        _controller.forward();
      },
      onTapUp: (_) {
        setState(() => _isPressed = false);
        _controller.reverse();
        widget.onTap();
      },
      onTapCancel: () {
        setState(() => _isPressed = false);
        _controller.reverse();
      },
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return Transform.scale(
            scale: 1.0 - _controller.value,
            child: child,
          );
        },
        child: widget.child,
      ),
    );
  }
}
