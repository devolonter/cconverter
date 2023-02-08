import 'package:currency_picker/currency_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'convert_pipe.dart';

class Settings {
  Settings._internal();
  factory Settings() => _instance;
  static final Settings _instance = Settings._internal();

  late final SharedPreferences _prefs;

  final List<Currency> _recent = [];
  List<Currency> get recentlyUsed => _recent;

  Future load() async {
    _recent.clear();
    _prefs = await SharedPreferences.getInstance();

    final List<String> codes = _prefs.getStringList('recent') ?? [];
    for (final String code in codes) {
      final Currency? currency = ConvertPipe().currencies.findByCode(code);
      if (currency != null) {
        _recent.add(currency);
      }
    }
  }

  void addRecent(Currency currency) {
    if (_recent.contains(currency)) {
      _recent.remove(currency);
    }

    _recent.insert(0, currency);
    if (_recent.length > 5) {
      _recent.removeLast();
    }

    _prefs.setStringList('recent', _recent.map((e) => e.code).toList());
  }
}
