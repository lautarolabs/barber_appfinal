// lib/views/cliente/home_screen.dart

import 'package:flutter/material.dart';
import 'barber_select_screen.dart'; // Para el flujo del cliente
import '../admin/login_screen.dart'; // ¡Importación para el Administrador!

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Barbería - Inicio'),
        actions: [
          // Botón para el administrador (Admin Login)
          IconButton(
            icon: const Icon(Icons.admin_panel_settings),
            onPressed: () {
              // NAVEGACIÓN: Ir al Login de Administrador
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const LoginScreen(),
                ),
              );
            },
          ),
        ],
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              // Título llamativo
              Text(
                '¡Bienvenido a la Barbería!',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontSize: 28,
                  fontWeight: FontWeight.w900,
                  color: Theme.of(context).colorScheme.secondary, // Dorado
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 10),
              Text(
                'Reserva tu turno de forma rápida y sencilla.',
                style: Theme.of(context).textTheme.bodyMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 60),

              // Botón principal para reservar
              ElevatedButton.icon(
                icon: const Icon(Icons.calendar_today),
                label: const Text(
                  'Reservar un Turno',
                  style: TextStyle(fontSize: 18),
                ),
                onPressed: () {
                  // NAVEGACIÓN: Ir a la selección de barbero
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const BarberSelectScreen(),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 55),
                ),
              ),

              const SizedBox(height: 20),

              // Opción secundaria (ej: ver ubicación)
              TextButton(
                onPressed: () {
                  // TODO: Implementar funcionalidad para ver ubicación/horarios
                  print('Ver Horarios y Ubicación');
                },
                child: const Text(
                  'Ver horarios y ubicación',
                  style: TextStyle(
                    color: Color(0xFFD4AF37), // Dorado
                    decoration: TextDecoration.underline,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}