import 'dart:io';
import '../models/ktp_ocr_result.dart';
import '../models/ktp_ocr_error.dart';
import 'text_recognition_service.dart';
import '../parser/ktp_parser.dart';
import '../preprocessing/image_preprocessor.dart';

class KtpOcrScanner {
  final TextRecognitionService _textRecognitionService = TextRecognitionService();
  final KtpParser _parser = KtpParser();
  final ImagePreprocessor _preprocessor = ImagePreprocessor();

  Future<KtpOcrResult> scanFromPath(String imagePath) async {
    if (!await File(imagePath).exists()) {
      throw KtpOcrError('File not found: ');
    }
    
    try {
      final processedPath = await _preprocessor.preprocess(imagePath);
      final rawText = await _textRecognitionService.recognizeText(processedPath);
      return _parser.parse(rawText);
    } catch (e) {
      throw KtpOcrError('OCR failed: ');
    }
  }

  Future<void> dispose() async {
    await _textRecognitionService.dispose();
  }
}
