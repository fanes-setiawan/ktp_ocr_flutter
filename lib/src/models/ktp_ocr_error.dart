class KtpOcrError implements Exception {
  final String message;
  KtpOcrError(this.message);
  @override
  String toString() => 'KtpOcrError: ';
}
