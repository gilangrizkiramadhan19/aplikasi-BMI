import 'dart:io';
import 'dart:typed_data';
import 'package:image/image.dart' as img;

/// Model untuk menyimpan informasi hasil kompresi gambar
class CompressionResult {
  final File compressedFile;
  final String originalSize;
  final String compressedSize;
  final double compressionPercentage;

  CompressionResult({
    required this.compressedFile,
    required this.originalSize,
    required this.compressedSize,
    required this.compressionPercentage,
  });

  /// Format ukuran file menjadi string yang mudah dibaca (KB, MB, dll)
  static String formatFileSize(int bytes) {
    if (bytes < 1024) {
      return '${bytes}B';
    } else if (bytes < 1024 * 1024) {
      return '${(bytes / 1024).toStringAsFixed(2)}KB';
    } else {
      return '${(bytes / (1024 * 1024)).toStringAsFixed(2)}MB';
    }
  }
}

/// Utility class untuk kompresi gambar
class ImageCompression {
  /// Kompresi gambar dengan resize dan pengurangan kualitas
  /// 
  /// Parameter:
  /// - [imageFile]: File gambar yang akan dikompresi
  /// - [maxWidth]: Lebar maksimal gambar (default: 1920px)
  /// - [maxHeight]: Tinggi maksimal gambar (default: 1920px)
  /// - [quality]: Kualitas JPEG 0-100 (default: 75)
  static Future<CompressionResult> compressImage(
    File imageFile, {
    int maxWidth = 1920,
    int maxHeight = 1920,
    int quality = 75,
  }) async {
    try {
      // Baca file asli
      final originalBytes = await imageFile.readAsBytes();
      final originalSize = originalBytes.length;

      // Decode gambar
      final image = img.decodeImage(originalBytes);
      if (image == null) {
        throw Exception('Gagal membaca gambar');
      }

      // Resize gambar dengan mempertahankan aspect ratio
      img.Image resized;
      if (image.width > maxWidth || image.height > maxHeight) {
        resized = img.copyResize(
          image,
          width: image.width > image.height ? maxWidth : null,
          height: image.width > image.height ? null : maxHeight,
          interpolation: img.Interpolation.linear,
        );
      } else {
        resized = image;
      }

      // Encode gambar dengan kualitas yang lebih rendah
      final compressedBytes = Uint8List.fromList(
        img.encodeJpg(resized, quality: quality),
      );

      // Simpan gambar terkompresi ke file temporary
      final tempDir = Directory.systemTemp;
      final compressedFile = File(
        '${tempDir.path}/compressed_${DateTime.now().millisecondsSinceEpoch}.jpg',
      );
      await compressedFile.writeAsBytes(compressedBytes);

      // Hitung persentase kompresi
      final compressedSize = compressedBytes.length;
      final compressionPercentage = 
          ((originalSize - compressedSize) / originalSize * 100);

      return CompressionResult(
        compressedFile: compressedFile,
        originalSize: CompressionResult.formatFileSize(originalSize),
        compressedSize: CompressionResult.formatFileSize(compressedSize),
        compressionPercentage: compressionPercentage,
      );
    } catch (e) {
      throw Exception('Error kompresi gambar: $e');
    }
  }

  /// Kompresi multiple gambar
  static Future<List<CompressionResult>> compressMultipleImages(
    List<File> imageFiles, {
    int maxWidth = 1920,
    int maxHeight = 1920,
    int quality = 75,
  }) async {
    final results = <CompressionResult>[];
    
    for (final file in imageFiles) {
      final result = await compressImage(
        file,
        maxWidth: maxWidth,
        maxHeight: maxHeight,
        quality: quality,
      );
      results.add(result);
    }
    
    return results;
  }
}
