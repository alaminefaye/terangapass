import 'dart:async';

import 'package:flutter/material.dart';

/// Bannière hero : « Bienvenue » écrit une fois, le slogan s’anime en boucle.
class TypewriterHeroMessage extends StatefulWidget {
  const TypewriterHeroMessage({
    super.key,
    required this.welcomeLine,
    required this.taglineLine,
    this.welcomeStyle,
    this.taglineStyle,
    this.typingInterval = const Duration(milliseconds: 55),
    this.deletingInterval = const Duration(milliseconds: 35),
    this.pauseWhenComplete = const Duration(milliseconds: 2800),
    this.pauseBetweenLines = const Duration(milliseconds: 400),
  });

  final String welcomeLine;
  final String taglineLine;
  final TextStyle? welcomeStyle;
  final TextStyle? taglineStyle;
  final Duration typingInterval;
  final Duration deletingInterval;
  final Duration pauseWhenComplete;
  final Duration pauseBetweenLines;

  @override
  State<TypewriterHeroMessage> createState() => _TypewriterHeroMessageState();
}

enum _Phase {
  typingWelcome,
  pauseAfterWelcome,
  typingTagline,
  pauseTagline,
  deletingTagline,
}

class _TypewriterHeroMessageState extends State<TypewriterHeroMessage> {
  Timer? _timer;
  _Phase _phase = _Phase.typingWelcome;
  int _welcomeLen = 0;
  int _taglineLen = 0;
  bool _welcomeDone = false;
  bool _cursorOn = true;

  String get _welcome => widget.welcomeLine.trim();
  String get _tagline => widget.taglineLine.trim();

  @override
  void initState() {
    super.initState();
    if (_welcome.isEmpty) {
      _welcomeDone = true;
      _phase = _Phase.typingTagline;
    }
    _schedule(_phase, widget.typingInterval);
    _blinkCursor();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _blinkCursor() {
    Future.delayed(const Duration(milliseconds: 520), () {
      if (!mounted) return;
      setState(() => _cursorOn = !_cursorOn);
      _blinkCursor();
    });
  }

  void _schedule(_Phase phase, Duration delay) {
    _timer?.cancel();
    _phase = phase;
    _timer = Timer(delay, _tick);
  }

  void _tick() {
    if (!mounted) return;

    switch (_phase) {
      case _Phase.typingWelcome:
        if (_welcomeLen < _welcome.length) {
          setState(() => _welcomeLen++);
          _schedule(_Phase.typingWelcome, widget.typingInterval);
          return;
        }
        setState(() => _welcomeDone = true);
        _schedule(_Phase.pauseAfterWelcome, widget.pauseBetweenLines);

      case _Phase.pauseAfterWelcome:
        _schedule(_Phase.typingTagline, widget.typingInterval);

      case _Phase.typingTagline:
        if (_tagline.isEmpty) return;
        if (_taglineLen < _tagline.length) {
          setState(() => _taglineLen++);
          _schedule(_Phase.typingTagline, widget.typingInterval);
          return;
        }
        _schedule(_Phase.pauseTagline, widget.pauseWhenComplete);

      case _Phase.pauseTagline:
        _schedule(_Phase.deletingTagline, widget.deletingInterval);

      case _Phase.deletingTagline:
        if (_taglineLen > 0) {
          setState(() => _taglineLen--);
          _schedule(_Phase.deletingTagline, widget.deletingInterval);
          return;
        }
        _schedule(_Phase.typingTagline, widget.typingInterval);
    }
  }

  bool get _cursorOnWelcome => !_welcomeDone;

  @override
  Widget build(BuildContext context) {
    final welcomeVisible = _welcome.substring(0, _welcomeLen);
    final taglineVisible = _tagline.substring(0, _taglineLen);

    final welcomeStyle = widget.welcomeStyle ??
        const TextStyle(
          color: Colors.white70,
          fontSize: 13,
          fontWeight: FontWeight.w500,
        );
    final taglineStyle = widget.taglineStyle ??
        const TextStyle(
          color: Colors.white,
          fontSize: 22,
          fontWeight: FontWeight.w700,
          height: 1.15,
        );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (_welcome.isNotEmpty)
          Text.rich(
            TextSpan(
              children: [
                TextSpan(text: welcomeVisible, style: welcomeStyle),
                if (_cursorOnWelcome)
                  TextSpan(
                    text: _cursorOn ? '|' : ' ',
                    style: welcomeStyle.copyWith(
                      color: welcomeStyle.color?.withValues(alpha: 0.75),
                    ),
                  ),
              ],
            ),
          ),
        if (_tagline.isNotEmpty && (_welcomeDone || _taglineLen > 0)) ...[
          if (_welcome.isNotEmpty) const SizedBox(height: 6),
          Text.rich(
            TextSpan(
              children: [
                TextSpan(text: taglineVisible, style: taglineStyle),
                if (_welcomeDone)
                  TextSpan(
                    text: _cursorOn ? '|' : ' ',
                    style: taglineStyle.copyWith(
                      color: taglineStyle.color?.withValues(alpha: 0.75),
                    ),
                  ),
              ],
            ),
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ],
    );
  }
}
