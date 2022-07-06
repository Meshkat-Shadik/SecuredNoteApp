import 'package:flutter/material.dart';

extension ToastX on String {
  void showToast(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(
        this,
        textAlign: TextAlign.center,
        style: const TextStyle(color: Colors.white),
      ),
      elevation: 10,
      behavior: SnackBarBehavior.floating,
      width: 200,
      backgroundColor: Colors.blueGrey.shade900,
    ));
  }
}
