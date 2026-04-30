class InventoryItem {
  final String name;
  final String category;
  final String quantity;
  final String unit;
  final String expiryDate;
  final String price;
  final String imageEmoji;

  const InventoryItem({
    required this.name,
    required this.category,
    required this.quantity,
    required this.unit,
    required this.expiryDate,
    required this.price,
    required this.imageEmoji,
  });
}
