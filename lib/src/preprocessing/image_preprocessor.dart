import 'dart:io';
import 'package:image/image.dart' as img;

class ImagePreprocessor {
  Future<String> preprocess(String imagePath) async {
    // 1. Resize if too large to prevent OOM
    // 2. We can apply grayscale here to improve OCR accuracy if needed
    try {
      final file = File(imagePath);
      final bytes = await file.readAsBytes();
      img.Image? originalImage = img.decodeImage(bytes);
      
      if (originalImage != null) {
         // Resize max dimension to 1200px
         if (originalImage.width > 1200 || originalImage.height > 1200) {
             originalImage = img.copyResize(originalImage, 
                width: originalImage.width > originalImage.height ? 1200 : null,
                height: originalImage.height >= originalImage.width ? 1200 : null);
         }
         
         // Apply Grayscale
         final grayscaleImage = img.grayscale(originalImage);
         
         // Save to temporary file
         final directory = Directory.systemTemp;
         final tmpPath = '${directory.path}/ktp_ocr_temp_${DateTime.now().millisecondsSinceEpoch}.jpg';
         
         File(tmpPath).writeAsBytesSync(img.encodeJpg(grayscaleImage, quality: 85));
         return tmpPath;
      }
    } catch(e) {
      // In case of error (e.g unsupported image), just return original path
      print('Pre-processing failed, returning original image: $e');
    }
    
    return imagePath;
  }
}
