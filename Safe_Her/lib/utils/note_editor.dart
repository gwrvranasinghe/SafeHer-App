import 'package:flutter/material.dart';
import 'note_model.dart';

class NoteEditor extends StatefulWidget {
  final Note? note;
  final VoidCallback onSecretUnlock;

  const NoteEditor({super.key, this.note, required this.onSecretUnlock});

  @override
  State<NoteEditor> createState() => _NoteEditorState();
}

class _NoteEditorState extends State<NoteEditor> {
  late TextEditingController titleController;
  late TextEditingController contentController;

  @override
  void initState() {
    super.initState();

    titleController = TextEditingController(text: widget.note?.title ?? "");

    contentController = TextEditingController(text: widget.note?.content ?? "");
  }

  void saveNote() {
    final note = Note(
      title: titleController.text.isEmpty ? "Untitled" : titleController.text,
      content: contentController.text,
    );

    Navigator.pop(context, note);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: [
          IconButton(icon: const Icon(Icons.save), onPressed: saveNote),
        ],
      ),

      body: Padding(
        padding: const EdgeInsets.all(16),

        child: Column(
          children: [
            TextField(
              controller: titleController,
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              decoration: const InputDecoration(
                hintText: "Title",
                border: InputBorder.none,
              ),
            ),

            Expanded(
              child: GestureDetector(
                onLongPress: () {
                  widget.onSecretUnlock();
                },

                child: TextField(
                  controller: contentController,
                  maxLines: null,
                  decoration: const InputDecoration(
                    hintText: "Start typing...",
                    border: InputBorder.none,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
