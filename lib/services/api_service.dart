// lib/services/api_service.dart

import '../models/barbero.dart';
import '../models/servicio.dart';
import '../models/turno.dart';

class ApiService {
  // --- Horarios y Configuración de la Barbería ---
  
  // Días de la semana (1 = Lunes, 7 = Domingo). 'false' significa cerrado.
  static const Map<int, bool> _workingDays = {
    DateTime.monday: true,
    DateTime.tuesday: true,
    DateTime.wednesday: true,
    DateTime.thursday: true,
    DateTime.friday: true,
    DateTime.saturday: true, // Sábados abierto
    DateTime.sunday: false,  // Domingos cerrado
  };

  // Horario de apertura y cierre
  static const int _openHour = 10; // 10:00 AM
  static const int _closeHour = 20; // 08:00 PM (20:00)
  static const int _slotIntervalMinutes = 15; // Intervalo de tiempo para mostrar opciones

  // --- Datos de Simulación (Mock-up) ---
  
  static final List<Barbero> _barberos = [
    Barbero(
      id: 'B001',
      nombre: 'Marco El Jefe',
      especialidad: 'Cortes Clásicos y Navaja',
      imagenURL: 'assets/barber_marco.jpg', 
    ),
    Barbero(
      id: 'B002',
      nombre: 'Leo El Artista',
      especialidad: 'Diseños y Fades Modernos',
      imagenURL: 'assets/barber_leo.jpg',
    ),
    Barbero(
      id: 'B003',
      nombre: 'Julián La Máquina',
      especialidad: 'Arreglo de Barba y Faciales',
      imagenURL: 'assets/barber_julian.jpg',
    ),
  ];

  static final List<Servicio> _servicios = [
    Servicio(
      id: 'S001',
      nombre: 'Corte de Pelo',
      descripcion: 'Corte clásico o moderno a máquina y tijera.',
      duracionMinutos: 45,
      precio: 1000.00,
    ),
    Servicio(
      id: 'S002',
      nombre: 'Arreglo de Barba',
      descripcion: 'Perfilado y afeitado con navaja, toalla caliente.',
      duracionMinutos: 30,
      precio: 750.00,
    ),
    Servicio(
      id: 'S003',
      nombre: 'Corte y Barba Completo',
      descripcion: 'Combinación de corte y barba con un descuento.',
      duracionMinutos: 75, 
      precio: 1600.00,
    ),
  ];

  static final List<Turno> _turnos = []; // Almacenamiento de reservas (en memoria)

  // --- Métodos de Lectura de Datos ---

  Future<List<Barbero>> getBarberos() async {
    await Future.delayed(const Duration(milliseconds: 500)); 
    return _barberos;
  }

  Future<List<Servicio>> getServicios() async {
    await Future.delayed(const Duration(milliseconds: 300));
    return _servicios;
  }

  Future<List<Turno>> getTurnos() async {
    await Future.delayed(const Duration(milliseconds: 500));
    return List.from(_turnos);
  }

  // --- Lógica de Disponibilidad (El Core) ---

