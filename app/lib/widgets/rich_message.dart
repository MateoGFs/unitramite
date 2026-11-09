import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

import '../core/utils/open_link.dart';

/// Muestra texto con un formato mínimo: **negrita**, [texto](url), URLs
/// sueltas (clicables) y listas con guion.
class RichMessage extends StatefulWidget {
  const RichMessage({
    super.key,
    required this.text,
    required this.style,
    required this.linkColor,
  });

  final String text;
  final TextStyle? style;
  final Color linkColor;

  @override
  State<RichMessage> createState() => _RichMessageState();
}

class _RichMessageState extends State<RichMessage> {
  static final RegExp _tokenRe = RegExp(
    r'\*\*(.+?)\*\*|\[([^\]]+)\]\((https?://[^)\s]+)\)|(https?://[^\s)\]]+)',
  );
  static final RegExp _bulletRe = RegExp(r'^\s*[-*]\s+');
  static final RegExp _trailingRe = RegExp(r'[.,;:!?]+$');

  final List<TapGestureRecognizer> _recognizers = [];

  @override
  void dispose() {
    _disposeRecognizers();
    super.dispose();
  }

  void _disposeRecognizers() {
    for (final recognizer in _recognizers) {
      recognizer.dispose();
    }
    _recognizers.clear();
  }

  TapGestureRecognizer _recognizerFor(String url) {
    final recognizer = TapGestureRecognizer()
      ..onTap = () => openLink(context, url);
    _recognizers.add(recognizer);
    return recognizer;
  }

  String _shorten(String url) =>
      url.length > 48 ? '${url.substring(0, 45)}…' : url;

  InlineSpan _linkSpan(String label, String url) {
    return TextSpan(
      text: label,
      style: TextStyle(
        color: widget.linkColor,
        decoration: TextDecoration.underline,
        decorationColor: widget.linkColor,
      ),
      recognizer: _recognizerFor(url),
    );
  }

  List<InlineSpan> _parseInline(String line) {
    final spans = <InlineSpan>[];
    var last = 0;
    for (final match in _tokenRe.allMatches(line)) {
      if (match.start > last) {
        spans.add(TextSpan(text: line.substring(last, match.start)));
      }
      if (match.group(1) != null) {
        spans.add(
          TextSpan(
            text: match.group(1),
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        );
      } else if (match.group(2) != null) {
        spans.add(_linkSpan(match.group(2)!, match.group(3)!));
      } else {
        var url = match.group(4)!;
        var trailing = '';
        final trim = _trailingRe.firstMatch(url);
        if (trim != null) {
          trailing = trim.group(0)!;
          url = url.substring(0, trim.start);
        }
        spans.add(_linkSpan(_shorten(url), url));
        if (trailing.isNotEmpty) spans.add(TextSpan(text: trailing));
      }
      last = match.end;
    }
    if (last < line.length) spans.add(TextSpan(text: line.substring(last)));
    return spans;
  }

  List<InlineSpan> _parse(String text) {
    final spans = <InlineSpan>[];
    final lines = text.trim().split('\n');
    for (var i = 0; i < lines.length; i++) {
      var line = lines[i];
      final bullet = _bulletRe.firstMatch(line);
      if (bullet != null) line = '•  ${line.substring(bullet.end)}';
      spans.addAll(_parseInline(line));
      if (i < lines.length - 1) spans.add(const TextSpan(text: '\n'));
    }
    return spans;
  }

  @override
  Widget build(BuildContext context) {
    _disposeRecognizers();
    final spans = _parse(widget.text);
    return SelectionArea(
      child: Text.rich(TextSpan(style: widget.style, children: spans)),
    );
  }
}