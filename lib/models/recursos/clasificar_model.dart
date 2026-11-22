class ClasificarModel {
  final int id;
  final String instruccion;
  final List<String> categorias;
  final List<String> items;
  final Map<String, List<String>> clasificacionCorrecta;
  final String retroalimentacion;

  ClasificarModel({
    required this.id,
    required this.instruccion,
    required this.categorias,
    required this.items,
    required this.clasificacionCorrecta,
    required this.retroalimentacion,
  });

  factory ClasificarModel.fromJson(Map<String, dynamic> json) {
    List<String> listaCategorias = (json['Categorias'] as String).split('; ');
    List<String> listaItems = (json['Items'] as String).split('; ');

    Map<String, List<String>> mapaClasificacion = {};
    String clasificacionRaw = json['Clasificacion_Correcta'] ?? '';

    if (clasificacionRaw.isNotEmpty) {
      List<String> grupos = clasificacionRaw.split('; ');
      for (var grupo in grupos) {
        List<String> partes = grupo.split(': ');
        if (partes.length == 2) {
          String nombreCategoria = partes[0].trim();
          List<String> elementos =
              partes[1].split(', ').map((e) => e.trim()).toList();

          mapaClasificacion[nombreCategoria] = elementos;
        }
      }
    }

    return ClasificarModel(
      id: json['Id'] ?? 0,
      instruccion: json['Instruccion'] ?? '',
      categorias: listaCategorias,
      items: listaItems,
      clasificacionCorrecta: mapaClasificacion,
      retroalimentacion: json['Retroalimentacion'] ?? '',
    );
  }
}
