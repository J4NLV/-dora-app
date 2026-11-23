import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../controllers/content_controller.dart';
import '../state/player_state_notifier.dart';
import 'dynamic_content_screen.dart';

class NivelesScreen extends StatelessWidget {
  const NivelesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<ContentController>();
    final playerState = context.watch<PlayerStateNotifier>().playerState;

    // Sincronizar lecciones desbloqueadas/completadas desde la nube (Firestore)
    if (playerState.completedLessons.isNotEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        controller.syncCompletedLessons(playerState.completedLessons);
      });
    }

    if (controller.isLoading) {
      return const Scaffold(
        backgroundColor: Color(0xFF5B3A82),
        body: Center(child: CircularProgressIndicator(color: Colors.white)),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFF5B3A82),
      body: CustomScrollView(
        slivers: [
          // Barra Superior Estilo Dora
          SliverAppBar(
            floating: true,
            pinned: true,
            backgroundColor: const Color(0xFF4A2F6A),
            elevation: 10,
            expandedHeight: 80,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFF7B5BA3), Color(0xFF5B3A82)],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
              ),
              title: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildTopStat(Icons.local_fire_department, "${playerState.streakDays}", Colors.orangeAccent),
                  const SizedBox(width: 25),
                  _buildTopStat(Icons.monetization_on, "${playerState.doracoins}", Colors.yellowAccent),
                ],
              ),
              centerTitle: true,
            ),
          ),
          
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, cursoIdx) {
                final curso = controller.cursos[cursoIdx];
                return Column(
                  children: [
                    _buildModuleHeader(curso.titulo),
                    ..._buildDoraPath(context, curso, controller),
                    const SizedBox(height: 30),
                  ],
                );
              },
              childCount: controller.cursos.length,
            ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 100)),
        ],
      ),
    );
  }

  Widget _buildTopStat(IconData icon, String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.black26,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.white10),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(width: 4),
          Text(
            text,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w900,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildModuleHeader(String title) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 25),
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
      decoration: BoxDecoration(
        color: const Color(0xFF7B5BA3),
        borderRadius: BorderRadius.circular(25),
        boxShadow: const [
          BoxShadow(color: Colors.black26, offset: Offset(0, 4), blurRadius: 4),
        ],
        border: Border.all(color: Colors.white24, width: 2),
      ),
      child: Text(
        title.toUpperCase(),
        textAlign: TextAlign.center,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 18,
          fontWeight: FontWeight.w900,
          letterSpacing: 1.5,
        ),
      ),
    );
  }

  List<Widget> _buildDoraPath(BuildContext context, dynamic curso, ContentController controller) {
    List<Widget> nodes = [];
    int globalIdx = 0;
    for (var tema in curso.temas) {
      for (var leccion in tema.lecciones) {
        bool isUnlocked = controller.isUnlocked(leccion.id);
        // Zig-zag suave
        double offset = (globalIdx % 4 == 1) ? 40 : (globalIdx % 4 == 3) ? -40 : 0;

        nodes.add(
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 10),
            child: Transform.translate(
              offset: Offset(offset, 0),
              child: _AnimatedNodeBox(
                leccion: leccion,
                isUnlocked: isUnlocked,
                onTap: () {
                  controller.setCurrentById(leccion.id);
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const DynamicContentScreen()),
                  );
                },
              ),
            ),
          ),
        );
        globalIdx++;
      }
    }
    return nodes;
  }
}

class _AnimatedNodeBox extends StatefulWidget {
  final dynamic leccion;
  final bool isUnlocked;
  final VoidCallback onTap;
  const _AnimatedNodeBox({required this.leccion, required this.isUnlocked, required this.onTap});

  @override
  State<_AnimatedNodeBox> createState() => _AnimatedNodeBoxState();
}

class _AnimatedNodeBoxState extends State<_AnimatedNodeBox> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scale;
  bool _isNavigating = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 300));
    _scale = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 0.9), weight: 50),
      TweenSequenceItem(tween: Tween(begin: 0.9, end: 1.1), weight: 30),
      TweenSequenceItem(tween: Tween(begin: 1.1, end: 1.0), weight: 20),
    ]).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorBase = widget.isUnlocked ? const Color(0xFFD4C5E0) : Colors.grey[400];
    final colorSombra = widget.isUnlocked ? const Color(0xFF7B5BA3) : Colors.grey[700];

    return GestureDetector(
      onTap: () {
        if (widget.isUnlocked && !_isNavigating) {
          _isNavigating = true;
          _controller.forward(from: 0.0);
          Future.delayed(const Duration(milliseconds: 200), () {
            if (mounted) {
              widget.onTap();
              Future.delayed(const Duration(milliseconds: 600), () {
                if (mounted) {
                  _isNavigating = false;
                }
              });
            }
          });
        }
      },
      child: AnimatedBuilder(
        animation: _scale,
        builder: (context, child) {
          return Transform.scale(
            scale: _scale.value,
            child: Column(
              children: [
                Stack(
                  alignment: Alignment.center,
                  children: [
                    // Sombra/Base 3D
                    Container(
                      width: 90,
                      height: 90,
                      decoration: BoxDecoration(
                        color: colorSombra,
                        borderRadius: BorderRadius.circular(25),
                      ),
                    ),
                    // Frente
                    Container(
                      width: 90,
                      height: 82,
                      margin: const EdgeInsets.only(bottom: 8),
                      decoration: BoxDecoration(
                        color: colorBase,
                        borderRadius: BorderRadius.circular(25),
                        boxShadow: [
                          if (widget.isUnlocked)
                            BoxShadow(color: Colors.white.withOpacity(0.5), blurRadius: 0, offset: const Offset(-3, -3)),
                        ],
                      ),
                      child: Icon(
                        widget.isUnlocked ? _getIconForType(widget.leccion.tipo) : Icons.lock,
                        size: 40,
                        color: widget.isUnlocked ? const Color(0xFF5B3A82) : Colors.white70,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                SizedBox(
                  width: 120,
                  child: Text(
                    widget.leccion.titulo.toUpperCase(),
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    style: TextStyle(
                      color: widget.isUnlocked ? Colors.white : Colors.white54,
                      fontWeight: FontWeight.w900,
                      fontSize: 10,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  IconData _getIconForType(String tipo) {
    switch (tipo) {
      case 'video': return Icons.play_circle_filled_rounded;
      case 'quiz': return Icons.extension_rounded;
      case 'clasificar': return Icons.grid_view_rounded;
      case 'relacionar': return Icons.compare_arrows_rounded;
      default: return Icons.star_rounded;
    }
  }
}
