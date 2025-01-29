import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../atoms/inputs/custom_text_field.dart';
import '../atoms/buttons/custom_button.dart';

class TransferContent extends StatefulWidget {
  const TransferContent({super.key});

  @override
  State<TransferContent> createState() => _TransferContentState();
}

class _TransferContentState extends State<TransferContent> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _recipientController = TextEditingController();
  final _descriptionController = TextEditingController();

  @override
  void dispose() {
    _amountController.dispose();
    _recipientController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _handleTransfer() {
    if (_formKey.currentState?.validate() ?? false) {
      // TODO: Implement transfer logic
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Transferir dinero',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 24),

              // Amount input
              CustomTextField(
                labelText: 'Monto a transferir',
                controller: _amountController,
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor ingrese un monto';
                  }
                  if (double.tryParse(value) == null) {
                    return 'Por favor ingrese un monto válido';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Recipient input
              CustomTextField(
                labelText: 'Destinatario',
                controller: _recipientController,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor ingrese un destinatario';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Description input
              CustomTextField(
                labelText: 'Descripción (opcional)',
                controller: _descriptionController,
              ),
              const SizedBox(height: 24),

              // Transfer button
              CustomButton(
                text: 'Transferir',
                onPressed: _handleTransfer,
              ),

              const SizedBox(height: 24),

              // Recent transfers
              const Text(
                'Transferencias recientes',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 16),

              // Recent transfers list
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: 3,
                itemBuilder: (context, index) {
                  return Card(
                    margin: const EdgeInsets.only(bottom: 8),
                    child: ListTile(
                      leading: const CircleAvatar(
                        backgroundColor: AppColors.lightGray,
                        child:
                            Icon(Icons.person, color: AppColors.primaryGreen),
                      ),
                      title: Text(
                        'Usuario ${index + 1}',
                        style: const TextStyle(fontWeight: FontWeight.w500),
                      ),
                      subtitle: const Text('Última transferencia: hace 2 días'),
                      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                      onTap: () {
                        // TODO: Implement quick transfer to recent contact
                      },
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
