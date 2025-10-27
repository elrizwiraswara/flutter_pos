class AppConst {
  // Prevents instantiation and extension
  AppConst._();

  static const String syncedMessage = 'Data synced';
  static const String synchronizingMessage = 'Running data syncronization';
  static const String syncPendingMessage = 'Data will automatically sync when internet available';
  static const String onlineMessage = 'Online mode';
  static const String offlineMessage = 'No internet connection, running in offline mode';
  static const String firstTimeInternetErrorMessage =
      'No Internet connection! Internet connection is required for the first time app open or user login';
  static const String fetchDataFailedMessage = 'Failed to fetch data, please try again';
  static const String noInternetMessage = 'Please check your internet connection and try again';

  static const int minSyncIntervalToleranceForCriticalInMinutes = 5;
  static const int minSyncIntervalToleranceForLessCriticalInMinutes = 100;

  static const List<String> authScopes = [
    'https://www.googleapis.com/auth/userinfo.profile',
    'https://www.googleapis.com/auth/userinfo.email',
  ];
}
