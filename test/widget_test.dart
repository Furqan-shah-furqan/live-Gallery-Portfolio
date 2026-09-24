import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:live_systems_gallery/main.dart';
import 'package:live_systems_gallery/pages/admin_access.dart';
import 'package:live_systems_gallery/services/project_store.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues(<String, Object>{});
  });

  Future<ProjectStore> createStore() async {
    final store = ProjectStore();
    await store.load();
    return store;
  }

  void useDesktopSize(WidgetTester tester) {
    tester.view.physicalSize = const Size(1440, 1000);
    tester.view.devicePixelRatio = 1.0;

    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });
  }

  Future<void> pumpHome(WidgetTester tester, ProjectStore store) async {
    await tester.pumpWidget(LiveSystemsApp(store: store));
    await tester.pump(const Duration(milliseconds: 1200));
  }

  testWidgets('Portfolio loads with the Aura-Bento hero and empty state', (
    WidgetTester tester,
  ) async {
    useDesktopSize(tester);
    final store = await createStore();

    await pumpHome(tester, store);

    expect(find.text('AUTONOMOUS FLUTTER INTERFACES'), findsOneWidget);
    expect(find.text('Explore Live Work'), findsOneWidget);
    expect(find.text('No Projects added Yet'), findsOneWidget);
  });

  testWidgets('Explore Live Work opens the all projects page', (
    WidgetTester tester,
  ) async {
    useDesktopSize(tester);
    final store = await createStore();

    await pumpHome(tester, store);

    final exploreButton = find.text('Explore Live Work').first;
    await tester.ensureVisible(exploreButton);
    await tester.tap(exploreButton);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 900));

    expect(find.text('ALL LIVE PROJECTS'), findsOneWidget);
    expect(find.text('No Projects added Yet'), findsOneWidget);
  });

  testWidgets('Admin Control requires the password before opening', (
    WidgetTester tester,
  ) async {
    useDesktopSize(tester);
    final store = await createStore();

    await pumpHome(tester, store);

    final adminButton = find.text('Admin Control').first;
    await tester.ensureVisible(adminButton);
    await tester.tap(adminButton);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 900));

    expect(find.text('Admin password'), findsOneWidget);

    await tester.enterText(
      find.widgetWithText(TextField, 'Enter password'),
      adminControlPassword,
    );
    await tester.tap(find.text('Unlock Admin'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 900));

    expect(find.text('ADMIN CONTROL'), findsOneWidget);
  });
}
