import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../../domain/entities/word_entity.dart';
import '../viewmodels/dictionary_viewmodel.dart';
import '../widgets/dictionary_word_card.dart';
import 'word_details_view.dart';

/// Main dictionary search view
class DictionaryView extends StatefulWidget {
  const DictionaryView({super.key});

  @override
  State<DictionaryView> createState() => _DictionaryViewState();
}

class _DictionaryViewState extends State<DictionaryView> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocus = FocusNode();

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocus.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    final viewModel = context.read<DictionaryViewModel>();
    viewModel.setSearchQuery(_searchController.text);
    if (_searchController.text.isNotEmpty) {
      viewModel.loadSuggestions(_searchController.text);
    }
  }

  void _performSearch() {
    final viewModel = context.read<DictionaryViewModel>();
    if (_searchController.text.isNotEmpty) {
      viewModel.performSearch(_searchController.text);
      _searchFocus.unfocus();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dictionnaire'),
        backgroundColor: Colors.green,
        elevation: 0,
      ),
      body: Consumer<DictionaryViewModel>(
        builder: (context, viewModel, child) {
          return Column(
            children: [
              // Search header
              Container(
                padding: const EdgeInsets.all(AppDimensions.paddingMedium),
                decoration: BoxDecoration(
                  color: Colors.green.shade50,
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(20),
                    bottomRight: Radius.circular(20),
                  ),
                ),
                child: TextField(
                  controller: _searchController,
                  focusNode: _searchFocus,
                  decoration: InputDecoration(
                    hintText: 'Rechercher un mot...',
                    prefixIcon: const Icon(Icons.search, color: Colors.green),
                    suffixIcon: _searchController.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear, color: Colors.green),
                            onPressed: () {
                              _searchController.clear();
                              viewModel.clearSearch();
                            },
                          )
                        : null,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    filled: true,
                    fillColor: Colors.white,
                  ),
                  onSubmitted: (_) => _performSearch(),
                ),
              ),

              // Search results
              Expanded(
                child: viewModel.isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : viewModel.hasError
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(Icons.error, color: Colors.red, size: 64),
                                const SizedBox(height: 16),
                                const Text(
                                  'Une erreur s\'est produite',
                                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  viewModel.errorMessage ?? 'Erreur inconnue',
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(color: Colors.grey),
                                ),
                                const SizedBox(height: 16),
                                ElevatedButton(
                                  onPressed: () {
                                    _searchController.clear();
                                    viewModel.clearSearch();
                                  },
                                  child: const Text('Réessayer'),
                                ),
                              ],
                            ),
                          )
                        : viewModel.searchResults.isEmpty
                            ? _buildEmptyState()
                            : _buildSearchResults(viewModel),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.book_outlined,
            size: 80,
            color: Colors.grey.shade400,
          ),
          const SizedBox(height: 16),
          Text(
            'Recherchez un mot',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Tapez dans la barre de recherche pour commencer',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey.shade500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchResults(DictionaryViewModel viewModel) {
    return ListView.builder(
      padding: const EdgeInsets.all(AppDimensions.paddingMedium),
      itemCount: viewModel.searchResults.length,
      itemBuilder: (context, index) {
        final word = viewModel.searchResults[index];
        return DictionaryWordCard(
          word: word,
          onTap: () => _navigateToWordDetails(word),
        );
      },
    );
  }

  void _navigateToWordDetails(WordEntity word) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => WordDetailsView(wordId: word.id),
      ),
    );
  }
}