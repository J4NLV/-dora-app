import 'package:dora/screen/perfil_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../state/player_state_notifier.dart';
import 'seleccionar_practica_screen.dart';
import 'shop_screen.dart';
import 'niveles_screen.dart';

class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({super.key});

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int _selectedIndex = 0; // Inicia en Niveles (índice 0)

  @override
  void initState() {
    super.initState();
    // Initialize player state when entering main navigation
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final playerNotifier = Provider.of<PlayerStateNotifier>(context, listen: false);
      playerNotifier.initialize();
    });
  }

  // Lista de las pantallas que se mostrarán
  static final List<Widget> _widgetOptions = <Widget>[
    const NivelesScreen(),
    const SeleccionarPracticaScreen(),
    const ShopScreen(),
    const PerfilScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true, // Permite que el body se dibuje por detrás del bottomNavigationBar
      // Fijamos el mismo color de fondo que usan las demás pantallas para que la barra se integre
      backgroundColor: const Color(0xFF7B5BA3),
      // Usamos AnimatedSwitcher para transiciones suaves
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 600), // AUMENTADO A 600ms
        switchInCurve: Curves.easeInOutCubic, // Curva más pronunciada
        switchOutCurve: Curves.easeInOutCubic,
        transitionBuilder: (Widget child, Animation<double> animation) {
           // Combinamos Fade con un ligero Slide o Scale para hacerlo más "moderno"
           return FadeTransition(
             opacity: animation,
             child: SlideTransition(
               position: Tween<Offset>(
                 begin: const Offset(0.0, 0.05), // Entra desde un poco abajo
                 end: Offset.zero,
               ).animate(animation),
               child: child,
             ),
           );
        },
        child: KeyedSubtree(
          key: ValueKey<int>(_selectedIndex),
          child: _widgetOptions[_selectedIndex],
        ),
      ),
      bottomNavigationBar: SafeArea(
        bottom: true,
        child: Padding(
          // Más separación vertical para que la barra no esté pegada al borde inferior
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
          child: CustomBottomNavBar(
            selectedIndex: _selectedIndex,
            onItemTapped: _onItemTapped,
          ),
        ),
      ),
    );
  }
}


// --- Widget para la Barra de Navegación Personalizada ---
class CustomBottomNavBar extends StatelessWidget {
  final int selectedIndex;
  final Function(int) onItemTapped;

  const CustomBottomNavBar({
    super.key,
    required this.selectedIndex,
    required this.onItemTapped,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 86, // mayor altura para que no quede tan pegada abajo
      padding: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        color: const Color(0xFFADD8E6), // Color azul claro de fondo
        borderRadius: BorderRadius.circular(35),
        // Se elimina el borde rosa y se añade una sombra suave para integración
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(25),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _buildNavItem(icon: Icons.home, index: 0),
          _buildNavItem(icon: Icons.lightbulb_outline, index: 1),
          _buildNavItem(icon: Icons.shopping_cart_outlined, index: 2),
          _buildNavItem(icon: Icons.person_outline, index: 3),
        ],
      ),
    );
  }

  Widget _buildNavItem({
    required IconData icon,
    required int index,
  }) {
    final bool isSelected = selectedIndex == index;
    return Material( // Material widget para habilitar el efecto ripple
      color: Colors.transparent,
      child: InkWell(
        onTap: () => onItemTapped(index),
        customBorder: const CircleBorder(), // Asegura que el ripple sea circular
        splashColor: const Color(0xFFF08080).withOpacity(0.4), // Color del ripple visible
        highlightColor: const Color(0xFFF08080).withOpacity(0.2),
        child: AnimatedContainer( // ANIMACIÓN DE ESCALA EN EL CONTENEDOR
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOutBack,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isSelected ? const Color(0xFFF08080).withAlpha(77) : Colors.transparent,
          ),
          transform: isSelected 
              ? Matrix4.diagonal3Values(1.15, 1.15, 1.0) // Crece un 15% al seleccionarse
              : Matrix4.identity(),
          child: Icon(
            icon,
            color: const Color(0xFFF08080),
            size: 32,
          ),
        ),
      ),
    );
  }
}
