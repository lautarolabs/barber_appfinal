class Barbero {
  final String id;
  final String nombre;
  final String especialidad; // Ej: "Especialista en degradados"
  final String imagenURL; // Ruta de la imagen del barbero
  final bool isAvailable; // Para saber si está activo

  Barbero({
    required this.id,
    required this.nombre,
    this.especialidad = 'Barbero Profesional',
    required this.imagenURL,
    this.isAvailable = true,
  });

  // Método opcional para facilitar el uso en el futuro (e.g., de una API)
  factory Barbero.fromJson(Map<String, dynamic> json) {
    return Barbero(
      id: json['id'] as String,
      nombre: json['nombre'] as String,
      especialidad: json['especialidad'] as String? ?? 'Barbero Profesional',
      imagenURL: json['imagenURL'] as String,
      isAvailable: json['isAvailable'] as bool? ?? true,
    );
  }
}