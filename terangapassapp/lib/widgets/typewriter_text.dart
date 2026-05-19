import 'dart:async';

import 'package:flutter/material.dart';

/// Texte animé lettre par lettre, avec rotation optionnelle entre plusieurs phrases.
class TypewriterText extends StatefulWidget {
  const TypewriterText({
    super.key,
    required this.phrases,
    this.style,
    this.prefix = '',
    this.loop = true,
    this.showCursor = true,
    this.maxLines = 2,
    this.textAlign = TextAlign.start,
    this.typingInterval = const Duration(milliseconds: 65),
    this.deletingInterval = const Duration(milliseconds: 40),
    this.pauseAfterPhrase = const Duration(milliseconds: 2200),
  });

  final List<String> phrases;
  final TextStyle? style;
  final String prefix;
  final bool loop;
  final bool showCursor;
  final int maxLines;
  final TextAlign textAlign;
  final Duration typingInterval;
  final Duration deletingInterval;
  final Duration pauseAfterPhrase;

  /// Extrait les segments depuis « A, B, C... ».
  static List<String> phrasesFromCommaList(String raw) {
    return raw
        .replaceAll(RegExp(r'\.+$'), '')
        .split(RegExp(r'[,،]\s*'))
        .map((s) => s.trim())
        .where((s) => s.isNotEmpty)
        .toList();
  }

  @override
  State<TypewriterText> createState() => _TypewriterTextState();
}

class _TypewriterTextState extends State<TypewriterText> {
  Timer? _timer;
  int _phraseIndex = 0;
  int _charIndex = 0;
  bool _deleting = false;
  bool _pausing = false;
  bool _finished = false;
  String _display = '';

  @override
  void initState() {
    super.initState();
    _scheduleTick(widget.typingInterval);
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _scheduleTick(Duration delay) {
    _timer?.cancel();
    if (_finished) return;
    _timer = Timer(delay, _tick);
  }

  void _tick() {
    if (!mounted || _finished) return;

    final phrases = widget.phrases.where((p) => p.trim().isNotEmpty).toList();
    if (phrases.isEmpty) return;

    if (_pausing) {
      _pausing = false;
      if (!widget.loop && phrases.length <= 1) {
        setState(() => _finished = true);
        return;
      }
      if (!widget.loop && _phraseIndex >= phrases.length - 1) {
        setState(() => _finished = true);
        return;
      }
      _deleting = true;
      _scheduleTick(widget.deletingInterval);
      return;
    }

    final phrase = phrases[_phraseIndex % phrases.length];

    if (!_deleting) {
      if (_charIndex < phrase.length) {
        _charIndex++;
        _display = '${widget.prefix}${phrase.substring(0, _charIndex)}';
        setState(() {});
        _scheduleTick(widget.typingInterval);
        return;
      }
      _pausing = true;
      setState(() {});
      _scheduleTick(widget.pauseAfterPhrase);
      return;
    }

    if (_charIndex > 0) {
      _charIndex--;
      _display = '${widget.prefix}${phrase.substring(0, _charIndex)}';
      setState(() {});
      _scheduleTick(widget.deletingInterval);
      return;
    }

    _deleting = false;
    _phraseIndex = (_phraseIndex + 1) % phrases.length;
    if (!widget.loop && _phraseIndex >= phrases.length) {
      setState(() => _finished = true);
      return;
    }
    _scheduleTick(widget.typingInterval);
  }

  @override
  Widget build(BuildContext context) {
    final showCursor = widget.showCursor && !_finished;

    return Text.rich(
      TextSpan(
        children: [
          TextSpan(text: _display, style: widget.style),
          if (showCursor)
            TextSpan(
              text: '|',
              style: widget.style?.copyWith(
                color: widget.style?.color?.withValues(alpha: 0.75),
              ),
            ),
        ],
      ),
      maxLines: widget.maxLines,
      overflow: TextOverflow.ellipsis,
      textAlign: widget.textAlign,
    );
  }
}
