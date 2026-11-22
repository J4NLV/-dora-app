import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../state/player_state_notifier.dart';

// Modelo interno para manejar los productos de la UI
class ShopItem {
  final String id;
  final String name;
  final String shopImage; // Imagen para mostrar en la estantería (maniquí)
  final String avatarImage; // Imagen que se pone el avatar
  final int price;
  final String category; // 'hair', 'glasses', 'hat', etc.

  const ShopItem({
    required this.id,
    required this.name,
    required this.shopImage,
    required this.avatarImage,
    required this.price,
    required this.category,
  });
}

// Catálogo de productos disponibles
final List<ShopItem> allShopItems = [
  // Pelucas (Artículos de prestigio: 350 y 500 Doracoins)
  ShopItem(
    id: 'hair_short',
    name: 'Cabello Corto',
    shopImage: 'assets/Tienda/Cabello Corto Maniquí.png',
    avatarImage: 'assets/Tienda/Cabello.png',
    price: 350,
    category: 'hair',
  ),
  ShopItem(
    id: 'hair_long',
    name: 'Cabello Largo',
    shopImage: 'assets/Tienda/Cabello Largo_Maniqui.png',
    avatarImage: 'assets/Tienda/Cabello Largo.png',
    price: 500,
    category: 'hair',
  ),

  // Lentes (80 y 120 Doracoins)
  ShopItem(
    id: 'glasses_classic',
    name: 'Lentes Clásicos',
    shopImage: 'assets/bombilla.png',
    avatarImage: 'assets/bombilla.png',
    price: 80,
    category: 'glasses',
  ),
  ShopItem(
    id: 'glasses_modern',
    name: 'Lentes Modernos',
    shopImage: 'assets/bombilla.png',
    avatarImage: 'assets/bombilla.png',
    price: 120,
    category: 'glasses',
  ),

  // Sombreros (150 y 200 Doracoins)
  ShopItem(
    id: 'hat_cap',
    name: 'Gorra Dora',
    shopImage: 'assets/bombilla.png',
    avatarImage: 'assets/bombilla.png',
    price: 150,
    category: 'hat',
  ),
  ShopItem(
    id: 'hat_beanie',
    name: 'Gorro de Invierno',
    shopImage: 'assets/bombilla.png',
    avatarImage: 'assets/bombilla.png',
    price: 200,
    category: 'hat',
  ),

  // Zapatos / Botas (220 y 280 Doracoins)
  ShopItem(
    id: 'shoes_sneakers',
    name: 'Tenis Deportivos',
    shopImage: 'assets/bombilla.png',
    avatarImage: 'assets/bombilla.png',
    price: 220,
    category: 'shoes',
  ),
  ShopItem(
    id: 'shoes_boots',
    name: 'Botas Aventureras',
    shopImage: 'assets/bombilla.png',
    avatarImage: 'assets/bombilla.png',
    price: 280,
    category: 'shoes',
  ),
];

class ShopScreen extends StatelessWidget {
  const ShopScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final playerNotifier = context.watch<PlayerStateNotifier>();
    final playerState = playerNotifier.playerState;

    final wigs = allShopItems.where((i) => i.category == 'hair').toList();
    final glasses = allShopItems.where((i) => i.category == 'glasses').toList();
    final hats = allShopItems.where((i) => i.category == 'hat').toList();
    final shoes = allShopItems.where((i) => i.category == 'shoes').toList();

