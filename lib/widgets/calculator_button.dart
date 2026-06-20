import 'package:flutter/material.dart';

class CalculatorButton extends StatelessWidget {
  final String teks;
  final Color warnaTombol;
  final Color warnaTeks;
  final VoidCallback onTap;

  const CalculatorButton({
    super.key,
    required this.teks,
    required this.warnaTombol,
    required this.warnaTeks,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.all(6),
        child: SizedBox(
          height: 70,
          child: ElevatedButton(
            onPressed: onTap,
            style: ElevatedButton.styleFrom(
              backgroundColor: warnaTombol,
              foregroundColor: warnaTeks,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(18),
              ),
              elevation: 3,
              padding: const EdgeInsets.symmetric(horizontal: 6),
            ),
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                teks,
                maxLines: 1,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}