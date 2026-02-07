import 'package:flutter/material.dart';

class PlantSearchBar extends StatelessWidget {
  final TextEditingController? controller;
  final VoidCallback? onMenuTap;
  final ValueChanged<String>? onChanged;
  final FocusNode? focusNode;

  const PlantSearchBar({
    super.key,
    this.controller,
    this.onMenuTap,
    this.onChanged,
    this.focusNode,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: TextField(
        controller: controller,
        onChanged: onChanged,
        focusNode: focusNode,
        autofocus: false,
        style: const TextStyle(fontSize: 16, color: Colors.black87),
        decoration: InputDecoration(
          hintText: 'Search your plant....',
          hintStyle: const TextStyle(color: Colors.black38, fontSize: 16),
          prefixIcon: const Icon(Icons.search, color: Colors.black87, size: 24),
          suffixIcon: IconButton(
            icon: const Icon(Icons.menu, color: Colors.black87, size: 24),
            onPressed: onMenuTap,
          ),
          filled: true,
          fillColor: Colors.white,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 14,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }
}
