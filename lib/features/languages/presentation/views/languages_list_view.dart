import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../shared/themes/dimensions.dart';
import '../../../../shared/widgets/common/empty_state_widget.dart';
import '../../../../shared/widgets/common/error_widget.dart' as custom_error;
import '../viewmodels/language_viewmodel.dart';
import '../widgets/language_card.dart';

/// View for displaying list of languages
class LanguagesListView extends StatefulWidget {
  const LanguagesListView({super.key});

  @override
  State<LanguagesListView> createState() => _LanguagesListViewState();
}

class _LanguagesListViewState extends State<LanguagesListView> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Load languages when view initializes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<LanguageViewModel>().loadLanguages();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Traditional Languages'),
        elevation: 0,
      ),
      body: Column(
        children: [
          // Search bar
          Padding(
            padding: const EdgeInsets.all(AppDimensions.spacingM),
            child: TextField(
              controller: _searchController,
              decoration: const InputDecoration(
                hintText: 'Search languages...',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(8)),
                ),
                filled: true,
                fillColor: Color(0xFFF5F5F5),
              ),
              onChanged: (query) {
                context.read<LanguageViewModel>().setSearchQuery(query);
              },
            ),
          ),

          // Content
          Expanded(
            child: Consumer<LanguageViewModel>(
              builder: (context, viewModel, child) {
                if (viewModel.isLoading && viewModel.languages.isEmpty) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }

                if (viewModel.error != null && viewModel.languages.isEmpty) {
                  return custom_error.ErrorWidget(
                    title: 'Error Loading Languages',
                    message: viewModel.error,
                    onRetry: () => viewModel.loadLanguages(),
                    retryText: 'Retry',
                  );
                }

                if (viewModel.filteredLanguages.isEmpty) {
                  if (_searchController.text.isEmpty) {
                    return const EmptyStateWidget(
                      icon: Icons.language,
                      title: 'No Languages Found',
                      message: 'No traditional languages available yet.',
                    );
                  } else {
                    return EmptyStateWithAction(
                      icon: Icons.search_off,
                      title: 'No Results',
                      message: 'No languages match your search.',
                      actionText: 'Clear Search',
                      onActionPressed: () {
                        _searchController.clear();
                        viewModel.setSearchQuery('');
                      },
                    );
                  }
                }

                return RefreshIndicator(
                  onRefresh: () => viewModel.loadLanguages(),
                  child: ListView.builder(
                    padding:
                        const EdgeInsets.only(bottom: AppDimensions.spacingM),
                    itemCount: viewModel.filteredLanguages.length,
                    itemBuilder: (context, index) {
                      final language = viewModel.filteredLanguages[index];
                      return LanguageCard(
                        language: language,
                        isSelected:
                            viewModel.selectedLanguage?.id == language.id,
                        onTap: () {
                          viewModel.selectLanguage(language);
                          // Navigate to language detail view
                          // Navigator.push(context, MaterialPageRoute(
                          //   builder: (_) => LanguageDetailView(language: language),
                          // ));
                        },
                      );
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
