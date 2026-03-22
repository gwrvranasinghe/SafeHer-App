import 'package:flutter/material.dart';
import '../pages/home_page.dart';

class FloatingHomeButton extends StatelessWidget {
  const FloatingHomeButton({super.key});

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      backgroundColor: Colors.lightBlue,
      child: const Icon(Icons.home),
      onPressed: () {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const SafeHerHome()),
          (route) => false,
        );
      },
    );
  }
}
