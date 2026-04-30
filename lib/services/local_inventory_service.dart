import '../models/inventory_item.dart';

class LocalInventoryService {
  static List<InventoryItem> getSampleItems() {
    return [
      InventoryItem(
        id: '1',
        name: 'Bread',
        category: 'Bakery',
        quantity: 12,
        expiryDate: DateTime.now().add(const Duration(days: 3)),
        imageUrl: '',
        createdAt: DateTime.now(),
      ),
      InventoryItem(
        id: '2',
        name: 'Milk',
        category: 'Dairy',
        quantity: 8,
        expiryDate: DateTime.now().add(const Duration(days: 5)),
        imageUrl: '',
        createdAt: DateTime.now(),
      ),
      InventoryItem(
        id: '3',
        name: 'Eggs',
        category: 'Protein',
        quantity: 30,
        expiryDate: DateTime.now().add(const Duration(days: 10)),
        imageUrl: '',
        createdAt: DateTime.now(),
      ),
    ];
  }
}
