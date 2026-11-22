class VideoModel {
  final int id;
  final String tema; // Columna 'Tema'
  final String explicacion; // Columna 'Información'; cuadro explicativo
  final String urlYoutube; // URL del video

  VideoModel({
    required this.id,
    required this.tema,
    required this.explicacion,
    required this.urlYoutube,
  });

  factory VideoModel.fromJson(Map<String, dynamic> json) {
    return VideoModel(
      id: json['Id'] ?? 0, // Busca la columna 'Id'
      tema: json['Tema'] ?? '', // Busca la columna 'Tema'
      explicacion: json['Explicación'] ?? '', // Ojo si tiene acento en el Excel
      urlYoutube: json['Url_Youtube'] ?? '',
    );
  }
}
