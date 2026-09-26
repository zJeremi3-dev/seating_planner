/// The UI languages the app can be displayed in.
enum AppLanguage {
  german,
  english;

  String get code => this == AppLanguage.german ? 'de' : 'en';

  static AppLanguage fromCode(String? code) {
    return code == 'en' ? AppLanguage.english : AppLanguage.german;
  }
}
