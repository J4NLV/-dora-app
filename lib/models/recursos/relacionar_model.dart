class RelacionarModel {
  final int id;
  final String instruccion;
  final List<String> columnaIzquierda;
  final List<String> columnaDerecha;
  final Map<String, String> paresCorrectos;
  final String retroalimentacion;

  RelacionarModel({
    required this.id,
    required this.instruccion,
    required this.columnaIzquierda,
    required this.columnaDerecha,
    required this.paresCorrectos,
    required this.retroalimentacion,
  });

  factory RelacionarModel.fromJson(Map<String, dynamic> json) {
    List<String> colIzq = (json['Columna_Izquierda'] as String).split('; ');
    List<String> colDer = (json['Columna_Derecha'] as String).split('; ');

    Map<String, String> mapaPares = {};
    String paresRaw = json['Pares_Correctos'] ?? '';

    if (paresRaw.isNotEmpty) {
      List<String> listaPares = paresRaw.split('; ');
      for (var par in listaPares) {
        List<String> partes = par.split(':');
        if (partes.length == 2) {
          mapaPares[partes[0].trim()] = partes[1].trim();
        }
      }
    }

    return RelacionarModel(
      id: json['Id'] ?? 0,
      instruccion: json['Instruccion'] ?? '',
      columnaIzquierda: colIzq,
      columnaDerecha: colDer,
      paresCorrectos: mapaPares,
      retroalimentacion: json['Retroalimentacion'] ?? '',
    );
  }
}
