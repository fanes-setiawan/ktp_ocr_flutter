class KtpOcrResult {
  final String? nik;
  final String? nama;
  final String? tempatLahir;
  final String? tanggalLahir;
  final String? jenisKelamin;
  final String? golonganDarah;
  final String? alamat;
  final String? rt;
  final String? rw;
  final String? kelDesa;
  final String? kecamatan;
  final String? agama;
  final String? statusPerkawinan;
  final String? pekerjaan;
  final String? kewarganegaraan;
  final String? berlakuHingga;
  final String rawText;
  final bool isComplete;

  KtpOcrResult({
    this.nik,
    this.nama,
    this.tempatLahir,
    this.tanggalLahir,
    this.jenisKelamin,
    this.golonganDarah,
    this.alamat,
    this.rt,
    this.rw,
    this.kelDesa,
    this.kecamatan,
    this.agama,
    this.statusPerkawinan,
    this.pekerjaan,
    this.kewarganegaraan,
    this.berlakuHingga,
    required this.rawText,
    this.isComplete = false,
  });

  Map<String, dynamic> toJson() => {
        'nik': nik,
        'nama': nama,
        'tempatLahir': tempatLahir,
        'tanggalLahir': tanggalLahir,
        'jenisKelamin': jenisKelamin,
        'golonganDarah': golonganDarah,
        'alamat': alamat,
        'rt': rt,
        'rw': rw,
        'kelDesa': kelDesa,
        'kecamatan': kecamatan,
        'agama': agama,
        'statusPerkawinan': statusPerkawinan,
        'pekerjaan': pekerjaan,
        'kewarganegaraan': kewarganegaraan,
        'berlakuHingga': berlakuHingga,
        'rawText': rawText,
        'isComplete': isComplete,
      };
}
