import 'package:flutter/services.dart';

class UsPhoneInputFormatter extends TextInputFormatter {
  const UsPhoneInputFormatter({this.allowLeadingOne = true});

  final bool allowLeadingOne;

  static String format(String input, {bool allowLeadingOne = true}) {
    var digits = _digitsOnly(input);
    if (allowLeadingOne && digits.length > 10 && digits.startsWith('1')) {
      digits = digits.substring(1);
    }
    if (digits.length > 10) {
      digits = digits.substring(0, 10);
    }
    return _formatDigits(digits);
  }

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    var digits = _digitsOnly(newValue.text);
    if (allowLeadingOne && digits.length > 10 && digits.startsWith('1')) {
      digits = digits.substring(1);
    }
    if (digits.length > 10) {
      digits = digits.substring(0, 10);
    }

    final formatted = _formatDigits(digits);
    final digitsBeforeCursor = _countDigitsBeforeCursor(
      newValue.text,
      newValue.selection.end,
    );
    final cursor = _cursorPositionForDigits(formatted, digitsBeforeCursor);

    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: cursor),
    );
  }

  static String _digitsOnly(String input) {
    return input.replaceAll(RegExp(r'\D'), '');
  }

  static String _formatDigits(String digits) {
    if (digits.isEmpty) return '';
    if (digits.length < 4) {
      return '($digits${digits.length == 3 ? ')' : ''}';
    }
    if (digits.length < 7) {
      return '(${digits.substring(0, 3)}) ${digits.substring(3)}';
    }
    return '(${digits.substring(0, 3)}) ${digits.substring(3, 6)}-${digits.substring(6)}';
  }

  static int _countDigitsBeforeCursor(String text, int cursorPosition) {
    if (cursorPosition <= 0) return 0;
    return _digitsOnly(text.substring(0, cursorPosition)).length;
  }

  static int _cursorPositionForDigits(String formatted, int digitsCount) {
    if (digitsCount <= 0) return 0;
    var seen = 0;
    for (var i = 0; i < formatted.length; i++) {
      if (_isDigit(formatted.codeUnitAt(i))) {
        seen++;
        if (seen == digitsCount) {
          return i + 1;
        }
      }
    }
    return formatted.length;
  }

  static bool _isDigit(int codeUnit) {
    return codeUnit >= 48 && codeUnit <= 57;
  }
}
