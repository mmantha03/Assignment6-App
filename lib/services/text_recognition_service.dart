import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';

class TextRecognitionService {
  final TextRecognizer textRecognizer = TextRecognizer(
    script: TextRecognitionScript.latin,
  );

  Future<String> recognizeTextFromImage(String imagePath) async {
    final inputImage = InputImage.fromFilePath(imagePath);
    final recognizedText = await textRecognizer.processImage(inputImage);

    return recognizedText.text.trim();
  }

  Future<void> dispose() async {
    await textRecognizer.close();
  }
}
