class NikValidator {
  String? sanitizeNik(String rawNik) {
    // Replace common OCR mistakes
    String sanitized = rawNik.replaceAll(RegExp(r'[oO]'), '0')
                             .replaceAll(RegExp(r'[iIlL]'), '1')
                             .replaceAll(RegExp(r'[sS]'), '5')
                             .replaceAll(RegExp(r'[gG]'), '6')
                             .replaceAll(RegExp(r'[bB]'), '8')
                             .replaceAll(RegExp(r'[^0-9]'), '');
    
    if (sanitized.length >= 16) {
       // Return exactly 16 digits
       return sanitized.substring(0, 16);
    }
    return null;
  }

  bool isValid(String nik) {
    if (nik.length != 16) return false;
    if (RegExp(r'[^0-9]').hasMatch(nik)) return false;
    
    // Minimal logical check: DDMMYY
    // Indices: 6-7 is DD, 8-9 is MM, 10-11 is YY
    try {
      int dd = int.parse(nik.substring(6, 8));
      int mm = int.parse(nik.substring(8, 10));
      
      // Female dates are dd + 40
      if (dd > 40) dd -= 40;
      
      if (dd < 1 || dd > 31) return false;
      if (mm < 1 || mm > 12) return false;
    } catch (e) {
      return false;
    }
    
    return true;
  }
}
