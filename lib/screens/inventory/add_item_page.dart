import 'package:flutter/material.dart';
import 'dart:io';

import 'package:image_picker/image_picker.dart';
import '../../logic/firestore_service.dart';
import '../../models/inventory_item.dart';

class AddItemPage extends StatefulWidget {
  const AddItemPage({super.key});

  @override
  State<AddItemPage> createState() => _AddItemPageState();
}

class _AddItemPageState extends State<AddItemPage> {
  final itemNameController = TextEditingController();
  final quantityController = TextEditingController();
  final priceController = TextEditingController();

  String selectedCategory = 'Meat';
  String selectedUnit = 'kg';
  DateTime? selectedDate;
  bool isSaving = false;
  File? selectedImage;

  final ImagePicker picker = ImagePicker();

  final categories = ['Meat', 'Dairy', 'Vegetable', 'Fruit', 'Bakery', 'Other'];
  final units = ['kg', 'g', 'L', 'ml', 'pcs'];

  @override
  void dispose() {
    itemNameController.dispose();
    quantityController.dispose();
    priceController.dispose();
    super.dispose();
  }

  Future<void> _pickExpiryDate() async {
    final pickedDate = await showDatePicker(
      context: context,
      firstDate: DateTime.now(),
      lastDate: DateTime(2035),
      initialDate: DateTime.now(),
    );

    if (pickedDate != null) {
      setState(() => selectedDate = pickedDate);
    }
  }

  Future<void> _pickImage() async {
    final picked = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 70,
    );

    if (picked != null) {
      setState(() {
        selectedImage = File(picked.path);
      });
    }
  }

  Future<void> _saveItem() async {
    if (itemNameController.text.trim().isEmpty ||
        quantityController.text.trim().isEmpty ||
        selectedDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please fill item name, quantity and expiry date'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    setState(() => isSaving = true);

    final newItem = InventoryItem(
      id: '',
      name: itemNameController.text.trim(),
      category: selectedCategory,
      quantity: int.tryParse(quantityController.text.trim()) ?? 0,
      expiryDate: selectedDate!,
      imageUrl: selectedImage?.path ?? '',
      createdAt: DateTime.now(),
    );

    await FirestoreService.instance.addItem(newItem);

    if (!mounted) return;

    setState(() => isSaving = false);
    Navigator.pop(context);
  }

  String get expiryText {
    if (selectedDate == null) return 'Select date';
    return '${selectedDate!.day}/${selectedDate!.month}/${selectedDate!.year}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _header(),
              const SizedBox(height: 22),
              _imageUploadBox(),
              const SizedBox(height: 22),

              _inputLabel('Item Name'),
              _textField(
                controller: itemNameController,
                hint: 'e.g. Chicken Breast',
              ),

              const SizedBox(height: 16),

              _inputLabel('Category'),
              _dropdown(
                value: selectedCategory,
                items: categories,
                onChanged: (value) {
                  setState(() => selectedCategory = value!);
                },
              ),

              const SizedBox(height: 16),

              _inputLabel('Quantity'),
              Row(
                children: [
                  Expanded(
                    child: _textField(
                      controller: quantityController,
                      hint: '0',
                      keyboardType: TextInputType.number,
                    ),
                  ),
                  const SizedBox(width: 10),
                  SizedBox(
                    width: 90,
                    child: _dropdown(
                      value: selectedUnit,
                      items: units,
                      onChanged: (value) {
                        setState(() => selectedUnit = value!);
                      },
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              _inputLabel('Expiry Date'),
              _dateBox(),

              const SizedBox(height: 16),

              _inputLabel('Purchase Price (RM)'),
              _textField(
                controller: priceController,
                hint: '0.00',
                keyboardType: TextInputType.number,
              ),

              const SizedBox(height: 28),

              _saveButton(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _header() {
    return Row(
      children: [
        InkWell(
          onTap: () => Navigator.pop(context),
          borderRadius: BorderRadius.circular(12),
          child: const Icon(
            Icons.arrow_back_ios_new_rounded,
            size: 20,
            color: Color(0xFF111827),
          ),
        ),
        const SizedBox(width: 18),
        const Text(
          'Add New Item',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w800,
            color: Color(0xFF111827),
          ),
        ),
      ],
    );
  }

  Widget _imageUploadBox() {
    return InkWell(
      onTap: _pickImage,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        height: 170,
        width: double.infinity,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: const Color(0xFFE5E7EB)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 14,
              offset: const Offset(0, 7),
            ),
          ],
        ),

        child: selectedImage != null
            ? ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: Image.file(
                  selectedImage!,
                  fit: BoxFit.cover,
                  width: double.infinity,
                ),
              )
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      color: const Color(0xFFF3E8FF),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Icon(
                      Icons.add_a_photo_outlined,
                      color: Color(0xFF7C3AED),
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Upload Food Image',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF374151),
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Tap to choose from gallery',
                    style: TextStyle(fontSize: 12, color: Color(0xFF9CA3AF)),
                  ),
                ],
              ),
      ),
    );
  }

  Widget _inputLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w700,
          color: Color(0xFF374151),
        ),
      ),
    );
  }

  Widget _textField({
    required TextEditingController controller,
    required String hint,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Container(
      height: 52,
      decoration: _fieldDecoration(),
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: const TextStyle(fontSize: 13, color: Color(0xFF9CA3AF)),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16),
        ),
      ),
    );
  }

  Widget _dropdown({
    required String value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
  }) {
    return Container(
      height: 52,
      padding: const EdgeInsets.symmetric(horizontal: 14),
      decoration: _fieldDecoration(),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          isExpanded: true,
          icon: const Icon(Icons.keyboard_arrow_down_rounded),
          items: items.map((item) {
            return DropdownMenuItem(
              value: item,
              child: Text(
                item,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
            );
          }).toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }

  Widget _dateBox() {
    return InkWell(
      onTap: _pickExpiryDate,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        height: 52,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: _fieldDecoration(),
        child: Row(
          children: [
            Expanded(
              child: Text(
                expiryText,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: selectedDate == null
                      ? const Color(0xFF9CA3AF)
                      : const Color(0xFF111827),
                ),
              ),
            ),
            const Icon(
              Icons.calendar_month_outlined,
              size: 20,
              color: Color(0xFF6B7280),
            ),
          ],
        ),
      ),
    );
  }

  BoxDecoration _fieldDecoration() {
    return BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(14),
      border: Border.all(color: const Color(0xFFE5E7EB)),
    );
  }

  Widget _saveButton() {
    return GestureDetector(
      onTap: isSaving ? null : _saveItem,
      child: Container(
        height: 54,
        width: double.infinity,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: const LinearGradient(
            colors: [Color(0xFF7C3AED), Color(0xFFA855F7)],
          ),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF7C3AED).withValues(alpha: 0.28),
              blurRadius: 16,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Center(
          child: isSaving
              ? const SizedBox(
                  width: 22,
                  height: 22,
                  child: CircularProgressIndicator(
                    color: Colors.white,
                    strokeWidth: 2.4,
                  ),
                )
              : const Text(
                  'Save Item',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                  ),
                ),
        ),
      ),
    );
  }
}
