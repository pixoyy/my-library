import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../../data/fake_db/auth_store.dart';
import '../../data/models/book_model.dart';
import '../../widgets/book_card.dart';

class BookmarkPage extends StatefulWidget {
  const BookmarkPage({super.key});

  @override
  State<BookmarkPage> createState() => _BookmarkPageState();
}

class _BookmarkPageState extends State<BookmarkPage> {
  final ScrollController _scrollController = ScrollController();
  bool _showScrollToTop = false;

  List<BookModel> get bookmarks {
    final email = AuthStore.currentUser?.email;
    if (email == null) return [];
    return AuthStore.bookmarks[email] ?? [];
  }

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_handleScroll);
  }

  void _handleScroll() {
    final shouldShow = _scrollController.offset > 300;
    if (shouldShow != _showScrollToTop) {
      setState(() {
        _showScrollToTop = shouldShow;
      });
    }
  }

  void scrollToTop() {
    _scrollController.animateTo(
      0,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOut,
    );
  }

  @override
  void dispose() {
    _scrollController.removeListener(_handleScroll);
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
          // SliverAppBar(
          //   pinned: true,
          //   floating: true,
          //   backgroundColor: AppTheme.brown,
          //   expandedHeight: 120,
          //   flexibleSpace: FlexibleSpaceBar(
          //     title: const Text(
          //       'My Bookmarks',
          //       style: TextStyle(
          //         color: Colors.white,
          //         fontWeight: FontWeight.bold,
          //       ),
          //     ),
          //     centerTitle: true,
          //     background: Container(
          //       decoration: BoxDecoration(
          //         gradient: LinearGradient(
          //           begin: Alignment.topCenter,
          //           end: Alignment.bottomCenter,
          //           colors: [
          //             AppTheme.brown,
          //             AppTheme.brown.withOpacity(0.8),
          //           ],
          //         ),
          //       ),
          //     ),
          //   ),
          // ),
          if (bookmarks.isEmpty)
            SliverFillRemaining(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.bookmarks_outlined,
                      size: 80,
                      color: AppTheme.brown.withOpacity(0.5),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'No bookmarks yet',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.brown.withOpacity(0.8),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Start adding your favorite books!',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
            )
          else
            SliverPadding(
              padding: const EdgeInsets.all(16),
              sliver: SliverGrid(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  childAspectRatio: 0.65,
                ),
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    return BookCard(book: bookmarks[index]);
                  },
                  childCount: bookmarks.length,
                ),
              ),
            ),
        ],
      ),
      floatingActionButton: bookmarks.isNotEmpty
          ? AnimatedScale(
              scale: _showScrollToTop ? 1 : 0.8,
              duration: const Duration(milliseconds: 200),
              child: AnimatedOpacity(
                opacity: _showScrollToTop ? 1 : 0,
                duration: const Duration(milliseconds: 200),
                child: FloatingActionButton(
                  backgroundColor: AppTheme.autumn,
                  onPressed: _showScrollToTop ? scrollToTop : null,
                  child: const Icon(Icons.arrow_upward, color: Colors.white),
                ),
              ),
            )
          : null,
    );
  }
}

