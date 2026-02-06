import 'package:flutter/material.dart';
import '../core/theme/app_theme.dart';
import '../data/models/book_model.dart';
import '../data/fake_db/auth_store.dart';
import '../features/home/book_detail_page.dart';

class BookCard extends StatefulWidget {
  final BookModel book;
  final String? searchQuery;
  const BookCard({super.key, required this.book, this.searchQuery});

  @override
  State<BookCard> createState() => _BookCardState();
}

class _BookCardState extends State<BookCard> {
  /// ambil email user dengan aman
  String? get _email => AuthStore.currentUser?.email;

  /// ambil list bookmark user, auto fallback []
  List<BookModel> get _bookmarks {
    if (_email == null) return [];
    return AuthStore.bookmarks[_email!] ?? [];
  }

  bool get isBookmarks {
    return _bookmarks.any((b) => b.title == widget.book.title);
  }

  void toggleBookmark() {
    if (_email == null) {
      _showCustomSnackBar('Please login to bookmark', false);
      return;
    }

    AuthStore.bookmarks.putIfAbsent(_email!, () => []);

    final wasBookmarked = isBookmarks;
    setState(() {
      wasBookmarked
          ? AuthStore.bookmarks[_email!]!.removeWhere(
              (b) => b.title == widget.book.title,
            )
          : AuthStore.bookmarks[_email!]!.add(widget.book);
    });

    _showCustomSnackBar(
      wasBookmarked
          ? '"${widget.book.title}" removed from bookmarks'
          : '"${widget.book.title}" added to bookmarks',
      !wasBookmarked,
    );
  }

  void _showCustomSnackBar(String message, bool isSuccess) {
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              isSuccess ? Icons.check_circle_outline : Icons.info_outline,
              color: Colors.white,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ),
        backgroundColor: isSuccess ? AppTheme.autumn : Colors.grey[700],
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  Widget _buildHighlightedTitle(String title, String? query) {
    if (query == null || query.isEmpty) {
      return Text(title, maxLines: 2, overflow: TextOverflow.ellipsis);
    }

    final lowerTitle = title.toLowerCase();
    final lowerQuery = query.toLowerCase();

    if (!lowerTitle.contains(lowerQuery)) {
      return Text(title, maxLines: 2, overflow: TextOverflow.ellipsis);
    }

    final spans = <TextSpan>[];
    var start = 0;

    while (true) {
      final index = lowerTitle.indexOf(lowerQuery, start);
      if (index == -1) {
        spans.add(TextSpan(text: title.substring(start)));
        break;
      }

      if (index > start) {
        spans.add(TextSpan(text: title.substring(start, index)));
      }

      spans.add(
        TextSpan(
          text: title.substring(index, index + query.length),
          style: const TextStyle(
            backgroundColor: Colors.yellow,
            fontWeight: FontWeight.bold,
          ),
        ),
      );

      start = index + query.length;
    }

    return RichText(
      maxLines: 2,
      overflow: TextOverflow.ellipsis,
      text: TextSpan(
        style: DefaultTextStyle.of(context).style,
        children: spans,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () async {
        await Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => BookDetailPage(book: widget.book)),
        );
        // Refresh state setelah kembali dari detail page
        if (mounted) setState(() {});
      },
      child: Card(
        elevation: 2,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Hero(
                tag: 'book_cover_${widget.book.title}',
                child: widget.book.coverId != null
                    ? Image.network(
                        'https://covers.openlibrary.org/b/id/${widget.book.coverId}-M.jpg',
                        width: double.infinity,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) =>
                            const Icon(Icons.book, size: 80),
                      )
                    : const Icon(Icons.book, size: 80),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHighlightedTitle(widget.book.title, widget.searchQuery),
                  Text(
                    widget.book.author,
                    style: const TextStyle(fontSize: 12),
                  ),
                  Text(
                    'Year: ${widget.book.firstPublishYear ?? '-'}',
                    style: const TextStyle(fontSize: 11),
                  ),
                  Align(
                    alignment: Alignment.centerRight,
                    child: IconButton(
                      icon: Icon(
                        isBookmarks ? Icons.bookmark : Icons.bookmark_border,
                        color: isBookmarks ? AppTheme.autumn : Colors.grey,
                      ),
                      onPressed: toggleBookmark,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
