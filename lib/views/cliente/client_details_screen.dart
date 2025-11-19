import 'package:flutter/material.dart';
import '../../models/barbero.dart';
import '../../models/servicio.dart';
import '../../services/api_service.dart';
import 'reservation_success_screen.dart'; // El paso final

class ClientDetailsScreen extends StatefulWidget {
  final Barbero barbero;
  final Servicio servicio;
  final DateTime fechaHora;

  const ClientDetailsScreen({
    super.key,
    required this.barbero,
    required this.servicio,
    required this.fechaHora,
  });

  @override
  State<ClientDetailsScreen> createState() => _ClientDetailsScreenState();
}

class _ClientDetailsScreenState extends State<ClientDetailsScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  bool _isLoading = false;

  // Formato para mostrar la fecha y hora seleccionadas
  String get _formattedDateTime {
    final date = widget.fechaHora;
    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');
    final year = date.year;
    final hour = date.hour.toString().padLeft(2, '0');
    final minute = date.minute.toString().padLeft(2, '0');
    return '$day/$month/$year a las $hour:$minute hs';
  }

  Future<void> _confirmReservation() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    final success = await ApiService().reservarTurno(
      idBarbero: widget.barbero.id,
      idServicio: widget.servicio.id,
      fechaHora: widget.fechaHora,
      nombreCliente: _nameController.text.trim(),
      telefonoCliente: _phoneController.text.trim(),
    );

    // Detener el indicador de carga
    if (mounted) {
      setState(() {
        _isLoading = false;
      });
    }

    if (success && mounted) {
      // Éxito: Navegar a la pantalla de confirmación
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
          builder: (context) => ReservationSuccessScreen(
            barbero: widget.barbero,
            servicio: widget.servicio,
            fechaHora: widget.fechaHora,
            nombreCliente: _nameController.text.trim(),
          ),
        ),
        (Route<dynamic> route) => route.isFirst, // Elimina todas las pantallas anteriores
      );
    } else if (mounted) {
      // Fallo: Mostrar un error (ej. por conflicto de última hora)
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Error: El turno ya no está disponible o hubo un conflicto.'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('4. Datos y Confirmación'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Resumen de la reserva
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.secondary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Theme.of(context).colorScheme.secondary),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Tu Reserva',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: Theme.of(context).colorScheme.secondary,
                      ),
                    ),
                    const Divider(color: Colors.white10),
                    _buildSummaryRow(
                        context, 'Barbero', widget.barbero.nombre),
                    _buildSummaryRow(
                        context, 'Servicio', widget.servicio.nombre),
                    _buildSummaryRow(
                        context, 'Duración', '${widget.servicio.duracionMinutos} min'),
                    _buildSummaryRow(
                        context, 'Costo', widget.servicio.precioFormato),
                    _buildSummaryRow(
                        context, 'Día y Hora', _formattedDateTime, isImportant: true),
                  ],
                ),
              ),
              const SizedBox(height: 30),

              // Formulario de datos del cliente
              Text(
                'Datos del Cliente',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 15),

              // Campo Nombre
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: 'Nombre Completo',
                  border: const OutlineInputBorder(),
                  filled: true,
                  fillColor: const Color(0xFF2C2C2C),
                  labelStyle: const TextStyle(color: Colors.white70),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor, ingresa tu nombre.';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),

              // Campo Teléfono
              TextFormField(
                controller: _phoneController,
                keyboardType: TextInputType.phone,
                decoration: InputDecoration(
                  labelText: 'Teléfono (WhatsApp)',
                  hintText: 'Ej: 1123456789',
                  border: const OutlineInputBorder(),
                  filled: true,
                  fillColor: const Color(0xFF2C2C2C),
                  labelStyle: const TextStyle(color: Colors.white70),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor, ingresa un número de contacto.';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 40),

              // Botón Final de Confirmación
              _isLoading
                  ? const Center(child: CircularProgressIndicator(color: Color(0xFFD4AF37)))
                  : ElevatedButton(
                      onPressed: _confirmReservation,
                      child: const Text(
                        'Confirmar Reserva',
                        style: TextStyle(fontSize: 18),
                      ),
                      style: ElevatedButton.styleFrom(
                        minimumSize: const Size(double.infinity, 55),
                      ),
                    ),
            ],
          ),
        ),
      ),
    );
  }

  // Widget auxiliar para mostrar filas de resumen
  Widget _buildSummaryRow(BuildContext context, String title, String value,
      {bool isImportant = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            '$title:',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  fontWeight: FontWeight.w300,
                  color: Colors.white70,
                ),
          ),
          Text(
            value,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  fontWeight: isImportant ? FontWeight.bold : FontWeight.normal,
                  color: isImportant
                      ? Theme.of(context).colorScheme.secondary
                      : Colors.white,
                ),
          ),
        ],
      ),
    );
  }
}