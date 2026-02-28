import 'package:flutter/material.dart';

class ControlButton extends StatelessWidget {
  final bool isPaused;
  final VoidCallback onPressed;
  
  const ControlButton({
    super.key,
    required this.isPaused,
    required this.onPressed,
  });
  
  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: isPaused ? 'Resume detection' : 'Pause detection',
      button: true,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: isPaused ? Colors.green : Colors.red,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 20),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
          minimumSize: const Size(200, 60),
        ),
        child: Text(
          isPaused ? '▶️ RESUME' : '⏸️ PAUSE',
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
