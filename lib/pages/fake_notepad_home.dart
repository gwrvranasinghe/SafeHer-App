import 'package:flutter/material.dart';
import 'note_model.dart';
import 'note_editor.dart';

class FakeNotepadHome extends StatefulWidget {
  final VoidCallback onSecretUnlock;

  const FakeNotepadHome({super.key, required this.onSecretUnlock});

  @override
  State<FakeNotepadHome> createState() => _FakeNotepadHomeState();
}

class _FakeNotepadHomeState extends State<FakeNotepadHome> {
  List<Note> notes = [];

  void addNote(Note note) {
    setState(() {
      notes.add(note);
    });
  }

  void openEditor({Note? note}) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            NoteEditor(note: note, onSecretUnlock: widget.onSecretUnlock),
      ),
    );

    if (result != null) {
      addNote(result);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Notes")),

      body: notes.isEmpty
          ? const Center(child: Text("No notes yet"))
          : ListView.builder(
              itemCount: notes.length,
              itemBuilder: (context, index) {
                final note = notes[index];

                return ListTile(
                  title: Text(note.title),
                  subtitle: Text(
                    note.content,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  onTap: () {
                    openEditor(note: note);
                  },
                );
              },
            ),

      floatingActionButton: FloatingActionButton(
        onPressed: () {
          openEditor();
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
