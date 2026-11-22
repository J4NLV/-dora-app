import 'package:flutter/material.dart';
import 'splash_screen.dart';
import 'auth_screen.dart';
import 'main_navigation_screen.dart';
import 'niveles_screen.dart';
import 'seleccionar_practica_screen.dart';
import 'shop_screen.dart';
import 'centro_de_ayuda_screen.dart';
import 'search_users_screen.dart';
import 'friend_requests_screen.dart';
import 'username_setup_screen.dart';

/// Definición de rutas nombradas para navegar entre pantallas
class Routes {
  static const String splash = '/';
  static const String auth = '/auth';
  static const String mainNavigation = '/main';
  static const String niveles = '/niveles';
  static const String seleccionarPractica = '/seleccionar_practica';
  static const String shop = '/shop';
  static const String centroDeAyuda = '/centro_de_ayuda';
  static const String searchUsers = '/search_users';
  static const String friendRequests = '/friend_requests';
  static const String usernameSetup = '/username_setup';
}

/// Generador de rutas para manejar la navegación
Route<dynamic> generateRoute(RouteSettings settings) {
  switch (settings.name) {
    case Routes.splash:
      return MaterialPageRoute(
        builder: (_) => const SplashScreen(),
        settings: settings,
      );
    case Routes.auth:
      return MaterialPageRoute(
        builder: (_) => const AuthScreen(),
        settings: settings,
      );
    case Routes.usernameSetup:
      return MaterialPageRoute(
        builder: (_) => const UsernameSetupScreen(),
        settings: settings,
      );
    case Routes.mainNavigation:
      return MaterialPageRoute(
        builder: (_) => const MainNavigationScreen(),
        settings: settings,
      );
    case Routes.niveles:
      return MaterialPageRoute(
        builder: (_) => const NivelesScreen(),
        settings: settings,
      );
    case Routes.seleccionarPractica:
      return MaterialPageRoute(
        builder: (_) => const SeleccionarPracticaScreen(),
        settings: settings,
      );
    case Routes.shop:
      return MaterialPageRoute(
        builder: (_) => const ShopScreen(),
        settings: settings,
      );
    case Routes.centroDeAyuda:
      return MaterialPageRoute(
        builder: (_) => const CentroDeAyudaScreen(),
        settings: settings,
      );
    case Routes.searchUsers:
      return MaterialPageRoute(
        builder: (_) => const SearchUsersScreen(),
        settings: settings,
      );
    case Routes.friendRequests:
      return MaterialPageRoute(
        builder: (_) => const FriendRequestsScreen(),
        settings: settings,
      );
    default:
      return MaterialPageRoute(
        builder: (_) => Scaffold(
          body: Center(
            child: Text('No route defined for ${settings.name}'),
          ),
        ),
      );
  }
}
