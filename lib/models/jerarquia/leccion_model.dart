class LeccionModel {
  final String id;
  final String titulo;
  final String tipo; // 'pregunta', 'video', 'clasificar', 'relacionar'
  final String estado;
  final dynamic contenido;

  LeccionModel({
    required this.id,
    required this.titulo,
    required this.tipo,
    required this.estado,
    required this.contenido,
  });

  factory LeccionModel.fromJson(Map<String, dynamic> json) {
    return LeccionModel(
      id: json['id']?.toString() ?? '',
      titulo: json['titulo'] ?? '',
      tipo: json['tipo'] ?? '',
      estado: json['estado'] ?? 'desbloqueado',
      contenido: json['contenido'],
    );
  }
}
