class AppConfig {
  static const String appName = 'Car Handover System';
  static const String appVersion = '1.0.0';
  static const String buildNumber = '1';

  // Environment configurations
  static const bool isProduction = true;
  static const bool isPhone = true;

  static const bool enableLogging = true;
  static const bool enableCrashlytics = false;



  // API Configuration
  static const String baseUrl = isProduction
      ? 'http://109.199.102.40:3000'
      : ( isPhone ? 'http://192.168.1.2:3000' : 'http://10.0.2.2:3000');

  static const int connectionTimeout = 30000; // 30 seconds
  static const int receiveTimeout = 30000; // 30 seconds

  // Storage Configuration
  static const String storagePrefix = 'car_handover_';
  static const int maxCacheSize = 100; // MB

  // PDF Configuration
  static const String pdfAuthor = 'Car Handover System';
  static const String pdfCreator = 'German Insurance Company';
  static const String pdfSubject = 'Vehicle Handover Report';

  // Email Configuration
  static const String emailFromName = 'Car Handover System';
  static const String emailSubject = 'Vehicle Handover Report';

  // File Upload Configuration
  static const int maxFileSize = 10 * 1024 * 1024; // 10 MB
  static const List<String> allowedImageTypes = [
    'image/jpeg',
    'image/png',
    'image/webp'
  ];

  // Signature Configuration
  static const double signatureStrokeWidth = 2.0;
  static const int signatureWidth = 400;
  static const int signatureHeight = 200;

  // Pagination
  static const int defaultPageSize = 20;
  static const int maxPageSize = 100;
}