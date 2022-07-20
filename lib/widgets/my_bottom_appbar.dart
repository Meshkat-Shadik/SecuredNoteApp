import 'package:flutter/material.dart';

class MyBottomAppbar extends StatelessWidget {
  const MyBottomAppbar({
    Key? key,
    required this.onFavPressed,
    required this.onExpensePressed,
    required this.isFavActive,
  }) : super(key: key);

  final VoidCallback onFavPressed;
  final VoidCallback onExpensePressed;
  final bool isFavActive;

  @override
  Widget build(BuildContext context) {
    return BottomAppBar(
      shape: const CircularNotchedRectangle(),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          IconButton(
            onPressed: onFavPressed,
            icon: Icon(
              Icons.favorite,
              color: isFavActive ? Colors.red : Colors.white,
            ),
            tooltip: 'Favourites',
          ),
          IconButton(
            onPressed: onExpensePressed,
            icon: const Icon(
              Icons.content_paste,
              size: 22,
            ),
            tooltip: 'Logout',
          ),
        ],
      ),
    );
  }
}
