import 'dart:convert';
import 'package:flutter/services.dart';
import '../models/jerarquia/curso_model.dart';
import '../models/jerarquia/seccion_model.dart';
import '../models/jerarquia/leccion_model.dart';

class DataResolver {
  static Future<List<CursoModel>> cargarTodoElCurriculo() async {
    try {
      final String jsonString = await rootBundle.loadString('assets/data/contenidos.json');
      final Map<String, dynamic> jsonData = json.decode(jsonString);
      final List<dynamic> estructuraRaw = jsonData['Estructura_Curriculo'] ?? [];

      List<CursoModel> curriculum = [];
      String? currentModuloName;
      String? currentSeccionName;
      CursoModel? currentCurso;
      SeccionModel? currentSeccion;
      
      List<dynamic> preguntasBuffer = [];

      // Función para agrupar las preguntas acumuladas en un único Quiz
      void flushPreguntas() {
        if (preguntasBuffer.isNotEmpty && currentSeccion != null) {
          // Generamos un ID determinista basado en la posición para que no cambie al recargar
          final String quizId = "quiz_${currentModuloName}_${currentSeccionName}_pos_${currentSeccion.lecciones.length}".replaceAll(' ', '_');
          
          currentSeccion.lecciones.add(LeccionModel(
            id: quizId,
            titulo: currentModuloName == "Diagnóstico" ? currentSeccionName! : "Reto: $currentSeccionName",
            tipo: "quiz",
            estado: "bloqueado",
            contenido: List.from(preguntasBuffer),
          ));
          preguntasBuffer.clear();
        }
      }

      for (var item in estructuraRaw) {
        String modulo = item['Modulo_Titulo'] ?? 'Otros';
        String seccion = item['Seccion_Titulo'] ?? modulo;

        // Detectar cambio de Módulo
        if (modulo != currentModuloName) {
          flushPreguntas();
          currentModuloName = modulo;
          currentCurso = CursoModel(titulo: modulo, temas: []);
          curriculum.add(currentCurso);
          currentSeccionName = null;
        }

        // Detectar cambio de Sección
        if (seccion != currentSeccionName) {
          flushPreguntas();
          currentSeccionName = seccion;
          currentSeccion = SeccionModel(titulo: seccion, lecciones: []);
          currentCurso?.temas.add(currentSeccion);
        }

        String tipo = item['Tipo_Leccion'];
        int recursoId = item['Recurso_ID'];

        if (tipo == 'pregunta') {
          // Acumular preguntas consecutivas
          var qList = jsonData['Recursos_Preguntas'] as List;
          var qData = qList.firstWhere((q) => q['Id'] == recursoId, orElse: () => null);
          if (qData != null) preguntasBuffer.add(qData);
        } else {
          // Si viene un Video/Clasificar/Relacionar, cerramos el Quiz pendiente
          flushPreguntas();
          
          String listaKey = 'Recursos_Video';
          if (tipo == 'clasificar') listaKey = 'Recursos_Clasificar';
          else if (tipo == 'relacionar') listaKey = 'Recursos_Relacionar';
          
          var lista = jsonData[listaKey] ?? [];
          var contenido = (lista as List).firstWhere((c) => c['Id'] == recursoId, orElse: () => null);

          if (contenido != null) {
            currentSeccion?.lecciones.add(LeccionModel(
              id: "${modulo}_${seccion}_${recursoId}_$tipo".replaceAll(' ', '_'),
              titulo: item['Leccion_Titulo'] ?? seccion,
              tipo: tipo,
              estado: 'bloqueado',
              contenido: contenido,
            ));
          }
        }
      }
      
      // No olvidar las preguntas al final del JSON
      flushPreguntas();

      return curriculum;
    } catch (e) {
      print("Error en DataResolver: $e");
      return [];
    }
  }
}
