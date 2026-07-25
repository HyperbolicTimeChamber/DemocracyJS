import 'package:hive_flutter/hive_flutter.dart';
import 'package:democracy_js/core/constants/app_constants.dart';

class HiveStorageService {
  late Box _pollsBox;
  late Box _votesBox;
  late Box _settingsBox;

  Box get pollsBox => _pollsBox;
  Box get votesBox => _votesBox;
  Box get settingsBox => _settingsBox;

  Future<void> init() async {
    await Hive.initFlutter();
    _pollsBox = await Hive.openBox(AppConstants.pollsBox);
    _votesBox = await Hive.openBox(AppConstants.votesBox);
    _settingsBox = await Hive.openBox(AppConstants.settingsBox);
  }
}
