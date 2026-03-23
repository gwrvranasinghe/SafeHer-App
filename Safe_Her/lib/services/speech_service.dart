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
  bool _isInitialized = false;

  Future<void> startListening() async {
    if (!_isInitialized) {
      _isInitialized = await _speech.initialize(
        onStatus: (status) {
          debugPrint("Status: $status");
          if ((status == 'done' || status == 'notListening') &&
              !_isDialogShowing) {
            _rearmListener();
          }
        },
        onError: (error) => debugPrint("Error: $error"),
      );
    }

    if (_isInitialized) {
      _listen();
    } else {
      debugPrint("Speech recognition denied or not available");
    }
  }

  void stopListening() {
    _speech.stop();
    _speech.cancel();
  }

  void _listen() {
    if (_speech.isListening) return;

    debugPrint("🎤 Listening for keywords...");
    _speech.listen(
      onResult: (result) {
        String words = result.recognizedWords.toLowerCase();
        debugPrint("Heard: $words");

        if ((words.contains("help") || words.contains("emergency")) &&
            !_isDialogShowing) {
          _speech.stop();
          _showCountdownDialog();
        }
      },
      listenFor: const Duration(seconds: 30),
      pauseFor: const Duration(seconds: 5),
      // ignore: deprecated_member_use
      listenMode: ListenMode.deviceDefault, // Better for Android stability
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
            startListening();
            debugPrint("SOS Cancelled by user");
          },
        );
      },
    );
  }

  void _rearmListener() {
    Future.delayed(const Duration(milliseconds: 800), () {
      if (!_isDialogShowing) {
        _listen();
      }
    });
  }
}
