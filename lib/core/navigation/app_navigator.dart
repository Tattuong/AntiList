import 'package:flutter/material.dart';

final GlobalKey<NavigatorState> rootNavigatorKey = GlobalKey<NavigatorState>();

class AppTabs {
  static final index = ValueNotifier<int>(0);
  static final shopFeatures = ValueNotifier<bool>(false);

  static void goHome() => index.value = 0;
  static void goLog() => index.value = 1;
  static void goInsights() => index.value = 2;
  static void goMore() => index.value = 3;
  static void goGarden() => goLog();
  static void goInventory() => goInsights();
  static void goJournal() => goMore();
  static void goShop({bool features = false}) {
    shopFeatures.value = features;
    rootNavigatorKey.currentState?.pushNamed('/shop');
  }
}

BuildContext? get rootContext => rootNavigatorKey.currentContext;

Future<T?> showAppModal<T>(Widget sheet) {
  final ctx = rootContext;
  if (ctx == null) return Future.value(null);
  return showModalBottomSheet<T>(
    context: ctx,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => sheet,
  );
}
