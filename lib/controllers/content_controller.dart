import 'package:flutter/material.dart';
import '../models/jerarquia/curso_model.dart';
import '../models/jerarquia/leccion_model.dart';
import '../services/data_resolver.dart';

class ContentController extends ChangeNotifier {
  List<CursoModel> cursos = [];
  int currentCursoIndex = 0;
  int currentSeccionIndex = 0;
  int currentLeccionIndex = 0;
  bool isLoading = true;
  
  Set<String> leccionesCompletadas = {}; 
  bool canMoveToNext = false; 

  int lives = 3;
  static const int maxLives = 3;

  ContentController() { _cargarDatos(); }

  void syncCompletedLessons(List<String> cloudCompleted) {
    bool changed = false;
    for (var id in cloudCompleted) {
      if (leccionesCompletadas.add(id)) {
        changed = true;
      }
    }
    if (changed) {
      notifyListeners();
    }
  }

  Future<void> _cargarDatos() async {
    isLoading = true;
    notifyListeners();
    cursos = await DataResolver.cargarTodoElCurriculo();
    isLoading = false;
    notifyListeners();
  }

  LeccionModel? getCurrentLeccion() {
    if (cursos.isEmpty) return null;
    try {
      return cursos[currentCursoIndex].temas[currentSeccionIndex].lecciones[currentLeccionIndex];
    } catch (_) { return null; }
  }

  dynamic getCurrentData() {
    return getCurrentLeccion()?.contenido;
  }

  void allowNext() { 
    canMoveToNext = true; 
    notifyListeners(); 
  }

  void loseLife() { 
    if (lives > 0) { 
      lives--; 
      notifyListeners(); 
    } 
  }

  void resetLives() { 
    lives = maxLives; 
    notifyListeners(); 
  }

  void setCurrentById(String id) {
    for (int i = 0; i < cursos.length; i++) {
      for (int j = 0; j < cursos[i].temas.length; j++) {
        for (int k = 0; k < cursos[i].temas[j].lecciones.length; k++) {
          if (cursos[i].temas[j].lecciones[k].id == id) {
            currentCursoIndex = i;
            currentSeccionIndex = j;
            currentLeccionIndex = k;
            canMoveToNext = false;
            resetLives();
            notifyListeners();
            return;
          }
        }
      }
    }
  }

  void nextLeccion() {
    if (cursos.isEmpty || !canMoveToNext) return;
    final current = getCurrentLeccion();
    if (current != null) {
      leccionesCompletadas.add(current.id);
      // Aquí podrías guardar el progreso en una DB o SharedPreferences
    }

    final cursoActual = cursos[currentCursoIndex];
    final seccionActual = cursoActual.temas[currentSeccionIndex];

    if (currentLeccionIndex < seccionActual.lecciones.length - 1) {
      currentLeccionIndex++;
    } else if (currentSeccionIndex < cursoActual.temas.length - 1) {
      currentSeccionIndex++;
      currentLeccionIndex = 0;
    } else if (currentCursoIndex < cursos.length - 1) {
      currentCursoIndex++;
      currentSeccionIndex = 0;
      currentLeccionIndex = 0;
    } else {
      // Fin del currículo
      canMoveToNext = false;
      notifyListeners();
      return;
    }
    
    canMoveToNext = false;
    resetLives();
    notifyListeners();
  }

  bool isUnlocked(String id) {
    if (cursos.isEmpty) return false;
    // La primera lección siempre está desbloqueada
    if (cursos[0].temas[0].lecciones.isNotEmpty && 
        cursos[0].temas[0].lecciones[0].id == id) return true;
    
    if (leccionesCompletadas.contains(id)) return true;
    
    // Si la anterior está completada, esta está desbloqueada
    String? prevId;
    for (var c in cursos) {
      for (var t in c.temas) {
        for (var l in t.lecciones) {
          if (l.id == id) {
            return prevId == null || leccionesCompletadas.contains(prevId);
          }
          prevId = l.id;
        }
      }
    }
    return false;
  }
}
