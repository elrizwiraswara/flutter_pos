import 'package:flutter/foundation.dart';

class HomeProvider extends ChangeNotifier {
  bool isBottomExpanded = false;

  void onChangedIsBottomExpanded(bool val) {
    isBottomExpanded = val;
    notifyListeners();
  }
}
