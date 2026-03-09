
import 'package:flutter/material.dart';
import '../models/notebook.dart';

class CreateNotebookScreen extends StatefulWidget {
  const CreateNotebookScreen({super.key});

  @override
  State<CreateNotebookScreen> createState() => _CreateNotebookScreenState();
}

class _CreateNotebookScreenState extends State<CreateNotebookScreen> {

  final titleController = TextEditingController();
  final subtitleController = TextEditingController();
  final yearController = TextEditingController();

  void save() {
    final notebook = Notebook(
      title: titleController.text,
      subtitle: subtitleController.text,
      year: int.tryParse(yearController.text) ?? 2026,
    );

    Navigator.pop(context, notebook);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Create Notebook")),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            TextField(
              controller: titleController,
              decoration: const InputDecoration(labelText: "Title"),
            ),
            TextField(
              controller: subtitleController,
              decoration: const InputDecoration(labelText: "Subtitle"),
            ),
            TextField(
              controller: yearController,
              decoration: const InputDecoration(labelText: "Year"),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: save,
              child: const Text("Save"),
            )
          ],
        ),
      ),
    );
  }
}
