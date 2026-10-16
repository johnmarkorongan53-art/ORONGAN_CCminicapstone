import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:jism/main.dart';

void main() {
  testWidgets('bottom navigation opens every destination', (tester) async {
    await tester.pumpWidget(const AthleteTrackApp());

    await tester.tap(find.byIcon(Icons.list_alt_outlined));
    await tester.pumpAndSettle();
    expect(find.text('Add Routine'), findsOneWidget);

    await tester.tap(find.byIcon(Icons.notifications_outlined));
    await tester.pumpAndSettle();
    expect(find.text('Weekly report ready'), findsOneWidget);

    await tester.tap(find.byIcon(Icons.person_outline));
    await tester.pumpAndSettle();
    expect(find.text('Juan Dela Cruz'), findsOneWidget);

    await tester.tap(find.byIcon(Icons.home_outlined));
    await tester.pumpAndSettle();
    expect(find.text('Quick Actions'), findsOneWidget);
  });

  testWidgets('schedule supports adding, editing, and deleting routines', (
    tester,
  ) async {
    await tester.pumpWidget(const AthleteTrackApp());
    await tester.tap(find.byIcon(Icons.list_alt_outlined));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Add Routine'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextFormField).at(0), 'Tempo Run');
    await tester.enterText(find.byType(TextFormField).at(1), 'Thu · 5:00 PM');
    await tester.enterText(find.byType(TextFormField).at(2), '35');
    await tester.tap(find.widgetWithText(FilledButton, 'Add'));
    await tester.pumpAndSettle();
    expect(find.text('Tempo Run'), findsOneWidget);
    expect(find.text('Tempo Run added successfully'), findsOneWidget);

    await tester.tap(find.byTooltip('Routine actions').first);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Edit'));
    await tester.pumpAndSettle();
    await tester.enterText(
      find.byType(TextFormField).at(0),
      'Tempo Run Edited',
    );
    await tester.tap(find.widgetWithText(FilledButton, 'Save'));
    await tester.pumpAndSettle();
    expect(find.text('Tempo Run Edited'), findsOneWidget);
    expect(find.text('Tempo Run'), findsNothing);

    await tester.tap(find.byTooltip('Routine actions').first);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Delete'));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(FilledButton, 'Delete'));
    await tester.pumpAndSettle();
    expect(find.text('Tempo Run Edited'), findsNothing);
  });

  testWidgets('profile can be edited and notice cards open details', (
    tester,
  ) async {
    await tester.pumpWidget(const AthleteTrackApp());

    await tester.tap(find.byIcon(Icons.person_outline));
    await tester.pumpAndSettle();
    await tester.scrollUntilVisible(
      find.text('Edit Profile'),
      300,
      scrollable: find
          .descendant(
            of: find.byType(ProfilePage),
            matching: find.byType(Scrollable),
          )
          .first,
    );
    await tester.tap(find.text('Edit Profile'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextFormField).at(0), 'Alex Runner');
    await tester.enterText(find.byType(TextFormField).at(1), 'Marathon');
    await tester.tap(find.widgetWithText(FilledButton, 'Save'));
    await tester.pumpAndSettle();
    expect(find.byType(AlertDialog), findsNothing);
    expect(find.text('Profile updated'), findsOneWidget);
    await tester.drag(
      find
          .descendant(
            of: find.byType(ProfilePage),
            matching: find.byType(Scrollable),
          )
          .first,
      const Offset(0, 500),
    );
    await tester.pumpAndSettle();
    expect(find.text('Alex Runner'), findsOneWidget);
    expect(find.text('Marathon'), findsOneWidget);

    await tester.tap(find.byIcon(Icons.notifications_outlined));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Weekly report ready'));
    await tester.pumpAndSettle();
    expect(find.text('You completed 80% of sessions'), findsWidgets);
  });
}
