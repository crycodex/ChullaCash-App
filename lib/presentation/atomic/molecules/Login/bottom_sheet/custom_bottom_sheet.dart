import 'package:flutter/material.dart';

class CustomBottomSheet extends StatelessWidget {
  final Widget child;
  final VoidCallback onClose;

  const CustomBottomSheet({
    super.key,
    required this.child,
    required this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOutCubic,
      tween: Tween(begin: 1.0, end: 0.0),
      builder: (context, value, child) {
        return Transform.translate(
          offset: Offset(0, MediaQuery.of(context).size.height * value * 0.3),
          child: child,
        );
      },
      child: Material(
        color: Colors.transparent,
        child: GestureDetector(
          onTap: onClose,
          child: Container(
            color: Colors.black38,
            width: double.infinity,
            height: double.infinity,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                GestureDetector(
                  onTap: () {}, // Evita que el tap se propague al fondo
                  onVerticalDragUpdate: (details) {
                    if (details.delta.dy > 0 && details.primaryDelta! > 0.5) {
                      onClose();
                    }
                  },
                  child: Container(
                    width: double.infinity,
                    constraints: BoxConstraints(
                      maxHeight: MediaQuery.of(context).size.height * 0.7,
                    ),
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(20),
                        topRight: Radius.circular(20),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black12,
                          blurRadius: 10,
                          spreadRadius: 5,
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Indicador de arrastre
                        Container(
                          margin: const EdgeInsets.symmetric(vertical: 12),
                          width: 40,
                          height: 4,
                          decoration: BoxDecoration(
                            color: Colors.grey[300],
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                        Flexible(
                          child: child,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
