import 'package:flutter/material.dart';

class MarkAsUsedDialog extends StatefulWidget {
  final int currentQuantity;

  const MarkAsUsedDialog({super.key, required this.currentQuantity});

  @override
  State<MarkAsUsedDialog> createState() => _MarkAsUsedDialogState();
}

class _MarkAsUsedDialogState extends State<MarkAsUsedDialog> {
  final controller = TextEditingController();

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  void _submit() {
    final usedAmount = int.tryParse(controller.text.trim()) ?? 0;

    if (usedAmount <= 0) {
      _showMessage('Please enter a valid quantity');
      return;
    }

    if (usedAmount > widget.currentQuantity) {
      _showMessage('Used quantity cannot exceed current stock');
      return;
    }

    Navigator.pop(context, usedAmount);
  }

  void _showMessage(String text) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(text), behavior: SnackBarBehavior.floating),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Mark as Used'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('Current quantity: ${widget.currentQuantity}'),
          const SizedBox(height: 14),
          TextField(
            controller: controller,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              hintText: 'Enter used quantity',
              border: OutlineInputBorder(),
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(onPressed: _submit, child: const Text('Save')),
      ],
    );
  }
}
