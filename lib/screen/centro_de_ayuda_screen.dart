import 'package:flutter/material.dart';

// Model for a help topic
class HelpTopic {
  final String question;
  final String answer;

  const HelpTopic({required this.question, required this.answer});
}

// Screen widget
class CentroDeAyudaScreen extends StatefulWidget {
  const CentroDeAyudaScreen({super.key});

  @override
  State<CentroDeAyudaScreen> createState() => _CentroDeAyudaScreenState();
}

class _CentroDeAyudaScreenState extends State<CentroDeAyudaScreen> {
  String? _selectedTopicId;

  final List<HelpTopic> _helpTopics = [
    const HelpTopic(
      question: '¿Qué es la racha y cómo se mantiene?',
      answer:
          'La racha mide los días consecutivos en los que has completado al menos una lección o ejercicio. Para mantenerla, debes completar una actividad diaria antes de que termine el día.',
    ),
    const HelpTopic(
      question: '¿Que es la estadística de progreso?',
      answer:
          'Tu estadística no solo cuenta las lecciones terminadas, sino que se basa en la cantidad de temas que has dominado. Se calcula como el porcentaje de Habilidades de Álgebra que has llevado al nivel de Dominio.',
    ),
    const HelpTopic(
      question: '¿Qué cuenta exactamente como una "Lección Terminada"?',
      answer:
          'Una Lección Terminada es cualquier nivel de aprendizaje que hayas completado desde la introducción hasta la prueba de salida. Si solo ves el video o resuelves una parte de los ejercicios, no cuenta hasta que el sistema lo marque como 100% completado.',
    ),
    const HelpTopic(
      question: '¿Mi Racha afecta mi estadística de Progreso?',
      answer:
          'No, la racha es una medida de Consistencia (días consecutivos de estudio), no de habilidad. Una racha alta no mejora tus estadísticas, pero si indica un hábito de estudio, lo cual es fundamental para el éxito del Álgebra.',
    ),
    const HelpTopic(
      question: '¿Para qué se utilizan las Doracoins y dónde puedo gastarlas?',
      answer:
          'Las Doracoins son la moneda de la aplicación, obtenida como recompensa principal cada vez que completas y dominas un tema o ejercicios (un Nivel) de Álgebra y las puedes gastar en la tienda de artículos para personalizar a Dora de la manera que tu quieras.',
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
      backgroundColor: const Color(0xFF7B5BA3), // Consistent background color
      body: SafeArea(
        child: Column(
          children: [
            const _Header(),
            Expanded(
              child: ListView.builder(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
                itemCount: _helpTopics.length + 1, // +1 for the contact card
                itemBuilder: (context, index) {
                  if (index < _helpTopics.length) {
                    final topic = _helpTopics[index];
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12.0),
                      child: _HelpTopicCard(
                        topic: topic,
                        isExpanded: _selectedTopicId == topic.question,
                        onTap: () => _handleTap(topic.question),
                      ),
                    );
                  } else {
                    return const _ContactCard();
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(4, 16, 16, 0),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white, size: 30),
            onPressed: () => Navigator.of(context).pop(),
          ),
          const Expanded(
            child: Text(
              'Centro de ayuda',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
          const SizedBox(width: 48), // To balance the IconButton
        ],
      ),
    );
  }
}

class _HelpTopicCard extends StatelessWidget {
  final HelpTopic topic;
  final bool isExpanded;
  final VoidCallback onTap;

  const _HelpTopicCard({
    required this.topic,
    required this.isExpanded,
    required this.onTap,
  });

  @override
Widget build(BuildContext context) {
    // This is adapted from DrawnTopicCard in seleccionar_practica_screen.dart
    return Column(
      children: [
        GestureDetector(
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            constraints: const BoxConstraints(minHeight: 60),
            decoration: BoxDecoration(
              color:
                  const Color(0xFFE8CCDC), // Light pink/purple color from image
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                  color: const Color(0xFF5B3A82),
                  width: 2.5), // Dark purple border
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.15),
                  blurRadius: 4,
                  offset: const Offset(2, 2),
                ),
              ],
            ),
            child: Center(
              child: Text(
                topic.question,
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
        AnimatedSize(
          duration: const Duration(milliseconds: 280),
          curve: Curves.easeInOut,
          child: isExpanded
              ? _buildDescriptionBox(topic.answer)
              : const SizedBox.shrink(),
        ),
      ],
    );
  }

  Widget _buildDescriptionBox(String description) {
    // This is also adapted from DrawnTopicCard
    return Padding(
      padding: const EdgeInsets.only(top: 8.0),
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFFE8CCDC),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFF5B3A82), width: 2.5),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.15),
              blurRadius: 4,
              offset: const Offset(2, 2),
            ),
          ],
        ),
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
        width: double.infinity,
        child: Text(
          description,
          textAlign: TextAlign.start,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Colors.black87,
            height: 1.4,
          ),
        ),
      ),
    );
  }
}

class _ContactCard extends StatelessWidget {
  const _ContactCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 16, bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF5B3A82), // Dark purple from the image
        borderRadius: BorderRadius.circular(12),
      ),
      child: const Column(
        children: [
          Text(
            'Contacto:',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'doralacalculadora@gmail.com',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}