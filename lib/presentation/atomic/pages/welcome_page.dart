import 'package:flutter/material.dart';

class WelcomePage extends StatelessWidget {
  const WelcomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Logo en la parte superior
              Align(
                alignment: Alignment.topLeft,
                child: SizedBox(
                  height: 50,
                  child: Image.asset(
                    'lib/assets/icons/icon.jpg',
                    fit: BoxFit.contain,
                  ),
                ),
              ),

              const Spacer(),

              // Título principal
              const Text(
                'Lleva el control de tu dinero sin esfuerzo',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1A237E), // Azul oscuro
                ),
              ),

              const SizedBox(height: 24),

              // Texto descriptivo
              const Text(
                'Gestiona tus finanzas fácilmente con nuestra interfaz intuitiva y amigable. Establece metas financieras, controla tu presupuesto y haz un seguimiento de tus gastos en un solo lugar.',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.black87,
                  height: 1.5,
                ),
              ),

              const Spacer(),

              // Botón de inicio de sesión
              ElevatedButton(
                onPressed: () {
                  // TODO: Implementar navegación a login
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: const Color(0xFF1A237E),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text(
                  'Iniciar Sesión',
                  style: TextStyle(fontSize: 16),
                ),
              ),

              const SizedBox(height: 16),

              // Texto de registro
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    'No tienes una cuenta? ',
                    style: TextStyle(color: Colors.black87),
                  ),
                  TextButton(
                    onPressed: () {
                      // TODO: Implementar navegación a registro
                    },
                    child: const Text(
                      'Regístrate Gratis!',
                      style: TextStyle(
                        color: Color(0xFF1A237E),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
      backgroundColor: const Color(0xFF8BC34A), // Color verde de fondo
    );
  }
}
