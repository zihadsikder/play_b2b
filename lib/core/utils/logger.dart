class AppLogger {
  static void log(String message, {String tag = 'APP'}) {
    print('[$tag] $message');
  }

  static void error(String message, {String tag = 'ERROR'}) {
    print('[$tag] $message');
  }

  static void success(String message, {String tag = 'SUCCESS'}) {
    print('[$tag] $message');
  }
}
