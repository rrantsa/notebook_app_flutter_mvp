import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import '../models/note.dart';

class CreateNoteScreen extends StatefulWidget {
  final int notebookId;

  const CreateNoteScreen({super.key, required this.notebookId});

  @override
  State<CreateNoteScreen> createState() => _CreateNoteScreenState();
}

class _CreateNoteScreenState extends State<CreateNoteScreen> {
  final titleController = TextEditingController();
  final captionController = TextEditingController();
  final dateController = TextEditingController();

  String? selectedImagePath;

  Future<void> pickImage() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.image,
      allowMultiple: false,
    );

    if (result != null && result.files.single.path != null) {
      setState(() {
        selectedImagePath = result.files.single.path!;
      });
    }
  }

  void save() {
    final note = Note(
      notebookId: widget.notebookId,
      title: titleController.text.trim(),
      caption: captionController.text.trim(),
      date: dateController.text.trim(),
      imagePath: selectedImagePath,
    );

    Navigator.pop(context, note);
  }

  @override
  void dispose() {
    titleController.dispose();
    captionController.dispose();
    dateController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Create Note")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: titleController,
              decoration: const InputDecoration(labelText: "Title"),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: dateController,
              decoration: const InputDecoration(labelText: "Date"),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: captionController,
              decoration: const InputDecoration(labelText: "Caption"),
              maxLines: 3,
            ),
            const SizedBox(height: 20),
            OutlinedButton.icon(
              onPressed: pickImage,
              icon: const Icon(Icons.image),
              label: const Text("Choose image"),
            ),
            const SizedBox(height: 12),
            if (selectedImagePath != null)
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.file(
                  File(selectedImagePath!),
                  height: 220,
                  fit: BoxFit.cover,
                ),
              ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: save,
              child: const Text("Save Note"),
            ),
          ],
        ),
      ),
    );
  }
}