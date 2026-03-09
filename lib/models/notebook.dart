class Notebook {
  int? id;
  String title;
  int year;
  String subtitle;

  Notebook({
    this.id,
    required this.title,
    required this.year,
    required this.subtitle,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'year': year,
      'subtitle': subtitle,
    };
  }

  factory Notebook.fromMap(Map<String, dynamic> map) {
    return Notebook(
      id: map['id'] as int?,
      title: map['title'] as String,
      year: map['year'] as int,
      subtitle: map['subtitle'] as String,
    );
  }
}