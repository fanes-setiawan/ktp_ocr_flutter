import 'package:flutter_test/flutter_test.dart';
import 'package:ktp_ocr_flutter/src/parser/nik_validator.dart';

void main() {
  group('NikValidator', () {
    final validator = NikValidator();

    test('returns true for valid 16 digit NIK', () {
      expect(validator.isValid('3201010101900001'), isTrue);
    });

    test('returns false for NIK less than 16 digits', () {
      expect(validator.isValid('320101010190000'), isFalse);
    });

    test('returns false for NIK more than 16 digits', () {
      expect(validator.isValid('32010101019000011'), isFalse);
    });

    test('returns false for NIK with letters', () {
      expect(validator.isValid('32010A0101900001'), isFalse);
    });
  });
}
