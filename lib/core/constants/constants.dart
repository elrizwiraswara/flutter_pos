class Constants {
  // Prevents instantiation and extension
  Constants._();

  static const googleServerClientId = String.fromEnvironment('GOOGLE_SERVER_CLIENT_ID');

  static const int minSyncIntervalToleranceForCriticalInMinutes = 5;
  static const int minSyncIntervalToleranceForLessCriticalInMinutes = 100;

  static const List<String> authScopes = [
    'https://www.googleapis.com/auth/userinfo.profile',
    'https://www.googleapis.com/auth/userinfo.email',
  ];
}
