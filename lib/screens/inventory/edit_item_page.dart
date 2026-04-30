import 'package:flutter/material.dart';

import '../../logic/firestore_service.dart';
import '../../models/inventory_item.dart';

class EditItemPage extends StatefulWidget {
  final InventoryItem item;

  const EditItemPage({super.key, required this.item});

  @override
  State<EditItemPage> createState() => _EditItemPageState();
}

class _EditItemPageState extends State<EditItemPage> {
  late TextEditingController _nameController;
  late TextEditingController _categoryController;
  late TextEditingController _quantityController;

  DateTime? _expiryDate;
  bool _isSaving = false;

  static const Color primaryPurple = Color(0xFF7C3AED);
  static const Color lightPurple = Color(0xFFF4ECFF);
  static const Color textDark = Color(0xFF111827);
  static const Color textGrey = Color(0xFF6B7280);
  static const Color borderGrey = Color(0xFFE5E7EB);

  @override
  void initState() {
    super.initState();

    _nameController = TextEditingController(text: widget.item.name);
    _categoryController = TextEditingController(text: widget.item.category);
    _quantityController = TextEditingController(
      text: widget.item.quantity.toString(),
    );
    _expiryDate = widget.item.expiryDate;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _categoryController.dispose();
    _quantityController.dispose();
    super.dispose();
  }

  Future<void> _pickExpiryDate() async {
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: _expiryDate ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2035),
    );

    if (pickedDate == null) return;

    setState(() {
      _expiryDate = pickedDate;
    });
  }

  Future<void> _saveItem() async {
    final name = _nameController.text.trim();
    final category = _categoryController.text.trim();
    final quantity = int.tryParse(_quantityController.text.trim()) ?? 0;

    if (name.isEmpty || category.isEmpty || _expiryDate == null) {
      _showMessage('Please fill in all fields');
      return;
    }

    if (quantity < 0) {
      _showMessage('Quantity cannot be negative');
      return;
    }

    setState(() => _isSaving = true);

    try {
      final updatedItem = InventoryItem(
        id: widget.item.id,
        name: name,
        category: category,
        quantity: quantity,
        expiryDate: _expiryDate!,
        imageUrl: widget.item.imageUrl,
        createdAt: widget.item.createdAt,
      );

      await FirestoreService.instance.updateItem(widget.item, updatedItem);

      if (!mounted) return;

      _showMessage('Item updated successfully');
      Navigator.pop(context);
    } catch (e) {
      _showMessage('Failed to update item');
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), behavior: SnackBarBehavior.floating),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: lightPurple,
      appBar: AppBar(
        backgroundColor: lightPurple,
        elevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: textDark),
        title: const Text(
          'Edit Item',
          style: TextStyle(color: textDark, fontWeight: FontWeight.w800),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(18),
          child: Column(
            children: [
              _buildHeaderCard(),
              const SizedBox(height: 18),
              _buildFormCard(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeaderCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [primaryPurple, Color(0xFFA855F7)],
        ),
        borderRadius: BorderRadius.circular(28),
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.edit_note_rounded, color: Colors.white, size: 34),
          SizedBox(height: 12),
          Text(
            'Update Item',
            style: TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.w900,
            ),
          ),
          SizedBox(height: 6),
          Text(
            'Quantity changes will save stock movement automatically.',
            style: TextStyle(color: Colors.white70, fontSize: 14),
          ),
        ],
      ),
    );
  }

  Widget _buildFormCard() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(26),
        border: Border.all(color: borderGrey),
      ),
      child: Column(
        children: [
          _buildTextField(
            'Item Name',
            _nameController,
            Icons.inventory_2_outlined,
          ),
          const SizedBox(height: 14),
          _buildTextField(
            'Category',
            _categoryController,
            Icons.category_outlined,
          ),
          const SizedBox(height: 14),
          _buildTextField(
            'Quantity',
            _quantityController,
            Icons.numbers_outlined,
            keyboardType: TextInputType.number,
          ),
          const SizedBox(height: 14),
          _buildDatePicker(),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            height: 54,
            child: ElevatedButton(
              onPressed: _isSaving ? null : _saveItem,
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryPurple,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18),
                ),
              ),
              child: _isSaving
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text(
                      'Save Changes',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField(
    String label,
    TextEditingController controller,
    IconData icon, {
    TextInputType keyboardType = TextInputType.text,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: primaryPurple),
        filled: true,
        fillColor: const Color(0xFFF9FAFB),
        border: _inputBorder(borderGrey),
        enabledBorder: _inputBorder(borderGrey),
        focusedBorder: _inputBorder(primaryPurple),
      ),
    );
  }

  OutlineInputBorder _inputBorder(Color color) {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(18),
      borderSide: BorderSide(color: color),
    );
  }

  Widget _buildDatePicker() {
    return InkWell(
      onTap: _pickExpiryDate,
      borderRadius: BorderRadius.circular(18),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
        decoration: BoxDecoration(
          color: const Color(0xFFF9FAFB),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: borderGrey),
        ),
        child: Row(
          children: [
            const Icon(Icons.calendar_month_outlined, color: primaryPurple),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                _expiryDate == null
                    ? 'Select Expiry Date'
                    : _formatDate(_expiryDate!),
                style: TextStyle(
                  color: _expiryDate == null ? textGrey : textDark,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
