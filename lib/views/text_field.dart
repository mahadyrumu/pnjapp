import 'package:flutter/material.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';

class CustomTextField extends StatelessWidget {
  final String label;
  final bool number;
  final TextEditingController controller;
  final String hint;
  final String? Function(String?)? validator;

  CustomTextField({
    super.key,
    required this.label,
    required this.number,
    required this.controller,
    this.hint = "",
    this.validator, // Make the validator parameter optional
  });

  // Mask Formatter for US Phone Number (e.g., (123) 456-7890)
  final maskFormatter = MaskTextInputFormatter(
    mask: '(###) ###-####',
    filter: {'#': RegExp(r'[0-9]')}, // Only allow digits
    type: MaskAutoCompletionType.lazy,
  );

  // Reset the formatter when needed
  void resetFormatter() {
    maskFormatter.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 5),
        number == true
            ? TextFormField(
                controller: controller,
                validator: validator,
                inputFormatters: [maskFormatter],
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Colors.grey[200],
                  hintText: hint,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(3),
                  ),
                ),
              )
            : TextFormField(
                controller: controller,
                validator: validator,
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Colors.grey[200],
                  hintText: hint,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(3),
                  ),
                ),
              ),
      ],
    );
  }
}
