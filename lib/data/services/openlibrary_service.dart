import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/book_model.dart';

class OpenLibraryService {
  static const _baseUrl = 'https://openlibrary.org';

  /// SEARCH BOOKS
  static Future<List<BookModel>> searchBooks(
    String query, {
    int page = 1,
    int limit = 20,
  }) async {
    // Search by title only
    final searchQuery = query.isEmpty ? 'fiction' : 'title:$query';
    final res = await http.get(
      Uri.parse('$_baseUrl/search.json?q=$searchQuery&page=$page&limit=$limit&lang=eng'),
    );

    final data = json.decode(res.body);
    final List docs = data['docs'];

    return docs.map((e) => BookModel.fromJson(e)).toList();
  }

  /// GET BOOK DESCRIPTION BY WORK KEY
  static Future<String?> fetchDescription(String workKey) async {
    final res = await http.get(
      Uri.parse('$_baseUrl$workKey.json'),
    );

    if (res.statusCode != 200) return null;

    final data = json.decode(res.body);

    final desc = data['description'];
    if (desc == null) return null;

    // kadang String, kadang Map
    if (desc is String) return desc;
    if (desc is Map && desc['value'] != null) return desc['value'];

    return null;
  }
}
