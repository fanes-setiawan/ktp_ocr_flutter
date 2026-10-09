import 'package:flutter_test/flutter_test.dart';
import 'package:ktp_ocr_flutter/src/utils/ktp_text_normalizer.dart';

void main() {
  group('KtpTextNormalizer', () {
    test('normalizes string correctly', () {
      expect(KtpTextNormalizer.normalize('  hello world  '), 'HELLO WORLD');
    });
  });
}
