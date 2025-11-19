class Servicio {
  final String id;
  final String nombre;
  final String descripcion;
  final int duracionMinutos; // Importante para calcular el slot de tiempo
  final double precio;

  Servicio({
    required this.id,
    required this.nombre,
    required this.descripcion,
    required this.duracionMinutos,
    required this.precio,
  });

  // Método para formato de precio
  String get precioFormato => '\$$precio';

  factory Servicio.fromJson(Map<String, dynamic> json) {
    return Servicio(
      id: json['id'] as String,
      nombre: json['nombre'] as String,
      descripcion: json['descripcion'] as String,
      duracionMinutos: json['duracionMinutos'] as int,
      precio: json['precio'] as double,
    );
  }
}