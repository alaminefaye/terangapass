import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../services/api_service.dart';
import '../services/location_service.dart';
import '../theme/app_theme.dart';
import '../widgets/assistant_markdown_message.dart';

const _ChatMessage _kDefaultWelcome = _ChatMessage(
  role: _ChatRole.assistant,
  content:
      'Bonjour, je suis votre assistant IA TerangaPass. Posez votre question.',
  excludeFromApiHistory: true,
);

/// Libellé court pour la puce, question complète envoyée à l’API.
class _AiSuggestion {
  const _AiSuggestion({required this.label, required this.query});

  final String label;
  final String query;
}

const List<_AiSuggestion> _kAiSuggestions = [
  _AiSuggestion(
    label: 'Sites de compétition',
    query:
        'Quels sont les sites de compétition listés dans TerangaPass (noms, adresses, coordonnées) ?',
  ),
  _AiSuggestion(
    label: 'Navettes',
    query: 'Comment fonctionnent les navettes TerangaPass (horaires, arrêts, fréquence) ?',
  ),
  _AiSuggestion(
    label: 'Infos touristiques',
    query: 'Quels points d’intérêt ou partenaires touristiques sont proposés dans l’application ?',
  ),
  _AiSuggestion(
    label: 'Annonces',
    query: 'Quelles sont les dernières annonces audio ou notifications importantes à connaître ?',
  ),
  _AiSuggestion(
    label: 'Urgences',
    query: 'Comment utiliser les fonctions d’urgence, SOS ou alerte médicale dans l’application ?',
  ),
  _AiSuggestion(
    label: 'Calendrier',
    query: 'Où trouver le calendrier ou les compétitions dans TerangaPass ?',
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

  @override
  void initState() {
    super.initState();
    _messages.add(_kDefaultWelcome);
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
      setState(() {
        _messages.add(
          _ChatMessage(
            role: _ChatRole.assistant,
            content: (reply != null && reply.trim().isNotEmpty)
                ? reply.trim()
                : 'Je n ai pas pu generer de reponse. Merci de reessayer.',
          ),
        );
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _messages.add(
          _ChatMessage(
            role: _ChatRole.assistant,
            content: 'Erreur IA: ${e.toString().replaceFirst('Exception: ', '')}',
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
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Assistant IA TerangaPass',
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
            color: AppTheme.backgroundColor,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (_profileName != null && _profileName!.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 4),
                    child: Text(
                      'Connecté(e) : $_profileName',
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                  ),
                const Text(
                  'Réponses basées sur les données TerangaPass (JOJ Dakar 2026).',
                  style: TextStyle(fontSize: 13, color: AppTheme.textSecondary),
                ),
                if (_locationPermissionTried == false) ...[
                  const SizedBox(height: 6),
                  TextButton.icon(
                    onPressed: _isSending
                        ? null
                        : () => _requestLocationAccess(),
                    icon: const Icon(Icons.location_on_outlined, size: 18),
                    label: const Text('Autoriser la localisation'),
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
                      color: isUser ? AppTheme.primaryGreen : Colors.white,
                      borderRadius: BorderRadius.only(
                        topLeft: const Radius.circular(16),
                        topRight: const Radius.circular(16),
                        bottomLeft: Radius.circular(isUser ? 16 : 4),
                        bottomRight: Radius.circular(isUser ? 4 : 16),
                      ),
                      border: isUser
                          ? null
                          : Border.all(
                              color: const Color(0xFFE8EAED),
                            ),
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
                    'Suggestions',
                    style: Theme.of(context).textTheme.labelMedium?.copyWith(
                          color: AppTheme.textSecondary,
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                ),
                SizedBox(
                  height: 40,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    itemCount: _kAiSuggestions.length,
                    separatorBuilder: (_, _) => const SizedBox(width: 8),
                    itemBuilder: (context, index) {
                      final s = _kAiSuggestions[index];
                      return ActionChip(
                        label: Text(
                          s.label,
                          style: const TextStyle(
                            fontSize: 13,
                            color: AppTheme.textPrimary,
                          ),
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                        visualDensity: VisualDensity.compact,
                        side: BorderSide(
                          color: AppTheme.primaryGreen.withValues(alpha: 0.35),
                        ),
                        backgroundColor: Colors.white,
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
                          decoration: InputDecoration(
                            hintText: 'Ecrire un message...',
                            filled: true,
                            fillColor: Colors.white,
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 10,
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide.none,
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
      backgroundColor: const Color(0xFFF7F8FA),
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
