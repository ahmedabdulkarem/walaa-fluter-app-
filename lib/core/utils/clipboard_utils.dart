// lib/core/utils/clipboard_utils.dart
// WHY: Reusable clipboard copy with SnackBar feedback.

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class ClipboardUtils {
  ClipboardUtils._();

  static Future<void> copy(BuildContext context, String text, {String? label}) {
    Clipboard.setData(ClipboardData(text: text));
    final message = label ?? 'تم النسخ';
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
      ),
    );
    return Future.value();
  }

  static String formatNamesForCopy(List<String> names) {
    return names.asMap().entries.map((e) => '${e.key + 1}. ${e.value}').join('\n');
  }
}