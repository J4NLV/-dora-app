// dart
import 'package:flutter/material.dart';

class TopicModel {
  final String title;
  final String description;

  const TopicModel({required this.title, required this.description});
}

class SeleccionarPracticaScreen extends StatefulWidget {
  const SeleccionarPracticaScreen({super.key});

  @override
  State<SeleccionarPracticaScreen> createState() =>
      _SeleccionarPracticaScreenState();
}

class _SeleccionarPracticaScreenState extends State<SeleccionarPracticaScreen> {
  String? _selectedTopicId;

  final List<TopicModel> _practiceTopics = [
    const TopicModel(
      title: 'Introducción al algebra',
      description:
      'Aquí aprenderás los conceptos fundamentales del álgebra, como variables, constantes y polinomios, para desarrollar el pensamiento abstracto y resolver problemas.',
    ),
    const TopicModel(
      title: 'Expresiones algebraicas',
      description: 'Descripción de Expresiones algebraicas.',
    ),
    const TopicModel(
      title: 'Operaciones con expresiones algebraicas',
      description: 'Descripción de Operaciones con expresiones algebraicas.',
    ),
    const TopicModel(
      title: 'Ecuaciones lineales',
      description: 'Descripción de Ecuaciones lineales.',
    ),
    const TopicModel(
      title: 'Sistemas de ecuaciones',
      description: 'Descripción de Sistemas de ecuaciones.',
    ),
  ];

  void _handleTap(String topicId) {
    setState(() {
      _selectedTopicId = (_selectedTopicId == topicId) ? null : topicId;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF7B5BA3),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 500),
            child: Column(
              children: [
                const HeaderWidget(),
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
                    itemCount: _practiceTopics.length,
                    itemBuilder: (context, index) {
                      final topic = _practiceTopics[index];
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12.0),
                        child: DrawnTopicCard(
                          topic: topic,
                          isExpanded: _selectedTopicId == topic.title,
                          onTap: () => _handleTap(topic.title),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}


class DrawnTopicCard extends StatefulWidget {
  final TopicModel topic;
  final bool isExpanded;
  final VoidCallback onTap;

  const DrawnTopicCard({
    super.key,
    required this.topic,
    required this.isExpanded,
    required this.onTap,
  });

  @override
  State<DrawnTopicCard> createState() => _DrawnTopicCardState();
}

class _DrawnTopicCardState extends State<DrawnTopicCard> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  // ignore: unused_field
  late Animation<double> _scaleAnimation;
  bool _isPressed = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
      lowerBound: 0.0,
      upperBound: 0.05, // Efecto de escala
    );
  }
  
  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleTapDown(TapDownDetails details) {
    setState(() => _isPressed = true);
    _controller.forward();
  }

  void _handleTapUp(TapUpDetails details) {
    setState(() => _isPressed = false);
    _controller.reverse();
    widget.onTap();
  }

  void _handleTapCancel() {
    setState(() => _isPressed = false);
    _controller.reverse();
  }

  @override
  Widget build(BuildContext context) {
    // Colores para el estado
    final bool isSelected = widget.isExpanded;
    final Color cardColor = isSelected ? const Color(0xFFD8BBE4) : const Color(0xFFE8CCDC);
    final Color borderColor = const Color(0xFF5B3A82);

    return Column(
      children: [
        GestureDetector(
          onTapDown: _handleTapDown,
          onTapUp: _handleTapUp,
          onTapCancel: _handleTapCancel,
          child: AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              return Transform.scale(
                scale: 1.0 - _controller.value,
                child: child,
              );
            },
            child: Container(
              height: 60,
              decoration: BoxDecoration(
                color: cardColor,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: borderColor, width: 2.5),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.15),
                    blurRadius: _isPressed ? 2 : 4,
                    offset: _isPressed ? const Offset(1, 1) : const Offset(2, 2),
                  ),
                ],
              ),
              child: Center(
                child: Text(
                  widget.topic.title,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Color(0xFF5B3A82),
                    fontWeight: FontWeight.w900,
                    fontSize: 16,
                  ),
                ),
              ),
            ),
          ),
        ),
        AnimatedSize(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOutCubic,
          child: widget.isExpanded ? _buildDescriptionBox(widget.topic.description) : const SizedBox.shrink(),
        ),
      ],
    );
  }

  Widget _buildDescriptionBox(String description) {
    return Padding(
      padding: const EdgeInsets.only(top: 8.0),
      child: FadeTransition(
        opacity: const AlwaysStoppedAnimation(1.0), // TODO: se podría animar la opacidad
        child: Container(
          decoration: BoxDecoration(
            color: const Color(0xFFF3E5F5), // Color más claro para la descripción
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFF5B3A82), width: 2.0),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 4,
                offset: const Offset(2, 2),
              ),
            ],
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
          child: Text(
            description,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Colors.black87,
              height: 1.4,
            ),
          ),
        ),
      ),
    );
  }
}
// dart
class HeaderWidget extends StatelessWidget {
  const HeaderWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 16.0),
      child: Container(
        height: 80,
        decoration: BoxDecoration(
          color: const Color(0xFF5B3A82),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white, width: 3),
          boxShadow: [
             BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            // Imagen a la izquierda con padding fijo
            Padding(
              padding: const EdgeInsets.only(left: 12.0),
              child: Image.asset(
                'assets/bombilla.png',
                height: 100,
                fit: BoxFit.contain,
              ),
            ),

            // Texto centrado ocupando el espacio restante
            const Expanded(
              child: Center(
                child: Text(
                  '¡Practica!',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 28,
                    fontWeight: FontWeight.w900,
                    shadows: [
                      Shadow(
                        color: Colors.black26,
                        offset: Offset(2, 2),
                        blurRadius: 4,
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // Espacio a la derecha para balancear visualmente (igual que el padding izquierdo)
            const SizedBox(width: 68),
          ],
        ),
      ),
    );
  }
}
