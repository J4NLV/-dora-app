import 'dart:async';

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/firebase_service.dart';
import 'routes.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _logoScale;
  late final Animation<double> _textOpacity;
  late final Animation<Offset> _textOffset;
  // Flag to prevent multiple navigations if user background/foregrounds app
  bool _navigationStarted = false;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    );

    _logoScale = Tween<double>(begin: 1.0, end: 0.82).animate(
      CurvedAnimation(parent: _controller, curve: const Interval(0.0, 0.6, curve: Curves.easeOut)),
    );

    _textOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: const Interval(0.5, 1.0, curve: Curves.easeIn)),
    );

    _textOffset = Tween<Offset>(begin: const Offset(0, 0.6), end: Offset.zero).animate(
      CurvedAnimation(parent: _controller, curve: const Interval(0.5, 1.0, curve: Curves.easeOut)),
    );

    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        // La animación ha terminado. Espera un poco antes de navegar.
        // La animación dura 1.4s, esperamos 1.6s más para un total de 3s.
        if (!_navigationStarted) {
          Timer(const Duration(milliseconds: 1600), () {
            _navigateToHome();
          });
        }
      }
    });

    // Asegura que siempre inicia desde el principio.
    _controller.reset();
    _controller.forward();
  }

  // Handle lifecycle changes to possibly resume animation or navigation
  // though normally initState runs once. The issue described (stuck on splash)
  // usually happens if navigation is attempted when context is not valid or
  // if logic fails silently.
  
  Future<void> _navigateToHome() async {
    if (!mounted || _navigationStarted) return;
    _navigationStarted = true;
    
    // Check if user is authenticated
    final user = FirebaseAuth.instance.currentUser;
    final isAuthenticated = user != null;
    
    if (isAuthenticated) {
      print('DEBUG: Auto-login with user: ${user.email} (${user.uid})');
      
      // Check if profile is complete using FirebaseService
      try {
        final firebaseService = FirebaseService.instance;
        final isProfileComplete = await firebaseService.checkProfileCompletion();
        
        if (!mounted) return;

        if (!isProfileComplete) {
          Navigator.of(context).pushReplacementNamed(Routes.usernameSetup);
          return;
        }
      } catch (e) {
        print('Error checking profile completion: $e');
        if (!mounted) return;
      }

      if (mounted) {
         Navigator.of(context).pushReplacementNamed(Routes.mainNavigation);
      }
    } else {
      print('DEBUG: No user logged in, navigating to AuthScreen');
      if (mounted) {
        Navigator.of(context).pushReplacementNamed(Routes.auth);
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const backgroundColor = Color(0xFF7B5BA3);

    return Scaffold(
      backgroundColor: backgroundColor,
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 600),
            child: AnimatedBuilder(
              animation: _controller,
              builder: (context, child) {
                return Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    LayoutBuilder(
                      builder: (context, constraints) {
                        final width = constraints.maxWidth;
                        final height = constraints.maxHeight;
                        // Responsivo: tamaño base en función del ancho disponible
                        final logoSize = (width * 0.45).clamp(120.0, 260.0);
                        final titleFontSize = (width * 0.085).clamp(18.0, 36.0);
                        final gap = (height * 0.02).clamp(12.0, 24.0);

                        return Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Transform.scale(
                              scale: _logoScale.value,
                              child: SizedBox(
                                width: logoSize,
                                height: logoSize,
                                child: Image.asset(
                                  'assets/logo_dora.png',
                                  fit: BoxFit.contain,
                                ),
                              ),
                            ),
                            SizedBox(height: gap),
                            Opacity(
                              opacity: _textOpacity.value,
                              child: FractionalTranslation(
                                translation: _textOffset.value,
                                child: Text(
                                  'Dora la calculadora',
                                  textAlign: TextAlign.center,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: titleFontSize,
                                    fontWeight: FontWeight.w900,
                                    letterSpacing: 1.2,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}
