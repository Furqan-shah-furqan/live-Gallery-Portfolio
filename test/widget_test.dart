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

  testWidgets('Portfolio loads and shows empty live systems state', (
    WidgetTester tester,
  ) async {
    useDesktopSize(tester);
    final store = await createStore();

    await tester.pumpWidget(LiveSystemsApp(store: store));
    await tester.pump(const Duration(milliseconds: 1000));

    expect(find.text('LIVE SYSTEMS GALLERY'), findsOneWidget);
    expect(find.text('Explore Live Work'), findsWidgets);
    expect(find.text('No Projects added Yet'), findsOneWidget);
  });

  testWidgets('Explore Live Work opens the all projects page', (
    WidgetTester tester,
  ) async {
    useDesktopSize(tester);
    final store = await createStore();

    await tester.pumpWidget(LiveSystemsApp(store: store));
    await tester.pump(const Duration(milliseconds: 1000));

    final exploreButton = find.text('Explore Live Work').first;
    await tester.ensureVisible(exploreButton);
    await tester.tap(exploreButton);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 800));

    expect(find.text('ALL LIVE PROJECTS'), findsOneWidget);
    expect(find.text('No Projects added Yet'), findsOneWidget);
  });

  testWidgets('Admin Control requires the password before opening', (
    WidgetTester tester,
  ) async {
    useDesktopSize(tester);
    final store = await createStore();

    await tester.pumpWidget(LiveSystemsApp(store: store));
    await tester.pump(const Duration(milliseconds: 1000));

    final adminButton = find.text('Admin Control');
    await tester.ensureVisible(adminButton);
    await tester.tap(adminButton);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 650));

    expect(find.text('Admin password'), findsOneWidget);

    await tester.enterText(find.byType(TextField), adminControlPassword);
    await tester.tap(find.text('Unlock Admin'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 900));

    expect(find.text('ADMIN CONTROL'), findsOneWidget);
  });
}
