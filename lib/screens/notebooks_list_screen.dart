import 'package:flutter/material.dart';

import '../database/database_helper.dart';
import '../models/notebook.dart';
import 'create_notebook_screen.dart';
import 'notebook_detail_screen.dart';

class NotebooksListScreen extends StatefulWidget {
  const NotebooksListScreen({super.key});

  @override
  State<NotebooksListScreen> createState() => _NotebooksListScreenState();
}

class _NotebooksListScreenState extends State<NotebooksListScreen> {
  List<Notebook> _notebooks = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadNotebooks();
  }

  Future<void> _loadNotebooks() async {
    setState(() {
      _isLoading = true;
    });

    final notebooks = await DatabaseHelper.instance.getNotebooks();

    setState(() {
      _notebooks = notebooks;
      _isLoading = false;
    });
  }

Future<void> _goToCreateNotebookScreen() async {
  final created = await Navigator.push<bool>(
    context,
    MaterialPageRoute(
      builder: (context) => const CreateNotebookScreen(),
    ),
  );

  if (created == true) {
    await _loadNotebooks();
  }
}

  Future<void> _deleteNotebook(int id) async {
    await DatabaseHelper.instance.deleteNotebook(id);
    await _loadNotebooks();
  }

  void _openNotebook(Notebook notebook) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => NotebookDetailScreen(notebook: notebook),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Notebooks'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _notebooks.isEmpty
              ? const Center(
                  child: Text(
                    'No notebook yet.\nTap + to create your first notebook.',
                    textAlign: TextAlign.center,
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _loadNotebooks,
                  child: ListView.builder(
                    itemCount: _notebooks.length,
                    itemBuilder: (context, index) {
                      final notebook = _notebooks[index];

                      return Card(
                        margin: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        child: ListTile(
                          title: Text(notebook.title),
                          subtitle: Text(
                            '${notebook.subtitle} • ${notebook.year}',
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.edit_outlined),
                                onPressed: () async {
                                  final updated = await Navigator.push<bool>(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          CreateNotebookScreen(notebook: notebook),
                                    ),
                                  );
                                  if (updated == true) {
                                    await _loadNotebooks();
                                  }
                                },
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete_outline),
                                onPressed: () async {
                                  final confirmed = await showDialog<bool>(
                                    context: context,
                                    builder: (context) => AlertDialog(
                                      title: const Text('Delete notebook'),
                                      content: Text(
                                        'Do you want to delete "${notebook.title}"?',
                                      ),
                                      actions: [
                                        TextButton(
                                          onPressed: () =>
                                              Navigator.pop(context, false),
                                          child: const Text('Cancel'),
                                        ),
                                        TextButton(
                                          onPressed: () =>
                                              Navigator.pop(context, true),
                                          child: const Text('Delete'),
                                        ),
                                      ],
                                    ),
                                  );

                                  if (confirmed == true && notebook.id != null) {
                                    await _deleteNotebook(notebook.id!);
                                  }
                                },
                              )
                            ]
                          ),
                          onTap: () => _openNotebook(notebook),
                          ),
                      );
                    },
                  ),
                ),
      floatingActionButton: FloatingActionButton(
        onPressed: _goToCreateNotebookScreen,
        child: const Icon(Icons.add),
      ),
    );
  }
}