import 'package:flutter/material.dart'; // Added for showDialog
import 'package:speech_to_text/speech_to_text.dart';
import '../main.dart'; // 1. IMPORT your main.dart to access navigatorKey
import 'sos_service.dart';
import 'dart:async';

class SpeechService {
  final SpeechToText _speech = SpeechToText();
  final SOSService _sosService = SOSService();

  // Flag to prevent multiple dialogs from opening at once
  bool _isDialogShowing = false;

  Future<void> startListening() async {
    bool available = await _speech.initialize(
      onStatus: (status) {
        print("Status: $status");
        if (status == 'done' || status == 'notListening') {
          _rearmListener();
        }
      },
      onError: (error) => print("Error: $error"),
    );

    if (available) {
      _listen();
    } else {
      print("Speech recognition denied or not available");
    }
  }

  void _listen() {
    print("🎤 Listening for keywords...");
    _speech.listen(
      onResult: (result) {
        String words = result.recognizedWords.toLowerCase();
        print("Heard: $words");

        // 2. CHECK if keyword is heard AND a dialog isn't already open
        if ((words.contains("help") || words.contains("emergency")) &&
            !_isDialogShowing) {
          _showCountdownDialog();
        }
      },
      listenFor: const Duration(seconds: 30),
      pauseFor: const Duration(seconds: 5),
      cancelOnError: false,
      partialResults: true,
    );
  }

  // 3. THE NEW COUNTDOWN DIALOG FUNCTION
  void _showCountdownDialog() {
    final context = navigatorKey.currentContext;
    if (context == null) return;

    _isDialogShowing = true; // Block other triggers

    showDialog(
      context: context,
      barrierDismissible: false, // User must press CANCEL to stop
      builder: (BuildContext context) {
        return SOSCountdownDialog(
          onConfirm: () {
            _isDialogShowing = false;
            _sosService.triggerSOS(); // Call your existing SOS function
          },
          onCancel: () {
            _isDialogShowing = false;
            print("SOS Cancelled by user");
          },
        );
      },
    );
  }

  void _rearmListener() {
    Future.delayed(const Duration(milliseconds: 500), () {
      _listen();
    });
  }
}

// 4. THE DIALOG WIDGET (Add this at the bottom of the same file)
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
        Navigator.pop(context); // Close dialog
        widget.onConfirm(); // Trigger SOS
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
        "🚨 EMERGENCY DETECTED",
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
