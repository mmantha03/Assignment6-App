import 'dart:convert';

import 'package:scanlog/models/journal_entry.dart';
import 'package:shared_preferences/shared_preferences.dart';

class StorageService {
  static const String entriesKey = 'journal_entries';

  Future<void> saveEntries(List<JournalEntry> entries) async {
    final prefs = await SharedPreferences.getInstance();
    final encodedEntries = entries
        .map((entry) => jsonEncode(entry.toMap()))
        .toList();

    await prefs.setStringList(entriesKey, encodedEntries);
  }

  Future<List<JournalEntry>> loadEntries() async {
    final prefs = await SharedPreferences.getInstance();
    final storedEntries = prefs.getStringList(entriesKey) ?? [];

    return storedEntries.map((entryJson) {
      final decoded = jsonDecode(entryJson) as Map<String, dynamic>;
      return JournalEntry.fromMap(decoded);
    }).toList()
      ..sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
  }
}
