import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_to_text.dart';
import '../main.dart';
import 'sos_service.dart';
import '../widgets/sos_countdown_dialog.dart';
import 'dart:async';

class SpeechService {
  final SpeechToText _speech = SpeechToText();
  final SOSService _sosService = SOSService();

  bool _isDialogShowing = false;

  Future<void> startListening() async {
    bool available = await _speech.initialize(
      onStatus: (status) {
        // ignore: avoid_print
        print("Status: $status");
        if (status == 'done' || status == 'notListening') {
          _rearmListener();
        }
      },
      // ignore: avoid_print
      onError: (error) => print("Error: $error"),
    );

    if (available) {
      _listen();
    } else {
      // ignore: avoid_print
      print("Speech recognition denied or not available");
    }
  }

  void _listen() {
    // ignore: avoid_print
    print("🎤 Listening for keywords...");
    _speech.listen(
      onResult: (result) {
        String words = result.recognizedWords.toLowerCase();
        // ignore: avoid_print
        print("Heard: $words");

        if ((words.contains("help") || words.contains("emergency")) &&
            !_isDialogShowing) {
          _showCountdownDialog();
        }
      },
      listenFor: const Duration(seconds: 30),
      pauseFor: const Duration(seconds: 5),
      // ignore: deprecated_member_use
      cancelOnError: false,
      // ignore: deprecated_member_use
      partialResults: true,
    );
  }

  void _showCountdownDialog() {
    final context = navigatorKey.currentContext;
    if (context == null) return;

    _isDialogShowing = true;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return SOSCountdownDialog(
          onConfirm: () {
            _isDialogShowing = false;
            _sosService.triggerSOS();
          },
          onCancel: () {
            _isDialogShowing = false;
            // ignore: avoid_print
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
