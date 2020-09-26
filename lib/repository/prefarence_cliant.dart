import 'package:flutter_riverpod/all.dart';
import 'package:shared_preferences/shared_preferences.dart';

final sharedPreferencesClient = Provider((ref) => SharedPreferencesClient());

class SharedPreferencesClient {
  Future<bool> getOnlyNotCompleted() async {
    final pref = await SharedPreferences.getInstance();
    return pref.getBool('onlyNotCompleted');
  }

  Future<void> saveOnlyNotCompleted(bool val) async {
    final pref = await SharedPreferences.getInstance();
    pref.setBool('onlyNotCompleted', val);
  }

  Future<int> getSortOrderIndex() async {
    final pref = await SharedPreferences.getInstance();
    return pref.getInt('sortOrder');
  }

  Future<void> saveSortOrderIndex(int index) async {
    final pref = await SharedPreferences.getInstance();
    pref.setInt('sortOrder', index);
  }
}
