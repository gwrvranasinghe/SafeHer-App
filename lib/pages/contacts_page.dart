import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:url_launcher/url_launcher.dart';
import '../widgets/floating_home_button.dart';

class ContactsPage extends StatefulWidget {
  const ContactsPage({super.key});

  @override
  State<ContactsPage> createState() => _ContactsPageState();
}

class _ContactsPageState extends State<ContactsPage> {
  final CollectionReference _contactsCollection = FirebaseFirestore.instance
      .collection('emergency_contacts');

  @override
  void initState() {
    super.initState();
    _initializeDefaultContacts();
  }

  Future<void> _initializeDefaultContacts() async {
    final snapshot = await _contactsCollection.get();
    if (snapshot.docs.isEmpty) {
      // Add default emergency contacts
      final defaultContacts = [
        {"name": "Mom", "phone": "0711111111"},
        {"name": "Dad", "phone": "0722222222"},
        {"name": "Police", "phone": "119"},
      ];

      for (var contact in defaultContacts) {
        await _contactsCollection.add(contact);
      }
    }
  }

  Future<void> _addContact(String name, String phone) async {
    try {
      await _contactsCollection.add({
        'name': name,
        'phone': phone,
        'createdAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error adding contact: $e')));
    }
  }

  Future<void> _deleteContact(String docId) async {
    try {
      await _contactsCollection.doc(docId).delete();
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Contact deleted')));
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error deleting contact: $e')));
    }
  }

  void _showAddContactDialog() {
    TextEditingController nameController = TextEditingController();
    TextEditingController phoneController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Add Emergency Contact"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(labelText: "Name"),
              ),
              TextField(
                controller: phoneController,
                decoration: const InputDecoration(labelText: "Phone"),
                keyboardType: TextInputType.phone,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel"),
            ),
            ElevatedButton(
              onPressed: () {
                if (nameController.text.isNotEmpty &&
                    phoneController.text.isNotEmpty) {
                  _addContact(nameController.text, phoneController.text);
                  Navigator.pop(context);
                }
              },
              child: const Text("Save"),
            ),
          ],
        );
      },
    );
  }

  Future<void> _makePhoneCall(String phoneNumber, String contactName) async {
    final Uri launchUri = Uri(scheme: 'tel', path: phoneNumber);
    try {
      if (await canLaunchUrl(launchUri)) {
        await launchUrl(launchUri);
      } else {
        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('Cannot call $contactName')));
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error calling $contactName: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Emergency Contacts")),
      body: StreamBuilder<QuerySnapshot>(
        stream: _contactsCollection.snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final contacts = snapshot.data!.docs;

          if (contacts.isEmpty) {
            return const Center(
              child: Text('No emergency contacts yet.\nTap + to add one.'),
            );
          }

          return ListView.builder(
            itemCount: contacts.length,
            itemBuilder: (context, index) {
              final contact = contacts[index].data() as Map<String, dynamic>;
              final docId = contacts[index].id;

              return Dismissible(
                key: Key(docId),
                direction: DismissDirection.endToStart,
                background: Container(
                  color: Colors.red,
                  alignment: Alignment.centerRight,
                  padding: const EdgeInsets.only(right: 20),
                  child: const Icon(Icons.delete, color: Colors.white),
                ),
                confirmDismiss: (direction) async {
                  return await showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        title: const Text("Delete Contact"),
                        content: Text(
                          "Are you sure you want to delete ${contact['name']}?",
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.of(context).pop(false),
                            child: const Text("Cancel"),
                          ),
                          TextButton(
                            onPressed: () => Navigator.of(context).pop(true),
                            child: const Text("Delete"),
                          ),
                        ],
                      );
                    },
                  );
                },
                onDismissed: (direction) {
                  _deleteContact(docId);
                },
                child: ListTile(
                  leading: const Icon(Icons.person),
                  title: Text(contact['name'] ?? 'Unknown'),
                  subtitle: Text(contact['phone'] ?? 'No phone'),
                  trailing: IconButton(
                    icon: const Icon(Icons.call),
                    onPressed: () {
                      _makePhoneCall(
                        contact['phone'] ?? '',
                        contact['name'] ?? 'Contact',
                      );
                    },
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton(
            heroTag: "add",
            backgroundColor: Colors.green,
            onPressed: _showAddContactDialog,
            child: const Icon(Icons.add),
          ),
          const SizedBox(height: 12),
          const FloatingHomeButton(),
        ],
      ),
    );
  }
}
