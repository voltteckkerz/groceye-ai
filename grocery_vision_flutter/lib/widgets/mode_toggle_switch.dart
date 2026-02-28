import 'package:flutter/material.dart';
import '../models/scan_mode.dart';

class ModeToggleSwitch extends StatefulWidget {
  final ScanMode currentMode;
  final Function(ScanMode) onModeChanged;

  const ModeToggleSwitch({
    super.key,
    required this.currentMode,
    required this.onModeChanged,
  });

  @override
  State<ModeToggleSwitch> createState() => _ModeToggleSwitchState();
}

class _ModeToggleSwitchState extends State<ModeToggleSwitch>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  double _dragPosition = 0.0;
  bool _isDragging = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _animation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutCubic,
    );

    // Set initial position
    if (widget.currentMode == ScanMode.label) {
      _controller.value = 1.0;
    }
  }

  @override
  void didUpdateWidget(ModeToggleSwitch oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.currentMode != oldWidget.currentMode) {
      if (widget.currentMode == ScanMode.label) {
        _controller.forward();
      } else {
        _controller.reverse();
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleTap(bool isRightSide) {
    final newMode = isRightSide ? ScanMode.label : ScanMode.item;
    if (newMode != widget.currentMode) {
      widget.onModeChanged(newMode);
    }
  }

  void _handleDragStart(DragStartDetails details) {
    setState(() {
      _isDragging = true;
    });
  }

  void _handleDragUpdate(DragUpdateDetails details, double width) {
    setState(() {
      _dragPosition += details.delta.dx;
      _dragPosition = _dragPosition.clamp(0.0, width - 90);
      
      // Update controller based on drag position
      _controller.value = _dragPosition / (width - 90);
    });
  }

  void _handleDragEnd(DragEndDetails details, double width) {
    setState(() {
      _isDragging = false;
    });

    // Determine which mode based on position
    final threshold = (width - 90) / 2;
    final newMode = _dragPosition > threshold ? ScanMode.label : ScanMode.item;
    
    if (newMode != widget.currentMode) {
      widget.onModeChanged(newMode);
    } else {
      // Snap back to current position
      if (widget.currentMode == ScanMode.label) {
        _controller.forward();
      } else {
        _controller.reverse();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    const double switchWidth = 200.0;
    const double switchHeight = 50.0;
    const double thumbWidth = 90.0;

    return GestureDetector(
      onTapUp: (details) {
        final isRightSide = details.localPosition.dx > switchWidth / 2;
        _handleTap(isRightSide);
      },
      child: Container(
        width: switchWidth,
        height: switchHeight,
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.6),
          borderRadius: BorderRadius.circular(25),
        ),
        child: Stack(
          children: [
            // Labels
            Row(
              children: [
                // Item label
                Expanded(
                  child: Center(
                    child: AnimatedDefaultTextStyle(
                      duration: const Duration(milliseconds: 300),
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: widget.currentMode == ScanMode.item
                            ? FontWeight.bold
                            : FontWeight.normal,
                      ),
                      child: const Text('Item'),
                    ),
                  ),
                ),
                // Label label
                Expanded(
                  child: Center(
                    child: AnimatedDefaultTextStyle(
                      duration: const Duration(milliseconds: 300),
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: widget.currentMode == ScanMode.label
                            ? FontWeight.bold
                            : FontWeight.normal,
                      ),
                      child: const Text('Label'),
                    ),
                  ),
                ),
              ],
            ),

            // Animated thumb
            AnimatedBuilder(
              animation: _animation,
              builder: (context, child) {
                final position = _isDragging
                    ? _dragPosition
                    : _animation.value * (switchWidth - thumbWidth - 8);

                return Positioned(
                  left: 4 + position,
                  top: 4,
                  child: GestureDetector(
                    onHorizontalDragStart: _handleDragStart,
                    onHorizontalDragUpdate: (details) =>
                        _handleDragUpdate(details, switchWidth),
                    onHorizontalDragEnd: (details) =>
                        _handleDragEnd(details, switchWidth),
                    child: Container(
                      width: thumbWidth,
                      height: switchHeight - 8,
                      decoration: BoxDecoration(
                        gradient: widget.currentMode == ScanMode.item
                            ? const LinearGradient(
                                colors: [Color(0xFFF73C1B), Color(0xFFFF6B4A)],
                              )
                            : const LinearGradient(
                                colors: [Color(0xFFFFB84D), Color(0xFFFFD700)],
                              ),
                        borderRadius: BorderRadius.circular(21),
                        boxShadow: [
                          BoxShadow(
                            color: (widget.currentMode == ScanMode.item
                                    ? const Color(0xFFF73C1B)
                                    : const Color(0xFFFFB84D))
                                .withOpacity(0.5),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Icon(
                        widget.currentMode == ScanMode.item
                            ? Icons.qr_code_scanner_rounded
                            : Icons.text_fields,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
