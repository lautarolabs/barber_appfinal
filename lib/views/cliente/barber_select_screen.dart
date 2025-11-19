import 'package:flutter/material.dart';
import '../../models/barbero.dart';
import '../../services/api_service.dart';
import 'service_select_screen.dart'; // Crearemos esta pantalla después

class BarberSelectScreen extends StatefulWidget {
  const BarberSelectScreen({super.key});

  @override
  State<BarberSelectScreen> createState() => _BarberSelectScreenState();
}

class _BarberSelectScreenState extends State<BarberSelectScreen> {
  late Future<List<Barbero>> _barberosFuture;

  @override
  void initState() {
    super.initState();
    // Inicia la carga de datos apenas se construye la pantalla
    _barberosFuture = ApiService().getBarberos();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('1. Elige tu Barbero'),
      ),
      body: FutureBuilder<List<Barbero>>(
        future: _barberosFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            // Mientras espera la respuesta del API simulado
            return const Center(child: CircularProgressIndicator(
              color: Color(0xFFD4AF37), // Color dorado
            ));
          } else if (snapshot.hasError) {
            // Si hay un error al cargar los datos
            return Center(child: Text('Error al cargar los barberos: ${snapshot.error}', 
              style: const TextStyle(color: Colors.red)));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            // Si no hay barberos disponibles
            return const Center(child: Text('No hay barberos disponibles por el momento.'));
          }
          
          // Si los datos se cargaron correctamente
          final List<Barbero> barberos = snapshot.data!;
          
          return ListView.builder(
            padding: const EdgeInsets.all(16.0),
            itemCount: barberos.length,
            itemBuilder: (context, index) {
              final barbero = barberos[index];
              return _BarberCard(
                barbero: barbero,
                onSelect: (selectedBarbero) {
                  // Cuando se selecciona un barbero, navegamos al siguiente paso
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ServiceSelectScreen(barbero: selectedBarbero),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}

// --- Componente Reutilizable: Tarjeta de Barbero ---

class _BarberCard extends StatelessWidget {
  final Barbero barbero;
  final Function(Barbero) onSelect;

  const _BarberCard({required this.barbero, required this.onSelect});

  @override
  Widget build(BuildContext context) {
    return Card(
      color: const Color(0xFF2C2C2C), // Gris oscuro para la tarjeta
      margin: const EdgeInsets.only(bottom: 15.0),
      child: ListTile(
        contentPadding: const EdgeInsets.all(10.0),
        leading: CircleAvatar(
          radius: 30,
          // Nota: Reemplaza con NetworkImage si usas URLs reales, o AssetImage
          // Necesitas poner las imágenes en la carpeta 'assets' para que funcione
          // Por ahora, usamos un icono como placeholder si no tienes las imágenes
          backgroundColor: Theme.of(context).colorScheme.secondary.withOpacity(0.2),
          child: barbero.imagenURL.startsWith('assets/')
              ? Image.asset(barbero.imagenURL, fit: BoxFit.cover, errorBuilder: (c, o, s) => const Icon(Icons.person, size: 30, color: Color(0xFFD4AF37)))
              : const Icon(Icons.person, size: 30, color: Color(0xFFD4AF37)),
        ),
        title: Text(
          barbero.nombre,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: Text(
          barbero.especialidad,
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        trailing: const Icon(Icons.arrow_forward_ios, color: Color(0xFFD4AF37)),
        onTap: () => onSelect(barbero),
      ),
    );
  }
}