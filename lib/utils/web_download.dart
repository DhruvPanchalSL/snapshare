// Conditional export — uses dart:html on web, stub on mobile
export 'web_download_stub.dart' if (dart.library.html) 'web_download_web.dart';
