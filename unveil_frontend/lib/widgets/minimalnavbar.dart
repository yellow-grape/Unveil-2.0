import 'package:flutter/material.dart';

class MinimalNavBar extends StatelessWidget {
  final List<String> items;
  final int selectedIndex;
  final ValueChanged<int> onItemSelected;
  final List<Widget> locations; // This should be declared

  const MinimalNavBar({
    Key? key,
    required this.items,
    required this.selectedIndex,
    required this.onItemSelected,
    required this.locations, // Make sure this is required
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      items: List.generate(
        items.length,
        (index) => BottomNavigationBarItem(
          icon: Icon(null), // Replace with your icon logic
          label: items[index],
        ),
      ),
      currentIndex: selectedIndex,
      onTap: (index) {
        onItemSelected(index);
      },
      backgroundColor: Colors.transparent, // Transparent background
      selectedItemColor: Theme.of(context).brightness == Brightness.dark
          ? Colors.white
          : Colors.black,
      unselectedItemColor: Colors.grey, // Color for unselected items
      type: BottomNavigationBarType.fixed, // Keep it fixed
      elevation: 0, // Remove shadow
    );
  }
}
