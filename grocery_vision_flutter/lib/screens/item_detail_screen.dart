import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/saved_item.dart';
import '../models/scan_mode.dart';
import '../services/favorites_service.dart';

class ItemDetailScreen extends StatefulWidget {
  final SavedItem item;
  final FavoritesService favoritesService;

  const ItemDetailScreen({
    super.key,
    required this.item,
    required this.favoritesService,
  });

  @override
  State<ItemDetailScreen> createState() => _ItemDetailScreenState();
}

class _ItemDetailScreenState extends State<ItemDetailScreen> {
  late SavedItem _item;

  @override
  void initState() {
    super.initState();
    _item = widget.item;
  }

  String _formatTimestamp(DateTime timestamp) {
    return DateFormat('MMM d, yyyy • h:mm a').format(timestamp);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFD1C9),
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.7),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.arrow_back,
                        color: Color(0xFF333333),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Scan Details',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF333333),
                          ),
                        ),
                        Text(
                          _formatTimestamp(_item.timestamp),
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.black.withOpacity(0.5),
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Favorite button
                  IconButton(
                    icon: Icon(
                      _item.isFavorite ? Icons.favorite : Icons.favorite_border,
                      color: const Color(0xFFFFB3D9),
                      size: 28,
                    ),
                    onPressed: () async {
                      await widget.favoritesService.toggleFavorite(_item.id);
                      setState(() {
                        _item.isFavorite = !_item.isFavorite;
                      });
                    },
                  ),
                ],
              ),
            ),

            // Mode indicator
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                decoration: BoxDecoration(
                  gradient: _item.mode == ScanMode.item
                      ? const LinearGradient(
                          colors: [Color(0xFFF73C1B), Color(0xFFFF6B4A)],
                        )
                      : const LinearGradient(
                          colors: [Color(0xFFFFB84D), Color(0xFFFFD700)],
                        ),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: (_item.mode == ScanMode.item
                              ? const Color(0xFFF73C1B)
                              : const Color(0xFFFFB84D))
                          .withOpacity(0.4),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      _item.mode == ScanMode.item
                          ? Icons.qr_code_scanner_rounded
                          : Icons.text_fields,
                      color: Colors.white,
                      size: 18,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      _item.mode.displayName,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),

            // All labels count
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Row(
                children: [
                  Text(
                    '${_item.allLabels.length} ${_item.mode == ScanMode.item ? "item" : "text"}${_item.allLabels.length > 1 ? "s" : ""} detected',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.black.withOpacity(0.6),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 12),

            // Labels list
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                itemCount: _item.allLabels.length,
                itemBuilder: (context, index) {
                  return _buildLabelCard(index);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLabelCard(int index) {
    final label = _item.allLabels[index];
    final confidence = _item.allConfidences != null && index < _item.allConfidences!.length
        ? _item.allConfidences![index]
        : null;
    final isPrimary = index == 0;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(isPrimary ? 0.9 : 0.7),
        borderRadius: BorderRadius.circular(16),
        border: isPrimary
            ? Border.all(
                color: const Color(0xFFF73C1B).withOpacity(0.5),
                width: 2,
              )
            : null,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isPrimary ? 0.1 : 0.05),
            blurRadius: isPrimary ? 12 : 8,
            offset: Offset(0, isPrimary ? 3 : 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Index number
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: isPrimary
                  ? const Color(0xFFF73C1B).withOpacity(0.2)
                  : Colors.black.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                '${index + 1}',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: isPrimary
                      ? const Color(0xFFF73C1B)
                      : Colors.black.withOpacity(0.6),
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),

          // Label text
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        label,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: isPrimary ? FontWeight.bold : FontWeight.w600,
                          color: const Color(0xFF333333),
                        ),
                      ),
                    ),
                    if (isPrimary)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF73C1B).withOpacity(0.2),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Text(
                          'PRIMARY',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFFF73C1B),
                          ),
                        ),
                      ),
                  ],
                ),
                if (confidence != null) ...[
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFF4CAF50).withOpacity(0.2),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.trending_up,
                              size: 12,
                              color: const Color(0xFF4CAF50),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '${(confidence * 100).toInt()}% confidence',
                              style: const TextStyle(
                                fontSize: 11,
                                color: Color(0xFF4CAF50),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
