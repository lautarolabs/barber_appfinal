// test/widget_test.dart

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

// Asegúrate de que esta línea apunte a tu main.dart.
// Reemplaza 'nombre_del_proyecto' con el nombre que usaste (ej: 'barber_booking_app').
import 'package:barber_appfinal/main.dart'; 

void main() {
  testWidgets('La aplicación se inicia y tiene el botón de reservar', (WidgetTester tester) async {
    
    // Construye nuestra aplicación (BarberApp) y dispara un frame.
    await tester.pumpWidget(const BarberApp()); 

    // Dado queHomeScreen (la vista inicial) tiene un botón de "Reservar un Turno",
    // verificamos que ese texto exista.

    // 1. Verificar si el texto '¡Bienvenido a la Barbería!' está visible.
    expect(find.text('¡Bienvenido a la Barbería!'), findsOneWidget);

    // 2. Verificar que el botón principal de reserva esté presente.
    expect(find.widgetWithText(ElevatedButton, 'Reservar un Turno'), findsOneWidget);

    // 3. Verificar que el icono del administrador esté presente (opcional pero útil para verificar la estructura).
    expect(find.byIcon(Icons.admin_panel_settings), findsOneWidget);

    // Nota: Si usaras el código de prueba predeterminado (MyApp),
    // buscarías '0' y '1', que son parte del ejemplo de contador.
    // En nuestro caso, probamos elementos de la HomeScreen real.

  });
}