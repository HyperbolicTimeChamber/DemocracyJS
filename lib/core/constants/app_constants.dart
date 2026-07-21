abstract class AppConstants {
  static const int defaultServerPort = 5000;
  static const int optionSoftLimit = 10;
  static const int optionHardLimit = 20;
  static const int minOptions = 2;
  static const int maxQuestionLength = 500;
  static const int maxOptionLength = 200;
  static const String mDnsServiceName = 'poll';
  static const String mDnsServiceType = '_http._tcp';
  static const Duration serverStartTimeout = Duration(seconds: 10);
  static const Duration wsReconnectInitial = Duration(seconds: 1);
  static const Duration wsReconnectMax = Duration(seconds: 10);

  // Hive box names
  static const String pollsBox = 'polls';
  static const String votesBox = 'votes';
  static const String settingsBox = 'settings';

  // Settings keys
  static const String serverPortKey = 'server_port';
}
