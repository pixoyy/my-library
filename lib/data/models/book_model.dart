class BookModel {
  final String title;
  final String author;
  final int? firstPublishYear;
  final String? coverId;
  final String workKey;
  String? description;
  List<String>? language;
  String? subjects;
  String? access;


  BookModel({
    required this.title,
    required this.author,
    this.firstPublishYear,
    this.coverId,
    required this.workKey,
    this.description,
    required this.language,
    this.subjects,
    this.access,
  });

  factory BookModel.fromJson(Map<String, dynamic> json) {
    return BookModel(
      title: json['title'] ?? '-',
      author:
          (json['author_name'] != null &&
              json['author_name'] is List &&
              json['author_name'].isNotEmpty)
          ? json['author_name'][0]
          : '-',
      firstPublishYear: json['first_publish_year'],
      coverId: json['cover_i']?.toString(),
      workKey: json['key'], // contoh: /works/OL45883W
      language: (json['language'] as List?)?.map((e) => e.toString()).toList(),
      subjects: json['subjects']?.toString(),
      access : json['ebook_access']?.toString(),

    );
  }
}
