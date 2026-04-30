import 'package:flutter/material.dart';

import '../models/inventory_item.dart';

class LocalInventoryService {
  LocalInventoryService._();

  static final ValueNotifier<List<InventoryItem>> itemsNotifier =
      ValueNotifier<List<InventoryItem>>([
        const InventoryItem(
          name: 'Chicken Breast',
          category: 'Meat',
          quantity: '2.5',
          unit: 'kg',
          expiryDate: '24 Aug 2026',
          price: '45.00',
          imageEmoji: '🍗',
        ),
        const InventoryItem(
          name: 'Fresh Milk',
          category: 'Dairy',
          quantity: '1',
          unit: 'L',
          expiryDate: '25 Apr 2026',
          price: '6.50',
          imageEmoji: '🥛',
        ),
        const InventoryItem(
          name: 'Garlic',
          category: 'Vegetable',
          quantity: '2.5',
          unit: 'kg',
          expiryDate: '10 May 2026',
          price: '8.00',
          imageEmoji: '🧄',
        ),
      ]);

  static void addItem(InventoryItem item) {
    itemsNotifier.value = [...itemsNotifier.value, item];
  }
}
