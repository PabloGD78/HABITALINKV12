class AppConfig {
  static const String devBaseUrl = 'http://10.0.2.2:3000'; // Para emulador Android
  static const String prodBaseUrl = 'https://api.tuapp.com';
  
  static String get baseUrl => devBaseUrl; // Cambia aquí una sola vez
}