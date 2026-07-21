import 'package:flutter/material.dart';
import 'package:local_poll/core/theme/app_colors.dart';
import 'package:local_poll/core/theme/app_dimensions.dart';

class OptionInputField extends StatefulWidget {
  const OptionInputField({super.key, required this.onAdd});

  final ValueChanged<String> onAdd;

  @override
  State<OptionInputField> createState() => _OptionInputFieldState();
}

class _OptionInputFieldState extends State<OptionInputField> {
  final _controller = TextEditingController();

  void _submit() {
    final text = _controller.text.trim();
    if (text.isNotEmpty) {
      widget.onAdd(text);
      _controller.clear();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: TextField(
            controller: _controller,
            decoration: const InputDecoration(hintText: 'Enter option...'),
            onSubmitted: (_) => _submit(),
          ),
        ),
        const SizedBox(width: AppDimensions.paddingSM),
        IconButton(
          onPressed: _submit,
          icon: const Icon(Icons.add_circle, color: AppColors.primary),
          iconSize: AppDimensions.iconSizeLG,
        ),
      ],
    );
  }
}
