import 'dart:io';
import 'package:flutter/material.dart';
import '../models/notebook.dart';
import '../models/note.dart';
import '../database/database_helper.dart';
import 'create_note_screen.dart';

class NotebookDetailScreen extends StatefulWidget {
  final Notebook notebook;

  const NotebookDetailScreen({super.key, required this.notebook});

  @override
  State<NotebookDetailScreen> createState() => _NotebookDetailScreenState();
}

class _NotebookDetailScreenState extends State<NotebookDetailScreen> {
  List<Note> notes = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadNotes();
  }

  Future<void> _loadNotes() async {
    if (widget.notebook.id == null) return;

    final loadedNotes = await DatabaseHelper.instance.getNotesByNotebookId(
      widget.notebook.id!,
    );

    setState(() {
      notes = loadedNotes;
      _isLoading = false;
    });
  }

  Future<void> addNote(Note note) async {
    await DatabaseHelper.instance.insertNote(note);
    await _loadNotes();
  }

  Future<void> editNote(Note note) async {
    final updatedNote = await Navigator.push<Note>(
      context,
      MaterialPageRoute(
        builder: (_) => CreateNoteScreen(
          notebookId: widget.notebook.id!,
          existingNote: note,
        ),
      ),
    );

    if (updatedNote != null) {
      await DatabaseHelper.instance.updateNote(updatedNote);
      await _loadNotes();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.notebook.title),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : notes.isEmpty
              ? const Center(
                  child: Text('No notes yet. Tap + to create one.'),
                )
              : ListView.builder(
                  itemCount: notes.length,
                  itemBuilder: (context, index) {
                    final note = notes[index];
                    return Card(
                      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      child: ListTile(
                        contentPadding: const EdgeInsets.all(12),
                        leading: note.imagePath != null
                            ? ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: Image.file(
                                  File(note.imagePath!),
                                  width: 60,
                                  height: 60,
                                  fit: BoxFit.cover,
                                ),
                              )
                            : const Icon(Icons.image_not_supported),
                        title: Text(note.title),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(note.date),
                            const SizedBox(height: 4),
                            Text(
                              note.caption,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.edit),
                              onPressed: () => editNote(note),
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () async {
                                if (note.id == null) return;

                                final confirm = await showDialog<bool>(
                                  context: context,
                                  builder: (context) => AlertDialog(
                                    title: const Text('Delete note'),
                                    content: const Text('Are you sure you want to delete this note?'),
                                    actions: [
                                      TextButton(
                                        onPressed: () => Navigator.pop(context, false),
                                        child: const Text('Cancel'),
                                      ),
                                      TextButton(
                                        onPressed: () => Navigator.pop(context, true),
                                        child: const Text('Delete'),
                                      ),
                                    ],
                                  ),
                                );

                                if (confirm == true) {
                                  await DatabaseHelper.instance.deleteNote(note.id!);
                                  await _loadNotes();
                                }
                              },
                            ),
                          ],
                        ),
                      ),
                    );

                  },
                ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.note_add),
        onPressed: () async {
          final note = await Navigator.push<Note>(
            context,
            MaterialPageRoute(
              builder: (_) => CreateNoteScreen(
                notebookId: widget.notebook.id ?? 0,
              ),
            ),
          );

          if (note != null) {
            await addNote(note);
          }
        },
      ),
    );
  }
}