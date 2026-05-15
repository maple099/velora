import '../../../models/inventory_item.dart';

class LocalRestockFormatter {
  String format(List<InventoryItem> items) {
    final lowStockItems = items.where((item) => item.quantity <= 2).toList();

    if (lowStockItems.isEmpty) {
      return 'No urgent restock needed. Your current inventory quantity looks stable.';
    }

    final buffer = StringBuffer();

    buffer.writeln('Smart Restock Advice');
    buffer.writeln('');

    for (final item in lowStockItems) {
      buffer.writeln('- Restock ${item.name}');
      buffer.writeln(
        '  Reason: Current quantity is ${item.quantity}, so this item may run out soon.',
      );
      buffer.writeln('');
    }

    return buffer.toString().trim();
  }
}
