class Constants {
  // Prevents instantiation and extension
  Constants._();

  // Web client ID from google-services.json (client_type: 3)
  // This is required for Google Sign-In to return a valid ID token for Firebase Auth.
  static const googleServerClientId = '822682936719-103eg2rvahkopk89r5fvc25ua25cqpgj.apps.googleusercontent.com';

  static const String selectedDeviceIdKey = 'selected_device_id';
  static const String selectedConnectionTypeKey = 'selected_connection_type';
  static const String selectedPaperSizeKey = 'selected_paper_size';
  static const String selectedBrightnessKey = 'selected_brightness';

  static const int minSyncIntervalToleranceForCriticalInMinutes = 5;
  static const int minSyncIntervalToleranceForLessCriticalInMinutes = 100;

  // Google OAuth scopes required for user authentication
  static const List<String> authScopes = [
    'https://www.googleapis.com/auth/userinfo.profile',
    'https://www.googleapis.com/auth/userinfo.email',
  ];

  // Non-critical error libraries that should be logged but not navigate to error screen
  static const nonCriticalErrorLibraries = {
    'image resource service',
  };
}
