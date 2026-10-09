import '../models/ktp_ocr_result.dart';
import 'nik_validator.dart';
import '../utils/ktp_text_normalizer.dart';

class KtpParser {
  final NikValidator _nikValidator = NikValidator();

  KtpOcrResult parse(String rawText) {
    // Normalisasi semua baris
    final lines = rawText
        .split('\n')
        .map((e) => KtpTextNormalizer.normalize(e))
        .where((e) => e.isNotEmpty)
        .toList();

    String? nik;
    String? nama;
    String? tempatLahir;
    String? tanggalLahir;
    String? jenisKelamin;
    String? alamat;
    String? rt;
    String? rw;
    String? kelDesa;
    String? kecamatan;
    String? agama;
    String? statusPerkawinan;
    String? pekerjaan;
    String? kewarganegaraan;
    String? berlakuHingga;
    String? golonganDarah;

    // 1. Ekstraksi berbasis Pola (Regex) yang pasti
    for (var line in lines) {
      // Cari NIK (16 digit)
      if (nik == null) {
         final possibleNikLines = line.split(RegExp(r'\s+'));
         for (var part in possibleNikLines) {
            String sanitized = part.replaceAll(RegExp(r'[^0-9A-Z]'), '')
                                   .replaceAll('O', '0')
                                   .replaceAll('I', '1')
                                   .replaceAll('L', '1')
                                   .replaceAll('S', '5')
                                   .replaceAll('B', '8')
                                   .replaceAll('G', '6');
            if (sanitized.length >= 16) {
               String candidate = sanitized.substring(0, 16);
               if (_nikValidator.isValid(candidate)) {
                 nik = candidate;
                 break;
               }
            }
         }
      }

      // Cari RT / RW (Format: 001/002 atau 001 002)
      if (rt == null || rw == null) {
        final rtRwMatch = RegExp(r'(\d{3})[\s/]+(\d{3})').firstMatch(line);
        if (rtRwMatch != null) {
          rt = rtRwMatch.group(1);
          rw = rtRwMatch.group(2);
        }
      }

      // Cari Jenis Kelamin
      if (jenisKelamin == null) {
        if (line.contains('LAKI')) jenisKelamin = 'LAKI-LAKI';
        else if (line.contains('PEREMPUAN')) jenisKelamin = 'PEREMPUAN';
      }

      // Cari Agama
      if (agama == null) {
        agama = _parseAgama(line);
      }

      // Cari Status Perkawinan
      if (statusPerkawinan == null) {
        statusPerkawinan = _parseStatusPerkawinan(line);
      }

      // Cari Golongan Darah
      if (golonganDarah == null && (line.contains('DARAH') || line.contains('GOL'))) {
        golonganDarah = _parseGolonganDarah(line);
      }

      // Cari Kewarganegaraan
      if (kewarganegaraan == null) {
        if (line.contains('WNI')) kewarganegaraan = 'WNI';
        if (line.contains('WNA')) kewarganegaraan = 'WNA';
      }
    }

    // 2. Ekstraksi Tanggal & Tempat Lahir
    // Biasanya Tempat Lahir dan Tanggal Lahir berdampingan: "JAKARTA, 17-08-1990"
    for (var line in lines) {
      final dateMatch = RegExp(r'(\d{2})[-\/\.\s]+(\d{2})[-\/\.\s]+(\d{4})').firstMatch(line.replaceAll('O', '0'));
      if (dateMatch != null) {
        String foundDate = '${dateMatch.group(1)}-${dateMatch.group(2)}-${dateMatch.group(3)}';
        
        // Cek apakah ini Berlaku Hingga atau Tanggal Lahir
        if (line.contains('HINGG') || line.contains('BERLAKU')) {
           berlakuHingga = foundDate;
        } else if (tanggalLahir == null) {
           tanggalLahir = foundDate;
           
           // Ekstrak tempat lahir sebelum koma/tanggal
           final beforeDate = line.substring(0, dateMatch.start).trim();
           String cleanedTempat = beforeDate.replaceAll(RegExp(r'[^A-Z\s]'), '').trim();
           if (cleanedTempat.isNotEmpty && !cleanedTempat.contains('LAHIR')) {
             tempatLahir = cleanedTempat;
           }
        } else if (berlakuHingga == null) {
           berlakuHingga = foundDate;
        }
      }
      if (berlakuHingga == null && line.contains('SEUMUR HIDUP')) {
        berlakuHingga = 'SEUMUR HIDUP';
      }
    }

    // 3. Ekstraksi Nama dan Field lainnya melalui pola titik dua ":" atau posisinya
    // Seringkali kolom label terpisah dari kolom value.
    List<String> unassignedValues = [];
    for (var line in lines) {
      // Hilangkan label yang jelas
      String cleanLine = line.replaceAll(RegExp(r'(NIK|NAMA|TEMPAT/TGL LAHIR|JENIS KELAMIN|ALAMAT|RT/RW|KEL/DESA|KECAMATAN|AGAMA|STATUS PERKAWINAN|PEKERJAAN|KEWARGANEGARAAN|BERLAKU HINGGA|PROVINSI.*?|KABUPATEN.*?)'), '').trim();
      if (cleanLine.startsWith(':')) cleanLine = cleanLine.substring(1).trim();
      
      if (cleanLine.isNotEmpty && cleanLine.length > 2) {
         unassignedValues.add(cleanLine);
      }
    }

    // Coba petakan unassigned values ke field yang kosong
    for (var val in unassignedValues) {
      // Jika berisi huruf alfabet mayoritas, mungkin nama, alamat, dsb
      if (RegExp(r"^[A-Z\s\.,']+$").hasMatch(val)) {
        if (nama == null && val != jenisKelamin && val != agama && val != statusPerkawinan && !val.contains('LAKI') && !val.contains('KATHOLIK')) {
          // Nama biasanya panjang dan tidak mengandung angka
          nama = val;
        } else if (alamat == null) {
          alamat = val;
        } else if (kelDesa == null) {
          kelDesa = val;
        } else if (kecamatan == null) {
          kecamatan = val;
        } else if (pekerjaan == null) {
          pekerjaan = val;
        }
      }
    }

    return KtpOcrResult(
      nik: nik,
      nama: nama,
      tempatLahir: tempatLahir,
      tanggalLahir: tanggalLahir,
      jenisKelamin: jenisKelamin,
      golonganDarah: golonganDarah,
      alamat: alamat,
      rt: rt,
      rw: rw,
      kelDesa: kelDesa,
      kecamatan: kecamatan,
      agama: agama,
      statusPerkawinan: statusPerkawinan,
      pekerjaan: pekerjaan,
      kewarganegaraan: kewarganegaraan,
      berlakuHingga: berlakuHingga,
      rawText: rawText,
      isComplete: nik != null && nama != null,
    );
  }

  String? _parseAgama(String? raw) {
    if (raw == null) return null;
    if (raw.contains('ISL') || raw.contains('1SL')) return 'ISLAM';
    if (raw.contains('KRIS')) return 'KRISTEN';
    if (raw.contains('KATH') || raw.contains('KAT')) return 'KATHOLIK';
    if (raw.contains('HIN')) return 'HINDU';
    if (raw.contains('BUD')) return 'BUDDHA';
    if (raw.contains('KONG')) return 'KONGHUCU';
    return null;
  }
  
  String? _parseStatusPerkawinan(String? raw) {
    if (raw == null) return null;
    if (raw.contains('BELUM')) return 'BELUM KAWIN';
    if (raw.contains('CERAI MATI')) return 'CERAI MATI';
    if (raw.contains('CERAI HIDUP')) return 'CERAI HIDUP';
    if (raw.contains('KAWIN')) return 'KAWIN';
    return null;
  }
  
  String? _parseGolonganDarah(String? raw) {
    if (raw == null) return null;
    final match = RegExp(r'(A|B|AB|O)[\+\-]?').firstMatch(raw);
    if (match != null) {
       return match.group(0);
    }
    return null;
  }
}
