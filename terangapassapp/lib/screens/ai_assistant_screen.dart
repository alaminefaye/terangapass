import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../services/api_service.dart';
import '../services/location_service.dart';
import '../theme/app_theme.dart';
import '../theme/app_theme_extensions.dart';
import '../l10n/app_localizations.dart';
import '../widgets/assistant_markdown_message.dart';

/// Libellé court pour la puce, question complète envoyée à l’API.
class _AiSuggestion {
  const _AiSuggestion({required this.label, required this.query});

  final String label;
  final String query;
}

List<_AiSuggestion> _aiSuggestions(AppLocalizations l10n) => [
      _AiSuggestion(
        label: l10n.aiSuggestionCompetitionSites,
        query: l10n.aiSuggestionCompetitionSitesQuery,
      ),
      _AiSuggestion(
        label: l10n.aiSuggestionShuttles,
        query: l10n.aiSuggestionShuttlesQuery,
      ),
      _AiSuggestion(
        label: l10n.aiSuggestionTourism,
        query: l10n.aiSuggestionTourismQuery,
      ),
      _AiSuggestion(
        label: l10n.aiSuggestionAnnouncements,
        query: l10n.aiSuggestionAnnouncementsQuery,
      ),
      _AiSuggestion(
        label: l10n.aiSuggestionEmergencies,
        query: l10n.aiSuggestionEmergenciesQuery,
      ),
      _AiSuggestion(
        label: l10n.aiSuggestionCalendar,
        query: l10n.aiSuggestionCalendarQuery,
      ),
    ];

class AIAssistantScreen extends StatefulWidget {
  const AIAssistantScreen({super.key});

  @override
  State<AIAssistantScreen> createState() => _AIAssistantScreenState();
}

