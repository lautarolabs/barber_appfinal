// lib/views/admin/admin_dashboard.dart

import 'package:flutter/material.dart';
import '../../models/turno.dart';
import '../../services/api_service.dart';
import '../../models/barbero.dart'; // Asegúrate de importar Barbero y Servicio si no están
import '../../models/servicio.dart';

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({super.key});

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  late Future<List<Turno>> _turnosFuture;

  @override
  void initState() {
    super.initState();
    _loadTurnos();
  }

  // Recarga los turnos y refresca la vista
  void _loadTurnos() {
    setState(() {
      _turnosFuture = ApiService().getTurnos();
    });
  }

  // Funciones corregidas para devolver Future<String>
  Future<String> _getBarberoName(String id) async {
    try {
      final barberos = await ApiService().getBarberos();
      return barberos.firstWhere((b) => b.id == id).nombre;
    } catch (e) {
      return 'Barbero Desconocido';
    }
  }

  Future<String> _getServiceName(String id) async {
    try {
      final servicios = await ApiService().getServicios();
      return servicios.firstWhere((s) => s.id == id).nombre;
    } catch (e) {
      return 'Servicio Desconocido';
    }
  }
  
  // Función para cerrar sesión (navega al inicio)
  void _logout() {
    Navigator.popUntil(context, (route) => route.isFirst);
  }

  // Muestra un diálogo de confirmación antes de cancelar
  Future<void> _showCancelConfirmation(Turno turno) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF212121), // Fondo oscuro para el diálogo
        title: const Text('Confirmar Cancelación', style: TextStyle(color: Color(0xFFD4AF37))),
        content: Text(
            '¿Está seguro de que desea cancelar el turno de ${turno.nombreCliente} con ${turno.formatoHora} del ${turno.formatoFecha}?',
            style: const TextStyle(color: Colors.white70)),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false), // No cancelar
            child: const Text('No, Mantener', style: TextStyle(color: Colors.white70)),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true), // Sí, cancelar
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Sí, Cancelar'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      final success = await ApiService().cancelarTurno(turno.id);
      if (mounted) {
        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Turno cancelado con éxito.'), backgroundColor: Colors.green),
          );
          _loadTurnos(); // Recarga la lista para reflejar el cambio
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Error: No se pudo cancelar el turno.'), backgroundColor: Colors.red),
          );
        }
      }
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Panel de Turnos (Admin)'),
        automaticallyImplyLeading: false, // No permitir volver atrás desde aquí
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadTurnos,
            tooltip: 'Recargar Turnos',
          ),
           IconButton(
            icon: const Icon(Icons.exit_to_app),
            onPressed: _logout,
            tooltip: 'Cerrar Sesión',
          ),
        ],
      ),
      body: FutureBuilder<List<Turno>>(
        future: _turnosFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: Color(0xFFD4AF37)));
          } else if (snapshot.hasError) {
            return Center(child: Text('Error al cargar turnos: ${snapshot.error}', style: const TextStyle(color: Colors.red)));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text(
              '¡Excelente! No hay turnos reservados por ahora.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 18, color: Colors.white70),
            ));
          }

          // Ordenar los turnos por fecha y hora (más próximos primero)
          final List<Turno> turnos = snapshot.data!;
          turnos.sort((a, b) => a.fechaHora.compareTo(b.fechaHora));

          return ListView.builder(
            padding: const EdgeInsets.all(16.0),
            itemCount: turnos.length,
            itemBuilder: (context, index) {
              final turno = turnos[index];
              return Card(
                color: const Color(0xFF2C2C2C),
                margin: const EdgeInsets.only(bottom: 15.0),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                elevation: 4,
                child: Padding(
                  padding: const EdgeInsets.all(15.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Encabezado de la hora y fecha
                      Text(
                        '${turno.formatoHora} - ${turno.formatoFecha}',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              color: Theme.of(context).colorScheme.secondary,
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      const Divider(height: 20, color: Colors.white10),

                      // Detalles del Barbero
                      FutureBuilder<String>(
                        future: _getBarberoName(turno.idBarbero),
                        builder: (context, nameSnapshot) => Text(
                          'Barbero: ${nameSnapshot.data ?? 'Cargando...'}',
                          style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: Colors.white),
                        ),
                      ),
                      const SizedBox(height: 5),

                      // Detalles del Servicio
                      FutureBuilder<String>(
                        future: _getServiceName(turno.idServicio),
                        builder: (context, serviceSnapshot) => Text(
                          'Servicio: ${serviceSnapshot.data ?? 'Cargando...'}',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.white70),
                        ),
                      ),
                      const SizedBox(height: 10),
                      
                      // Detalles del Cliente
                      Text(
                        'Cliente: ${turno.nombreCliente}',
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: Colors.white),
                      ),
                      Text(
                        'Contacto: ${turno.telefonoCliente}',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.white70),
                      ),
                      
                      const SizedBox(height: 20),
                      
                      // Botón de Acción (Cancelar)
                      Align(
                        alignment: Alignment.centerRight,
                        child: ElevatedButton.icon(
                          onPressed: () => _showCancelConfirmation(turno), // Llamada a la función de confirmación
                          icon: const Icon(Icons.delete_forever, size: 20),
                          label: const Text('Cancelar Turno', style: TextStyle(fontSize: 16)),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red.shade700, // Rojo más oscuro para cancelar
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}