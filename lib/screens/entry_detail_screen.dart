import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:scanlog/models/journal_entry.dart';
import 'package:scanlog/providers/journal_provider.dart';

class EntryDetailScreen extends StatefulWidget {
  const EntryDetailScreen({super.key, required this.entry});

  final JournalEntry entry;

  @override
  State<EntryDetailScreen> createState() => _EntryDetailScreenState();
}

class _EntryDetailScreenState extends State<EntryDetailScreen> {
  late final TextEditingController titleController;
  late final TextEditingController textController;
  late final TextEditingController notesController;
  late String category;
  late bool completed;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    titleController = TextEditingController(text: widget.entry.title);
    textController = TextEditingController(text: widget.entry.text);
    notesController = TextEditingController(text: widget.entry.notes);
    category = widget.entry.category;
    completed = widget.entry.completed;
  }

  @override
  void dispose() {
    titleController.dispose();
    textController.dispose();
    notesController.dispose();
    super.dispose();
  }

  Future<void> saveChanges() async {
    final title = titleController.text.trim();
    final text = textController.text.trim();

    if (title.isEmpty) {
      setState(() => errorMessage = 'Add a title before saving.');
      return;
    }

    if (text.isEmpty) {
      setState(() => errorMessage = 'Entry text cannot be empty.');
      return;
    }

    final updatedEntry = widget.entry.copyWith(
      title: title,
      text: text,
      category: category,
      notes: notesController.text.trim(),
      completed: completed,
      updatedAt: DateTime.now(),
    );

    await context.read<JournalProvider>().updateEntry(updatedEntry);

    if (mounted) {
      Navigator.of(context).pop();
    }
  }

  Future<void> deleteEntry() async {
    await context.read<JournalProvider>().deleteEntry(widget.entry.id);

    if (mounted) {
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Scan Details'),
        actions: [
          IconButton(
            tooltip: 'Delete',
            onPressed: deleteEntry,
            icon: const Icon(Icons.delete_outline),
          ),
        ],
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextField(
              controller: titleController,
              decoration: const InputDecoration(
                labelText: 'Title',
                prefixIcon: Icon(Icons.title_rounded),
              ),
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              initialValue: category,
              decoration: const InputDecoration(
                labelText: 'Category',
                prefixIcon: Icon(Icons.folder_outlined),
              ),
              items: JournalProvider.categories
                  .map(
                    (item) => DropdownMenuItem(
                      value: item,
                      child: Text(item),
                    ),
                  )
                  .toList(),
              onChanged: (value) {
                if (value != null) {
                  setState(() => category = value);
                }
              },
            ),
            const SizedBox(height: 12),
            SwitchListTile(
              contentPadding: const EdgeInsets.symmetric(horizontal: 8),
              tileColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              title: const Text('Done'),
              value: completed,
              onChanged: (value) => setState(() => completed = value),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: textController,
              minLines: 8,
              maxLines: 14,
              decoration: const InputDecoration(
                labelText: 'Extracted text',
                alignLabelWithHint: true,
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: notesController,
              minLines: 3,
              maxLines: 6,
              decoration: const InputDecoration(
                labelText: 'Notes',
                prefixIcon: Icon(Icons.edit_note_rounded),
              ),
            ),
            if (errorMessage != null) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: colorScheme.errorContainer,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  errorMessage!,
                  style: TextStyle(color: colorScheme.onErrorContainer),
                ),
              ),
            ],
            const SizedBox(height: 18),
            FilledButton.icon(
              onPressed: saveChanges,
              icon: const Icon(Icons.save_outlined),
              label: const Text('Save Changes'),
            ),
          ],
        ),
      ),
    );
  }
}
