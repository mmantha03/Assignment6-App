import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:scanlog/main.dart';
import 'package:scanlog/models/journal_entry.dart';
import 'package:scanlog/providers/journal_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  test('journal entry converts to and from storage', () {
    final now = DateTime(2026, 6, 28);
    final entry = JournalEntry(
      id: '1',
      title: 'Class Notes',
      text: 'Important exam dates',
      category: 'School',
      notes: 'Review later',
      completed: false,
      createdAt: now,
      updatedAt: now,
    );

    final restored = JournalEntry.fromMap(entry.toMap());

    expect(restored.title, 'Class Notes');
    expect(restored.category, 'School');
    expect(restored.notes, 'Review later');
  });

  test('provider requires a title and scanned text before saving', () async {
    SharedPreferences.setMockInitialValues({});
    final provider = JournalProvider();

    final savedWithoutTitle = await provider.addEntry();
    expect(savedWithoutTitle, isFalse);
    expect(provider.errorMessage, 'Add a title before saving.');

    provider.updateDraftTitle('Receipt');
    final savedWithoutText = await provider.addEntry();
    expect(savedWithoutText, isFalse);
    expect(provider.errorMessage, 'Add or scan text before saving.');
  });

  testWidgets('home screen shows empty saved scan state', (tester) async {
    SharedPreferences.setMockInitialValues({});
    tester.view.physicalSize = const Size(430, 1200);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(const ScanLogApp());
    await tester.pumpAndSettle();

    expect(find.text('ScanLog'), findsOneWidget);
    expect(find.text('No saved scans yet'), findsOneWidget);
  });
}
