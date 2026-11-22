import 'package:flutter/material.dart';

class FormattedText extends StatelessWidget {
  final String text;
  final TextStyle baseStyle;
  final TextStyle? boldStyle;
  final TextAlign textAlign;

  const FormattedText({
    super.key,
    required this.text,
    required this.baseStyle,
    this.boldStyle,
    this.textAlign = TextAlign.start,
  });

  @override
  Widget build(BuildContext context) {
    // Normalizar saltos de línea literales "\\n" a "\n"
    final cleanText = text.replaceAll('\\n', '\n');

    final spans = <InlineSpan>[];
    // Expresión regular para capturar **negrita**
    final regex = RegExp(r'\*\*(.*?)\*\*');
    int lastMatchEnd = 0;

    for (final match in regex.allMatches(cleanText)) {
      if (match.start > lastMatchEnd) {
        spans.add(TextSpan(
          text: cleanText.substring(lastMatchEnd, match.start),
          style: baseStyle,
        ));
      }

      final boldContent = match.group(1) ?? '';
      spans.add(TextSpan(
        text: boldContent,
        style: boldStyle ?? baseStyle.copyWith(fontWeight: FontWeight.w900),
      ));

      lastMatchEnd = match.end;
    }

    if (lastMatchEnd < cleanText.length) {
      spans.add(TextSpan(
        text: cleanText.substring(lastMatchEnd),
        style: baseStyle,
      ));
    }

    return Text.rich(
      TextSpan(children: spans),
      textAlign: textAlign,
    );
  }
}
