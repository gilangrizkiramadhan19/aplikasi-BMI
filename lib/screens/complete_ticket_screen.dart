import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'dart:io';
import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import '../providers/ticket_provider.dart';
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
  File? _selectedImage;
  Uint8List? _selectedImageBytes;
  late TextEditingController _materialController;
  final ImagePicker _imagePicker = ImagePicker();

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
        final bytes = await pickedFile.readAsBytes();
        setState(() {
          _selectedImage = File(pickedFile.path);
          _selectedImageBytes = bytes;
        });
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
        final bytes = await pickedFile.readAsBytes();
        setState(() {
          _selectedImage = File(pickedFile.path);
          _selectedImageBytes = bytes;
        });
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
    if (_selectedImage == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Foto bukti harus dipilih'),
          backgroundColor: Color(0xFFE53935),
        ),
      );
      return;
    }

    context.read<TicketProvider>().completeTicket(
      widget.ticketId,
      _selectedImage!.path,
      _materialController.text.isEmpty ? null : _materialController.text,
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
              Text(
                'Foto Bukti Perbaikan',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: Colors.grey[900],
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Ambil atau pilih foto yang menunjukkan hasil perbaikan',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w400,
                ),
              ),
              const SizedBox(height: 12),

              if (_selectedImage == null)
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
                    Stack(
                      children: [
                        Container(
                          width: double.infinity,
                          height: 280,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(14),
                            color: Colors.grey.withOpacity(0.2),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.08),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(14),
                            child: kIsWeb && _selectedImageBytes != null
                                ? Image.memory(
                                    _selectedImageBytes!,
                                    fit: BoxFit.cover,
                                  )
                                : _selectedImage != null
                                    ? Image.file(
                                        _selectedImage!,
                                        fit: BoxFit.cover,
                                      )
                                    : Container(),
                          ),
                        ),
                        Positioned(
                          top: 12,
                          right: 12,
                          child: Container(
                            decoration: BoxDecoration(
                              color: const Color(0xFFE53935),
                              borderRadius: BorderRadius.circular(24),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.2),
                                  blurRadius: 6,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: IconButton(
                              icon: const Icon(Icons.close),
                              color: Colors.white,
                              onPressed: () {
                                setState(() {
                                  _selectedImage = null;
                                  _selectedImageBytes = null;
                                });
                              },
                            ),
                          ),
                        ),
                        Positioned(
                          bottom: 12,
                          right: 12,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.black.withOpacity(0.5),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: const Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.check_circle,
                                  color: Color(0xFF43A047),
                                  size: 16,
                                ),
                                SizedBox(width: 6),
                                Text(
                                  'Foto dipilih',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
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
