import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/firebase_service.dart';
import '../services/user_service.dart';
import '../widgets/guest_warning_dialog.dart';
import 'routes.dart';

/// Authentication screen with login and registration tabs
class AuthScreen extends StatefulWidget {
  final bool showRegister;

  const AuthScreen({Key? key, this.showRegister = false}) : super(key: key);

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> with TickerProviderStateMixin {
  late TabController _tabController;
  final _firebaseService = FirebaseService.instance;
  final _userService = UserService.instance;

  // Animation for Entrance
  late AnimationController _entranceController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      length: 2,
      vsync: this,
      initialIndex: widget.showRegister ? 1 : 0,
    );

    // Initializing entrance animation
    _entranceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _entranceController, curve: Curves.easeOut),
    );
    _slideAnimation = Tween<Offset>(begin: const Offset(0, 0.1), end: Offset.zero).animate(
      CurvedAnimation(parent: _entranceController, curve: Curves.easeOutCubic),
    );
    _entranceController.forward();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _entranceController.dispose();
    super.dispose();
  }

  void _handleGuestMode() {
    GuestWarningDialog.show(
      context,
      onContinueAsGuest: () async {
        try {
          // Sign in anonymously
          await _firebaseService.signInAnonymously();
          if (mounted) {
            Navigator.of(context).pushReplacementNamed(Routes.mainNavigation);
          }
        } catch (e) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Error: ${e.toString()}')),
            );
          }
        }
      },
      onCreateAccount: () {
        _tabController.animateTo(1);
      },
    );
  }

  Future<void> _handleGoogleSignIn() async {
    try {
      final user = await _firebaseService.signInWithGoogle();
      if (user != null && mounted) {
        // Check if profile is complete
        final isProfileComplete = await _firebaseService.checkProfileCompletion();
        
        if (mounted) {
          if (isProfileComplete) {
            Navigator.of(context).pushReplacementNamed(Routes.mainNavigation);
          } else {
            Navigator.of(context).pushReplacementNamed(Routes.usernameSetup);
          }
        }
      }
    } on FirebaseAuthException catch (e) {
      if (mounted) {
        String message = 'Error al iniciar sesión con Google';
        if (e.code == 'account-exists-with-different-credential') {
          message = 'Ya existe una cuenta con este correo';
        }
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(message)),
        );
      }
    } catch (e) {
      // Ignore PigeonUserDetails type error - user was logged in successfully
      if (e.toString().contains('PigeonUserDetails')) {
        if (mounted) {
          // User was logged in with Google, check profile completion
          final isProfileComplete = await _firebaseService.checkProfileCompletion();
          
          if (mounted) {
            if (isProfileComplete) {
              Navigator.of(context).pushReplacementNamed(Routes.mainNavigation);
            } else {
              Navigator.of(context).pushReplacementNamed(Routes.usernameSetup);
            }
          }
        }
      } else {
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
      body: SafeArea(
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: SlideTransition(
            position: _slideAnimation,
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 500),
                child: Column(
                  children: [
                    const SizedBox(height: 40),
                    
                    // Logo and title
                    const Text(
                      'DORA',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 48,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 2,
                      ),
                    ),
                    const SizedBox(height: 30),

                    // Tab content
                    Expanded(
                      child: TabBarView(
                        controller: _tabController,
                        physics: const NeverScrollableScrollPhysics(),
                        children: [
                          _LoginTab(
                            onGoogleSignIn: _handleGoogleSignIn,
                            onGuestMode: _handleGuestMode,
                            onSwitchToRegister: () => _tabController.animateTo(1),
                          ),
                          _RegisterTab(
                            onGoogleSignIn: _handleGoogleSignIn,
                            onGuestMode: _handleGuestMode,
                            onSwitchToLogin: () => _tabController.animateTo(0),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Login tab content
class _LoginTab extends StatefulWidget {
  final VoidCallback onGoogleSignIn;
  final VoidCallback onGuestMode;
  final VoidCallback onSwitchToRegister;

  const _LoginTab({
    required this.onGoogleSignIn,
    required this.onGuestMode,
    required this.onSwitchToRegister,
  });

  @override
  State<_LoginTab> createState() => _LoginTabState();
}

class _LoginTabState extends State<_LoginTab> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _firebaseService = FirebaseService.instance;
  bool _obscurePassword = true;
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      await _firebaseService.signInWithEmail(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );

      if (mounted) {
        // Check if profile is complete
        final isProfileComplete = await _firebaseService.checkProfileCompletion();
        
        if (mounted) {
          if (isProfileComplete) {
            Navigator.of(context).pushReplacementNamed(Routes.mainNavigation);
          } else {
            Navigator.of(context).pushReplacementNamed(Routes.usernameSetup);
          }
        }
      }
    } on FirebaseAuthException catch (e) {
      if (mounted) {
        String message = 'Error al iniciar sesión';
        if (e.code == 'user-not-found') {
          message = 'No existe una cuenta con este correo';
        } else if (e.code == 'wrong-password') {
          message = 'Contraseña incorrecta';
        } else if (e.code == 'invalid-email') {
          message = 'Correo electrónico inválido';
        }
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(message)),
        );
      }
    } catch (e) {
      // Ignore PigeonUserDetails type error - user was logged in successfully
      if (e.toString().contains('PigeonUserDetails')) {
        if (mounted) {
          // User was logged in, check profile completion
          final isProfileComplete = await _firebaseService.checkProfileCompletion();
          
          if (mounted) {
            if (isProfileComplete) {
              Navigator.of(context).pushReplacementNamed(Routes.mainNavigation);
            } else {
              Navigator.of(context).pushReplacementNamed(Routes.usernameSetup);
            }
          }
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error: ${e.toString()}')),
          );
        }
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _handleForgotPassword() async {
    final email = _emailController.text.trim();
    if (email.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Ingresa tu correo electrónico')),
      );
      return;
    }

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

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Form(
        key: _formKey,
        child: Column(
          children: [
            // Email field
            _buildInputField(
              label: 'Correo electrónico:',
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Ingresa tu correo';
                }
                if (!value.contains('@')) {
                  return 'Correo inválido';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // Password field
            _buildInputField(
              label: 'Contraseña:',
              controller: _passwordController,
              obscureText: _obscurePassword,
              suffixIcon: IconButton(
                icon: Icon(
                  _obscurePassword ? Icons.visibility_off : Icons.visibility,
                  color: const Color(0xFF5B3A82),
                ),
                onPressed: () {
                  setState(() => _obscurePassword = !_obscurePassword);
                },
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Ingresa tu contraseña';
                }
                return null;
              },
            ),
            const SizedBox(height: 12),

            // Forgot password
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: _handleForgotPassword,
                child: const Text(
                  'Olvidé mi contraseña',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    decoration: TextDecoration.underline,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 8),

            // Divider
            const Row(
              children: [
                Expanded(child: Divider(color: Colors.white, thickness: 1.5)),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  child: Text(
                    'o',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                Expanded(child: Divider(color: Colors.white, thickness: 1.5)),
              ],
            ),
            const SizedBox(height: 16),

            // Google sign in button
            _AnimatedButton(
              onTap: widget.onGoogleSignIn,
              child: _buildGoogleButtonContent(),
            ),
            const SizedBox(height: 16),

            // Guest mode button
            _buildGuestButton(widget.onGuestMode),
            const SizedBox(height: 24),

            // Create account link
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  '¿No tienes cuenta? ',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                  ),
                ),
                TextButton(
                  onPressed: widget.onSwitchToRegister,
                  child: const Text(
                    'Crea una',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w900,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Login button
            _AnimatedButton(
              onTap: _isLoading ? () {} : _handleLogin,
              child: Container(
                width: double.infinity,
                height: 50,
                decoration: BoxDecoration(
                   color: const Color(0xFF5B3A82),
                   borderRadius: BorderRadius.circular(12),
                   boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 4, offset: Offset(0,2))],
                ),
                alignment: Alignment.center,
                child: _isLoading
                    ? const SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : const Text(
                        'Iniciar sesión',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w900,
                          color: Colors.white
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInputField({
    required String label,
    required TextEditingController controller,
    bool obscureText = false,
    Widget? suffixIcon,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 14,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          obscureText: obscureText,
          keyboardType: keyboardType,
          validator: validator,
          decoration: InputDecoration(
            filled: true,
            fillColor: const Color(0xFFD4C5E0),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 14,
            ),
            suffixIcon: suffixIcon,
          ),
        ),
      ],
    );
  }

  Widget _buildGoogleButtonContent() {
    return Container(
      width: double.infinity,
      height: 50,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 2, offset: Offset(0, 1))],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset(
            'assets/google_logo.png',
            height: 24,
            errorBuilder: (context, error, stackTrace) {
              return const Icon(Icons.g_mobiledata, size: 24);
            },
          ),
          const SizedBox(width: 12),
          const Text(
            'Continuar con Google',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: Colors.black87,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGuestButton(VoidCallback onPressed) {
    return TextButton(
      onPressed: onPressed,
      child: const Text(
        'Continuar como invitado',
        style: TextStyle(
          color: Colors.white,
          fontSize: 16,
          fontWeight: FontWeight.w700,
          decoration: TextDecoration.underline,
        ),
      ),
    );
  }
}

/// Register tab content
class _RegisterTab extends StatefulWidget {
  final VoidCallback onGoogleSignIn;
  final VoidCallback onGuestMode;
  final VoidCallback onSwitchToLogin;

  const _RegisterTab({
    required this.onGoogleSignIn,
    required this.onGuestMode,
    required this.onSwitchToLogin,
  });

  @override
  State<_RegisterTab> createState() => _RegisterTabState();
}

class _RegisterTabState extends State<_RegisterTab> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _firebaseService = FirebaseService.instance;
  final _userService = UserService.instance;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _isLoading = false;

  @override
  void dispose() {
    _usernameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _handleRegister() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      // Create account
      final user = await _firebaseService.signUpWithEmail(
        email: _emailController.text.trim(),
        password: _passwordController.text,
        username: _usernameController.text.trim(),
      );

      if (user != null) {
        // Reset user data (initialize with zeros)
        await _userService.resetUserData(user.uid);

        if (mounted) {
          Navigator.of(context).pushReplacementNamed(Routes.mainNavigation);
        }
      }
    } on FirebaseAuthException catch (e) {
      if (mounted) {
        String message = 'Error al crear la cuenta';
        if (e.code == 'weak-password') {
          message = 'La contraseña es muy débil';
        } else if (e.code == 'email-already-in-use') {
          message = 'Ya existe una cuenta con este correo';
        } else if (e.code == 'invalid-email') {
          message = 'Correo electrónico inválido';
        }
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(message)),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString().replaceAll('Exception: ', ''))),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Form(
        key: _formKey,
        child: Column(
          children: [
            // Username field
            _buildInputField(
              label: 'Elige nombre de usuario:',
              controller: _usernameController,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Ingresa un nombre de usuario';
                }
                if (value.length < 3) {
                  return 'Mínimo 3 caracteres';
                }
                if (value.contains(' ')) {
                  return 'No puede contener espacios';
                }
                if (!RegExp(r'^[a-zA-Z0-9_]+$').hasMatch(value)) {
                  return 'Solo letras, números y guión bajo';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // Email field
            _buildInputField(
              label: 'Correo electrónico:',
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Ingresa tu correo';
                }
                if (!value.contains('@')) {
                  return 'Correo inválido';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // Password field
            _buildInputField(
              label: 'Contraseña:',
              controller: _passwordController,
              obscureText: _obscurePassword,
              suffixIcon: IconButton(
                icon: Icon(
                  _obscurePassword ? Icons.visibility_off : Icons.visibility,
                  color: const Color(0xFF5B3A82),
                ),
                onPressed: () {
                  setState(() => _obscurePassword = !_obscurePassword);
                },
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Ingresa una contraseña';
                }
                if (value.length < 6) {
                  return 'Mínimo 6 caracteres';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // Confirm password field
            _buildInputField(
              label: 'Confirmar contraseña:',
              controller: _confirmPasswordController,
              obscureText: _obscureConfirmPassword,
              suffixIcon: IconButton(
                icon: Icon(
                  _obscureConfirmPassword ? Icons.visibility_off : Icons.visibility,
                  color: const Color(0xFF5B3A82),
                ),
                onPressed: () {
                  setState(() => _obscureConfirmPassword = !_obscureConfirmPassword);
                },
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Confirma tu contraseña';
                }
                if (value != _passwordController.text) {
                  return 'Las contraseñas no coinciden';
                }
                return null;
              },
            ),
            const SizedBox(height: 24),

            // Divider
            const Row(
              children: [
                Expanded(child: Divider(color: Colors.white, thickness: 1.5)),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  child: Text(
                    'o',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                Expanded(child: Divider(color: Colors.white, thickness: 1.5)),
              ],
            ),
            const SizedBox(height: 16),

            // Google sign in button
            _AnimatedButton(
              onTap: widget.onGoogleSignIn,
              child: _buildGoogleButtonContent(),
            ),
            const SizedBox(height: 16),

            // Guest mode button
            _buildGuestButton(widget.onGuestMode),
            const SizedBox(height: 24),

            // Already have account link
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  '¿Ya tienes cuenta? ',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                  ),
                ),
                TextButton(
                  onPressed: widget.onSwitchToLogin,
                  child: const Text(
                    'Inicia sesión',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w900,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Register button
            _AnimatedButton(
              onTap: _isLoading ? () {} : _handleRegister,
              child: Container(
                width: double.infinity,
                height: 50,
                decoration: BoxDecoration(
                   color: const Color(0xFF5B3A82),
                   borderRadius: BorderRadius.circular(12),
                   boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 4, offset: Offset(0,2))],
                ),
                alignment: Alignment.center,
                child: _isLoading
                    ? const SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : const Text(
                        'Registrarse',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w900,
                          color: Colors.white
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInputField({
    required String label,
    required TextEditingController controller,
    bool obscureText = false,
    Widget? suffixIcon,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 14,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          obscureText: obscureText,
          keyboardType: keyboardType,
          validator: validator,
          decoration: InputDecoration(
            filled: true,
            fillColor: const Color(0xFFD4C5E0),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 14,
            ),
            suffixIcon: suffixIcon,
          ),
        ),
      ],
    );
  }

  Widget _buildGoogleButtonContent() {
    return Container(
      width: double.infinity,
      height: 50,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 2, offset: Offset(0, 1))],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset(
            'assets/google_logo.png',
            height: 24,
            errorBuilder: (context, error, stackTrace) {
              return const Icon(Icons.g_mobiledata, size: 24);
            },
          ),
          const SizedBox(width: 12),
          const Text(
            'Continuar con Google',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: Colors.black87,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGuestButton(VoidCallback onPressed) {
    return TextButton(
      onPressed: onPressed,
      child: const Text(
        'Continuar como invitado',
        style: TextStyle(
          color: Colors.white,
          fontSize: 16,
          fontWeight: FontWeight.w700,
          decoration: TextDecoration.underline,
        ),
      ),
    );
  }
}

// Widget auxiliar para animar botones al hacer click
class _AnimatedButton extends StatefulWidget {
  final Widget child;
  final VoidCallback onTap;

  const _AnimatedButton({required this.child, required this.onTap});

  @override
  State<_AnimatedButton> createState() => _AnimatedButtonState();
}

class _AnimatedButtonState extends State<_AnimatedButton> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
      lowerBound: 0.0,
      upperBound: 0.05,
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
      onTap: () async {
        await _controller.forward();
        await _controller.reverse();
        widget.onTap();
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
