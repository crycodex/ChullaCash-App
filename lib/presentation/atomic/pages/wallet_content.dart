import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';

class WalletContent extends StatelessWidget {
  const WalletContent({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Balance Overview
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                children: [
                  const Text(
                    'Balance Total',
                    style: TextStyle(
                      fontSize: 16,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    '\$2,345.67',
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildQuickAction(
                        icon: Icons.add,
                        label: 'Agregar',
                        color: AppColors.primaryGreen,
                        onTap: () {},
                      ),
                      _buildQuickAction(
                        icon: Icons.send,
                        label: 'Enviar',
                        color: AppColors.primaryGreen,
                        onTap: () {},
                      ),
                      _buildQuickAction(
                        icon: Icons.history,
                        label: 'Historial',
                        color: AppColors.primaryGreen,
                        onTap: () {},
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Recent Activity
            const Text(
              'Actividad Reciente',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: ListView.builder(
                itemCount: 10,
                itemBuilder: (context, index) {
                  final bool isIncome = index % 2 == 0;
                  return Card(
                    margin: const EdgeInsets.only(bottom: 8),
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: isIncome
                            ? AppColors.primaryGreen.withOpacity(0.1)
                            : AppColors.lightGray,
                        child: Icon(
                          isIncome ? Icons.add : Icons.remove,
                          color: isIncome
                              ? AppColors.primaryGreen
                              : AppColors.textSecondary,
                        ),
                      ),
                      title: Text(
                        isIncome ? 'Depósito' : 'Retiro',
                        style: const TextStyle(fontWeight: FontWeight.w500),
                      ),
                      subtitle: Text(
                        '${DateTime.now().day}/${DateTime.now().month}/${DateTime.now().year}',
                      ),
                      trailing: Text(
                        isIncome ? '+\$100.00' : '-\$50.00',
                        style: TextStyle(
                          color: isIncome
                              ? AppColors.primaryGreen
                              : AppColors.textPrimary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickAction({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