class _AIAssistantScreenState extends State<AIAssistantScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final ApiService _apiService = ApiService();
  bool _isSending = false;
  final List<_ChatMessage> _messages = [];
  String? _profileName;
  final LocationService _locationService = LocationService();
  /// `null` : pas encore demandé ; `true` / `false` : dernier essai de localisation.
  bool? _locationPermissionTried;
  bool _welcomeSeeded = false;

  @override
  void initState() {
    super.initState();
    _loadPersistedMessages();
    _loadProfileName();
    WidgetsBinding.instance.addPostFrameCallback((_) => _requestLocationAccess());
  }

  /// Demande l’accès à la localisation à l’ouverture de l’écran (dialogue système).
  Future<void> _requestLocationAccess() async {
    final pos = await _locationService.getCurrentPositionIfAllowed();
    if (!mounted) return;
    setState(() {
      _locationPermissionTried = pos != null;
    });
  }

  Future<void> _loadProfileName() async {
    try {
      final p = await _apiService.getUserProfile();
      final n = p['name']?.toString().trim();
      if (!mounted || n == null || n.isEmpty) return;
      setState(() => _profileName = n);
    } catch (_) {}
  }

  Future<void> _loadPersistedMessages() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final key = await ApiService.aiConversationPrefsKey();
      final raw = prefs.getString(key);
      if (raw == null || raw.isEmpty || !mounted) return;
      final decoded = jsonDecode(raw);
      if (decoded is! List) return;
      final loaded = <_ChatMessage>[];
      for (final e in decoded) {
        if (e is Map) {
          loaded.add(_ChatMessage.fromJson(Map<String, dynamic>.from(e)));
        }
      }
      if (loaded.isEmpty || !mounted) return;
      setState(() {
        _messages
          ..clear()
          ..addAll(loaded);
      });
    } catch (_) {}
  }

  void _trimMessagesIfNeeded() {
    const maxTotal = 100;
    if (_messages.length <= maxTotal) return;
    final first = _messages.first;
    final tail = _messages.sublist(_messages.length - (maxTotal - 1));
    _messages
      ..clear()
      ..add(first)
      ..addAll(tail);
  }

  Future<void> _persistMessages() async {
    try {
      _trimMessagesIfNeeded();
      final prefs = await SharedPreferences.getInstance();
      final key = await ApiService.aiConversationPrefsKey();
      final raw = jsonEncode(_messages.map((m) => m.toJson()).toList());
      await prefs.setString(key, raw);
    } catch (_) {}
  }

  List<Map<String, String>> _buildConversationHistoryForApi() {
    if (_messages.length < 2) return [];
    final prior = _messages.sublist(0, _messages.length - 1);
    final out = <Map<String, String>>[];
    for (final m in prior) {
      if (m.excludeFromApiHistory) continue;
      out.add({
        'role': m.role == _ChatRole.user ? 'user' : 'assistant',
        'content': m.content,
      });
    }
    while (out.isNotEmpty && out.first['role'] != 'user') {
      out.removeAt(0);
    }
    if (out.length > 24) {
      return out.sublist(out.length - 24);
    }
    return out;
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _sendMessage([String? presetQuery]) async {
    if (_isSending) return;
    final text = (presetQuery ?? _messageController.text).trim();
    if (text.isEmpty) return;

    setState(() {
      _messages.add(_ChatMessage(role: _ChatRole.user, content: text));
      _isSending = true;
    });

    _messageController.clear();

    _scrollToBottom();

    try {
      final history = _buildConversationHistoryForApi();
      final pos = await _locationService.getCurrentPositionIfAllowed();
      if (mounted) {
        setState(() => _locationPermissionTried = pos != null);
      }

      final response = await _apiService.sendAiMessage(
        text,
        conversationHistory: history.isEmpty ? null : history,
        latitude: pos?.latitude,
        longitude: pos?.longitude,
        accuracyMeters: pos?.accuracy,
      );
      final data = response['data'];
      final reply =
          data is Map<String, dynamic> ? data['reply']?.toString() : null;

      if (!mounted) return;
      final l10n = AppLocalizations.of(context)!;
      setState(() {
        _messages.add(
          _ChatMessage(
            role: _ChatRole.assistant,
            content: (reply != null && reply.trim().isNotEmpty)
                ? reply.trim()
                : l10n.aiEmptyReply,
          ),
        );
      });
    } catch (e) {
      if (!mounted) return;
      final l10n = AppLocalizations.of(context)!;
      setState(() {
        _messages.add(
          _ChatMessage(
            role: _ChatRole.assistant,
            content: l10n.aiErrorPrefix(
              e.toString().replaceFirst('Exception: ', ''),
            ),
          ),
        );
      });
    } finally {
      if (mounted) {
        setState(() {
          _isSending = false;
        });
      }
      await _persistMessages();
      if (mounted) {
        _scrollToBottom();
      }
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      if (!_scrollController.hasClients) return;
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOut,
      );
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_welcomeSeeded && _messages.isEmpty) {
      final l10n = AppLocalizations.of(context)!;
      _messages.add(
        _ChatMessage(
          role: _ChatRole.assistant,
          content: l10n.aiWelcomeMessage,
          excludeFromApiHistory: true,
        ),
      );
      _welcomeSeeded = true;
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final tp = context.tp;
    final suggestions = _aiSuggestions(l10n);
    return Scaffold(
      backgroundColor: tp.scaffold,
      appBar: AppBar(
        title: Text(
          l10n.aiTitle,
          overflow: TextOverflow.ellipsis,
          maxLines: 1,
        ),
        backgroundColor: AppTheme.primaryGreen,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            color: tp.surface,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (_profileName != null && _profileName!.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 4),
                    child: Text(
                      l10n.aiConnectedAs(_profileName!),
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: tp.textPrimary,
                      ),
                    ),
                  ),
                Text(
                  l10n.aiDisclaimer,
                  style: TextStyle(fontSize: 13, color: tp.textSecondary),
                ),
                if (_locationPermissionTried == false) ...[
                  const SizedBox(height: 6),
                  TextButton.icon(
                    onPressed: _isSending
                        ? null
                        : () => _requestLocationAccess(),
                    icon: const Icon(Icons.location_on_outlined, size: 18),
                    label: Text(l10n.aiAllowLocation),
                    style: TextButton.styleFrom(
                      foregroundColor: AppTheme.primaryGreen,
                      visualDensity: VisualDensity.compact,
                    ),
                  ),
                ],
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final message = _messages[index];
                final isUser = message.role == _ChatRole.user;
                return Align(
                  alignment: isUser
                      ? Alignment.centerRight
                      : Alignment.centerLeft,
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 10),
                    padding: EdgeInsets.symmetric(
                      horizontal: isUser ? 14 : 14,
                      vertical: isUser ? 10 : 12,
                    ),
                    constraints: BoxConstraints(
                      maxWidth: MediaQuery.of(context).size.width * 0.88,
                    ),
                    decoration: BoxDecoration(
                      color: isUser ? AppTheme.primaryGreen : tp.surfaceElevated,
                      borderRadius: BorderRadius.only(
                        topLeft: const Radius.circular(16),
                        topRight: const Radius.circular(16),
                        bottomLeft: Radius.circular(isUser ? 16 : 4),
                        bottomRight: Radius.circular(isUser ? 4 : 16),
                      ),
                      border: isUser
                          ? null
                          : Border.all(color: tp.border),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(
                            alpha: isUser ? 0.06 : 0.07,
                          ),
                          blurRadius: isUser ? 6 : 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: isUser
                        ? Text(
                            message.content,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                              height: 1.45,
                            ),
                          )
                        : AssistantMarkdownMessage(
                            content: message.content,
                          ),
                  ),
                );
              },
            ),
          ),
          SafeArea(
            top: false,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(12, 0, 12, 6),
                  child: Text(
                    l10n.aiSuggestionsTitle,
                    style: Theme.of(context).textTheme.labelMedium?.copyWith(
                          color: tp.textSecondary,
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                ),
                SizedBox(
                  height: 40,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    itemCount: suggestions.length,
                    separatorBuilder: (_, _) => const SizedBox(width: 8),
                    itemBuilder: (context, index) {
                      final s = suggestions[index];
                      return ActionChip(
                        label: Text(
                          s.label,
                          style: TextStyle(
                            fontSize: 13,
                            color: tp.textPrimary,
                          ),
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                        visualDensity: VisualDensity.compact,
                        side: BorderSide(
                          color: AppTheme.primaryGreen.withValues(alpha: 0.35),
                        ),
                        backgroundColor: tp.surface,
                        onPressed: _isSending ? null : () => _sendMessage(s.query),
                      );
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _messageController,
                          textInputAction: TextInputAction.send,
                          onSubmitted: (_) => _sendMessage(),
                          enabled: !_isSending,
                          style: TextStyle(color: tp.textPrimary),
                          decoration: InputDecoration(
                            hintText: l10n.aiMessageHint,
                            hintStyle: TextStyle(color: tp.textSecondary),
                            filled: true,
                            fillColor: tp.surface,
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 10,
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(color: tp.border),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(color: tp.border),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton(
                        onPressed: _isSending ? null : () => _sendMessage(),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.primaryGreen,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 14,
                          ),
                        ),
                        child: _isSending
                            ? const SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    Colors.white,
                                  ),
                                ),
                              )
                            : const Icon(
                                Icons.send_rounded,
                                color: Colors.white,
                              ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

enum _ChatRole { user, assistant }

class _ChatMessage {
  final _ChatRole role;
  final String content;

  /// Message purement local (ex. accueil) — non renvoyé dans l’historique API.
  final bool excludeFromApiHistory;

  const _ChatMessage({
    required this.role,
    required this.content,
    this.excludeFromApiHistory = false,
  });

  Map<String, dynamic> toJson() => {
        'role': role == _ChatRole.user ? 'user' : 'assistant',
        'content': content,
        'excludeFromApiHistory': excludeFromApiHistory,
      };

  factory _ChatMessage.fromJson(Map<String, dynamic> json) {
    final r = json['role'] == 'user' ? _ChatRole.user : _ChatRole.assistant;
    return _ChatMessage(
      role: r,
      content: json['content'] as String? ?? '',
      excludeFromApiHistory: json['excludeFromApiHistory'] as bool? ?? false,
    );
  }
}
