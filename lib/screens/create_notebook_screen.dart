
import 'package:flutter/material.dart';
import '../models/notebook.dart';
import '../database/database_helper.dart';

class CreateNotebookScreen extends StatefulWidget {
  final Notebook? notebook;

  const CreateNotebookScreen({
    super.key,
    this.notebook,
  });

  @override
  State<CreateNotebookScreen> createState() => _CreateNotebookScreenState();
}

class _CreateNotebookScreenState extends State<CreateNotebookScreen> {
  final _formKey = GlobalKey<FormState>();

  final _titleController = TextEditingController();
  final _subtitleController = TextEditingController();
  final _yearController = TextEditingController();

  bool _isSaving = false;

  bool get isEditMode => widget.notebook != null;

  @override
  void initState() {
    super.initState();

    if (isEditMode) {
      _titleController.text = widget.notebook!.title;
      _subtitleController.text = widget.notebook!.subtitle;
      _yearController.text = widget.notebook!.year.toString();
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _subtitleController.dispose();
    _yearController.dispose();
    super.dispose();
  }

  Future<void> _saveNotebook() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isSaving = true;
    });

    final notebook = Notebook(
      id: widget.notebook?.id,
      title: _titleController.text.trim(),
      subtitle: _subtitleController.text.trim(),
      year: int.parse(_yearController.text.trim()),
    );

    if (isEditMode) {
      await DatabaseHelper.instance.updateNotebook(notebook);
    } else {
      await DatabaseHelper.instance.insertNotebook(notebook);
    }

    if (!mounted) return;

    Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(isEditMode ? 'Edit Notebook' : 'Create Notebook'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: 'Title',
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter a title';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _subtitleController,
                decoration: const InputDecoration(
                  labelText: 'Subtitle',
                ),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _yearController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Year',
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter a year';
                  }

                  final year = int.tryParse(value.trim());
                  if (year == null) {
                    return 'Please enter a valid year';
                  }

                  return null;
                },
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isSaving ? null : _saveNotebook,
                  child: Text(isEditMode ? 'Save Changes' : 'Create Notebook'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
