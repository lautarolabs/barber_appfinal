// lib/main.dart

import 'package:flutter/material.dart';
import 'views/cliente/home_screen.dart'; // Importaremos esta vista luego

void main() {
  runApp(const BarberApp());
}

class BarberApp extends StatelessWidget {
  const BarberApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Barber Booking App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        // Paleta de colores oscura y elegante
        primaryColor: const Color(0xFF121212), // Negro/Gris Oscuro principal
        colorScheme: ColorScheme.fromSwatch(
          primarySwatch: Colors.grey, // Para generar tonos
        ).copyWith(
          secondary: const Color(0xFFD4AF37), // Dorado como acento
          brightness: Brightness.dark, // Modo oscuro
        ),
        scaffoldBackgroundColor: const Color(0xFF212121), // Fondo más oscuro
        appBarTheme: const AppBarTheme(
          color: Color(0xFF121212),
          elevation: 0,
          titleTextStyle: TextStyle(
            color: Color(0xFFD4AF37),
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        textTheme: const TextTheme(
          // Texto blanco para contraste con fondo oscuro
          bodyLarge: TextStyle(color: Colors.white),
          bodyMedium: TextStyle(color: Colors.white70),
          titleLarge: TextStyle(color: Color(0xFFD4AF37)), // Títulos en dorado
        ),
        // Estilo de botones para el acento
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFFD4AF37), // Dorado de fondo
            foregroundColor: Colors.black, // Texto negro para contraste
            padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8.0),
            ),
          ),
        ),
      ),
      home: const HomeScreen(), // Pantalla inicial para el cliente
    );
  }
}