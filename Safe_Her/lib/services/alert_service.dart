import 'dart:async';
import 'package:flutter/material.dart';
import '../main.dart';

class SOSAlert {
  static void showCountdown(BuildContext context) {
    int secondsLeft = 10;
    Timer? timer;

    showDialog(
      context: navigatorKey.currentContext!,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            timer ??= Timer.periodic(const Duration(seconds: 1), (t) {
              if (secondsLeft > 1) {
                setState(() => secondsLeft--);
              } else {
                t.cancel();
                Navigator.pop(context);
                _executeSOS();
              }
            });

            return AlertDialog(
              backgroundColor: Colors.red.shade900,
              title: const Text(
                "EMERGENCY DETECTED",
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    "Triggering SOS in:",
                    style: TextStyle(color: Colors.white70),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    "$secondsLeft",
                    style: const TextStyle(
                      fontSize: 60,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    timer?.cancel();
                    Navigator.pop(context);
                    // ignore: avoid_print
                    print("SOS Cancelled by user");
                  },
                  child: const Text(
                    "CANCEL",
                    style: TextStyle(color: Colors.yellow, fontSize: 18),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  static void _executeSOS() {
    // ignore: avoid_print
    print("CALLING SOS FUNCTION NOW!");
  }
}