  Future<List<DateTime>> getAvailableSlots({
    required Barbero barbero,
    required Servicio servicio,
    required DateTime date,
  }) async {
    // 1. Verificar si es un día de trabajo
    if (!_workingDays.containsKey(date.weekday) || !_workingDays[date.weekday]!) {
      return []; 
    }

    // 2. Obtener los turnos ya reservados para este barbero en esta fecha
    final turnosDelDia = _turnos.where((t) {
      return t.idBarbero == barbero.id &&
             t.fechaHora.year == date.year &&
             t.fechaHora.month == date.month &&
             t.fechaHora.day == date.day;
    }).toList();

    // 3. Obtener la duración del servicio
    final duracionServicio = servicio.duracionMinutos;

    // 4. Generar todos los posibles slots del día
    final List<DateTime> todosLosSlots = [];
    DateTime currentTime = DateTime(date.year, date.month, date.day, _openHour, 0);

    while (currentTime.hour < _closeHour) {
      todosLosSlots.add(currentTime);
      currentTime = currentTime.add(const Duration(minutes: _slotIntervalMinutes));
    }

    // 5. Filtrar los slots disponibles (lógica de solapamiento y límites)
    final List<DateTime> slotsDisponibles = [];

    for (var slotInicio in todosLosSlots) {
      final slotFin = slotInicio.add(Duration(minutes: duracionServicio));
      bool isConflict = false;

      // Conflicto 1: El slot termina después del horario de cierre de la barbería
      if (slotFin.hour > _closeHour || (slotFin.hour == _closeHour && slotFin.minute > 0)) {
         isConflict = true;
      }
      
      // Conflicto 2: El slot de inicio es anterior a la hora actual (solo aplica para hoy)
      if (date.day == DateTime.now().day && slotInicio.isBefore(DateTime.now())) {
          isConflict = true;
      }

      if (!isConflict) {
          // Conflicto 3: Solapamiento con turnos ya existentes
          for (var turno in turnosDelDia) {
            // Buscamos la duración del servicio ya reservado
            final turnoServicio = _servicios.firstWhere((s) => s.id == turno.idServicio);
            final turnoFin = turno.fechaHora.add(Duration(minutes: turnoServicio.duracionMinutos));

            // Solapamiento si: el nuevo slot empieza antes de que termine el turno existente
            // Y el nuevo slot termina después de que empiece el turno existente
            if (slotInicio.isBefore(turnoFin) && slotFin.isAfter(turno.fechaHora)) {
              isConflict = true;
              break;
            }
          }
      }

      if (!isConflict) {
        slotsDisponibles.add(slotInicio);
      }
    }

    return slotsDisponibles;
  }

  // --- Lógica de Reserva (Creación del Turno) ---

  Future<bool> reservarTurno({
    required String idBarbero,
    required String idServicio,
    required DateTime fechaHora,
    required String nombreCliente,
    required String telefonoCliente,
  }) async {
    // Nota: La lógica de prevención de conflicto ya debería haber sido verificada
    // por el método getAvailableSlots, pero la repetimos como seguridad final.
    
    final servicio = _servicios.firstWhere((s) => s.id == idServicio);
    final duracion = Duration(minutes: servicio.duracionMinutos);
    final horaFin = fechaHora.add(duracion);

    final conflicto = _turnos.any((turnoExistente) {
      if (turnoExistente.idBarbero != idBarbero) return false;
      
      final servicioExistente = _servicios.firstWhere((s) => s.id == turnoExistente.idServicio);
      final finExistente = turnoExistente.fechaHora.add(Duration(minutes: servicioExistente.duracionMinutos));

      // Comprueba si el nuevo turno se solapa con el existente
      return fechaHora.isBefore(finExistente) && horaFin.isAfter(turnoExistente.fechaHora);
    });

    if (conflicto) {
      // Si por alguna razón la verificación falló o hubo un intento simultáneo
      return false; 
    }

    // Creación y Almacenamiento
    final nuevoTurno = Turno(
      id: DateTime.now().millisecondsSinceEpoch.toString(), 
      idBarbero: idBarbero,
      idServicio: idServicio,
      fechaHora: fechaHora,
      nombreCliente: nombreCliente,
      telefonoCliente: telefonoCliente,
    );

    _turnos.add(nuevoTurno);
    
    // Simular un retraso en la base de datos
    await Future.delayed(const Duration(milliseconds: 700));

    return true; 
  }

  Future<bool> cancelarTurno(String idTurno) async {
    await Future.delayed(const Duration(milliseconds: 500)); // Simula latencia
    
    // Encuentra el índice del turno a eliminar
    final index = _turnos.indexWhere((turno) => turno.id == idTurno);

    if (index != -1) {
      _turnos.removeAt(index);
      return true; // Cancelación exitosa
    } else {
      return false; // Turno no encontrado
    }
  }
}

