import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../controllers/content_controller.dart';
import '../widgets/pregunta_widget.dart';
import '../widgets/video_widget.dart';
import '../widgets/clasificar_widget.dart';
import '../widgets/relacionar_widget.dart';
import '../widgets/quiz_widget.dart';

class DynamicContentScreen extends StatelessWidget {
  const DynamicContentScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<ContentController>();
    final leccion = controller.getCurrentLeccion();
    final data = controller.getCurrentData();

    if (leccion == null || data == null) {
      return Scaffold(
        appBar: AppBar(title: const Text("Contenido")),
        body: const Center(child: Text("Sin contenido disponible")),
      );
    }

    // Auto-unlock for videos to allow moving forward
    if (leccion.tipo == 'video' && !controller.canMoveToNext) {
      Future.microtask(() => controller.allowNext());
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(leccion.titulo),
        backgroundColor: const Color(0xFF7B5BA3),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF7B5BA3), Color(0xFF5B3A82)],
          ),
        ),
        child: _buildContent(leccion.tipo, data),
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(20.0),
        decoration: const BoxDecoration(
          color: Colors.white,
          boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10, offset: Offset(0, -5))],
        ),
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: controller.canMoveToNext ? const Color(0xFF7B5BA3) : Colors.grey,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 18),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            elevation: controller.canMoveToNext ? 5 : 0,
          ),
          onPressed: controller.canMoveToNext ? () => controller.nextLeccion() : null,
          child: Text(
            controller.canMoveToNext ? "CONTINUAR" : "¡TERMINA EL RETO PARA AVANZAR!",
            style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 18, letterSpacing: 1.2),
          ),
        ),
      ),
    );
  }

  Widget _buildContent(String tipo, dynamic data) {
    switch (tipo) {
      case 'quiz':
        return QuizWidget(questions: data as List<dynamic>);
      case 'pregunta':
        return PreguntaWidget(data: data as Map<String, dynamic>);
      case 'video':
        return VideoWidget(data: data as Map<String, dynamic>);
      case 'clasificar':
        return ClasificarWidget(data: data as Map<String, dynamic>);
      case 'relacionar':
        return RelacionarWidget(data: data as Map<String, dynamic>);
      default:
        return Center(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Text("El tipo de contenido '$tipo' se está preparando...", 
                textAlign: TextAlign.center, 
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          ),
        );
    }
  }
}
