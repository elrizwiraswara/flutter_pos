class AppConfig {
  // Prevents instantiation and extension
  AppConfig._();

  static const googleServerClientId = String.fromEnvironment('GOOGLE_SERVER_CLIENT_ID');
}
