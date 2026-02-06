import 'dart:ui';
import 'package:flutter/material.dart';
// import 'package:flutter/gestures.dart';
import '../../data/models/book_model.dart';
import '../../data/services/openlibrary_service.dart';
import '../../data/fake_db/auth_store.dart';
import '../../core/theme/app_theme.dart';

class BookDetailPage extends StatefulWidget {
  final BookModel book;
  const BookDetailPage({super.key, required this.book});

  @override
  State<BookDetailPage> createState() => _BookDetailPageState();
}

class _BookDetailPageState extends State<BookDetailPage> {
  late ScrollController _scrollController;
  bool _showTitle = false;
  static const double _expandedHeight = 420.0;
  bool isLoading = true;

  String? get _email => AuthStore.currentUser?.email;

  List<BookModel> get _bookmarks {
    if (_email == null) return [];
    return AuthStore.bookmarks[_email!] ?? [];
  }

  bool get isBookmark {
    return _bookmarks.any((b) => b.title == widget.book.title);
  }

  void toggleBookmark() {
    if (_email == null) return;

    AuthStore.bookmarks.putIfAbsent(_email!, () => []);

    setState(() {
      isBookmark
          ? AuthStore.bookmarks[_email!]!.removeWhere(
              (b) => b.title == widget.book.title,
            )
          : AuthStore.bookmarks[_email!]!.add(widget.book);
    });
  }

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController()..addListener(_scrollListener);
    _loadDescription();
  }

  void _scrollListener() {
    if (_scrollController.hasClients) {
      // Threshold is when the expanded height minus toolbar height is scrolled past
      final threshold = _expandedHeight - kToolbarHeight;
      if (_scrollController.offset > threshold && !_showTitle) {
        setState(() => _showTitle = true);
      } else if (_scrollController.offset <= threshold && _showTitle) {
        setState(() => _showTitle = false);
      }
    }
  }

  Future<void> _loadDescription() async {
    final desc = await OpenLibraryService.fetchDescription(widget.book.workKey);
    if (mounted) {
      setState(() {
        widget.book.description =
            desc ?? 'No description available for this book.';
        isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _scrollController.removeListener(_scrollListener);
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.cream,
      body: CustomScrollView(
        controller: _scrollController,
        slivers: [
          _buildSliverAppBar(),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeaderInfo(),
                  const SizedBox(height: 24),
                  _buildBookStats(),
                  const SizedBox(height: 24),
                  _buildDescription(),
                  const SizedBox(height: 100), // Bottom padding
                ],
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: _buildFloatingBookmarkButton(),
    );
  }

  Widget _buildSliverAppBar() {
    return SliverAppBar(
      expandedHeight: 420,
      pinned: true,
      backgroundColor: AppTheme.brown,
      title: _showTitle
          ? Text(
              widget.book.title,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            )
          : null,
      centerTitle: true,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
        onPressed: () => Navigator.pop(context),
      ),
      flexibleSpace: FlexibleSpaceBar(
        background: Stack(
          fit: StackFit.expand,
          children: [
            // Blurry Background
            widget.book.coverId != null
                ? Image.network(
                    'https://covers.openlibrary.org/b/id/${widget.book.coverId}-L.jpg',
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(color: AppTheme.brown);
                    },
                  )
                : Container(color: AppTheme.brown),

            // Blur Effect
            BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
              child: Container(color: AppTheme.brown.withOpacity(0.3)),
            ),

            // Gradient Overlay
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withOpacity(0.3),
                    Colors.transparent,
                    AppTheme.cream.withOpacity(0.8),
                    AppTheme.cream,
                  ],
                  stops: const [0.0, 0.4, 0.9, 1.0],
                ),
              ),
            ),

            // Main Cover Image
            Center(
              child: Padding(
                padding: const EdgeInsets.only(top: 60),
                child: Hero(
                  tag: 'book_cover_${widget.book.title}',
                  child: Container(
                    height: 280,
                    width: 190,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.3),
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: widget.book.coverId != null
                          ? Image.network(
                              'https://covers.openlibrary.org/b/id/${widget.book.coverId}-L.jpg',
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return Container(
                                  color: Colors.white,
                                  child: const Icon(
                                    Icons.book,
                                    size: 80,
                                    color: AppTheme.brown,
                                  ),
                                );
                              },
                            )
                          : Container(
                              color: Colors.white,
                              child: const Icon(
                                Icons.book,
                                size: 80,
                                color: AppTheme.brown,
                              ),
                            ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeaderInfo() {
    return Column(
      children: [
        Text(
          widget.book.title,
          textAlign: TextAlign.start,
          style: const TextStyle(
            fontSize: 26,
            fontWeight: FontWeight.bold,
            fontFamily: 'Serif', 
            color: Color(0xFF2D2D2D),
            height: 1.2,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          widget.book.author,
          textAlign: TextAlign.start,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: AppTheme.brown.withOpacity(0.8),
          ),
        ),
      ],
    );
  }

  Widget _buildBookStats() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppTheme.brown.withOpacity(0.08),
            blurRadius: 15,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          // _buildStatItem(
          //   icon: Icons.person,
          //   label: 'Author',
          //   value: widget.book.author,
          // ),
          // Container(height: 40, width: 1, color: Colors.grey.withOpacity(0.2)),
          _buildStatItem(
            icon: Icons.calendar_today,
            label: 'Published',
            value: widget.book.firstPublishYear?.toString() ?? 'N/A',
          ),
          Container(height: 40, width: 1, color: Colors.grey.withOpacity(0.2)),
          _buildStatItem(
            icon: Icons.translate,
            label: 'Language',
            value:
                widget.book.language?.take(2).join(', ').toUpperCase() ?? 'N/A',
          ),
          Container(height: 40, width: 1, color: Colors.grey.withOpacity(0.2)),
          _buildStatItem(
            icon: Icons.public,
            label: 'Ebook Access',
            value: (widget.book.access ?? 'N/A').toUpperCase(),
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Column(
      children: [
        Icon(icon, color: AppTheme.autumn, size: 22),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 15,
            color: Color(0xFF2D2D2D),
          ),
        ),
        Text(
          label,
          style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
        ),
      ],
    );
  }

  Widget _buildDescription() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'About this Book',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Color(0xFF2D2D2D),
          ),
        ),
        const SizedBox(height: 12),
        isLoading
            ? const Center(
                child: Padding(
                  padding: EdgeInsets.all(20),
                  child: CircularProgressIndicator(color: AppTheme.autumn),
                ),
              )
            : _ExpandableDescription(
                text: widget.book.description ?? 'No description available.',
              ),
      ],
    );
  }

  Widget _buildFloatingBookmarkButton() {
    return FloatingActionButton.extended(
      onPressed: toggleBookmark,
      backgroundColor: isBookmark ? Colors.red.shade400 : AppTheme.brown,
      icon: Icon(
        isBookmark ? Icons.bookmark_remove : Icons.bookmark_add,
        color: Colors.white,
      ),
      label: Text(
        isBookmark ? 'Remove Bookmark' : 'Bookmark',
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _ExpandableDescription extends StatefulWidget {
  final String text;
  final int maxLines;

  const _ExpandableDescription({required this.text, this.maxLines = 6});

  @override
  State<_ExpandableDescription> createState() => _ExpandableDescriptionState();
}

class _ExpandableDescriptionState extends State<_ExpandableDescription> {
  bool isExpanded = false;

  @override
  Widget build(BuildContext context) {
    return AnimatedSize(
      duration: const Duration(milliseconds: 300),
      alignment: Alignment.topCenter,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.text,
            maxLines: isExpanded ? null : widget.maxLines,
            overflow: isExpanded ? TextOverflow.visible : TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 15,
              height: 1.6,
              color: Color(0xFF555555),
            ),
          ),
          if (widget.text.length > 200) ...[
            const SizedBox(height: 8),
            GestureDetector(
              onTap: () => setState(() => isExpanded = !isExpanded),
              child: Text(
                isExpanded ? 'Read Less' : 'Read More',
                style: const TextStyle(
                  color: AppTheme.autumn,
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
