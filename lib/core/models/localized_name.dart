import 'dart:ui';

class LocalizedName {
  final String tr;
  final String en;
  final String de;

  const LocalizedName({
    required this.tr,
    required this.en,
    required this.de,
  });

  static const empty = LocalizedName(tr: '', en: '', de: '');

  factory LocalizedName.fromJson(dynamic json) {
    if (json is String) {
      return LocalizedName(tr: json, en: json, de: json);
    }
    if (json is! Map) return empty;
    final map = Map<String, dynamic>.from(json);
    return LocalizedName(
      tr: (map['tr'] ?? '').toString(),
      en: (map['en'] ?? '').toString(),
      de: (map['de'] ?? '').toString(),
    );
  }

  String resolve(Locale locale) {
    switch (locale.languageCode) {
      case 'en':
        return en.isNotEmpty ? en : (tr.isNotEmpty ? tr : de);
      case 'de':
        return de.isNotEmpty ? de : (tr.isNotEmpty ? tr : en);
      case 'tr':
      default:
        return tr.isNotEmpty ? tr : (en.isNotEmpty ? en : de);
    }
  }

  @override
  String toString() => tr.isNotEmpty ? tr : (en.isNotEmpty ? en : de);
}
