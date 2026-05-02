import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'dart:io';
import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import '../providers/ticket_provider.dart';
import '../utils/image_compression.dart';
import '../widgets/photo_zoom_viewer.dart';
import '../widgets/zoomable_image.dart';
import 'home_screen.dart';

class CompleteTicketScreen extends StatefulWidget {
  final int ticketId;

  const CompleteTicketScreen({
    Key? key,
    required this.ticketId,
  }) : super(key: key);

  @override
  State<CompleteTicketScreen> createState() => _CompleteTicketScreenState();
}

class _CompleteTicketScreenState extends State<CompleteTicketScreen> {
  List<File> _selectedImages = [];
  List<Uint8List> _selectedImageBytes = [];
  List<CompressionResult?> _compressionResults = [];
  bool _isCompressing = false;
  late TextEditingController _materialController;
  final ImagePicker _imagePicker = ImagePicker();
  static const int maxPhotos = 3;

  @override
  void initState() {
    super.initState();
    _materialController = TextEditingController();
  }

  @override
  void dispose() {
    _materialController.dispose();
    super.dispose();
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

  Future<void> _compressAndSetImage(File imageFile) async {
    if (_selectedImages.length >= maxPhotos) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Maksimum $maxPhotos foto sudah tercapai'),
            backgroundColor: const Color(0xFFE53935),
          ),
        );
      }
      return;
    }

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
        _selectedImages.add(compressionResult.compressedFile);
        _selectedImageBytes.add(bytes);
        _compressionResults.add(compressionResult);
        _isCompressing = false;
      });

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Foto ${_selectedImages.length} berhasil ditambahkan (${compressionResult.compressionPercentage.toStringAsFixed(1)}% lebih kecil)',
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

  void _showImagePickerOptions() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Pilih Sumber Foto',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('Ambil dari Kamera'),
              onTap: () {
                Navigator.pop(context);
                _pickImageFromCamera();
              },
            ),
            ListTile(
              leading: const Icon(Icons.image),
              title: const Text('Pilih dari Galeri'),
              onTap: () {
                Navigator.pop(context);
                _pickImageFromGallery();
              },
            ),
          ],
        ),
      ),
    );
  }

  void _handleUpload() {
    if (_selectedImages.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Minimal 1 foto bukti harus dipilih'),
          backgroundColor: Color(0xFFE53935),
        ),
      );
      return;
    }
    
    context.read<TicketProvider>().completeTicket(
      widget.ticketId,
      _selectedImages.map((f) => f.path).toList(),
      _materialController.text.isEmpty ? null : _materialController.text,
      fileBytes: _selectedImageBytes,
    ).then((success) {
      if (!mounted) return;

      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Tugas berhasil diselesaikan dan disimpan!'),
            backgroundColor: Color(0xFF43A047),
          ),
        );

        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => const HomeScreen()),
          (route) => false,
        );
      } else {
        final error = context.read<TicketProvider>().error;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $error'),
            backgroundColor: const Color(0xFFE53935),
          ),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Selesaikan Tugas',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
            fontSize: 20,
          ),
        ),
        backgroundColor: const Color(0xFF1565C0),
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Info Card
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: const Color(0xFF43A047).withOpacity(0.08),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: const Color(0xFF43A047).withOpacity(0.25),
                    width: 1,
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: const Color(0xFF43A047).withOpacity(0.15),
                      ),
                      child: const Icon(
                        Icons.check_circle,
                        color: Color(0xFF43A047),
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Text(
                        'Upload foto perbaikan dan deskripsi untuk menyelesaikan tugas ini',
                        style: TextStyle(
                          fontSize: 12,
                          color: Color(0xFF2E7D32),
                          fontWeight: FontWeight.w500,
                          height: 1.4,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 28),

              // Photo Section
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Foto Bukti Perbaikan',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: Colors.grey[900],
                    ),
                  ),
                  Text(
                    '${_selectedImages.length}/$maxPhotos',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF43A047),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                'Ambil atau pilih foto yang menunjukkan hasil perbaikan (hingga $maxPhotos)',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w400,
                ),
              ),
              const SizedBox(height: 12),

              if (_isCompressing)
                Container(
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
                      const SizedBox(height: 6),
                      Text(
                        'Proses otomatis kompresi gambar sedang berjalan',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ],
                  ),
                )
              else if (_selectedImages.isEmpty)
                GestureDetector(
                  onTap: _showImagePickerOptions,
                  child: Container(
                    width: double.infinity,
                    height: 180,
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
                          child: Icon(
                            Icons.camera_alt_outlined,
                            size: 40,
                            color: const Color(0xFF43A047),
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
                          'Tap untuk ambil dari kamera atau galeri',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              else
                Column(
                  children: [
                    // Photo Grid (3 columns)
                    Wrap(
                      spacing: 10,
                      runSpacing: 10,
                      children: [
                        for (int i = 0; i < _selectedImages.length; i++)
                          GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => PhotoZoomViewer(
                                    images: _selectedImages,
                                    initialIndex: i,
                                  ),
                                ),
                              );
                            },
                            child: Stack(
                              children: [
                                Container(
                                  width: (MediaQuery.of(context).size.width - 50) / 3,
                                  height: (MediaQuery.of(context).size.width - 50) / 3,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(10),
                                    border: Border.all(
                                      color: const Color(0xFF43A047).withOpacity(0.3),
                                      width: 1,
                                    ),
                                  ),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(10),
                                    child: kIsWeb && i < _selectedImageBytes.length
                                        ? Image.memory(
                                            _selectedImageBytes[i],
                                            fit: BoxFit.cover,
                                          )
                                        : Image.file(
                                            _selectedImages[i],
                                            fit: BoxFit.cover,
                                          ),
                                  ),
                                ),
                                // Remove button
                                Positioned(
                                  top: 4,
                                  right: 4,
                                  child: Container(
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: Colors.black.withOpacity(0.6),
                                    ),
                                    child: IconButton(
                                      icon: const Icon(Icons.close),
                                      color: Colors.white,
                                      iconSize: 16,
                                      onPressed: () {
                                        setState(() {
                                          _selectedImages.removeAt(i);
                                          _selectedImageBytes.removeAt(i);
                                          _compressionResults.removeAt(i);
                                        });
                                      },
                                    ),
                                  ),
                                ),
                                // Zoom icon
                                Positioned(
                                  bottom: 4,
                                  right: 4,
                                  child: Container(
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: const Color(0xFF43A047).withOpacity(0.8),
                                    ),
                                    padding: const EdgeInsets.all(4),
                                    child: const Icon(
                                      Icons.zoom_in,
                                      color: Colors.white,
                                      size: 14,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        // Add photo button
                        if (_selectedImages.length < maxPhotos)
                          GestureDetector(
                            onTap: _showImagePickerOptions,
                            child: Container(
                              width: (MediaQuery.of(context).size.width - 50) / 3,
                              height: (MediaQuery.of(context).size.width - 50) / 3,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(
                                  color: const Color(0xFF43A047).withOpacity(0.3),
                                  width: 2,
                                  style: BorderStyle.solid,
                                ),
                                color: const Color(0xFF43A047).withOpacity(0.05),
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.add_a_photo_outlined,
                                    size: 28,
                                    color: Colors.grey[600],
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'Tambah',
                                    style: TextStyle(
                                      fontSize: 11,
                                      color: Colors.grey[600],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    // Compression Info
                    if (_compressionResults.isNotEmpty)
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
                            Column(
                              children: [
                                for (int i = 0; i < _compressionResults.length; i++)
                                  if (_compressionResults[i] != null)
                                    Padding(
                                      padding: const EdgeInsets.only(bottom: 8),
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                'Foto ${i + 1}',
                                                style: TextStyle(
                                                  fontSize: 11,
                                                  color: Colors.grey[600],
                                                  fontWeight: FontWeight.w500,
                                                ),
                                              ),
                                              const SizedBox(height: 2),
                                              Text(
                                                '${_compressionResults[i]!.originalSize} → ${_compressionResults[i]!.compressedSize}',
                                                style: const TextStyle(
                                                  fontSize: 12,
                                                  fontWeight: FontWeight.w600,
                                                  color: Colors.grey,
                                                ),
                                              ),
                                            ],
                                          ),
                                          Text(
                                            '${_compressionResults[i]!.compressionPercentage.toStringAsFixed(1)}%',
                                            style: const TextStyle(
                                              fontSize: 12,
                                              fontWeight: FontWeight.w700,
                                              color: Color(0xFF43A047),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                              ],
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              const SizedBox(height: 28),

              // Material Section
              Text(
                'Deskripsi Perbaikan (Opsional)',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: Colors.grey[900],
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Jelaskan apa yang telah diperbaiki dan material apa yang digunakan',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w400,
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _materialController,
                maxLines: 4,
                decoration: InputDecoration(
                  hintText: 'Contoh: Ganti oli mesin, setel bearing, perbaiki sambungan, dll',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(
                      color: Colors.grey.withOpacity(0.3),
                      width: 1,
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(
                      color: Color(0xFF1565C0),
                      width: 2,
                    ),
                  ),
                  filled: true,
                  fillColor: Colors.white,
                  contentPadding: const EdgeInsets.all(14),
                  hintStyle: TextStyle(
                    color: Colors.grey[500],
                    fontSize: 12,
                  ),
                ),
              ),
              const SizedBox(height: 32),

              // Submit Button
              Consumer<TicketProvider>(
                builder: (context, ticketProvider, _) {
                  return SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton.icon(
                      onPressed: ticketProvider.isLoading ? null : _handleUpload,
                      icon: ticketProvider.isLoading
                          ? null
                          : const Icon(Icons.cloud_upload_outlined),
                      label: ticketProvider.isLoading
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2.5,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  Colors.white,
                                ),
                              ),
                            )
                          : const Text(
                              'Selesaikan dan Simpan',
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 0.3,
                              ),
                            ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF43A047),
                        foregroundColor: Colors.white,
                        disabledBackgroundColor:
                            const Color(0xFF43A047).withOpacity(0.5),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        elevation: 0,
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 12),
              
              // Cancel Button
              SizedBox(
                width: double.infinity,
                height: 52,
                child: OutlinedButton.icon(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.arrow_back),
                  label: const Text(
                    'Kembali',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(
                      color: Colors.grey.withOpacity(0.4),
                      width: 1.5,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    foregroundColor: const Color(0xFF1565C0),
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}
