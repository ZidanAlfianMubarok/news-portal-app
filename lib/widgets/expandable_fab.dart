import 'package:flutter/material.dart';
import 'dart:math' as math;

class ExpandableFab extends StatefulWidget {
  final VoidCallback onWriteNewsPressed;

  const ExpandableFab({super.key, required this.onWriteNewsPressed});

  @override
  State<ExpandableFab> createState() => _ExpandableFabState();
}

class _ExpandableFabState extends State<ExpandableFab>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _expandAnimation;
  bool _isOpen = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      value: _isOpen ? 1.0 : 0.0,
      duration: const Duration(milliseconds: 250),
      vsync: this,
    );
    _expandAnimation = CurvedAnimation(
      curve: Curves.fastOutSlowIn,
      parent: _controller,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _toggle() {
    setState(() {
      _isOpen = !_isOpen;
      if (_isOpen) {
        _controller.forward();
      } else {
        _controller.reverse();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        _buildExpandingAction(
          icon: Icons.help_outline,
          label: 'Help',
          color: Colors.orange,
          index: 2,
          onPressed: () {}, // Fake button
        ),
        const SizedBox(height: 16),
        _buildExpandingAction(
          icon: Icons.info_outline,
          label: 'Info',
          color: Colors.blue,
          index: 1,
          onPressed: () {}, // Fake button
        ),
        const SizedBox(height: 16),
        _buildExpandingAction(
          icon: Icons.edit_note,
          label: 'Write News',
          color: const Color(0xFF4e54c8),
          index: 0,
          onPressed: () {
            _toggle();
            widget.onWriteNewsPressed();
          },
        ),
        const SizedBox(height: 16),
        FloatingActionButton(
          onPressed: _toggle,
          backgroundColor: const Color(0xFF4e54c8),
          child: AnimatedIcon(
            icon: AnimatedIcons.menu_close,
            progress: _expandAnimation,
          ),
        ),
      ],
    );
  }

  Widget _buildExpandingAction({
    required IconData icon,
    required String label,
    required Color color,
    required int index,
    required VoidCallback onPressed,
  }) {
    return ScaleTransition(
      scale: _expandAnimation,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
          ),
          const SizedBox(width: 8),
          FloatingActionButton.small(
            onPressed: onPressed,
            backgroundColor: color,
            heroTag: 'fab_$index', // Unique tag for Hero animation
            child: Icon(icon, color: Colors.white),
          ),
        ],
      ),
    );
  }
}
