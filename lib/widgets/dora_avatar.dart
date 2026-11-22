import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../state/player_state_notifier.dart';

class DoraAvatar extends StatelessWidget {
  final double width;
  final double height;

  const DoraAvatar({
    super.key,
    this.width = 100,
    this.height = 100,
  });

  @override
  Widget build(BuildContext context) {
    final playerState = context.watch<PlayerStateNotifier>().playerState;

    return SizedBox(
      width: width,
      height: height,
      child: Stack(
        alignment: Alignment.center,
        clipBehavior: Clip.none, // Permitir que el pelo se salga un poco si es necesario
        children: [
          // 1. BASE (Cuerpo)
          Image.asset(
            'assets/dora_base.png',
            width: width,
            height: height,
            fit: BoxFit.contain,
          ),

          // 2. PELO (Ajustado para que no se vea gigante)
          if (playerState.equippedHair != null && playerState.equippedHair!.isNotEmpty)
            _buildAccessory(
              playerState.equippedHair!, 
              type: 'hair',
            ),

          // 3. LENTES
          if (playerState.equippedGlasses != null && playerState.equippedGlasses!.isNotEmpty)
            _buildAccessory(
              playerState.equippedGlasses!, 
              type: 'glasses',
            ),

          // 4. SOMBRERO
           if (playerState.equippedHat != null && playerState.equippedHat!.isNotEmpty)
            _buildAccessory(
              playerState.equippedHat!, 
              type: 'hat',
            ),
        ],
      ),
    );
  }

  Widget _buildAccessory(String assetPath, {required String type}) {
    // AJUSTE DE PROPORCIONES
    // En lugar de llenar todo el espacio, ajustamos según el tipo de accesorio
    
    double? customWidth;
    double? topOffset;
    
    if (type == 'hair') {
      // El pelo suele ser un poco más ancho que la cabeza, pero no tanto como el cuadro completo
      // Lo subimos un poco para que encaje en la frente
      customWidth = width * 0.85; // Reducimos al 85% del ancho total
      topOffset = -height * 0.05; // Lo subimos un 5%
    } else if (type == 'glasses') {
      customWidth = width * 0.7; // Los lentes son más pequeños
      topOffset = height * 0.25; // A la altura de los ojos
    } else if (type == 'hat') {
      customWidth = width * 0.9;
      topOffset = -height * 0.15; // Más arriba que el pelo
    }

    return Positioned(
      top: topOffset ?? 0,
      child: Image.asset(
        assetPath,
        width: customWidth ?? width,
        fit: BoxFit.contain,
        errorBuilder: (context, error, stackTrace) => const SizedBox.shrink(),
      ),
    );
  }
}
