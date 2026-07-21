import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../routes/app_router.dart';
import '../../services/search_service.dart';
import 'widgets/search_bar_widget.dart';
import 'widgets/empty_search_widget.dart';
import 'widgets/searching_widget.dart';
import 'widgets/no_results_widget.dart';
import 'widgets/search_results_widget.dart';

enum ScreenSearchState { initial, searching, results, noResults }

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  static const _navy = Color(0xFF1F2937);
  static const _bg = Color(0xFFFAF6EA);

  final TextEditingController _searchCtrl = TextEditingController();
  Timer? _debounceTimer;
  ScreenSearchState _searchState = ScreenSearchState.initial;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final searchService = Provider.of<SearchService>(context, listen: false);
      if (searchService.query.isNotEmpty) {
        _searchCtrl.text = searchService.query;
        setState(() {
          _searchState = searchService.searchResults.isEmpty
              ? ScreenSearchState.noResults
              : ScreenSearchState.results;
        });
      } else {
        setState(() {
          _searchState = ScreenSearchState.initial;
        });
      }
    });
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    _searchCtrl.dispose();
    super.dispose();
  }

  void _onSearchChanged(String text) {
    if (_debounceTimer?.isActive ?? false) _debounceTimer!.cancel();

    if (text.trim().isEmpty) {
      setState(() {
        _searchState = ScreenSearchState.initial;
      });
      context.read<SearchService>().updateQuery('');
      return;
    }

    setState(() {
      _searchState = ScreenSearchState.searching;
    });

    _debounceTimer = Timer(const Duration(milliseconds: 400), () {
      if (!mounted) return;
      final searchService = context.read<SearchService>();
      searchService.updateQuery(text);

      setState(() {
        _searchState = searchService.searchResults.isEmpty
            ? ScreenSearchState.noResults
            : ScreenSearchState.results;
      });
    });
  }

  void _onSearchSubmitted(String text) {
    if (_debounceTimer?.isActive ?? false) _debounceTimer!.cancel();
    if (text.trim().isEmpty) return;

    final searchService = context.read<SearchService>();
    searchService.updateQuery(text);
    searchService.addRecentSearch(text);

    setState(() {
      _searchState = searchService.searchResults.isEmpty
          ? ScreenSearchState.noResults
          : ScreenSearchState.results;
    });
  }

  void _onSearchSelected(String text) {
    if (_debounceTimer?.isActive ?? false) _debounceTimer!.cancel();

    setState(() {
      _searchCtrl.text = text;
      _searchCtrl.selection = TextSelection.fromPosition(TextPosition(offset: text.length));
      _searchState = ScreenSearchState.searching;
    });

    // Short artificial delay to make search animation visible and smooth
    Future.delayed(const Duration(milliseconds: 300), () {
      if (!mounted) return;
      final searchService = context.read<SearchService>();
      searchService.updateQuery(text);
      searchService.addRecentSearch(text);

      setState(() {
        _searchState = searchService.searchResults.isEmpty
            ? ScreenSearchState.noResults
            : ScreenSearchState.results;
      });
    });
  }

  void _onClear() {
    if (_debounceTimer?.isActive ?? false) _debounceTimer!.cancel();
    _searchCtrl.clear();
    context.read<SearchService>().updateQuery('');
    setState(() {
      _searchState = ScreenSearchState.initial;
    });
  }

  @override
  Widget build(BuildContext context) {
    final searchService = context.watch<SearchService>();
    final recents = searchService.recentSearches;

    return Scaffold(
      backgroundColor: _bg,
      appBar: AppBar(
        title: const Text(
          'Search Dishes',
          style: TextStyle(
            fontWeight: FontWeight.w800,
            fontSize: 18,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
        backgroundColor: _navy,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Reusable Debounced Search Bar
            SearchBarWidget(
              controller: _searchCtrl,
              onChanged: _onSearchChanged,
              onSubmitted: _onSearchSubmitted,
              onClear: _onClear,
            ),
            const SizedBox(height: 16),

            // Animated Switched States Container
            Expanded(
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 400),
                switchInCurve: Curves.easeInOut,
                switchOutCurve: Curves.easeInOut,
                transitionBuilder: (Widget child, Animation<double> animation) {
                  return FadeTransition(
                    opacity: animation,
                    child: child,
                  );
                },
                child: _buildStateWidget(recents),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStateWidget(List<String> recents) {
    switch (_searchState) {
      case ScreenSearchState.initial:
        return EmptySearchWidget(
          key: const ValueKey('initial_state'),
          recentSearches: recents,
          onClearAllRecents: () => context.read<SearchService>().clearRecentSearches(),
          onRemoveRecent: (query) => context.read<SearchService>().removeRecentSearch(query),
          onSelectChip: _onSearchSelected,
        );
      case ScreenSearchState.searching:
        return const SearchingWidget(
          key: ValueKey('searching_state'),
        );
      case ScreenSearchState.results:
        return SearchResultsWidget(
          key: const ValueKey('results_state'),
          results: context.read<SearchService>().searchResults,
          query: _searchCtrl.text,
          onSelectFood: (foodName) {
            context.read<SearchService>().addRecentSearch(_searchCtrl.text);
            final food = context.read<SearchService>().searchResults.firstWhere((f) => f.name == foodName);
            Navigator.pushNamed(
              context,
              AppRouter.foodDetails,
              arguments: food,
            );
          },
        );
      case ScreenSearchState.noResults:
        return NoResultsWidget(
          key: const ValueKey('no_results_state'),
          onSelectChip: _onSearchSelected,
        );
    }
  }
}
