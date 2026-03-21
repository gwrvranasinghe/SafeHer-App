import 'dart:async';
import 'package:flutter/material.dart';

class SOSCountdownDialog extends StatefulWidget {
  final VoidCallback onConfirm;
  final VoidCallback onCancel;

  const SOSCountdownDialog({
    super.key,
    required this.onConfirm,
    required this.onCancel,
  });

  @override
  State<SOSCountdownDialog> createState() => _SOSCountdownDialogState();
}

class _SOSCountdownDialogState extends State<SOSCountdownDialog> {
  int _secondsLeft = 10;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_secondsLeft > 1) {
        setState(() => _secondsLeft--);
      } else {
        timer.cancel();
        Navigator.pop(context);
        widget.onConfirm();
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: Colors.red.shade900,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: const Text(
        "EMERGENCY DETECTED",
        textAlign: TextAlign.center,
        style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            "Sending SOS in:",
            style: TextStyle(color: Colors.white70),
          ),
          const SizedBox(height: 20),
          Text(
            "$_secondsLeft",
            style: const TextStyle(
              fontSize: 80,
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
      actions: [
        Center(
          child: TextButton(
            onPressed: () {
              Navigator.pop(context);
              widget.onCancel();
            },
            child: const Text(
              "CANCEL",
              style: TextStyle(
                color: Colors.yellow,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
