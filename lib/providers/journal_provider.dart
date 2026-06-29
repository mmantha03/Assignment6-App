import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';
import 'package:scanlog/models/journal_entry.dart';
import 'package:scanlog/services/storage_service.dart';
import 'package:scanlog/services/text_recognition_service.dart';
import 'package:uuid/uuid.dart';

class JournalProvider extends ChangeNotifier {
  static const List<String> categories = [
    'General',
    'School',
    'Work',
    'Receipt',
    'Reminder',
  ];

  final StorageService storageService;
  final TextRecognitionService textRecognitionService;
  final ImagePicker imagePicker;
  final Uuid uuid;

  JournalProvider({
    StorageService? storageService,
    TextRecognitionService? textRecognitionService,
    ImagePicker? imagePicker,
    Uuid? uuid,
  })  : storageService = storageService ?? StorageService(),
        textRecognitionService =
            textRecognitionService ?? TextRecognitionService(),
        imagePicker = imagePicker ?? ImagePicker(),
        uuid = uuid ?? const Uuid();

  List<JournalEntry> entries = [];
  String draftTitle = '';
  String scannedText = '';
  String draftNotes = '';
  String draftCategory = 'General';
  String selectedCategory = 'All';
  String? errorMessage;
  bool isScanning = false;

  List<String> get filterOptions => ['All', ...categories];

  List<JournalEntry> get filteredEntries {
    if (selectedCategory == 'All') {
      return entries;
    }

    return entries
        .where((entry) => entry.category == selectedCategory)
        .toList();
  }

  int get openCount => entries.where((entry) => !entry.completed).length;

  int get completedCount => entries.where((entry) => entry.completed).length;

  void updateDraftTitle(String value) {
    draftTitle = value;
    errorMessage = null;
    notifyListeners();
  }

  void updateScannedText(String value) {
    scannedText = value;
    errorMessage = null;
    notifyListeners();
  }

  void updateDraftNotes(String value) {
    draftNotes = value;
    notifyListeners();
  }

  void updateDraftCategory(String value) {
    draftCategory = value;
    notifyListeners();
  }

  void updateSelectedCategory(String value) {
    selectedCategory = value;
    notifyListeners();
  }

  Future<void> loadEntries() async {
    entries = await storageService.loadEntries();
    notifyListeners();
  }

  Future<bool> addEntry() async {
    final cleanedTitle = draftTitle.trim();
    final cleanedText = scannedText.trim();
    final cleanedNotes = draftNotes.trim();

    if (cleanedTitle.isEmpty) {
      errorMessage = 'Add a title before saving.';
      notifyListeners();
      return false;
    }

    if (cleanedText.isEmpty) {
      errorMessage = 'Add or scan text before saving.';
      notifyListeners();
      return false;
    }

    final now = DateTime.now();
    final entry = JournalEntry(
      id: uuid.v4(),
      title: cleanedTitle,
      text: cleanedText,
      category: draftCategory,
      notes: cleanedNotes,
      completed: false,
      createdAt: now,
      updatedAt: now,
    );

    entries = [entry, ...entries];
    clearDraft();

    await storageService.saveEntries(entries);
    notifyListeners();
    return true;
  }

  Future<void> updateEntry(JournalEntry updatedEntry) async {
    entries = entries
        .map((entry) => entry.id == updatedEntry.id ? updatedEntry : entry)
        .toList();
    await storageService.saveEntries(entries);
    notifyListeners();
  }

  Future<void> toggleCompleted(String id) async {
    final now = DateTime.now();
    entries = entries.map((entry) {
      if (entry.id != id) {
        return entry;
      }

      return entry.copyWith(
        completed: !entry.completed,
        updatedAt: now,
      );
    }).toList();

    await storageService.saveEntries(entries);
    notifyListeners();
  }

  Future<void> deleteEntry(String id) async {
    entries = entries.where((entry) => entry.id != id).toList();
    await storageService.saveEntries(entries);
    notifyListeners();
  }

  void clearDraft() {
    draftTitle = '';
    scannedText = '';
    draftNotes = '';
    draftCategory = 'General';
    errorMessage = null;
  }

  Future<void> scanFromGallery() async {
    await scanImage(ImageSource.gallery);
  }

  Future<void> scanFromCamera() async {
    await scanImage(ImageSource.camera);
  }

  Future<void> scanImage(ImageSource source) async {
    isScanning = true;
    errorMessage = null;
    notifyListeners();

    try {
      final selectedImage = await imagePicker.pickImage(
        source: source,
        imageQuality: 90,
      );

      if (selectedImage == null) {
        isScanning = false;
        notifyListeners();
        return;
      }

      final extractedText = await textRecognitionService
          .recognizeTextFromImage(selectedImage.path);

      if (extractedText.trim().isEmpty) {
        errorMessage = 'No text was found in that image.';
      } else {
        scannedText = extractedText.trim();
        if (draftTitle.trim().isEmpty) {
          draftTitle = _titleFromText(scannedText);
        }
      }
    } catch (_) {
      errorMessage = kIsWeb
          ? 'Text recognition works on a mobile device.'
          : 'The scan could not be completed.';
    }

    isScanning = false;
    notifyListeners();
  }

  String _titleFromText(String text) {
    final firstLine = text
        .split('\n')
        .map((line) => line.trim())
        .firstWhere((line) => line.isNotEmpty, orElse: () => 'Scanned note');

    if (firstLine.length <= 40) {
      return firstLine;
    }

    return '${firstLine.substring(0, 40)}...';
  }

  @override
  void dispose() {
    textRecognitionService.dispose();
    super.dispose();
  }
}
