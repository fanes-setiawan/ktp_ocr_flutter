import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:ktp_ocr_flutter/ktp_ocr_flutter.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'KTP OCR Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: const KtpOcrScreen(),
    );
  }
}

class KtpOcrScreen extends StatefulWidget {
  const KtpOcrScreen({super.key});

  @override
  State<KtpOcrScreen> createState() => _KtpOcrScreenState();
}

class _KtpOcrScreenState extends State<KtpOcrScreen> {
  final ImagePicker _picker = ImagePicker();
  final KtpOcrScanner _scanner = KtpOcrScanner();
  
  File? _imageFile;
  KtpOcrResult? _ocrResult;
  bool _isLoading = false;
  String? _errorMessage;

  Future<void> _pickImage(ImageSource source) async {
    try {
      final pickedFile = await _picker.pickImage(source: source);
      if (pickedFile != null) {
        setState(() {
          _imageFile = File(pickedFile.path);
          _ocrResult = null;
          _errorMessage = null;
          _isLoading = true;
        });

        await _scanKtp(pickedFile.path);
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Error picking image: ';
        _isLoading = false;
      });
    }
  }

  Future<void> _scanKtp(String path) async {
    try {
      final result = await _scanner.scanFromPath(path);
      setState(() {
        _ocrResult = result;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Error scanning KTP: ';
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _scanner.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('KTP OCR Scanner'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton.icon(
                  onPressed: () => _pickImage(ImageSource.camera),
                  icon: const Icon(Icons.camera_alt),
                  label: const Text('Camera'),
                ),
                ElevatedButton.icon(
                  onPressed: () => _pickImage(ImageSource.gallery),
                  icon: const Icon(Icons.photo_library),
                  label: const Text('Gallery'),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (_isLoading)
              const Center(child: CircularProgressIndicator())
            else if (_errorMessage != null)
              Text(
                _errorMessage!,
                style: const TextStyle(color: Colors.red),
                textAlign: TextAlign.center,
              )
            else if (_imageFile != null) ...[
              Image.file(
                _imageFile!,
                height: 200,
                fit: BoxFit.contain,
              ),
              const SizedBox(height: 16),
              if (_ocrResult != null)
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Hasil Scan:', style: Theme.of(context).textTheme.titleLarge),
                        const Divider(),
                        _buildResultRow('NIK', _ocrResult!.nik),
                        _buildResultRow('Nama', _ocrResult!.nama),
                        _buildResultRow('Tempat Lahir', _ocrResult!.tempatLahir),
                        _buildResultRow('Tanggal Lahir', _ocrResult!.tanggalLahir),
                        _buildResultRow('Jenis Kelamin', _ocrResult!.jenisKelamin),
                        _buildResultRow('Alamat', _ocrResult!.alamat),
                        _buildResultRow('RT/RW', '\ / '),
                        const SizedBox(height: 16),
                        Text('Raw Text:', style: Theme.of(context).textTheme.titleMedium),
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.all(8),
                          color: Colors.grey[200],
                          child: Text(
                            _ocrResult!.rawText,
                            style: const TextStyle(fontSize: 12),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildResultRow(String label, String? value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            child: Text(value ?? 'Tidak terbaca'),
          ),
        ],
      ),
    );
  }
}
