class PreguntaModel {
  final int id; // Número de la pregunta
  final String pregunta; // Instrucciones o pregunta
  final List<String> opciones; // Opciones en lista
  final String respuestaCorrectaTexto;
  final String retroalimentacion;

  PreguntaModel({
    required this.id,
    required this.pregunta,
    required this.opciones,
    required this.respuestaCorrectaTexto,
    required this.retroalimentacion,
  });

  factory PreguntaModel.fromJson(Map<String, dynamic> json) {
    return PreguntaModel(
      id: json['Id'] ?? 0,
      pregunta: json['Pregunta']?.toString() ?? '',
      // Juntamos las 4 columnas del Excel en una sola lista para Flutter
      opciones: [
        json['Opcion_1']?.toString() ?? '',
        json['Opcion_2']?.toString() ?? '',
        json['Opcion_3']?.toString() ?? '',
        json['Opcion_4']?.toString() ?? '',
      ],
      respuestaCorrectaTexto:
          json['Respuesta_Correcta_Texto']?.toString() ?? '',
      retroalimentacion: json['Retroalimentacion']?.toString() ?? '',
    );
  }

  int get respuestaCorrectaIndex {
    return opciones.indexOf(respuestaCorrectaTexto);
  }
}
