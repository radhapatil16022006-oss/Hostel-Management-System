import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hostel_management_system/main.dart';

void main() {
  testWidgets('login renders roles and theme control', (tester) async {
    await tester.pumpWidget(const HostelManagementApp());
    await tester.pumpAndSettle();

    expect(find.text('Welcome back'), findsOneWidget);
    expect(find.text('Admin / Warden'), findsOneWidget);
    expect(find.text('Student'), findsOneWidget);
    expect(find.byIcon(Icons.dark_mode_rounded), findsOneWidget);

    await tester.tap(find.byIcon(Icons.dark_mode_rounded));
    await tester.pumpAndSettle();
    expect(find.byIcon(Icons.light_mode_rounded), findsOneWidget);
  });

  testWidgets('warden can sign in and search the student directory', (
    tester,
  ) async {
    await tester.pumpWidget(const HostelManagementApp());
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextFormField).at(0), 'warden');
    await tester.enterText(find.byType(TextFormField).at(1), 'demo123');
    await tester.tap(find.text('Sign in'));
    await tester.pumpAndSettle();

    expect(find.text('TOTAL STUDENTS'), findsOneWidget);
    expect(find.text('9'), findsOneWidget);

    await tester.tap(find.text('Students').last);
    await tester.pumpAndSettle();
    expect(find.text('Student directory'), findsOneWidget);

    await tester.enterText(find.byType(TextField).first, 'Mira Shah');
    await tester.pumpAndSettle();
    expect(find.text('Mira Shah'), findsNWidgets(2));
    expect(find.text('Rahul Deshmukh'), findsNothing);
  });

  testWidgets('student sign-in opens the assigned room view', (tester) async {
    await tester.pumpWidget(const HostelManagementApp());
    await tester.pumpAndSettle();

    await tester.tap(find.text('Student'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextFormField).at(0), 'student_005');
    await tester.enterText(find.byType(TextFormField).at(1), 'demo123');
    await tester.tap(find.text('Sign in'));
    await tester.pumpAndSettle();

    expect(find.text('Sara Khan'), findsOneWidget);
    await tester.tap(find.text('My room'));
    await tester.pumpAndSettle();
    expect(find.text('ROOM 201'), findsOneWidget);
  });
}
