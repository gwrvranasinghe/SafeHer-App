import 'package:flutter/material.dart';
import '../widgets/floating_home_button.dart';

class ContactsPage extends StatelessWidget {
  const ContactsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Emergency Contacts")),
      body: ListView(
        children: const [
          ListTile(
            leading: Icon(Icons.person),
            title: Text("Mom"),
            subtitle: Text("0711111111"),
          ),
          ListTile(
            leading: Icon(Icons.person),
            title: Text("Dad"),
            subtitle: Text("0722222222"),
          ),
          ListTile(
            leading: Icon(Icons.person),
            title: Text("Police"),
            subtitle: Text("119"),
          ),
        ],
      ),
      floatingActionButton: const FloatingHomeButton(),
    );
  }
}
