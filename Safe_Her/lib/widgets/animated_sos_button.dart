import 'package:flutter/material.dart';
import '../services/sos_service.dart';

class AnimatedSOSButton extends StatefulWidget {
  const AnimatedSOSButton({super.key});

  @override
  State<AnimatedSOSButton> createState() => _AnimatedSOSButtonState();
}

class _AnimatedSOSButtonState extends State<AnimatedSOSButton>
    with SingleTickerProviderStateMixin {
  late AnimationController controller;
  late Animation<double> animation;

  // 1. Create a single instance of your service
  final SOSService _sosService = SOSService();

  @override
  void initState() {
    super.initState();

    controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    );

    animation = Tween<double>(begin: 1, end: 1.15).animate(controller);
    controller.repeat(reverse: true);
  }

  @override
  void dispose() {
    // 2. CRITICAL: Stop the animation controller when the widget is destroyed
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      // 3. Trigger the SOS function directly on tap
      onTap: () async {
        // This starts getting GPS and fetching Firebase contacts instantly
        await _sosService.triggerSOS();

        // Optional: Show a quick toast/snack to confirm it was pressed
        if (mounted) {
          // ignore: use_build_context_synchronously
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("SOS Initiated! Sending location..."),
              backgroundColor: Colors.redAccent,
            ),
          );
        }
      },
      child: ScaleTransition(
        scale: animation,
        child: Container(
          width: 180,
          height: 180,
          decoration: BoxDecoration(
            color: Colors.red,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                // ignore: deprecated_member_use
                color: Colors.red.withOpacity(0.5),
                blurRadius: 25,
                spreadRadius: 5,
              ),
            ],
          ),
          child: const Center(
            child: Text(
              "SOS",
              style: TextStyle(
                color: Colors.white,
                fontSize: 40,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
