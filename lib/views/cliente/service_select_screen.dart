import 'package:flutter/material.dart';
import '../../models/barbero.dart';
import '../../models/servicio.dart';
import '../../services/api_service.dart';
import 'date_time_select_screen.dart'; // El siguiente paso

class ServiceSelectScreen extends StatefulWidget {
  final Barbero barbero;

  const ServiceSelectScreen({super.key, required this.barbero});

  @override
  State<ServiceSelectScreen> createState() => _ServiceSelectScreenState();
}

class _ServiceSelectScreenState extends State<ServiceSelectScreen> {
  late Future<List<Servicio>> _serviciosFuture;
  Servicio? _servicioSeleccionado;

  @override
  void initState() {
    super.initState();
    // Carga los servicios disponibles al inicio
    _serviciosFuture = ApiService().getServicios();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('2. Elige el Servicio'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(40.0),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              'Estás reservando con: ${widget.barbero.nombre}',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: Theme.of(context).colorScheme.secondary,
                fontWeight: FontWeight.normal,
              ),
            ),
          ),
        ),
      ),
      body: FutureBuilder<List<Servicio>>(
        future: _serviciosFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: Color(0xFFD4AF37)));
          } else if (snapshot.hasError) {
            return Center(child: Text('Error al cargar servicios: ${snapshot.error}', style: const TextStyle(color: Colors.red)));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No hay servicios disponibles.'));
          }

          final List<Servicio> servicios = snapshot.data!;

          return Column(
            children: [
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.all(16.0),
                  itemCount: servicios.length,
                  itemBuilder: (context, index) {
                    final servicio = servicios[index];
                    
                    // Tarjeta de Servicio
                    return _ServiceCard(
                      servicio: servicio,
                      isSelected: _servicioSeleccionado?.id == servicio.id,
                      onTap: () {
                        setState(() {
                          _servicioSeleccionado = servicio;
                        });
                      },
                    );
                  },
                ),
              ),
              // Botón de Continuar
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: ElevatedButton(
                  onPressed: _servicioSeleccionado == null
                      ? null // Deshabilitado si no hay selección
                      : () {
                          // NAVEGACIÓN: Ir a la selección de fecha/hora
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => DateTimeSelectScreen(
                                barbero: widget.barbero,
                                servicio: _servicioSeleccionado!,
                              ),
                            ),
                          );
                        },
                  child: const Text('Continuar a Fecha y Hora'),
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 50),
                    backgroundColor: _servicioSeleccionado == null ? Colors.grey : Theme.of(context).colorScheme.secondary,
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

// --- Componente Reutilizable: Tarjeta de Servicio ---

class _ServiceCard extends StatelessWidget {
  final Servicio servicio;
  final bool isSelected;
  final VoidCallback onTap;

  const _ServiceCard({
    required this.servicio,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: isSelected ? const Color(0xFFD4AF37).withOpacity(0.2) : const Color(0xFF2C2C2C), // Dorado tenue si seleccionado
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8.0),
        side: isSelected
            ? const BorderSide(color: Color(0xFFD4AF37), width: 2.5) // Borde dorado
            : BorderSide.none,
      ),
      margin: const EdgeInsets.only(bottom: 15.0),
      child: ListTile(
        onTap: onTap,
        title: Text(
          servicio.nombre,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            color: isSelected ? const Color(0xFFD4AF37) : Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(
              servicio.descripcion,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.white70),
            ),
            const SizedBox(height: 4),
            Text(
              'Duración: ${servicio.duracionMinutos} minutos',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(fontStyle: FontStyle.italic),
            ),
          ],
        ),
        trailing: Text(
          servicio.precioFormato,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            color: isSelected ? const Color(0xFFD4AF37) : Colors.white,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
    );
  }
}