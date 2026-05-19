import 'dart:async';

import 'package:flutter/material.dart';

import 'typewriter_text.dart';

/// Champ de recherche avec hint animé mot par mot (effet machine à écrire).
class TypewriterSearchField extends StatefulWidget {
  const TypewriterSearchField({
    super.key,
    required this.controller,
    required this.terms,
    required this.onSubmitted,
    this.prefix = '',
    this.textStyle,
    this.hintStyle,
    this.showCursor = true,
    this.typingInterval = const Duration(milliseconds: 75),
    this.deletingInterval = const Duration(milliseconds: 45),
    this.pauseAfterWord = const Duration(milliseconds: 1400),
  });

  final TextEditingController controller;
  final List<String> terms;
  final String prefix;
  final VoidCallback onSubmitted;
  final TextStyle? textStyle;
  final TextStyle? hintStyle;
  final bool showCursor;
  final Duration typingInterval;
  final Duration deletingInterval;
  final Duration pauseAfterWord;

  /// Extrait les mots depuis un hint du type « Restaurants, sites, hôtels... ».
  static List<String> termsFromHint(String hint) =>
      TypewriterText.phrasesFromCommaList(hint);

  @override
  State<TypewriterSearchField> createState() => _TypewriterSearchFieldState();
}

class _TypewriterSearchFieldState extends State<TypewriterSearchField> {
  final FocusNode _focusNode = FocusNode();
  Timer? _timer;
  int _wordIndex = 0;
  int _charIndex = 0;
  bool _deleting = false;
  bool _pausing = false;
  String _animatedHint = '';

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_onControllerChanged);
    _focusNode.addListener(_onFocusChanged);
    _scheduleTick(widget.typingInterval);
  }

  @override
  void dispose() {
    _timer?.cancel();
    widget.controller.removeListener(_onControllerChanged);
    _focusNode.dispose();
    super.dispose();
  }

  bool get _shouldAnimate =>
      widget.terms.isNotEmpty &&
      widget.controller.text.isEmpty &&
      !_focusNode.hasFocus;

  void _onControllerChanged() {
    if (mounted) setState(() {});
    if (!_shouldAnimate) {
      _timer?.cancel();
    } else if (_timer == null || !_timer!.isActive) {
      _scheduleTick(widget.typingInterval);
    }
  }

  void _onFocusChanged() {
    if (mounted) setState(() {});
    if (_focusNode.hasFocus) {
      _timer?.cancel();
    } else if (_shouldAnimate) {
      _scheduleTick(widget.typingInterval);
    }
  }

  void _scheduleTick(Duration delay) {
    _timer?.cancel();
    if (!_shouldAnimate) return;
    _timer = Timer(delay, _tick);
  }

  void _tick() {
    if (!mounted || !_shouldAnimate) return;

    if (_pausing) {
      _pausing = false;
      _deleting = true;
      _scheduleTick(widget.deletingInterval);
      return;
    }

    final terms = widget.terms;
    if (terms.isEmpty) return;

    final word = terms[_wordIndex % terms.length];

    if (!_deleting) {
      if (_charIndex < word.length) {
        _charIndex++;
        _animatedHint = '${widget.prefix}${word.substring(0, _charIndex)}';
        setState(() {});
        _scheduleTick(widget.typingInterval);
        return;
      }
      _pausing = true;
      setState(() {});
      _scheduleTick(widget.pauseAfterWord);
      return;
    }

    if (_charIndex > 0) {
      _charIndex--;
      _animatedHint = '${widget.prefix}${word.substring(0, _charIndex)}';
      setState(() {});
      _scheduleTick(widget.deletingInterval);
      return;
    }

    _deleting = false;
    _wordIndex = (_wordIndex + 1) % terms.length;
    _scheduleTick(widget.typingInterval);
  }

  @override
  Widget build(BuildContext context) {
    final showAnimated = _shouldAnimate;

    return Stack(
      alignment: Alignment.centerLeft,
      children: [
        TextField(
          controller: widget.controller,
          focusNode: _focusNode,
          textInputAction: TextInputAction.search,
          onSubmitted: (_) => widget.onSubmitted(),
          style: widget.textStyle,
          decoration: InputDecoration(
            isDense: true,
            filled: false,
            fillColor: Colors.transparent,
            border: InputBorder.none,
            enabledBorder: InputBorder.none,
            focusedBorder: InputBorder.none,
            disabledBorder: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(vertical: 14),
            hintText: showAnimated ? null : ' ',
            hintStyle: widget.hintStyle,
          ),
        ),
        if (showAnimated)
          IgnorePointer(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 14),
              child: Text.rich(
                TextSpan(
                  children: [
                    TextSpan(text: _animatedHint, style: widget.hintStyle),
                    if (widget.showCursor)
                      TextSpan(
                        text: '|',
                        style: widget.hintStyle?.copyWith(
                          color: widget.hintStyle?.color?.withValues(alpha: 0.65),
                        ),
                      ),
                  ],
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),
      ],
    );
  }
}
