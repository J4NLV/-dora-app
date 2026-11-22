// GUÍA DE NAVEGACIÓN - Dora App
// ================================

/**
 * ESTRUCTURA DE PANTALLAS Y NAVEGACIÓN
 *
 * 1. SplashScreen (Pantalla de inicio)
 *    - Se muestra al iniciar la app
 *    - Dura 1.4 segundos (animación del logo y texto)
 *    - Después navega automáticamente a MainNavigationScreen
 *    - Ruta: Routes.splash ("/")
 *
 * 2. MainNavigationScreen (Pantalla de navegación principal)
 *    - Contiene la barra de navegación inferior
 *    - Gestiona 4 pantallas principales mediante IndexedStack
 *    - Ruta: Routes.mainNavigation ("/main")
 *    - Pantallas que contiene:
 *      - NivelesScreen (índice 0, ícono: home)
 *      - SeleccionarPracticaScreen (índice 1, ícono: lightbulb)
 *      - ShopScreen (índice 2, ícono: shopping_cart)
 *      - Pantalla de perfil (índice 3, ícono: person) - Por implementar
 *
 * 3. NivelesScreen (Selección de niveles)
 *    - Muestra una grilla de niveles
 *    - Primer ícono de la barra: home
 *    - Ruta: Routes.niveles ("/niveles")
 *
 * 4. SeleccionarPracticaScreen (Selección de prácticas)
 *    - Muestra una lista de tópicos/prácticas
 *    - Segundo ícono de la barra: lightbulb (foquito)
 *    - Ruta: Routes.seleccionarPractica ("/seleccionar_practica")
 *
 * 5. ShopScreen (Tienda de artículos)
 *    - Muestra artículos para comprar
 *    - Tercer ícono de la barra: shopping_cart (carrito)
 *    - Ruta: Routes.shop ("/shop")
 */

/**
 * CÓMO NAVEGAR ENTRE PANTALLAS
 *
 * OPCIÓN 1: Usar rutas nombradas (recomendado)
 * ============================================
 * Navigator.of(context).pushNamed(Routes.seleccionarPractica);
 * Navigator.of(context).pushReplacementNamed(Routes.mainNavigation);
 * Navigator.of(context).pop(); // Atrás
 *
 * OPCIÓN 2: Cambiar el índice en la barra de navegación (dentro de MainNavigation)
 * ==================================================================================
 * Simplemente toca los ícones en la barra de navegación
 *
 * EJEMPLO: Desde NivelesScreen ir a SeleccionarPracticaScreen
 * ============================================================
 * onTap: () {
 *   // Método 1: Usar rutas
 *   Navigator.of(context).pushNamed(Routes.seleccionarPractica);
 *
 *   // Método 2: Si estás dentro de MainNavigationScreen, cambia el índice
 *   // (Esto es automático al pulsar el botón de la barra)
 * }
 */

/**
 * ARCHIVOS INVOLUCRADOS
 *
 * - lib/main.dart
 *   Punto de entrada de la app
 *   Configura las rutas y el tema
 *
 * - lib/screen/routes.dart
 *   Define todas las rutas nombradas
 *   Contiene la función generateRoute()
 *   Aquí AÑADES nuevas rutas cuando crees nuevas pantallas
 *
 * - lib/screen/splash_screen.dart
 *   Pantalla de bienvenida con animación
 *   Navega a MainNavigationScreen después de la animación
 *
 * - lib/screen/main_navigation_screen.dart
 *   Gestor de la navegación principal
 *   Contiene la barra de navegación personalizada
 *
 * - lib/screen/niveles_screen.dart
 *   Muestra grilla de niveles
 *
 * - lib/screen/seleccionar_practica_screen.dart
 *   Muestra lista de prácticas
 *
 * - lib/screen/shop_screen.dart
 *   Muestra tienda de artículos
 */

/**
 * FLUJO DE NAVEGACIÓN ACTUAL
 *
 * App inicia
 *   ↓
 * SplashScreen (1.8 segundos)
 *   ↓
 * MainNavigationScreen
 *   ├─ NivelesScreen (visible por defecto)
 *   ├─ SeleccionarPracticaScreen (toca el foquito)
 *   ├─ ShopScreen (toca el carrito)
 *   └─ Pantalla de Perfil (toca el ícono de persona)
 *
 * El usuario puede navegar entre estas 4 pantallas
 * usando la barra de navegación inferior
 */

/**
 * CÓMO AÑADIR UNA NUEVA PANTALLA
 *
 * 1. Crea el archivo en lib/screen/nueva_pantalla.dart
 * 2. Crea la clase StatelessWidget o StatefulWidget
 * 3. Ve a lib/screen/routes.dart
 * 4. Añade una nueva ruta: static const String nueva = '/nueva';
 * 5. Importa la pantalla: import 'nueva_pantalla.dart';
 * 6. Añade un case en generateRoute():
 *    case Routes.nueva:
 *      return MaterialPageRoute(
 *        builder: (_) => const NuevaPantalla(),
 *        settings: settings,
 *      );
 * 7. Ya puedes navegar usando: Navigator.of(context).pushNamed(Routes.nueva);
 */

