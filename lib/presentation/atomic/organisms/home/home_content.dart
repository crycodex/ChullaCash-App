import 'package:flutter/material.dart';
import '../../../theme/app_colors.dart';
//get
import 'package:get/get.dart';
//controllers
import '../../../controllers/user_controller.dart';

class HomeContent extends StatelessWidget {
  HomeContent({super.key});

  final UserController userController = Get.put(UserController());

  Color _textColor(BuildContext context) {
    return userController.isDarkMode.value
        ? Colors.white
        : Theme.of(context).textTheme.bodyLarge!.color!;
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final bool isDarkMode = userController.isDarkMode.value;

      return SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Bienvenido de nuevo,',
                        style: TextStyle(
                          fontSize: 16,
                          color: isDarkMode
                              ? Colors.white70
                              : AppColors.textSecondary,
                        ),
                      ),
                      FutureBuilder(
                        future: userController.userName(),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return const CircularProgressIndicator();
                          }
                          return Obx(() => Text(
                                userController.name.value,
                                style: TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  color: isDarkMode
                                      ? Colors.white
                                      : AppColors.lightGray,
                                ),
                              ));
                        },
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Sección de Balance
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: isDarkMode
                      ? Colors.white
                      : AppColors.darkSurface.withOpacity(0.8),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: isDarkMode
                          ? Colors.black.withOpacity(0.5)
                          : Colors.grey.withOpacity(0.1),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Balance Total',
                      style: TextStyle(
                        fontSize: 16,
                        color: isDarkMode
                            ? Colors.white70
                            : AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '\$43,323.44',
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color:
                            isDarkMode ? AppColors.textPrimary : Colors.white,
                      ),
                    ),
                    const SizedBox(height: 24),
                    // Time period selector
                    Row(),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Movimientos recientes
              Text(
                'Movimientos recientes',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: isDarkMode ? Colors.white : AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: ListView.builder(
                  itemCount: 5,
                  itemBuilder: (context, index) {
                    return Card(
                      color: isDarkMode
                          ? Colors.white
                          : AppColors.darkSurface.withOpacity(0.8),
                      margin: const EdgeInsets.only(bottom: 8),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: isDarkMode
                              ? AppColors.primaryGreen.withOpacity(0.2)
                              : AppColors.lightGray,
                          child: Icon(Icons.payment,
                              color: isDarkMode
                                  ? AppColors.primaryGreen
                                  : AppColors.primaryGreen),
                        ),
                        title: Text(
                          'Movimiento ${index + 1}',
                          style: TextStyle(
                            fontWeight: FontWeight.w500,
                            color: _textColor(context),
                          ),
                        ),
                        subtitle: Text('Hace 2 horas',
                            style: TextStyle(
                              color: isDarkMode
                                  ? Colors.white70
                                  : AppColors.textSecondary,
                            )),
                        trailing: Text(
                          '\$50.00',
                          style: TextStyle(
                            color: isDarkMode
                                ? Colors.white
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
    });
  }
}
