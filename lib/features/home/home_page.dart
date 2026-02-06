import 'dart:async';
import 'package:flutter/material.dart';
import '../../data/models/book_model.dart';
import '../../data/services/openlibrary_service.dart';
import '../../widgets/book_card.dart';
import '../../widgets/loading_widget.dart';
import '../../core/theme/app_theme.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  static const String _defaultQuery = 'fiction';
  static const int _limit = 20;
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _searchCtrl = TextEditingController();
  Timer? _debounce;
  bool _showScrollToTop = false;
  int _currentPage = 1;
  bool _hasMore = true;
  String _currentQuery = _defaultQuery;
  final Map<int, List<BookModel>> _pageCache = {};

  List<BookModel> books = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchBooks(); // default load
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

  // ================= FETCH API =================
  Future<void> fetchBooks([String query = _defaultQuery]) async {
    _currentQuery = query;
    _currentPage = 1;
    _hasMore = true;
    _pageCache.clear();
    await _fetchPage(query: query, page: 1);
  }

  Future<void> _fetchPage({required String query, required int page}) async {
    final cached = _pageCache[page];
    if (cached != null) {
      setState(() {
        books = cached;
      });
      scrollToTop();
      return;
    }
    setState(() => isLoading = true);

    try {
      final result = await OpenLibraryService.searchBooks(query, page: page);

      // Filter books by title match (case insensitive)
      final filteredResult = query == _defaultQuery
          ? result
          : result.where((book) {
              final title = book.title.toLowerCase();
              final searchTerm = query.toLowerCase();
              return title.contains(searchTerm);
            }).toList();

      setState(() {
        books = filteredResult;
        _hasMore = result.isNotEmpty && filteredResult.length >= _limit;
      });
      _pageCache[page] = filteredResult;
      scrollToTop();
    } catch (e) {
      setState(() {
        books = [];
        _hasMore = false;
      });
    } finally {
      setState(() => isLoading = false);
    }
  }

  // ================= DEBOUNCE =================
  void _onSearchChanged(String value) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();

    _debounce = Timer(const Duration(milliseconds: 400), () {
      final query = value.trim().isEmpty ? _defaultQuery : value.trim();
      fetchBooks(query);
    });
  }

  // ================= API SEARCH (ENTER / SEND) =================
  void _onSearchSubmitted(String query) {
    final cleaned = query.trim();
    fetchBooks(cleaned.isEmpty ? _defaultQuery : cleaned);
  }

  List<int> _pageWindow() {
    final start = (_currentPage - 2).clamp(1, _currentPage);
    final pages = <int>[];
    var page = start;
    while (pages.length < 5) {
      pages.add(page);
      page++;
      if (page > _currentPage && !_hasMore) break;
    }
    return pages;
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        CustomScrollView(
          controller: _scrollController,
          slivers: [
            // 🔍 SEARCH BAR
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: TextField(
                  controller: _searchCtrl,
                  onChanged: _onSearchChanged,
                  onSubmitted: _onSearchSubmitted,
                  decoration: InputDecoration(
                    hintText: 'Search title',
                    prefixIcon: const Icon(Icons.search),
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
              ),
            ),

            if (books.isNotEmpty)
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(12, 0, 12, 8),
                  child: Align(
                    alignment: Alignment.centerRight,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: AppTheme.cream,
                        // color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: AppTheme.autumn.withOpacity(0.3),
                          width: 2,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: AppTheme.brown.withOpacity(0.1),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          _PageNavButton(
                            label: '<<',
                            enabled: _currentPage > 1,
                            color: AppTheme.brown,
                            onTap: () {
                              final newPage = _currentPage - 1;
                              setState(() => _currentPage = newPage);
                              _fetchPage(query: _currentQuery, page: newPage);
                            },
                          ),
                          const SizedBox(width: 6),
                          for (final page in _pageWindow())
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 2,
                              ),
                              child: _PageNumberButton(
                                page: page,
                                isActive: page == _currentPage,
                                color: AppTheme.autumn,
                                onTap: () {
                                  setState(() => _currentPage = page);
                                  _fetchPage(query: _currentQuery, page: page);
                                },
                              ),
                            ),
                          const SizedBox(width: 6),
                          _PageNavButton(
                            label: '>>',
                            enabled: _hasMore,
                            color: AppTheme.brown,
                            onTap: () {
                              final newPage = _currentPage + 1;
                              setState(() => _currentPage = newPage);
                              _fetchPage(query: _currentQuery, page: newPage);
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),

            if (isLoading)
              const SliverFillRemaining(child: LoadingWidget())
            else if (books.isEmpty)
              const SliverFillRemaining(
                child: Center(child: Text('No books found')),
              )
            else
              SliverPadding(
                padding: const EdgeInsets.all(8),
                sliver: SliverGrid(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 0.65,
                    crossAxisSpacing: 8,
                    mainAxisSpacing: 8,
                  ),
                  delegate: SliverChildBuilderDelegate((context, index) {
                    return BookCard(
                      book: books[index],
                      searchQuery: _currentQuery == _defaultQuery
                          ? null
                          : _currentQuery,
                    );
                  }, childCount: books.length),
                ),
              ),

            // Next Page Button at bottom
            if (books.isNotEmpty && _hasMore)
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Center(
                    child: ElevatedButton(
                      onPressed: isLoading
                          ? null
                          : () {
                              final newPage = _currentPage + 1;
                              setState(() => _currentPage = newPage);
                              _fetchPage(query: _currentQuery, page: newPage);
                            },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.autumn,
                        foregroundColor: Colors.white,
                        elevation: 4,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 32,
                          vertical: 14,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: isLoading
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  Colors.white,
                                ),
                              ),
                            )
                          : const Text(
                              'Next Page',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                    ),
                  ),
                ),
              ),
          ],
        ),

        // ⬆ SCROLL TO TOP
        Positioned(
          bottom: 20,
          right: 20,
          child: IgnorePointer(
            ignoring: !_showScrollToTop,
            child: AnimatedScale(
              scale: _showScrollToTop ? 1 : 0.8,
              duration: const Duration(milliseconds: 200),
              child: AnimatedOpacity(
                opacity: _showScrollToTop ? 1 : 0,
                duration: const Duration(milliseconds: 200),
                child: FloatingActionButton(
                  backgroundColor: AppTheme.autumn,
                  onPressed: scrollToTop,
                  child: const Icon(Icons.arrow_upward, color: Colors.white),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _scrollController.removeListener(_handleScroll);
    _scrollController.dispose();
    _searchCtrl.dispose();
    super.dispose();
  }
}

class _PageNavButton extends StatelessWidget {
  final String label;
  final bool enabled;
  final VoidCallback onTap;
  final Color color;

  const _PageNavButton({
    required this.label,
    required this.enabled,
    required this.onTap,
    this.color = Colors.brown,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(6),
      onTap: enabled ? onTap : null,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
        child: Text(
          label,
          style: TextStyle(
            color: enabled ? color : color.withOpacity(0.8),
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}

class _PageNumberButton extends StatelessWidget {
  final int page;
  final bool isActive;
  final VoidCallback onTap;
  final Color color;

  const _PageNumberButton({
    required this.page,
    required this.isActive,
    required this.onTap,
    this.color = Colors.brown,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(8),
      onTap: isActive ? null : onTap,
      child: Container(
        width: 28,
        height: 28,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: isActive ? color : Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: isActive ? color : color.withOpacity(0.4)),
        ),
        child: Text(
          '$page',
          style: TextStyle(
            color: isActive ? Colors.white : color,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}

// import 'dart:async';
// import 'package:flutter/material.dart';
// import '../../data/models/book_model.dart';
// import '../../data/services/openlibrary_service.dart';
// import '../../widgets/book_card.dart';
// import '../../widgets/loading_widget.dart';
// import '../../core/theme/app_theme.dart';

// class HomePage extends StatefulWidget {
//   const HomePage({super.key});

//   @override
//   State<HomePage> createState() => _HomePageState();
// }

// class _HomePageState extends State<HomePage> {
//   static const String _defaultQuery = 'fiction';
//   static const int _limit = 20;
//   final ScrollController _scrollController = ScrollController();
//   final TextEditingController _searchCtrl = TextEditingController();
//   Timer? _debounce;
//   bool _showScrollToTop = false;
//   int _currentPage = 1;
//   bool _hasMore = true;
//   String _currentQuery = _defaultQuery;
//   final Map<int, List<BookModel>> _pageCache = {};

//   List<BookModel> books = [];
//   bool isLoading = true;

//   @override
//   void initState() {
//     super.initState();
//     fetchBooks(); // default load
//     _scrollController.addListener(_handleScroll);
//   }

//   void _handleScroll() {
//     final shouldShow = _scrollController.offset > 300;
//     if (shouldShow != _showScrollToTop) {
//       setState(() {
//         _showScrollToTop = shouldShow;
//       });
//     }
//   }

//   void scrollToTop() {
//     if (_scrollController.hasClients) {
//       _scrollController.animateTo(
//         0,
//         duration: const Duration(milliseconds: 300),
//         curve: Curves.easeOut,
//       );
//     }
//   }

//   // ================= FETCH API =================
//   Future<void> fetchBooks([String query = _defaultQuery]) async {
//     _currentQuery = query;
//     _currentPage = 1;
//     _hasMore = true;
//     _pageCache.clear();
//     await _fetchPage(query: query, page: 1);
//   }

//   Future<void> _fetchPage({required String query, required int page}) async {
//     final cached = _pageCache[page];
//     if (cached != null) {
//       setState(() {
//         books = cached;
//       });
//       scrollToTop();
//       return;
//     }
//     setState(() => isLoading = true);

//     try {
//       final result = await OpenLibraryService.searchBooks(query, page: page);

//       // Filter books by title match (case insensitive)
//       final filteredResult = query == _defaultQuery
//           ? result
//           : result.where((book) {
//               final title = book.title.toLowerCase();
//               final searchTerm = query.toLowerCase();
//               return title.contains(searchTerm);
//             }).toList();

//       setState(() {
//         books = filteredResult;
//         _hasMore = result.isNotEmpty && filteredResult.length >= _limit;
//       });
//       _pageCache[page] = filteredResult;
//       scrollToTop();
//     } catch (e) {
//       setState(() {
//         books = [];
//         _hasMore = false;
//       });
//     } finally {
//       setState(() => isLoading = false);
//     }
//   }

//   // ================= DEBOUNCE =================
//   void _onSearchChanged(String value) {
//     if (_debounce?.isActive ?? false) _debounce!.cancel();

//     _debounce = Timer(const Duration(milliseconds: 400), () {
//       final query = value.trim().isEmpty ? _defaultQuery : value.trim();
//       fetchBooks(query);
//     });
//   }

//   // ================= API SEARCH (ENTER / SEND) =================
//   void _onSearchSubmitted(String query) {
//     final cleaned = query.trim();
//     fetchBooks(cleaned.isEmpty ? _defaultQuery : cleaned);
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: AppTheme.cream,
//       body: Stack(
//         children: [
//           CustomScrollView(
//             controller: _scrollController,
//             slivers: [
//               // 🔍 APP BAR WITH SEARCH
//               SliverAppBar(
//                 pinned: true,
//                 floating: true,
//                 expandedHeight: 50,
//                 backgroundColor: AppTheme.brown,
//                 flexibleSpace: FlexibleSpaceBar(
//                   titlePadding: EdgeInsets.zero,
//                   background: Container(
//                     decoration: BoxDecoration(
//                       gradient: LinearGradient(
//                         begin: Alignment.topCenter,
//                         end: Alignment.bottomCenter,
//                         colors: [
//                           AppTheme.brown,
//                           AppTheme.brown.withOpacity(0.9),
//                         ],
//                       ),
//                     ),
//                     child: Align(
//                       alignment: Alignment.bottomCenter,
//                       child: Padding(
//                         padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
//                         child: TextField(
//                           controller: _searchCtrl,
//                           onChanged: _onSearchChanged,
//                           onSubmitted: _onSearchSubmitted,
//                           style: const TextStyle(color: Colors.black87),
//                           decoration: InputDecoration(
//                             hintText: 'Search title...',
//                             hintStyle: TextStyle(color: Colors.grey[600]),
//                             prefixIcon: const Icon(
//                               Icons.search,
//                               color: AppTheme.brown,
//                             ),
//                             filled: true,
//                             fillColor: Colors.white,
//                             contentPadding: const EdgeInsets.symmetric(
//                               horizontal: 16,
//                             ),
//                             border: OutlineInputBorder(
//                               borderRadius: BorderRadius.circular(30),
//                               borderSide: BorderSide.none,
//                             ),
//                           ),
//                         ),
//                       ),
//                     ),
//                   ),
//                 ),
//               ),

//               // PAGINATION CONTROLS (TOP)
//               if (books.isNotEmpty)
//                 SliverToBoxAdapter(
//                   child: Padding(
//                     padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
//                     child: Container(
//                       padding: const EdgeInsets.symmetric(
//                         horizontal: 12,
//                         vertical: 8,
//                       ),
//                       decoration: BoxDecoration(
//                         color: Colors.white,
//                         borderRadius: BorderRadius.circular(16),
//                         boxShadow: [
//                           BoxShadow(
//                             color: AppTheme.brown.withOpacity(0.1),
//                             blurRadius: 8,
//                             offset: const Offset(0, 2),
//                           ),
//                         ],
//                       ),
//                       child: Row(
//                         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                         children: [
//                           Text(
//                             'Page $_currentPage',
//                             style: const TextStyle(
//                               color: AppTheme.brown,
//                               fontWeight: FontWeight.bold,
//                             ),
//                           ),
//                           Row(
//                             mainAxisSize: MainAxisSize.min,
//                             children: [
//                               _PageNavButton(
//                                 label: 'Prev',
//                                 icon: Icons.chevron_left,
//                                 enabled: _currentPage > 1,
//                                 onTap: () {
//                                   final newPage = _currentPage - 1;
//                                   setState(() => _currentPage = newPage);
//                                   _fetchPage(
//                                     query: _currentQuery,
//                                     page: newPage,
//                                   );
//                                 },
//                               ),
//                               const SizedBox(width: 8),
//                               _PageNavButton(
//                                 label: 'Next',
//                                 icon: Icons.chevron_right,
//                                 isRightIcon: true,
//                                 enabled: _hasMore,
//                                 onTap: () {
//                                   final newPage = _currentPage + 1;
//                                   setState(() => _currentPage = newPage);
//                                   _fetchPage(
//                                     query: _currentQuery,
//                                     page: newPage,
//                                   );
//                                 },
//                               ),
//                             ],
//                           ),
//                         ],
//                       ),
//                     ),
//                   ),
//                 ),

//               // LOADING / EMPTY / GRID
//               if (isLoading)
//                 const SliverFillRemaining(child: LoadingWidget())
//               else if (books.isEmpty)
//                 SliverFillRemaining(
//                   child: Center(
//                     child: Column(
//                       mainAxisAlignment: MainAxisAlignment.center,
//                       children: [
//                         Icon(
//                           Icons.search_off_rounded,
//                           size: 64,
//                           color: AppTheme.brown.withOpacity(0.5),
//                         ),
//                         const SizedBox(height: 16),
//                         Text(
//                           'No books found',
//                           style: TextStyle(
//                             fontSize: 18,
//                             color: AppTheme.brown.withOpacity(0.8),
//                             fontWeight: FontWeight.w600,
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//                 )
//               else
//                 SliverPadding(
//                   padding: const EdgeInsets.all(16),
//                   sliver: SliverGrid(
//                     gridDelegate:
//                         const SliverGridDelegateWithFixedCrossAxisCount(
//                           crossAxisCount: 2,
//                           childAspectRatio: 0.65,
//                           crossAxisSpacing: 16,
//                           mainAxisSpacing: 16,
//                         ),
//                     delegate: SliverChildBuilderDelegate((context, index) {
//                       return BookCard(
//                         book: books[index],
//                         searchQuery: _currentQuery == _defaultQuery
//                             ? null
//                             : _currentQuery,
//                       );
//                     }, childCount: books.length),
//                   ),
//                 ),

//               // BOTTOM NEXT BUTTON
//               if (books.isNotEmpty && _hasMore)
//                 SliverToBoxAdapter(
//                   child: Padding(
//                     padding: const EdgeInsets.all(24),
//                     child: Center(
//                       child: ElevatedButton(
//                         onPressed: isLoading
//                             ? null
//                             : () {
//                                 final newPage = _currentPage + 1;
//                                 setState(() => _currentPage = newPage);
//                                 _fetchPage(query: _currentQuery, page: newPage);
//                               },
//                         style: ElevatedButton.styleFrom(
//                           backgroundColor: AppTheme.autumn,
//                           foregroundColor: Colors.white,
//                           padding: const EdgeInsets.symmetric(
//                             horizontal: 48,
//                             vertical: 16,
//                           ),
//                           elevation: 4,
//                           shape: RoundedRectangleBorder(
//                             borderRadius: BorderRadius.circular(30),
//                           ),
//                         ),
//                         child: isLoading
//                             ? const SizedBox(
//                                 width: 24,
//                                 height: 24,
//                                 child: CircularProgressIndicator(
//                                   strokeWidth: 2,
//                                   valueColor: AlwaysStoppedAnimation<Color>(
//                                     Colors.white,
//                                   ),
//                                 ),
//                               )
//                             : const Text(
//                                 'Load More Books',
//                                 style: TextStyle(
//                                   fontSize: 16,
//                                   fontWeight: FontWeight.bold,
//                                 ),
//                               ),
//                       ),
//                     ),
//                   ),
//                 ),
//             ],
//           ),

//           // ⬆ SCROLL TO TOP
//           Positioned(
//             bottom: 20,
//             right: 20,
//             child: IgnorePointer(
//               ignoring: !_showScrollToTop,
//               child: AnimatedScale(
//                 scale: _showScrollToTop ? 1 : 0.8,
//                 duration: const Duration(milliseconds: 200),
//                 child: AnimatedOpacity(
//                   opacity: _showScrollToTop ? 1 : 0,
//                   duration: const Duration(milliseconds: 200),
//                   child: FloatingActionButton(
//                     backgroundColor: AppTheme.autumn,
//                     onPressed: scrollToTop,
//                     child: const Icon(Icons.arrow_upward, color: Colors.white),
//                   ),
//                 ),
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   @override
//   void dispose() {
//     _debounce?.cancel();
//     _scrollController.removeListener(_handleScroll);
//     _scrollController.dispose();
//     _searchCtrl.dispose();
//     super.dispose();
//   }
// }

// class _PageNavButton extends StatelessWidget {
//   final String label;
//   final IconData icon;
//   final bool enabled;
//   final VoidCallback onTap;
//   final bool isRightIcon;

//   const _PageNavButton({
//     required this.label,
//     required this.icon,
//     required this.enabled,
//     required this.onTap,
//     this.isRightIcon = false,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return InkWell(
//       borderRadius: BorderRadius.circular(20),
//       onTap: enabled ? onTap : null,
//       child: Container(
//         padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
//         decoration: BoxDecoration(
//           color: enabled ? AppTheme.brown.withOpacity(0.1) : Colors.transparent,
//           borderRadius: BorderRadius.circular(20),
//         ),
//         child: Row(
//           children: [
//             if (!isRightIcon)
//               Icon(
//                 icon,
//                 size: 16,
//                 color: enabled ? AppTheme.brown : Colors.grey,
//               ),
//             if (!isRightIcon) const SizedBox(width: 4),
//             Text(
//               label,
//               style: TextStyle(
//                 color: enabled ? AppTheme.brown : Colors.grey,
//                 fontWeight: FontWeight.bold,
//                 fontSize: 12,
//               ),
//             ),
//             if (isRightIcon) const SizedBox(width: 4),
//             if (isRightIcon)
//               Icon(
//                 icon,
//                 size: 16,
//                 color: enabled ? AppTheme.brown : Colors.grey,
//               ),
//           ],
//         ),
//       ),
//     );
//   }
// }
