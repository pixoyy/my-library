import 'package:flutter/material.dart';
import 'package:my_library/core/theme/app_theme.dart';
import '../../data/models/book_model.dart';
import '../../data/services/openlibrary_service.dart';
import '../../widgets/book_card.dart';

class CategoryPage extends StatefulWidget {
  const CategoryPage({super.key});

  @override
  State<CategoryPage> createState() => _CategoryPageState();
}

class _CategoryPageState extends State<CategoryPage> {
  final ScrollController _scrollController = ScrollController();
  bool _showScrollToTop = false;
  bool _isLoadingMore = false;
  int _currentPage = 1;
  bool _hasMore = true;

  final List<Map<String, dynamic>> categories = [
    {'name': 'Programming', 'icon': Icons.code},
    {'name': 'Romance', 'icon': Icons.favorite},
    {'name': 'Science', 'icon': Icons.science},
    {'name': 'History', 'icon': Icons.history_edu},
    {'name': 'Fantasy', 'icon': Icons.auto_awesome},
    {'name': 'Horror', 'icon': Icons.dark_mode},
    {'name': 'Biography', 'icon': Icons.person},
    {'name': 'Mystery', 'icon': Icons.search},
    {'name': 'Adventure', 'icon': Icons.explore},
    {'name': 'Poetry', 'icon': Icons.menu_book},
    {'name': 'Art', 'icon': Icons.brush},
  ];

  bool isLoading = false;
  String selectedCategory = '';
  List<BookModel> books = [];

  @override
  void initState() {
    super.initState();
    // Load kategori pertama sebagai default
    loadByCategory(categories.first['name']);
    _scrollController.addListener(_handleScroll);
  }

  void _handleScroll() {
    final shouldShow = _scrollController.offset > 300;
    if (shouldShow != _showScrollToTop) {
      setState(() {
        _showScrollToTop = shouldShow;
      });
    }

    if (_scrollController.hasClients &&
        _scrollController.position.pixels >=
            _scrollController.position.maxScrollExtent - 300) {
      _loadMore();
    }
  }

  Future<void> loadByCategory(String category) async {
    setState(() {
      isLoading = true;
      selectedCategory = category;
      books.clear();
      _currentPage = 1;
      _hasMore = true;
    });

    try {
      final result = await OpenLibraryService.searchBooks(
        category,
        page: _currentPage,
      );
      setState(() {
        books = result;
        _hasMore = result.isNotEmpty;
      });
    } catch (_) {
      setState(() {
        books = [];
        _hasMore = false;
      });
    } finally {
      setState(() => isLoading = false);
    }
  }

  Future<void> _loadMore() async {
    if (_isLoadingMore || !_hasMore || isLoading) return;

    setState(() => _isLoadingMore = true);
    final nextPage = _currentPage + 1;

    try {
      final result = await OpenLibraryService.searchBooks(
        selectedCategory,
        page: nextPage,
      );
      setState(() {
        _currentPage = nextPage;
        books.addAll(result);
        _hasMore = result.isNotEmpty;
      });
    } catch (_) {
      setState(() {
        _hasMore = false;
      });
    } finally {
      setState(() => _isLoadingMore = false);
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
          SliverToBoxAdapter(
            child: Container(
              height: 70,
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: ListView.separated(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                scrollDirection: Axis.horizontal,
                itemCount: categories.length,
                separatorBuilder: (_, __) => const SizedBox(width: 12),
                itemBuilder: (_, i) {
                  final cat = categories[i];
                  final active = selectedCategory == cat['name'];

                  return AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    child: active
                        ? ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppTheme.autumn,
                              foregroundColor: Colors.white,
                              elevation: 4,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                              ),
                            ),
                            icon: Icon(cat['icon'], size: 18),
                            label: Text(cat['name']),
                            onPressed: () => loadByCategory(cat['name']),
                          )
                        : OutlinedButton.icon(
                            style: OutlinedButton.styleFrom(
                              foregroundColor: AppTheme.brown,
                              side: const BorderSide(color: AppTheme.brown),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                              ),
                            ),
                            icon: Icon(cat['icon'], size: 18),
                            label: Text(cat['name']),
                            onPressed: () => loadByCategory(cat['name']),
                          ),
                  );
                },
              ),
            ),
          ),
          if (isLoading)
            const SliverFillRemaining(
              child: Center(
                child: CircularProgressIndicator(color: AppTheme.autumn),
              ),
            )
          else if (books.isEmpty)
            SliverFillRemaining(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.category_outlined,
                      size: 80,
                      color: Colors.grey[400],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'No books found for "$selectedCategory"',
                      style: TextStyle(fontSize: 16, color: Colors.grey[600]),
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
                delegate: SliverChildBuilderDelegate((context, index) {
                  if (index >= books.length) {
                    return const Center(
                      child: Padding(
                        padding: EdgeInsets.all(12),
                        child: CircularProgressIndicator(
                          color: AppTheme.autumn,
                          strokeWidth: 2,
                        ),
                      ),
                    );
                  }
                  return BookCard(book: books[index]);
                }, childCount: books.length + (_isLoadingMore ? 1 : 0)),
              ),
            ),
        ],
      ),
      floatingActionButton: books.isNotEmpty
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
