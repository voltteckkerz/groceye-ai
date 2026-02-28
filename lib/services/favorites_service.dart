import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/saved_item.dart';
import '../models/scan_mode.dart';

class FavoritesService {
  static const String _storageKey = 'saved_items';
  late SharedPreferences _prefs;
  List<SavedItem> _items = [];

  // Initialize service
  Future<void> initialize() async {
    _prefs = await SharedPreferences.getInstance();
    await _loadItems();
  }

  // Load items from storage
  Future<void> _loadItems() async {
    final String? itemsJson = _prefs.getString(_storageKey);
    if (itemsJson != null) {
      final List<dynamic> decoded = jsonDecode(itemsJson);
      _items = decoded.map((json) => SavedItem.fromJson(json)).toList();
      // Sort by timestamp descending (newest first)
      _items.sort((a, b) => b.timestamp.compareTo(a.timestamp));
    }
  }

  // Save items to storage
  Future<void> _saveItems() async {
    final List<Map<String, dynamic>> encoded = 
        _items.map((item) => item.toJson()).toList();
    await _prefs.setString(_storageKey, jsonEncode(encoded));
  }

  // Get all items
  List<SavedItem> getAllItems() {
    return List.from(_items);
  }

  // Get only favorites
  List<SavedItem> getFavorites() {
    return _items.where((item) => item.isFavorite).toList();
  }

  // Get count of items
  int getItemCount() {
    return _items.length;
  }

  // Get count of favorites
  int getFavoriteCount() {
    return _items.where((item) => item.isFavorite).length;
  }

  // Save new item (with deduplication)
  Future<void> saveItem(SavedItem item) async {
    // Check for duplicate within last 5 minutes
    final fiveMinutesAgo = DateTime.now().subtract(const Duration(minutes: 5));
    final isDuplicate = _items.any((existing) =>
        existing.name.toLowerCase() == item.name.toLowerCase() &&
        existing.mode == item.mode &&
        existing.timestamp.isAfter(fiveMinutesAgo));

    if (!isDuplicate) {
      _items.insert(0, item); // Add to beginning
      await _saveItems();
    }
  }

  // Toggle favorite status
  Future<void> toggleFavorite(String id) async {
    final index = _items.indexWhere((item) => item.id == id);
    if (index != -1) {
      _items[index].isFavorite = !_items[index].isFavorite;
      await _saveItems();
    }
  }

  // Delete item
  Future<void> deleteItem(String id) async {
    _items.removeWhere((item) => item.id == id);
    await _saveItems();
  }

  // Clear all items
  Future<void> clearAll() async {
    _items.clear();
    await _saveItems();
  }

  // Clear non-favorites
  Future<void> clearNonFavorites() async {
    _items.removeWhere((item) => !item.isFavorite);
    await _saveItems();
  }
}
