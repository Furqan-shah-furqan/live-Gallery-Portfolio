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
  await store.load();
  final themeController = ThemeController();
  await themeController.load();
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
