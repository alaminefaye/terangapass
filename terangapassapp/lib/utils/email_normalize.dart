/// Même logique que le backend : trim, minuscules, caractères invisibles.
String normalizeEmailForAuth(String raw) {
  var s = raw.trim().toLowerCase();
  s = s.replaceAll(RegExp(r'[\u200B-\u200D\uFEFF\u00A0]'), '');
  return s;
}
