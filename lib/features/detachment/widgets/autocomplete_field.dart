import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';

class AutocompleteField extends StatelessWidget {
  final String label;
  final String? initialValue;
  final List<String> suggestions;
  final ValueChanged<String> onChanged;

  const AutocompleteField({
    super.key,
    required this.label,
    this.initialValue,
    required this.suggestions,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Autocomplete<String>(
      initialValue: initialValue != null
          ? TextEditingValue(text: initialValue!)
          : null,
      optionsBuilder: (textEditingValue) {
        if (textEditingValue.text.isEmpty) {
          return const Iterable<String>.empty();
        }
        final query = textEditingValue.text.trim().toLowerCase();
        return suggestions.where((option) {
          return option.toLowerCase().contains(query);
        });
      },
      onSelected: (value) => onChanged(value),
      fieldViewBuilder:
          (context, textEditingController, focusNode, onFieldSubmitted) {
        return TextField(
          controller: textEditingController,
          focusNode: focusNode,
          textCapitalization: TextCapitalization.words,
          decoration: InputDecoration(
            labelText: label,
            labelStyle:
                const TextStyle(fontFamily: 'Cairo'),
            border: const OutlineInputBorder(),
            suffixIcon: suggestions.isNotEmpty
                ? const Icon(Icons.arrow_drop_down,
                    color: AppColors.onSurfaceVariant)
                : null,
          ),
          style: const TextStyle(fontFamily: 'Cairo'),
          onChanged: (_) => onFieldSubmitted(),
        );
      },
      optionsViewBuilder: (context, onSelected, options) {
        return Align(
          alignment: Alignment.topLeft,
          child: Material(
            elevation: 4,
            borderRadius: BorderRadius.circular(12),
            color: AppColors.surface,
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxHeight: 200),
              child: ListView.builder(
                padding: EdgeInsets.zero,
                shrinkWrap: true,
                itemCount: options.length,
                itemBuilder: (_, index) {
                  final option = options.elementAt(index);
                  return ListTile(
                    dense: true,
                    title: Text(option,
                        style: const TextStyle(
                            fontFamily: 'Cairo', fontSize: 14)),
                    onTap: () => onSelected(option),
                  );
                },
              ),
            ),
          ),
        );
      },
    );
  }
}
