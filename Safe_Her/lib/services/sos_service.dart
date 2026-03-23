import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geolocator/geolocator.dart';
import 'package:telephony/telephony.dart';

class SOSService {
  final CollectionReference _contactsCollection = FirebaseFirestore.instance
      .collection('emergency_contacts');

  final Telephony telephony = Telephony.instance;

  Future<void> triggerSOS() async {
    // ignore: avoid_print
    print("HELP DETECTED - Initiating SOS");

    try {
      // Get Location
      Position position = await _determinePosition();
      String mapUrl =
          "https://www.google.com/maps/search/?api=1&query=${position.latitude},${position.longitude}";

      // Fetch Emergency Contacts from Firestore
      QuerySnapshot snapshot = await _contactsCollection.get();
      List<String> recipients = snapshot.docs
          .map(
            (doc) => (doc.data() as Map<String, dynamic>)['phone'].toString(),
          )
          .toList();

      if (recipients.isEmpty) {
        // ignore: avoid_print
        print("No contacts found to message.");
        return;
      }

      // Prepare and Send Message
      String message =
          "EMERGENCY! I need help. My current location is: $mapUrl";

      await _sendSMS(message, recipients);
    } catch (e) {
      // ignore: avoid_print
      print("Error in SOS Service: $e");
    }
  }

  // GPS coordinates
  Future<Position> _determinePosition() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) return Future.error('Location services are disabled.');

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return Future.error('Permission denied');
      }
    }

    return await Geolocator.getCurrentPosition();
  }

  Future<void> _sendSMS(String message, List<String> recipients) async {
    for (String number in recipients) {
      await telephony.sendSms(to: number, message: message, isMultipart: true);
    }
    // ignore: avoid_print
    print("SMS Sent directly to all contacts!");
  }
}
