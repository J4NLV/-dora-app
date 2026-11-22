import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/user_model.dart';
import '../services/user_service.dart';
import '../services/firebase_service.dart';

class EditarPerfilScreen extends StatefulWidget {
  const EditarPerfilScreen({super.key});

  @override
  State<EditarPerfilScreen> createState() => _EditarPerfilScreenState();
}

class _EditarPerfilScreenState extends State<EditarPerfilScreen> {
  final _userService = UserService.instance;
  final _firebaseService = FirebaseService.instance;
  
  UserModel? _currentUser;
  bool _isLoading = true;
  bool _isUpdating = false;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    setState(() => _isLoading = true);
    
    try {
      final user = await _userService.getCurrentUserProfile();
      setState(() {
        _currentUser = user;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al cargar datos: ${e.toString()}')),
        );
      }
    }
  }

  Future<void> _updateUsername() async {
    final controller = TextEditingController(text: _currentUser?.username ?? '');
    
    final newUsername = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cambiar nombre de usuario'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            labelText: 'Nuevo nombre de usuario',
            hintText: 'Ingresa tu nuevo nombre',
          ),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, controller.text.trim()),
            child: const Text('Guardar'),
          ),
        ],
      ),
    );

    if (newUsername != null && newUsername.isNotEmpty && newUsername != _currentUser?.username) {
      setState(() => _isUpdating = true);
      
      try {
        await _userService.updateUsername(newUsername);
        await _loadUserData();
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Nombre de usuario actualizado')),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error: ${e.toString()}')),
          );
        }
      } finally {
        setState(() => _isUpdating = false);
      }
    }
  }

  Future<void> _updateProfilePhoto() async {
    // Temporarily disabled - Firebase Storage not configured
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Función de foto de perfil temporalmente deshabilitada'),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  Future<void> _changeEmail() async {
    // Changing email is complex and requires re-authentication.
    // For now, we will just inform the user.
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Para cambiar tu correo, por favor contacta a soporte o crea una nueva cuenta.'),
        ),
      );
    }
  }

  Future<void> _changePassword() async {
    final email = _currentUser?.email ?? FirebaseAuth.instance.currentUser?.email;

    if (email == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No se pudo obtener el correo electrónico')),
        );
      }
      return;
    }

    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cambiar contraseña'),
        content: Text('¿Deseas enviar un correo a $email para restablecer tu contraseña?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Enviar correo'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        await _firebaseService.resetPassword(email);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Se envió un correo para restablecer tu contraseña'),
            ),
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

  Future<void> _deleteAccount() async {
    // Step 1: Show confirmation dialog
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('¿Eliminar cuenta?'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Esta acción es permanente y no se puede deshacer.',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 12),
            Text('Se eliminarán todos tus datos, progreso y amigos.'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(
              foregroundColor: Colors.red,
            ),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );

    // Step 2: Delete account if confirmed
    if (confirm == true) {
      setState(() => _isUpdating = true);
      
      try {
        await _firebaseService.deleteAccount();
        
        if (mounted) {
          // Navigate directly to auth screen (login/register)
          Navigator.of(context).pushNamedAndRemoveUntil(
            '/auth',
            (route) => false,
          );
        }
      } catch (e) {
        setState(() => _isUpdating = false);
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error al eliminar cuenta: ${e.toString()}'),
              backgroundColor: Colors.red,
              duration: const Duration(seconds: 4),
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final safePadding = MediaQuery.of(context).padding.top;

    return Scaffold(
      backgroundColor: const Color(0xFF7B5BA3),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: Colors.white),
            )
          : Stack(
              children: [
                Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 700),
                    child: SingleChildScrollView(
                      padding: EdgeInsets.only(top: safePadding + 10, bottom: 40),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          // Header
                          _buildHeader(),
                          const SizedBox(height: 30),

                          // Profile Image
                          _buildProfileImage(),
                          const SizedBox(height: 40),

                          // Editable Fields
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 40.0),
                            child: Column(
                              children: [
                                _buildEditableField(
                                  title: 'Nombre de usuario',
                                  value: _currentUser?.username ?? '',
                                  icon: Icons.edit_outlined,
                                  onAction: _updateUsername,
                                ),
                                const SizedBox(height: 30),

                                _buildEditableField(
                                  title: 'Correo electrónico',
                                  value: _currentUser?.email ?? FirebaseAuth.instance.currentUser?.email ?? '',
                                  actionText: 'Cambiar correo',
                                  onAction: _changeEmail,
                                ),
                                const SizedBox(height: 30),

                                _buildEditableField(
                                  title: 'Contraseña',
                                  value: '*********',
                                  icon: Icons.visibility_off_outlined,
                                  actionText: 'Cambiar contraseña',
                                  onAction: _changePassword,
                                ),
                                const SizedBox(height: 50),

                                // Delete Account Button
                                _buildDeleteAccountButton(),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                
                // Loading overlay
                if (_isUpdating)
                  Container(
                    color: Colors.black54,
                    child: const Center(
                      child: CircularProgressIndicator(color: Colors.white),
                    ),
                  ),
              ],
            ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white, size: 30),
            onPressed: () => Navigator.pop(context),
          ),
          const SizedBox(width: 10),
          const Text(
            'Cuenta',
            style: TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileImage() {
    return Column(
      children: [
        Stack(
          children: [
            CircleAvatar(
              radius: 60,
              backgroundColor: const Color(0xFF5B3A82),
              backgroundImage: _currentUser?.photoUrl != null
                  ? NetworkImage(_currentUser!.photoUrl!)
                  : null,
              child: _currentUser?.photoUrl == null
                  ? Text(
                      _currentUser?.username.isNotEmpty == true
                          ? _currentUser!.username[0].toUpperCase()
                          : 'Y',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 48,
                        fontWeight: FontWeight.w900,
                      ),
                    )
                  : null,
            ),
            Positioned(
              bottom: 0,
              right: 0,
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: const BoxDecoration(
                  color: Color(0xFF5B3A82),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.camera_alt,
                  color: Colors.white,
                  size: 20,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 15),
        TextButton(
          onPressed: _updateProfilePhoto,
          child: const Text(
            'Cambiar foto de perfil',
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              decoration: TextDecoration.underline,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildEditableField({
    required String title,
    required String value,
    IconData? icon,
    String? actionText,
    required VoidCallback onAction,
  }) {
    return InkWell(
      onTap: onAction,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              if (icon != null)
                Icon(icon, color: Colors.white70, size: 20),
              if (icon != null) const SizedBox(width: 10),
              Expanded(
                child: Text(
                  value,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                  ),
                ),
              ),
              if (actionText != null)
                TextButton(
                  onPressed: onAction,
                  child: Text(
                    actionText,
                    style: const TextStyle(
                      color: Color(0xFFE0B0FF),
                      fontSize: 14,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ),
              if (actionText == null && icon != null)
                 IconButton(
                    icon: const Icon(Icons.edit, color: Color(0xFFE0B0FF), size: 20),
                    onPressed: onAction,
                 ),
            ],
          ),
          const Divider(color: Colors.white24, thickness: 1),
        ],
      ),
    );
  }

  Widget _buildDeleteAccountButton() {
    return InkWell(
      onTap: _deleteAccount,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
        decoration: BoxDecoration(
          color: Colors.red.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.red.withOpacity(0.3), width: 1),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.warning_amber_rounded, color: Colors.red[300], size: 24),
            const SizedBox(width: 12),
            Text(
              'Eliminar cuenta',
              style: TextStyle(
                color: Colors.red[300],
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}