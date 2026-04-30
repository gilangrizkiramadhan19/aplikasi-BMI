import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import '../providers/schedule_provider.dart';
import '../models/schedule_model.dart';
import '../utils/image_compression.dart';

class SubmitPmReportScreen extends StatefulWidget {
  final Schedule schedule;

  const SubmitPmReportScreen({
    Key? key,
    required this.schedule,
  }) : super(key: key);

  @override
  State<SubmitPmReportScreen> createState() => _SubmitPmReportScreenState();
}

class _SubmitPmReportScreenState extends State<SubmitPmReportScreen> {
  File? _selectedImage;
  Uint8List? _selectedImageBytes;
  CompressionResult? _compressionResult;
  bool _isCompressing = false;
  bool _isSubmitting = false;

  late TextEditingController _keteranganController;
  late TextEditingController _materialController;
  final ImagePicker _imagePicker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _keteranganController = TextEditingController();
    _materialController = TextEditingController();
  }

  @override
  void dispose() {
    _keteranganController.dispose();
    _materialController.dispose();
    super.dispose();
  }

  Future<void> _compressAndSetImage(File imageFile) async {
    setState(() {
      _isCompressing = true;
    });

    try {
      final compressionResult = await ImageCompression.compressImage(
        imageFile,
        maxWidth: 1920,
        maxHeight: 1920,
        quality: 75,
      );

      if (!mounted) return;

      final bytes = await compressionResult.compressedFile.readAsBytes();
      setState(() {
        _selectedImage = compressionResult.compressedFile;
        _selectedImageBytes = bytes;
        _compressionResult = compressionResult;
        _isCompressing = false;
      });

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Foto berhasil dikompres (${compressionResult.compressionPercentage.toStringAsFixed(1)}% lebih kecil)',
          ),
          backgroundColor: const Color(0xFF43A047),
          duration: const Duration(seconds: 3),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isCompressing = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error kompresi foto: $e'),
          backgroundColor: const Color(0xFFE53935),
        ),
      );
    }
  }

  Future<void> _pickImageFromCamera() async {
    try {
      final pickedFile = await _imagePicker.pickImage(
        source: ImageSource.camera,
        imageQuality: 80,
      );

      if (pickedFile != null) {
        _compressAndSetImage(File(pickedFile.path));
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $e'),
          backgroundColor: const Color(0xFFE53935),
        ),
      );
    }
  }

  Future<void> _pickImageFromGallery() async {
    try {
      final pickedFile = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 80,
      );

      if (pickedFile != null) {
        _compressAndSetImage(File(pickedFile.path));
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $e'),
          backgroundColor: const Color(0xFFE53935),
        ),
      );
    }
  }

  void _showImagePickerOptions() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Pilih Sumber Foto'),
        content: const Text('Ambil foto dari mana?'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _pickImageFromCamera();
            },
            child: const Text('Kamera'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _pickImageFromGallery();
            },
            child: const Text('Galeri'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
        ],
      ),
    );
  }

  Future<void> _handleSubmit() async {
    // Validasi
    if (_selectedImage == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Foto dokumentasi harus diupload'),
          backgroundColor: Color(0xFFE53935),
        ),
      );
      return;
    }

    if (_keteranganController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Keterangan pekerjaan tidak boleh kosong'),
          backgroundColor: Color(0xFFE53935),
        ),
      );
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      await context.read<ScheduleProvider>().submitReport(
            widget.schedule.id,
            _selectedImage!.path,
            _keteranganController.text,
            _materialController.text.isEmpty ? null : _materialController.text,
            fileBytes: _selectedImageBytes,
          );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Laporan berhasil disubmit'),
          backgroundColor: Color(0xFF43A047),
        ),
      );

      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $e'),
          backgroundColor: const Color(0xFFE53935),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Laporan Perawatan'),
        backgroundColor: const Color(0xFF1565C0),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Schedule Info Card
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFF1565C0).withOpacity(0.05),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: const Color(0xFF1565C0).withOpacity(0.2),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.schedule.maintenanceItem,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF1565C0),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(
                        Icons.location_on_outlined,
                        size: 16,
                        color: Colors.grey[600],
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          widget.schedule.location,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[700],
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Dokumentasi Foto
            Text(
              'Dokumentasi Foto',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: Colors.grey[800],
              ),
            ),
            const SizedBox(height: 12),

            // Photo Preview
            if (_isCompressing)
              Container(
                width: double.infinity,
                height: 220,
                decoration: BoxDecoration(
                  border: Border.all(
                    color: const Color(0xFF43A047).withOpacity(0.3),
                    width: 2,
                  ),
                  borderRadius: BorderRadius.circular(14),
                  color: const Color(0xFF43A047).withOpacity(0.05),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SizedBox(
                      width: 50,
                      height: 50,
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(
                          Color(0xFF43A047),
                        ),
                        strokeWidth: 3,
                      ),
                    ),
                    const SizedBox(height: 14),
                    const Text(
                      'Mengompresi Foto...',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF43A047),
                      ),
                    ),
                  ],
                ),
              )
            else if (_selectedImage == null)
              GestureDetector(
                onTap: _showImagePickerOptions,
                child: Container(
                  width: double.infinity,
                  height: 220,
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: const Color(0xFF43A047).withOpacity(0.3),
                      width: 2,
                      style: BorderStyle.solid,
                    ),
                    borderRadius: BorderRadius.circular(14),
                    color: const Color(0xFF43A047).withOpacity(0.05),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: const Color(0xFF43A047).withOpacity(0.12),
                        ),
                        child: const Icon(
                          Icons.camera_alt_outlined,
                          size: 40,
                          color: Color(0xFF43A047),
                        ),
                      ),
                      const SizedBox(height: 14),
                      const Text(
                        'Pilih Foto',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF43A047),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Tap untuk ambil foto dokumentasi',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
              )
            else
              Stack(
                children: [
                  Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: const Color(0xFF43A047).withOpacity(0.3),
                        width: 1,
                      ),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(14),
                      child: Image.file(
                        _selectedImage!,
                        fit: BoxFit.cover,
                        height: 220,
                      ),
                    ),
                  ),
                  Positioned(
                    top: 8,
                    right: 8,
                    child: Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.black.withOpacity(0.6),
                      ),
                      child: IconButton(
                        icon: const Icon(Icons.close),
                        color: Colors.white,
                        onPressed: () {
                          setState(() {
                            _selectedImage = null;
                            _selectedImageBytes = null;
                            _compressionResult = null;
                          });
                        },
                      ),
                    ),
                  ),
                ],
              ),

            const SizedBox(height: 12),

            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: _showImagePickerOptions,
                icon: const Icon(Icons.refresh),
                label: const Text('Ganti Foto'),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(
                    color: Color(0xFF1565C0),
                    width: 1.5,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  foregroundColor: const Color(0xFF1565C0),
                ),
              ),
            ),

            // Compression Info
            if (_compressionResult != null) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFF43A047).withOpacity(0.08),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: const Color(0xFF43A047).withOpacity(0.2),
                    width: 1,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(
                          Icons.compress,
                          color: Color(0xFF43A047),
                          size: 18,
                        ),
                        const SizedBox(width: 8),
                        const Text(
                          'Informasi Kompresi',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF43A047),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Ukuran Asli',
                              style: TextStyle(
                                fontSize: 11,
                                color: Colors.grey[600],
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              _compressionResult!.originalSize,
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ),
                        Icon(
                          Icons.arrow_forward,
                          size: 18,
                          color: Colors.grey[400],
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Ukuran Terkompresi',
                              style: TextStyle(
                                fontSize: 11,
                                color: Colors.grey[600],
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              _compressionResult!.compressedSize,
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFF43A047),
                              ),
                            ),
                          ],
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              'Reduksi',
                              style: TextStyle(
                                fontSize: 11,
                                color: Colors.grey[600],
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '${_compressionResult!.compressionPercentage.toStringAsFixed(1)}%',
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFF43A047),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],

            const SizedBox(height: 24),

            // Keterangan Pekerjaan
            Text(
              'Keterangan Pekerjaan',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: Colors.grey[800],
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _keteranganController,
              maxLines: 4,
              decoration: InputDecoration(
                hintText: 'Jelaskan hasil perawatan, kondisi mesin, dan pekerjaan yang dilakukan...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(
                    color: Colors.grey[300]!,
                  ),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(
                    color: Colors.grey[300]!,
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(
                    color: Color(0xFF1565C0),
                    width: 2,
                  ),
                ),
                contentPadding: const EdgeInsets.all(12),
              ),
            ),

            const SizedBox(height: 20),

            // Material Digunakan (Optional)
            Text(
              'Material Digunakan (Opsional)',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: Colors.grey[800],
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _materialController,
              maxLines: 3,
              decoration: InputDecoration(
                hintText: 'Sebutkan material yang digunakan (contoh: oli, seal, bearing, dsb)',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(
                    color: Colors.grey[300]!,
                  ),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(
                    color: Colors.grey[300]!,
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(
                    color: Color(0xFF1565C0),
                    width: 2,
                  ),
                ),
                contentPadding: const EdgeInsets.all(12),
              ),
            ),

            const SizedBox(height: 32),

            // Submit Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _isSubmitting ? null : _handleSubmit,
                icon: _isSubmitting
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Colors.white,
                          ),
                        ),
                      )
                    : const Icon(Icons.send),
                label: Text(
                  _isSubmitting ? 'Mengirim...' : 'Kirim Laporan',
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF43A047),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}
