import 'dart:ui';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

import 'core/app_theme.dart';
import 'core/theme_controller.dart';
import 'pages/home_page.dart';
import 'services/project_store.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final store = ProjectStore();
  final themeController = ThemeController();

  // Both loads are backed by browser storage (IndexedDB via idb_shim and
  // localStorage via shared_preferences). On the web that access can fail —
  // blocked site data, private browsing, or IndexedDB denial — and an await
  // that throws here would prevent runApp() entirely, leaving a blank white
  // page. Each load is therefore isolated: the app always boots, falls back
  // to the empty project list and the default palette, and logs the reason.
  try {
    await store.load();
  } catch (error) {
    debugPrint('Project storage unavailable at startup: $error');
  }
  try {
    await themeController.load();
  } catch (error) {
    debugPrint('Theme storage unavailable at startup: $error');
  }

  runApp(
    LiveSystemsApp(
      store: store,
      themeController: themeController,
    ),
  );
}

class LiveSystemsApp extends StatelessWidget {
  LiveSystemsApp({
    super.key,
    required this.store,
    ThemeController? themeController,
  }) : themeController = themeController ?? ThemeController();

  final ProjectStore store;
  final ThemeController themeController;

  @override
  Widget build(BuildContext context) {
    return ProjectStoreScope(
      notifier: store,
      child: ThemeControllerScope(
        notifier: themeController,
        child: AnimatedBuilder(
          animation: themeController,
          builder: (context, _) {
            return MaterialApp(
              debugShowCheckedModeBanner: false,
              title: 'Live Systems Gallery',
              theme: AppTheme.themeFor(themeController.palette),
              themeAnimationDuration: const Duration(milliseconds: 620),
              themeAnimationCurve: const Cubic(0.22, 1, 0.36, 1),
              scrollBehavior: const NoScrollbarBehavior(),
              builder: (context, child) => child ?? const SizedBox(),
              home: const HomePage(),
            );
          },
        ),
      ),
    );
  }
}

class NoScrollbarBehavior extends MaterialScrollBehavior {
  const NoScrollbarBehavior();

  @override
  Widget buildScrollbar(
    BuildContext context,
    Widget child,
    ScrollableDetails details,
  ) {
    return child;
  }

  @override
  Set<PointerDeviceKind> get dragDevices => <PointerDeviceKind>{
        PointerDeviceKind.touch,
        PointerDeviceKind.mouse,
        PointerDeviceKind.trackpad,
        PointerDeviceKind.stylus,
        PointerDeviceKind.unknown,
      };
}
