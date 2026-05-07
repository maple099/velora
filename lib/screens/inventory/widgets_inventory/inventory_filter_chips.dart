import 'package:flutter/material.dart';

class InventoryFilterChips extends StatelessWidget {
  final String selectedFilter;
  final ValueChanged<String> onSelected;

  const InventoryFilterChips({
    super.key,
    required this.selectedFilter,
    required this.onSelected,
  });

  static const filters = ['All Items', 'Low Stock', 'Near Expiry'];

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 10,
      children: filters.map((filter) {
        final isSelected = selectedFilter == filter;

        return ChoiceChip(
          label: Text(filter),
          selected: isSelected,
          onSelected: (_) => onSelected(filter),
          selectedColor: const Color(0xFF7C3AED),
          backgroundColor: Colors.white,
          labelStyle: TextStyle(
            color: isSelected ? Colors.white : const Color(0xFF475569),
            fontWeight: FontWeight.w700,
          ),
          side: BorderSide(
            color: isSelected
                ? const Color(0xFF7C3AED)
                : const Color(0xFFE2E8F0),
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
        );
      }).toList(),
    );
  }
}
