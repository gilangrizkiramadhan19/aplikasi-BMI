import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/ticket_provider.dart';

// ── BMI Brand Colors ──────────────────────────────────────────────
class _BMI {
  static const blue     = Color(0xFF1B3A7A);
  static const blueMid  = Color(0xFF2550A7);
  static const blueLight= Color(0xFFEBF1FF);
  static const gold     = Color(0xFFC9920A);
  static const goldMid  = Color(0xFFE4A80E);
  static const goldLight= Color(0xFFFDF6E3);
  static const goldPale = Color(0xFFFFF8E7);
  static const textDark = Color(0xFF1A1A2E);
  static const textMid  = Color(0xFF4A5568);
  static const textLight= Color(0xFF718096);
  static const bg       = Color(0xFFF4F6FB);
  static const border   = Color(0xFFE2E8F0);
  static const success  = Color(0xFF16A34A);
  static const error    = Color(0xFFD32F2F);
}

class CreateTicketScreen extends StatefulWidget {
  const CreateTicketScreen({Key? key}) : super(key: key);

  @override
  State<CreateTicketScreen> createState() => _CreateTicketScreenState();
}

class _CreateTicketScreenState extends State<CreateTicketScreen> {
  late TextEditingController _titleController;
  late TextEditingController _locationController;
  late TextEditingController _descriptionController;
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _titleController       = TextEditingController();
    _locationController    = TextEditingController();
    _descriptionController = TextEditingController();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _locationController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  // ── Submit ────────────────────────────────────────────────────────
  void _handleSubmit() {
    if (!_formKey.currentState!.validate()) return;

    context.read<TicketProvider>().createNewTicket(
      _titleController.text.trim(),
      _locationController.text.trim(),
      _descriptionController.text.trim(),
    ).then((success) {
      if (!mounted) return;

      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Row(
              children: [
                Icon(Icons.check_circle_outline, color: Colors.white, size: 18),
                SizedBox(width: 8),
                Text('Laporan berhasil dibuat!'),
              ],
            ),
            backgroundColor: _BMI.success,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
        );
        _titleController.clear();
        _locationController.clear();
        _descriptionController.clear();
        Navigator.pop(context);
      } else {
        final error = context.read<TicketProvider>().error;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.error_outline, color: Colors.white, size: 18),
                const SizedBox(width: 8),
                Expanded(child: Text('Error: $error')),
              ],
            ),
            backgroundColor: _BMI.error,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
        );
      }
    });
  }

  // ── Build ─────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _BMI.bg,
      // ── AppBar ────────────────────────────────────────────────────
      appBar: AppBar(
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [_BMI.blue, _BMI.blueMid],
            ),
          ),
        ),
        title: const Text(
          'Buat Laporan Baru',
          style: TextStyle(
            fontWeight: FontWeight.w700,
            color: Colors.white,
            fontSize: 18,
            letterSpacing: 0.3,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        centerTitle: true,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(3),
          child: Container(
            height: 3,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.transparent,
                  _BMI.goldMid,
                  _BMI.gold,
                  _BMI.goldMid,
                  Colors.transparent,
                ],
              ),
            ),
          ),
        ),
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              // ── Info Banner ───────────────────────────────────────
              Container(
                padding: const EdgeInsets.all(13),
                decoration: BoxDecoration(
                  color: _BMI.blueLight,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: _BMI.blue.withOpacity(0.2)),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: _BMI.blue.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: const Icon(
                        Icons.info_outline,
                        color: _BMI.blue,
                        size: 16,
                      ),
                    ),
                    const SizedBox(width: 10),
                    const Expanded(
                      child: Text(
                        'Laporkan kerusakan mesin yang baru untuk ditangani oleh teknisi.',
                        style: TextStyle(
                          fontSize: 12,
                          color: _BMI.blue,
                          fontWeight: FontWeight.w500,
                          height: 1.5,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // ── Judul Laporan ─────────────────────────────────────
              const _FieldLabel(label: 'Judul Laporan', required: true),
              const SizedBox(height: 8),
              _BMITextField(
                controller: _titleController,
                hintText: 'Contoh: Motor Conveyor Rusak',
                icon: Icons.assignment_outlined,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Judul tidak boleh kosong';
                  }
                  if (value.length < 3) return 'Judul minimal 3 karakter';
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // ── Lokasi ────────────────────────────────────────────
              const _FieldLabel(label: 'Lokasi', required: true),
              const SizedBox(height: 8),
              _BMITextField(
                controller: _locationController,
                hintText: 'Contoh: Line Produksi A',
                icon: Icons.location_on_outlined,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Lokasi tidak boleh kosong';
                  }
                  if (value.length < 3) return 'Lokasi minimal 3 karakter';
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // ── Deskripsi ─────────────────────────────────────────
              const _FieldLabel(label: 'Deskripsi', required: true),
              const SizedBox(height: 8),
              _BMITextField(
                controller: _descriptionController,
                hintText: 'Jelaskan masalah/kerusakan secara detail...',
                icon: Icons.description_outlined,
                maxLines: 5,
                alignTop: true,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Deskripsi tidak boleh kosong';
                  }
                  if (value.length < 10) {
                    return 'Deskripsi minimal 10 karakter';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 28),

              // ── Section divider ───────────────────────────────────
              Row(
                children: [
                  Expanded(
                    child: Container(
                      height: 1,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Colors.transparent,
                            _BMI.gold.withOpacity(0.4),
                          ],
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    child: Text(
                      'KONFIRMASI',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        color: _BMI.gold,
                        letterSpacing: 1.0,
                      ),
                    ),
                  ),
                  Expanded(
                    child: Container(
                      height: 1,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            _BMI.gold.withOpacity(0.4),
                            Colors.transparent,
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // ── Submit Button ─────────────────────────────────────
              Consumer<TicketProvider>(
                builder: (context, ticketProvider, _) {
                  return Column(
                    children: [
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton.icon(
                          onPressed: ticketProvider.isLoading
                              ? null
                              : _handleSubmit,
                          icon: ticketProvider.isLoading
                              ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                              strokeWidth: 2.5,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                  Colors.white),
                            ),
                          )
                              : const Icon(Icons.send_outlined, size: 19),
                          label: Text(
                            ticketProvider.isLoading
                                ? 'Mengirim...'
                                : 'Kirim Laporan',
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 0.2,
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: _BMI.success,
                            foregroundColor: Colors.white,
                            disabledBackgroundColor:
                            _BMI.success.withOpacity(0.55),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 0,
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),

                      // ── Cancel Button ─────────────────────────────
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: OutlinedButton.icon(
                          onPressed: () => Navigator.pop(context),
                          icon: const Icon(Icons.close, size: 18),
                          label: const Text(
                            'Batal',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: _BMI.blue,
                            side: const BorderSide(color: _BMI.blue, width: 1.2),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),

              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Sub-widgets
// ─────────────────────────────────────────────────────────────────────────────

/// Label di atas field dengan tanda bintang merah jika required
class _FieldLabel extends StatelessWidget {
  final String label;
  final bool required;
  const _FieldLabel({required this.label, this.required = false});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 3,
          height: 14,
          margin: const EdgeInsets.only(right: 8),
          decoration: BoxDecoration(
            color: _BMI.gold,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        Text(
          label,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: _BMI.textDark,
          ),
        ),
        if (required) ...[
          const SizedBox(width: 3),
          const Text(
            '*',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: Color(0xFFE53935),
            ),
          ),
        ],
      ],
    );
  }
}

/// Text field dengan styling BMI
class _BMITextField extends StatelessWidget {
  final TextEditingController controller;
  final String hintText;
  final IconData icon;
  final int maxLines;
  final bool alignTop;
  final String? Function(String?) validator;

  const _BMITextField({
    required this.controller,
    required this.hintText,
    required this.icon,
    required this.validator,
    this.maxLines = 1,
    this.alignTop = false,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      style: const TextStyle(
        fontSize: 14,
        color: _BMI.textDark,
        fontWeight: FontWeight.w500,
      ),
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: TextStyle(
          fontSize: 13,
          color: _BMI.textLight.withOpacity(0.7),
          fontWeight: FontWeight.w400,
        ),
        prefixIcon: Padding(
          padding: EdgeInsets.only(top: alignTop ? 12 : 0),
          child: Icon(icon, color: _BMI.blue.withOpacity(0.6), size: 20),
        ),
        alignLabelWithHint: alignTop,
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(
          vertical: 13,
          horizontal: 12,
        ),
        // Default border
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: _BMI.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: _BMI.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: _BMI.blue, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: _BMI.error),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: _BMI.error, width: 2),
        ),
        errorStyle: const TextStyle(
          fontSize: 11,
          color: _BMI.error,
          fontWeight: FontWeight.w500,
        ),
      ),
      validator: validator,
    );
  }
}