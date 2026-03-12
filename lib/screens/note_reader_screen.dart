import 'dart:io';
import 'package:flutter/material.dart';
import '../models/note.dart';
import '../models/notebook.dart';

class NoteReaderScreen extends StatefulWidget {
  final Notebook notebook;
  final List<Note> notes;
  final int initialIndex;

  const NoteReaderScreen({
    super.key,
    required this.notebook,
    required this.notes,
    required this.initialIndex,
  });

  @override
  State<NoteReaderScreen> createState() => _NoteReaderScreenState();
}

class _NoteReaderScreenState extends State<NoteReaderScreen> {
  late PageController _pageController;
  late List<Note> _sortedNotes;
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();

    _sortedNotes = List.from(widget.notes);

    _currentIndex = widget.initialIndex;

    _pageController = PageController(
      initialPage: widget.initialIndex,
    );
  }

  void _next() {
    if (_currentIndex < _sortedNotes.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 250),
        curve: Curves.ease,
      );
    }
  }

  void _previous() {
    if (_currentIndex > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 250),
        curve: Curves.ease,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,

      appBar: AppBar(
        title: Text(widget.notebook.title),
      ),

      body: PageView.builder(
        controller: _pageController,
        itemCount: _sortedNotes.length,
        onPageChanged: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        itemBuilder: (context, index) {
          final note = _sortedNotes[index];

          return Padding(
            padding: const EdgeInsets.all(40),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [

                Text(
                  note.date,
                  style: const TextStyle(
                    fontSize: 16,
                    color: Colors.grey,
                  ),
                ),

                const SizedBox(height: 8),

                Text(
                  note.title,
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 24),

                if (note.imagePath != null)
                  Center(
                    child: Image.file(
                      File(note.imagePath!),
                      height: 250,
                      fit: BoxFit.contain,
                    ),
                  ),

                const SizedBox(height: 24),

                Text(
                  note.caption ?? "",
                  style: const TextStyle(
                    fontSize: 18,
                    height: 1.4,
                  ),
                ),

                const Spacer(),

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [

                    Text(
                      "${_currentIndex + 1} / ${_sortedNotes.length}",
                      style: const TextStyle(
                        color: Colors.grey,
                      ),
                    ),

                    Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.arrow_back),
                          onPressed: _previous,
                        ),
                        IconButton(
                          icon: const Icon(Icons.arrow_forward),
                          onPressed: _next,
                        ),
                      ],
                    )
                  ],
                )
              ],
            ),
          );
        },
      ),
    );
  }
}