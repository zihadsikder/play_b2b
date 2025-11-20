class AppLogger {
  static void log(String message, {String tag = 'APP'}) {
    log('[$tag] $message');
  }

  static void error(String message, {String tag = 'ERROR'}) {
    log('[$tag] ❌ $message');
  }

  static void success(String message, {String tag = 'SUCCESS'}) {
    log('[$tag] ✅ $message');
  }
}
