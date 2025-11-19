class Turno {
  final String id;
  final String idBarbero;
  final String idServicio;
  final DateTime fechaHora; // La fecha y hora exacta del turno
  final String nombreCliente;
  final String telefonoCliente; // Contacto del cliente

  Turno({
    required this.id,
    required this.idBarbero,
    required this.idServicio,
    required this.fechaHora,
    required this.nombreCliente,
    required this.telefonoCliente,
  });

  // Para el administrador: facilita ver la información
  String get formatoFecha => '${fechaHora.day}/${fechaHora.month}/${fechaHora.year}';
  String get formatoHora => '${fechaHora.hour.toString().padLeft(2, '0')}:${fechaHora.minute.toString().padLeft(2, '0')}';

  // Nota: Para un entorno real, necesitarías métodos to/from JSON.
}