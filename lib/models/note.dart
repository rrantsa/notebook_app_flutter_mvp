class Note {
  int? id;
  int notebookId;
  String date;
  String title;
  String caption;
  String? imagePath;

  Note({
    this.id,
    required this.notebookId,
    required this.date,
    required this.title,
    required this.caption,
    this.imagePath,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'notebookId': notebookId,
      'date': date,
      'title': title,
      'caption': caption,
      'imagePath': imagePath,
    };
  }

  factory Note.fromMap(Map<String, dynamic> map) {
    return Note(
      id: map['id'] as int?,
      notebookId: map['notebookId'] as int,
      date: map['date'] as String,
      title: map['title'] as String,
      caption: map['caption'] as String,
      imagePath: map['imagePath'] as String?,
    );
  }
}