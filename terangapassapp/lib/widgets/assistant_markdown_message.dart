import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:url_launcher/url_launcher.dart';

import '../theme/app_theme.dart';

/// Transforme les numéros visibles en liens `tel:` (hors blocs ``` ... ```).
String prepareAssistantMarkdown(String raw) {
  return _linkifyPhonesOutsideCode(raw.trim());
}

String _linkifyPhonesOutsideCode(String input) {
  final fence = RegExp(r'```[\s\S]*?```', multiLine: true);
  final out = StringBuffer();
  var start = 0;
  for (final m in fence.allMatches(input)) {
    out.write(_linkifyPhonesPlain(input.substring(start, m.start)));
    out.write(m.group(0));
    start = m.end;
  }
  out.write(_linkifyPhonesPlain(input.substring(start)));
  return out.toString();
}

String _linkifyPhonesPlain(String s) {
  // +221 … (Sénégal) — espaces / tirets / points tolérés
  return s.replaceAllMapped(
    RegExp(
      r'\+221[\s.\-]*(?:\d[\s.\-]*){9,12}',
      caseSensitive: false,
    ),
    (m) {
      final raw = m.group(0)!;
      final digits = raw.replaceAll(RegExp(r'[^\d]'), '');
      if (digits.length < 9) return raw;
      final national = digits.startsWith('221') ? digits : '221$digits';
      final e164 = '+$national';
      final display = raw.replaceAll(RegExp(r'\s+'), ' ').trim();
      return '[$display](tel:$e164)';
    },
  );
}

Future<void> assistantMarkdownOnTapLink(
  String text,
  String? href,
  String title,
) async {
  if (href == null || href.isEmpty) return;
  final uri = Uri.tryParse(href);
  if (uri == null) return;

  if (uri.scheme == 'tel') {
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
    return;
  }

  if (uri.scheme == 'http' || uri.scheme == 'https') {
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }
}

/// Bulle de réponse assistant : Markdown, téléphones cliquables, code lisible et non « lien ».
class AssistantMarkdownMessage extends StatelessWidget {
  const AssistantMarkdownMessage({super.key, required this.content});

  final String content;

  @override
  Widget build(BuildContext context) {
    if (content.trim().isEmpty) {
      return const SizedBox.shrink();
    }
    final prepared = prepareAssistantMarkdown(content);
    final base = Theme.of(context).textTheme.bodyMedium ?? const TextStyle();

    final sheet = MarkdownStyleSheet(
      p: base.copyWith(
        fontSize: 14,
        height: 1.48,
        color: AppTheme.textPrimary,
      ),
      h1: base.copyWith(
        fontSize: 18,
        fontWeight: FontWeight.w800,
        height: 1.25,
        color: AppTheme.textPrimary,
      ),
      h2: base.copyWith(
        fontSize: 16,
        fontWeight: FontWeight.w800,
        height: 1.3,
        color: AppTheme.textPrimary,
      ),
      h3: base.copyWith(
        fontSize: 15,
        fontWeight: FontWeight.w700,
        height: 1.3,
        color: AppTheme.textPrimary,
      ),
      strong: base.copyWith(
        fontWeight: FontWeight.w700,
        color: AppTheme.textPrimary,
      ),
      em: base.copyWith(
        fontStyle: FontStyle.italic,
        color: AppTheme.textPrimary,
      ),
      listBullet: base.copyWith(
        fontSize: 14,
        color: AppTheme.primaryGreen,
        fontWeight: FontWeight.w700,
      ),
      listIndent: 20,
      blockSpacing: 10,
      blockquote: base.copyWith(
        fontSize: 14,
        color: AppTheme.textSecondary,
        fontStyle: FontStyle.italic,
      ),
      blockquoteDecoration: BoxDecoration(
        color: const Color(0xFFF0FDF4),
        borderRadius: BorderRadius.circular(8),
        border: Border(
          left: BorderSide(color: AppTheme.primaryGreen, width: 3),
        ),
      ),
      blockquotePadding: const EdgeInsets.fromLTRB(10, 8, 8, 8),
      // Inline code : fond discret, pas de lien
      code: base.copyWith(
        fontSize: 13,
        fontFamily: 'monospace',
        backgroundColor: const Color(0xFFEEF2F6),
        color: const Color(0xFF374151),
      ),
      // Blocs ``` … ``` : zone séparée, monospace, pas confondue avec un lien
      codeblockDecoration: BoxDecoration(
        color: const Color(0xFFF3F4F6),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      codeblockPadding: const EdgeInsets.all(12),
      codeblockAlign: WrapAlignment.start,
      horizontalRuleDecoration: BoxDecoration(
        border: Border(
          top: BorderSide(color: Colors.grey.shade300, width: 1),
        ),
      ),
      a: base.copyWith(
        fontSize: 14,
        color: const Color(0xFF15803D),
        fontWeight: FontWeight.w600,
        decoration: TextDecoration.underline,
        decorationColor: const Color(0xFF15803D),
      ),
    );

    return SelectionArea(
      child: MarkdownBody(
        data: prepared,
        shrinkWrap: true,
        fitContent: true,
        styleSheet: sheet,
        selectable: false,
        onTapLink: assistantMarkdownOnTapLink,
      ),
    );
  }
}
