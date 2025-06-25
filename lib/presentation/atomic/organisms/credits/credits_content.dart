import 'package:flutter/material.dart';
import '../../../theme/app_colors.dart';

class CreditsContent extends StatelessWidget {
  const CreditsContent({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Créditos',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Sección de Desarrolladores
            const _SectionTitle(title: 'Desarrollador'),
            _InfoCard(
              icon: Icons.person_outline,
              title: 'Cristhian Recalde',
              subtitle: 'Desarrollador Principal',
              description: 'Desarrollo y diseño de la aplicación',
            ),

            const SizedBox(height: 24),

            // Sección de Tecnologías
            const _SectionTitle(title: 'Tecnologías'),
            _InfoCard(
              icon: Icons.code,
              title: 'Flutter',
              subtitle: 'Framework de desarrollo multiplataforma',
              description: 'SDK de Google para crear aplicaciones nativas',
            ),
            _InfoCard(
              icon: Icons.cloud,
              title: 'Firebase',
              subtitle: 'Backend y servicios en la nube',
              description: 'Autenticación, base de datos y almacenamiento',
            ),
            _InfoCard(
              icon: Icons.auto_awesome,
              title: 'GetX',
              subtitle: 'Gestión de estado y navegación',
              description: 'Framework para manejo de estado y rutas',
            ),

            const SizedBox(height: 24),

            // Sección de Agradecimientos
            const _SectionTitle(title: 'Agradecimientos'),
            _InfoCard(
              icon: Icons.favorite_outline,
              title: 'Comunidad Flutter',
              subtitle: 'Por su apoyo y recursos',
              description: 'Paquetes, tutoriales y soluciones compartidas',
            ),
            _InfoCard(
              icon: Icons.people_outline,
              title: 'Usuarios',
              subtitle: 'Por sus valiosos comentarios',
              description: 'Feedback y sugerencias para mejorar la app',
            ),
            //revisores de la app
            const _SectionTitle(title: 'Q/A Testers de la App'),
            _InfoCard(
              icon: Icons.person_outline,
              title: 'Samantha Antonella Maisincho Mera',
              subtitle: 'Q/A Tester',
              description: 'Revisión y pruebas de la aplicación',
            ),

            const SizedBox(height: 32),
            // Línea divisoria
            Container(
              height: 1,
              color: AppColors.primaryGreen.withValues(alpha: 0.2),
              margin: const EdgeInsets.symmetric(vertical: 16),
            ),

            // Versión de la App
            Center(
              child: Column(
                children: [
                  const Text(
                    'ChullaCash',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primaryGreen,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Versión 2.2.1',
                    style: TextStyle(
                      color: Theme.of(context).textTheme.bodySmall?.color,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '© 2025 ChullaCash. Todos los derechos reservados.',
                    style: TextStyle(
                      color: Theme.of(context).textTheme.bodySmall?.color,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;

  const _SectionTitle({required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16, left: 4),
      child: Row(
        children: [
          Container(
            width: 3,
            height: 20,
            decoration: const BoxDecoration(
              color: AppColors.primaryGreen,
              borderRadius: BorderRadius.all(Radius.circular(3)),
            ),
          ),
          const SizedBox(width: 8),
          Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.primaryGreen,
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final String description;

  const _InfoCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 0,
      color: Theme.of(context).brightness == Brightness.dark
          ? Colors.grey[900]
          : Colors.grey[100],
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: AppColors.primaryGreen.withValues(alpha: 0.1),
          width: 1,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.primaryGreen.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                icon,
                color: AppColors.primaryGreen,
                size: 24,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(
                      color: AppColors.primaryGreen,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style: TextStyle(
                      color: Theme.of(context).textTheme.bodyMedium?.color,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
