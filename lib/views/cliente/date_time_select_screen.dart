import 'package:flutter/material.dart';
import '../../models/barbero.dart';
import '../../models/servicio.dart';
import '../../services/api_service.dart';
import 'client_details_screen.dart'; // El siguiente paso

class DateTimeSelectScreen extends StatefulWidget {
  final Barbero barbero;
  final Servicio servicio;

  const DateTimeSelectScreen({
    super.key,
    required this.barbero,
    required this.servicio,
  });

  @override
  State<DateTimeSelectScreen> createState() => _DateTimeSelectScreenState();
}

class _DateTimeSelectScreenState extends State<DateTimeSelectScreen> {
  DateTime _selectedDate = DateTime.now();
  DateTime? _selectedTimeSlot;
  late Future<List<DateTime>> _availableSlotsFuture;

  @override
  void initState() {
    super.initState();
    // Carga inicial para la fecha de hoy
    _loadAvailableSlots(_selectedDate);
  }

  void _loadAvailableSlots(DateTime date) {
    setState(() {
      _selectedDate = date;
      _selectedTimeSlot = null; // Reiniciar la selección de hora
      _availableSlotsFuture = ApiService().getAvailableSlots(
        barbero: widget.barbero,
        servicio: widget.servicio,
        date: date,
      );
    });
  }

  // Abre el selector de calendario
  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now(), // No se puede reservar en el pasado
      lastDate: DateTime.now().add(const Duration(days: 30)), // 30 días de antelación
      builder: (context, child) {
        return Theme(
          data: ThemeData.dark().copyWith(
            colorScheme: ColorScheme.dark(
              primary: Theme.of(context).colorScheme.secondary, // Dorado para el acento
              onPrimary: Colors.black, // Texto negro en dorado
              surface: const Color(0xFF2C2C2C), // Fondo de calendario
              onSurface: Colors.white,
            ),
            dialogBackgroundColor: const Color(0xFF212121),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != _selectedDate) {
      _loadAvailableSlots(picked);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('3. Fecha y Hora'),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Sección de información y selección de fecha
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Barbero: ${widget.barbero.nombre} | Servicio: ${widget.servicio.nombre}',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.secondary,
                  ),
                ),
                const SizedBox(height: 15),
                Text(
                  'Día seleccionado:',
                  style: Theme.of(context).textTheme.titleSmall,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    ElevatedButton.icon(
                      onPressed: () => _selectDate(context),
                      icon: const Icon(Icons.calendar_month),
                      label: const Text('Cambiar Fecha'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF2C2C2C),
                        foregroundColor: Theme.of(context).colorScheme.secondary,
                      ),
                    ),
                  ],
                ),
                const Divider(height: 30, color: Colors.white10),
                Text(
                  'Horarios disponibles (Duración: ${widget.servicio.duracionMinutos} min):',
                  style: Theme.of(context).textTheme.titleSmall,
                ),
              ],
            ),
          ),

          // Sección de slots de tiempo
          Expanded(
            child: FutureBuilder<List<DateTime>>(
              future: _availableSlotsFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator(color: Color(0xFFD4AF37)));
                } else if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}', style: const TextStyle(color: Colors.red)));
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return Center(child: Text(
                    'No hay turnos disponibles para este día o barbero.',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.titleMedium,
                  ));
                }

                final List<DateTime> availableSlots = snapshot.data!;

                return GridView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 4,
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 10,
                    childAspectRatio: 2.5,
                  ),
                  itemCount: availableSlots.length,
                  itemBuilder: (context, index) {
                    final slot = availableSlots[index];
                    final isSelected = _selectedTimeSlot == slot;
                    
                    // Formato HH:MM
                    final timeText = '${slot.hour.toString().padLeft(2, '0')}:${slot.minute.toString().padLeft(2, '0')}';

                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          _selectedTimeSlot = slot;
                        });
                      },
                      child: Container(
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: isSelected ? Theme.of(context).colorScheme.secondary : const Color(0xFF2C2C2C),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: Theme.of(context).colorScheme.secondary,
                            width: isSelected ? 0 : 1,
                          ),
                        ),
                        child: Text(
                          timeText,
                          style: TextStyle(
                            color: isSelected ? Colors.black : Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),

          // Botón de Continuar
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: ElevatedButton(
              onPressed: _selectedTimeSlot == null
                  ? null
                  : () {
                      // NAVEGACIÓN: Ir a la confirmación de datos
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ClientDetailsScreen(
                            barbero: widget.barbero,
                            servicio: widget.servicio,
                            fechaHora: _selectedTimeSlot!, // El DateTime completo
                          ),
                        ),
                      );
                    },
              child: const Text('Continuar a Mis Datos'),
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 50),
              ),
            ),
          ),
        ],
      ),
    );
  }
}