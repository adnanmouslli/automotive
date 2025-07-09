class AppConstants {
  static const String appName = 'نظام تسليم واستلام المركبات';
  static const String companyName = 'شركة التأمين الألمانية';

  // Storage Keys
  static const String userKey = 'user';
  static const String ordersKey = 'orders';
  static const String settingsKey = 'settings';

  // Status Constants
  static const String statusPending = 'pending';
  static const String statusInProgress = 'in_progress';
  static const String statusCompleted = 'completed';
  static const String statusCancelled = 'cancelled';

  // User Roles
  static const String roleAdmin = 'admin';
  static const String roleDriver = 'driver';

  // Email Configuration
  static const String defaultFromEmail = 'noreply@car-handover.com';
  static const String supportEmail = 'support@car-handover.com';

  // PDF Configuration
  static const String pdfTemplateId = '8e87f8da-86d9-4459-8a6a-7444e18ccf8f';

  // File Paths
  static const String signatureImagePath = 'signatures/';
  static const String orderImagePath = 'orders/';
  static const String pdfReportPath = 'reports/';

  // API Endpoints (for future use)
  static const String baseUrl = 'https://api.car-handover.com/v1/';
  static const String loginEndpoint = 'auth/login';
  static const String ordersEndpoint = 'orders';
  static const String usersEndpoint = 'users';
}