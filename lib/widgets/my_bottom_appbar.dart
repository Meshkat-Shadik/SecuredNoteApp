import 'package:flutter/material.dart';

class MyBottomAppbar extends StatelessWidget {
  const MyBottomAppbar({
    Key? key,
    required this.onFavPressed,
    required this.onExitPressed,
    required this.isFavActive,
  }) : super(key: key);

  final VoidCallback onFavPressed;
  final VoidCallback onExitPressed;
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
            onPressed: onExitPressed,
            icon: const Icon(Icons.exit_to_app),
            tooltip: 'Logout',
          ),
        ],
      ),
    );
  }
}
