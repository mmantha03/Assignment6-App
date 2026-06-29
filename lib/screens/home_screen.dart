import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:scanlog/providers/journal_provider.dart';
import 'package:scanlog/screens/entry_detail_screen.dart';
import 'package:scanlog/widgets/entry_card.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late final TextEditingController titleController;
  late final TextEditingController textController;
  late final TextEditingController notesController;

  @override
  void initState() {
    super.initState();
    titleController = TextEditingController();
    textController = TextEditingController();
    notesController = TextEditingController();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<JournalProvider>().loadEntries();
    });
  }

  @override
  void dispose() {
    titleController.dispose();
    textController.dispose();
    notesController.dispose();
    super.dispose();
  }

  void syncControllers(JournalProvider provider) {
    _sync(titleController, provider.draftTitle);
    _sync(textController, provider.scannedText);
    _sync(notesController, provider.draftNotes);
  }

  void _sync(TextEditingController controller, String value) {
    if (controller.text == value) {
      return;
    }

    controller.text = value;
    controller.selection = TextSelection.collapsed(
      offset: controller.text.length,
    );
  }

  Future<void> saveEntry(JournalProvider provider) async {
    final saved = await provider.addEntry();

    if (!mounted) {
      return;
    }

    if (saved) {
      titleController.clear();
      textController.clear();
      notesController.clear();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Scan saved')),
      );
    }
  }

  void openEntry(JournalProvider provider, int index) {
    final entry = provider.filteredEntries[index];

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => EntryDetailScreen(entry: entry),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<JournalProvider>();
    final colorScheme = Theme.of(context).colorScheme;
    syncControllers(provider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('ScanLog'),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
          children: [
            _SummaryRow(
              total: provider.entries.length,
              open: provider.openCount,
              completed: provider.completedCount,
            ),
            const SizedBox(height: 16),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      'New Scan',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.w800,
                          ),
                    ),
                    const SizedBox(height: 14),
                    TextField(
                      controller: titleController,
                      textInputAction: TextInputAction.next,
                      decoration: const InputDecoration(
                        labelText: 'Title',
                        prefixIcon: Icon(Icons.title_rounded),
                      ),
                      onChanged: provider.updateDraftTitle,
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<String>(
                      initialValue: provider.draftCategory,
                      decoration: const InputDecoration(
                        labelText: 'Category',
                        prefixIcon: Icon(Icons.folder_outlined),
                      ),
                      items: JournalProvider.categories
                          .map(
                            (category) => DropdownMenuItem(
                              value: category,
                              child: Text(category),
                            ),
                          )
                          .toList(),
                      onChanged: provider.isScanning
                          ? null
                          : (value) {
                              if (value != null) {
                                provider.updateDraftCategory(value);
                              }
                            },
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: textController,
                      minLines: 6,
                      maxLines: 10,
                      decoration: const InputDecoration(
                        labelText: 'Extracted text',
                        alignLabelWithHint: true,
                      ),
                      onChanged: provider.updateScannedText,
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: notesController,
                      minLines: 2,
                      maxLines: 4,
                      decoration: const InputDecoration(
                        labelText: 'Notes',
                        prefixIcon: Icon(Icons.edit_note_rounded),
                      ),
                      onChanged: provider.updateDraftNotes,
                    ),
                    if (provider.errorMessage != null) ...[
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: colorScheme.errorContainer,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          provider.errorMessage!,
                          style: TextStyle(
                            color: colorScheme.onErrorContainer,
                          ),
                        ),
                      ),
                    ],
                    if (provider.isScanning) ...[
                      const SizedBox(height: 12),
                      const LinearProgressIndicator(),
                    ],
                    const SizedBox(height: 14),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: provider.isScanning
                                ? null
                                : provider.scanFromGallery,
                            icon: const Icon(Icons.photo_library_outlined),
                            label: const Text('Gallery'),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: provider.isScanning
                                ? null
                                : provider.scanFromCamera,
                            icon: const Icon(Icons.camera_alt_outlined),
                            label: const Text('Camera'),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    FilledButton.icon(
                      onPressed:
                          provider.isScanning ? null : () => saveEntry(provider),
                      icon: const Icon(Icons.save_outlined),
                      label: const Text('Save Scan'),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 18),
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Saved Scans',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w800,
                        ),
                  ),
                ),
                DropdownButton<String>(
                  value: provider.selectedCategory,
                  items: provider.filterOptions
                      .map(
                        (category) => DropdownMenuItem(
                          value: category,
                          child: Text(category),
                        ),
                      )
                      .toList(),
                  onChanged: (value) {
                    if (value != null) {
                      provider.updateSelectedCategory(value);
                    }
                  },
                ),
              ],
            ),
            const SizedBox(height: 8),
            if (provider.entries.isEmpty)
              const _EmptyState(
                icon: Icons.document_scanner_outlined,
                title: 'No saved scans yet',
                subtitle: 'Saved scans will appear here.',
              )
            else if (provider.filteredEntries.isEmpty)
              const _EmptyState(
                icon: Icons.filter_alt_off_outlined,
                title: 'No scans in this category',
                subtitle: 'Choose a different filter or save a new scan.',
              )
            else
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: provider.filteredEntries.length,
                separatorBuilder: (_, _) => const SizedBox(height: 10),
                itemBuilder: (context, index) {
                  final entry = provider.filteredEntries[index];

                  return EntryCard(
                    entry: entry,
                    onTap: () => openEntry(provider, index),
                    onToggleCompleted: () => provider.toggleCompleted(entry.id),
                    onDelete: () => provider.deleteEntry(entry.id),
                  );
                },
              ),
          ],
        ),
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  const _SummaryRow({
    required this.total,
    required this.open,
    required this.completed,
  });

  final int total;
  final int open;
  final int completed;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _SummaryTile(
            label: 'Total',
            value: total,
            icon: Icons.inventory_2_outlined,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _SummaryTile(
            label: 'Open',
            value: open,
            icon: Icons.radio_button_unchecked,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _SummaryTile(
            label: 'Done',
            value: completed,
            icon: Icons.check_circle_outline,
          ),
        ),
      ],
    );
  }
}

class _SummaryTile extends StatelessWidget {
  const _SummaryTile({
    required this.label,
    required this.value,
    required this.icon,
  });

  final String label;
  final int value;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: colorScheme.primary),
          const SizedBox(height: 10),
          Text(
            '$value',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w900,
                ),
          ),
          Text(label),
        ],
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  final IconData icon;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Icon(
            icon,
            size: 42,
            color: Theme.of(context).colorScheme.primary,
          ),
          const SizedBox(height: 12),
          Text(
            title,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.black54,
                ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
