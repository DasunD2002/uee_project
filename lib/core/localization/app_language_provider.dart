import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../theme/app_colors.dart';
import 'app_language.dart';
import 'app_localizations.dart';

class AppLanguageProvider extends ChangeNotifier {
  AppLanguageProvider._();

  static final AppLanguageProvider instance = AppLanguageProvider._();
  static const String _prefKey = 'app_language';

  AppLanguage _currentLanguage = AppLanguage.english;
  bool _initialized = false;

  AppLanguage get currentLanguage => _currentLanguage;
  Locale get currentLocale => _currentLanguage.locale;
  bool get isInitialized => _initialized;

  Future<void> init() async {
    if (_initialized) return;
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedCode = prefs.getString(_prefKey) ?? prefs.getString('settings.language');
      if (savedCode != null) {
        _currentLanguage = AppLanguage.fromCode(savedCode);
      }
    } catch (_) {
      _currentLanguage = AppLanguage.english;
    } finally {
      _initialized = true;
      notifyListeners();
    }
  }

  Future<void> setLanguage(AppLanguage language) async {
    if (_currentLanguage == language) return;
    _currentLanguage = language;
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_prefKey, language.code);
      await prefs.setString('settings.language', language.code);
    } catch (_) {
      // Ignored if storage write fails; state is still updated in-memory
    }
  }

  /// Shows an interactive dialog to select language (English, Sinhala, Tamil)
  Future<void> showLanguageDialog(BuildContext context) async {
    final l10n = AppLocalizations.of(context);
    await showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return ListenableBuilder(
          listenable: this,
          builder: (context, _) {
            return AlertDialog(
              backgroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              title: Row(
                children: [
                  const Icon(Icons.language, color: AppColors.brown, size: 22),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      l10n.selectLanguageTitle,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.brown,
                      ),
                    ),
                  ),
                ],
              ),
              contentPadding: const EdgeInsets.symmetric(vertical: 12),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: AppLanguage.values.map((lang) {
                  final isSelected = lang == _currentLanguage;
                  return InkWell(
                    onTap: () {
                      setLanguage(lang);
                      Navigator.pop(dialogContext);
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                      color: isSelected ? const Color(0xFFFFEAEA) : Colors.transparent,
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  lang.nativeName,
                                  style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                                    color: isSelected ? AppColors.brown : Colors.black87,
                                  ),
                                ),
                                if (lang != AppLanguage.english)
                                  Text(
                                    lang.englishName,
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: isSelected ? AppColors.brown.withValues(alpha: 0.8) : Colors.black54,
                                    ),
                                  ),
                              ],
                            ),
                          ),
                          if (isSelected)
                            const Icon(
                              Icons.check_circle,
                              color: AppColors.brown,
                              size: 20,
                            ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(dialogContext),
                  child: Text(
                    l10n.cancel,
                    style: const TextStyle(color: AppColors.brown),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }
}
