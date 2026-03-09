import 'dart:io';

import 'package:flutter/material.dart';
import '../models/note.dart';
import 'package:image_picker/image_picker.dart';
import '../services/image_service.dart';

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

  File? selectedImage;

Future<void> pickImage() async {

  final picker = ImagePicker();

  final picked = await picker.pickImage(
    source: ImageSource.gallery,
  );

  if (picked != null) {
    setState(() {
      selectedImage = File(picked.path);
    });
  }
}

  Future<void> save() async {
    String? imagePath;
    if (selectedImage != null) {
      imagePath = await ImageService.copyImage(selectedImage!);
    }
    final note = Note(
      notebookId: widget.notebookId,
      title: titleController.text.trim(),
      caption: captionController.text.trim(),
      date: dateController.text.trim(),
      imagePath: imagePath,
    );
    if (!mounted) return;
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
            ElevatedButton(
              onPressed: pickImage,
              child: Text("Select image"),
            ),
            const SizedBox(height: 12),
            if (selectedImage != null)
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.file(
                selectedImage!,
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