    return Scaffold(
      backgroundColor: const Color(0xFF7B5BA3),
      body: SafeArea(
        child: Column(
          children: [
            // Custom AppBar sin botón de retroceso (es pantalla principal)
            Container(
              padding: const EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                color: const Color(0xFF7B5BA3),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Tienda',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 28,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  Chip(
                    backgroundColor: const Color(0xFF5B3A82),
                    side: BorderSide.none,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                    label: Text(
                      '${playerState.doracoins}',
                      style: const TextStyle(
                          color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                    avatar: const Icon(Icons.monetization_on, color: Colors.yellow),
                  ),
                ],
              ),
            ),
            
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(16.0),
                children: [
                  _AnimatedShopSection(
                    title: 'Lentes',
                    items: glasses,
                    playerNotifier: playerNotifier,
                    delay: 0,
                  ),
                  const SizedBox(height: 16),
                  _AnimatedShopSection(
                    title: 'Sombreros',
                    items: hats,
                    playerNotifier: playerNotifier,
                    delay: 100,
                  ),
                  const SizedBox(height: 16),
                  _AnimatedShopSection(
                    title: 'Zapatos',
                    items: shoes,
                    playerNotifier: playerNotifier,
                    delay: 200,
                  ),
                  const SizedBox(height: 16),
                  _AnimatedShopSection(
                    title: 'Pelucas',
                    items: wigs,
                    playerNotifier: playerNotifier,
                    delay: 300,
                  ),
                  // Espacio extra al final para que no se tape con el bottom nav
                  const SizedBox(height: 80),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AnimatedShopSection extends StatefulWidget {
  final String title;
  final List<ShopItem> items;
  final PlayerStateNotifier? playerNotifier;
  final int delay;

  const _AnimatedShopSection({
    required this.title,
    required this.items,
    this.playerNotifier,
    required this.delay,
  });

  @override
  State<_AnimatedShopSection> createState() => _AnimatedShopSectionState();
}

class _AnimatedShopSectionState extends State<_AnimatedShopSection> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );

    _slideAnimation = Tween<Offset>(begin: const Offset(0, 0.2), end: Offset.zero).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic),
    );

    Future.delayed(Duration(milliseconds: widget.delay), () {
      if (mounted) _controller.forward();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.items.isEmpty) {
      return FadeTransition(
        opacity: _fadeAnimation,
        child: SlideTransition(
          position: _slideAnimation,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.title,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Padding(
                padding: EdgeInsets.only(top: 4.0, bottom: 8.0, left: 4.0),
                child: Text(
                  'Próximamente',
                  style: TextStyle(color: Colors.white54, fontStyle: FontStyle.italic, fontSize: 14),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return FadeTransition(
      opacity: _fadeAnimation,
      child: SlideTransition(
        position: _slideAnimation,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.title,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 12),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2, 
                childAspectRatio: 0.85, 
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
              ),
              itemCount: widget.items.length,
              itemBuilder: (context, index) {
                return _ShopItemCard(
                  item: widget.items[index],
                  notifier: widget.playerNotifier!,
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _ShopItemCard extends StatefulWidget {
  final ShopItem item;
  final PlayerStateNotifier notifier;

  const _ShopItemCard({
    required this.item,
    required this.notifier,
  });

  @override
  State<_ShopItemCard> createState() => _ShopItemCardState();
}

class _ShopItemCardState extends State<_ShopItemCard> with SingleTickerProviderStateMixin {
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

  Future<void> _handleTap() async {
    // Animación completa al dar click
    await _controller.forward();
    await _controller.reverse();
    
    // Acción de la lógica (Equipar/Comprar)
    // Aquí invocamos la lógica real, que estaba dispersa en los botones
    // Pero como hay diferentes acciones (Comprar vs Equipar), lo ideal es mantener la animación visual
    // y dejar que los botones internos manejen la lógica, O envolver todo y detectar.
    
    // NOTA: Para este widget en particular, tiene botones internos.
    // Si queremos que TODA la tarjeta se anime al tocar los botones internos,
    // necesitamos envolver los botones en GestureDetector que activen esta animación.
  }

  @override
  Widget build(BuildContext context) {
    final state = widget.notifier.playerState;
    final isOwned = state.inventory.contains(widget.item.id);
    
    bool isEquipped = false;
    if (widget.item.category == 'hair') {
      isEquipped = state.equippedHair == widget.item.avatarImage;
    } else if (widget.item.category == 'glasses') {
      isEquipped = state.equippedGlasses == widget.item.avatarImage;
    }

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Transform.scale(
          scale: 1.0 - _controller.value,
          child: child,
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFF9575CD).withOpacity(0.5), 
          borderRadius: BorderRadius.circular(20),
          border: isEquipped 
              ? Border.all(color: Colors.yellow, width: 3) 
              : Border.all(color: Colors.white24, width: 1),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 6,
              offset: const Offset(0, 4),
            )
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Image.asset(
                  widget.item.shopImage,
                  fit: BoxFit.contain,
                  errorBuilder: (c, o, s) => const Icon(Icons.image_not_supported, color: Colors.white54),
                ),
              ),
            ),
            
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4.0),
              child: Text(
                widget.item.name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            
            const SizedBox(height: 8),

            Padding(
              padding: const EdgeInsets.only(bottom: 12.0, left: 8, right: 8),
              child: isEquipped
                  ? Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.yellow,
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: const Text(
                        'Equipado',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    )
                  : GestureDetector(
                      onTap: () async {
                        // Animación al presionar el botón
                        await _controller.forward();
                        await _controller.reverse();
                        
                        // Lógica para todas las categorías
                        if (isOwned) {
                          if (widget.item.category == 'hair') {
                            widget.notifier.equipItem(hair: widget.item.avatarImage);
                          } else if (widget.item.category == 'glasses') {
                            widget.notifier.equipItem(glasses: widget.item.avatarImage);
                          } else if (widget.item.category == 'hat') {
                            widget.notifier.equipItem(hat: widget.item.avatarImage);
                          }
                        } else {
                          if (state.doracoins >= widget.item.price) {
                            widget.notifier.spendDoracoins(widget.item.price);
                            widget.notifier.addToInventory(widget.item.id);
                            if (widget.item.category == 'hair') {
                              widget.notifier.equipItem(hair: widget.item.avatarImage);
                            } else if (widget.item.category == 'glasses') {
                              widget.notifier.equipItem(glasses: widget.item.avatarImage);
                            } else if (widget.item.category == 'hat') {
                              widget.notifier.equipItem(hat: widget.item.avatarImage);
                            }
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: const Text('¡No tienes suficientes Doracoins!'),
                                backgroundColor: const Color(0xFF5B3A82),
                                behavior: SnackBarBehavior.floating,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                              ),
                            );
                          }
                        }
                      },
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        decoration: BoxDecoration(
                          color: isOwned ? const Color(0xFF42A5F5) : const Color(0xFF66BB6A),
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: isOwned 
                          ? const Text(
                              'Equipar',
                              textAlign: TextAlign.center,
                              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                            )
                          : Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(Icons.monetization_on, size: 16, color: Colors.yellow),
                                const SizedBox(width: 4),
                                Text(
                                  '${widget.item.price}',
                                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
