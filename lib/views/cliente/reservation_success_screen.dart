import 'package:flutter/material.dart';
import '../../models/barbero.dart';
import '../../models/servicio.dart';

class ReservationSuccessScreen extends StatelessWidget {
  final Barbero barbero;
  final Servicio servicio;
  final DateTime fechaHora;
  final String nombreCliente;

  const ReservationSuccessScreen({
    super.key,
    required this.barbero,
    required this.servicio,
    required this.fechaHora,
    required this.nombreCliente,
  });

  String get _formattedTime {
    final hour = fechaHora.hour.toString().padLeft(2, '0');
    final minute = fechaHora.minute.toString().padLeft(2, '0');
    return '$hour:$minute hs';
  }

  String get _formattedDate {
    final day = fechaHora.day.toString().padLeft(2, '0');
    final month = fechaHora.month.toString().padLeft(2, '0');
    final year = fechaHora.year;
    return '$day/$month/$year';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Reserva Confirmada'),
        automaticallyImplyLeading: false, // No permitir volver atrás
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.check_circle_outline,
                color: Color(0xFFD4AF37), // Dorado
                size: 100,
              ),
              const SizedBox(height: 20),
              Text(
                '¡Reserva Exitosa, $nombreCliente!',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontSize: 26,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                'Tu turno ha sido reservado con éxito.',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 40),

              // Detalles del Turno
              _buildDetailCard(context, [
                _buildDetailRow(context, 'Barbero:', barbero.nombre),
                _buildDetailRow(context, 'Servicio:', servicio.nombre),
                _buildDetailRow(context, 'Fecha:', _formattedDate),
                _buildDetailRow(context, 'Hora:', _formattedTime, isImportant: true),
              ]),

              const SizedBox(height: 60),
              // Botón para volver al inicio
              ElevatedButton(
                onPressed: () {
                  // Vuelve a la primera pantalla (HomeScreen)
                  Navigator.popUntil(context, (route) => route.isFirst);
                },
                child: const Text('Volver al Inicio'),
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 50),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Widget auxiliar para mostrar el resumen final
  Widget _buildDetailCard(BuildContext context, List<Widget> children) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF2C2C2C),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        children: children,
      ),
    );
  }

  Widget _buildDetailRow(BuildContext context, String label, String value,
      {bool isImportant = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: Colors.white70,
                ),
          ),
          Text(
            value,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: isImportant
                      ? Theme.of(context).colorScheme.secondary
                      : Colors.white,
                  fontWeight: isImportant ? FontWeight.bold : FontWeight.normal,
                ),
          ),
        ],
      ),
    );
  }
}