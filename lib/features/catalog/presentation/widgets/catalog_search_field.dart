import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../voice_search/presentation/widgets/voice_search_button.dart';
import '../../domain/product_search_suggestions.dart';
import '../providers/catalog_providers.dart';

class CatalogSearchField extends ConsumerStatefulWidget {
  const CatalogSearchField({
    super.key,
    required this.controller,
    required this.onChanged,
    this.autofocus = false,
    this.categoryId,
  });

  final TextEditingController controller;
  final ValueChanged<String> onChanged;
  final bool autofocus;
  final String? categoryId;

  @override
  ConsumerState<CatalogSearchField> createState() => _CatalogSearchFieldState();
}

class _CatalogSearchFieldState extends ConsumerState<CatalogSearchField> {
  final _focusNode = FocusNode();

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  void _submitSearch(String query) {
    final text = query.trim();
    widget.controller.value = TextEditingValue(
      text: text,
      selection: TextSelection.collapsed(offset: text.length),
    );
    _focusNode.unfocus();
    widget.onChanged(text);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return RawAutocomplete<String>(
      textEditingController: widget.controller,
      focusNode: _focusNode,
      optionsBuilder: (value) async {
        if (value.text.trim().isEmpty) return const [];
        final categoryId = widget.categoryId;
        try {
          final products = await ref.read(productsProvider.future);
          if (!mounted) return const [];
          return productSearchSuggestions(
            products,
            query: value.text,
            categoryId: categoryId,
          );
        } catch (_) {
          // The listing shows catalog loading errors and its retry action.
          return const [];
        }
      },
      onSelected: _submitSearch,
      optionsViewBuilder: (context, onSelected, options) =>
          _SearchSuggestions(options: options.toList(), onSelected: onSelected),
      fieldViewBuilder: (context, controller, focusNode, onFieldSubmitted) =>
          TextField(
            controller: controller,
            focusNode: focusNode,
            autofocus: widget.autofocus,
            onChanged: widget.onChanged,
            onSubmitted: _submitSearch,
            onTapOutside: (_) => focusNode.unfocus(),
            textInputAction: TextInputAction.search,
            decoration: InputDecoration(
              hintText: 'Tìm sản phẩm hoặc cửa hàng',
              prefixIcon: const Icon(Icons.search_rounded),
              suffixIcon: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (controller.text.isNotEmpty)
                    IconButton(
                      tooltip: 'Xóa tìm kiếm',
                      onPressed: () {
                        controller.clear();
                        widget.onChanged('');
                        focusNode.requestFocus();
                      },
                      icon: const Icon(Icons.close_rounded),
                    ),
                  VoiceSearchButton(onSearch: _submitSearch),
                ],
              ),
              filled: true,
              fillColor: theme.scaffoldBackgroundColor,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide.none,
              ),
            ),
          ),
    );
  }
}

class _SearchSuggestions extends StatelessWidget {
  const _SearchSuggestions({required this.options, required this.onSelected});

  final List<String> options;
  final ValueChanged<String> onSelected;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final highlightedIndex = AutocompleteHighlightedOption.of(context);
    return Material(
      key: const ValueKey('search-suggestions'),
      elevation: 4,
      color: colors.surface,
      borderRadius: BorderRadius.circular(12),
      clipBehavior: Clip.antiAlias,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxHeight: 320),
        child: ListView.builder(
          padding: const EdgeInsets.symmetric(vertical: 4),
          shrinkWrap: true,
          itemCount: options.length,
          itemBuilder: (context, index) => ListTile(
            key: ValueKey('search-suggestion-${options[index]}'),
            leading: Icon(Icons.search_rounded, color: colors.onSurfaceVariant),
            title: Text(
              options[index],
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            trailing: Icon(
              Icons.north_west_rounded,
              size: 18,
              color: colors.onSurfaceVariant,
            ),
            tileColor: index == highlightedIndex
                ? colors.surfaceContainerLow
                : null,
            onTap: () => onSelected(options[index]),
          ),
        ),
      ),
    );
  }
}
