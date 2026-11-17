import 'package:flutter/material.dart';

import '../models/umkm_model.dart';
import '../services/api_service.dart';

class UmkmFormScreen extends StatefulWidget {
  final Umkm? umkm;

  const UmkmFormScreen({super.key, this.umkm});

  @override
  State<UmkmFormScreen> createState() => _UmkmFormScreenState();
}

class _UmkmFormScreenState extends State<UmkmFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final ApiService _apiService = ApiService();

  late TextEditingController _namaController;
  late TextEditingController _jenisController;
  late TextEditingController _pemilikController;
  late TextEditingController _alamatController;
  late TextEditingController _noTelpController;
  late TextEditingController _deskripsiController;

  bool _isLoading = false;

  bool get _isEditMode => widget.umkm != null;

  @override
  void initState() {
    super.initState();
    _namaController = TextEditingController(text: widget.umkm?.namaUmkm ?? '');
    _jenisController = TextEditingController(text: widget.umkm?.kategori ?? '');
    _pemilikController = TextEditingController(
      text: widget.umkm?.pemilik ?? '',
    );
    _alamatController = TextEditingController(text: widget.umkm?.alamat ?? '');
    _noTelpController = TextEditingController(text: widget.umkm?.kontak ?? '');
    _deskripsiController = TextEditingController(
      text: widget.umkm?.deskripsi ?? '',
    );
  }

  @override
  void dispose() {
    _namaController.dispose();
    _jenisController.dispose();
    _pemilikController.dispose();
    _alamatController.dispose();
    _noTelpController.dispose();
    _deskripsiController.dispose();
    super.dispose();
  }

  Future<void> _saveForm() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    final umkm = Umkm(
      namaUmkm: _namaController.text.trim(),
      kategori: _jenisController.text.trim().isEmpty
          ? 'Lainnya'
          : _jenisController.text.trim(),
      pemilik: _pemilikController.text.trim().isEmpty
          ? '-'
          : _pemilikController.text.trim(),
      alamat: _alamatController.text.trim(),
      kontak: _noTelpController.text.trim(),
      deskripsi: _deskripsiController.text.trim(),
    );

    try {
      if (_isEditMode) {
        await _apiService.update(widget.umkm!.id!, umkm);
      } else {
        await _apiService.create(umkm);
      }

      if (!mounted) return;
      setState(() {
        _isLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            _isEditMode
                ? 'UMKM berhasil diperbarui'
                : 'UMKM berhasil ditambahkan',
          ),
          backgroundColor: const Color(0xFF26342E),
        ),
      );
      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            e.toString().replaceAll('Exception: ', ''),
            style: const TextStyle(color: Colors.white),
          ),
          backgroundColor: Colors.red.shade700,
          duration: const Duration(seconds: 4),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditMode ? 'Edit UMKM' : 'Tambah UMKM'),
        actions: [
          IconButton(
            icon: _isLoading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      color: Color(0xFF176B57),
                      strokeWidth: 2,
                    ),
                  )
                : const Icon(Icons.save),
            onPressed: _isLoading ? null : _saveForm,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                padding: const EdgeInsets.all(18),
                margin: const EdgeInsets.only(bottom: 20),
                decoration: BoxDecoration(
                  color: const Color(0xFFE5F1EC),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.storefront,
                      color: Color(0xFF176B57),
                      size: 28,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        _isEditMode
                            ? 'Perbarui profil usaha'
                            : 'Kenalkan usaha lokalmu',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF176B57),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              _buildTextField(
                controller: _namaController,
                label: 'Nama UMKM',
                icon: Icons.storefront,
                required: true,
              ),
              const SizedBox(height: 16),
              _buildTextField(
                controller: _jenisController,
                label: 'Kategori (misal: Kuliner, Fashion, dsb)',
                icon: Icons.category,
                required: true,
              ),
              const SizedBox(height: 16),
              _buildTextField(
                controller: _pemilikController,
                label: 'Nama Pemilik',
                icon: Icons.person,
                required: true,
              ),
              const SizedBox(height: 16),
              _buildTextField(
                controller: _alamatController,
                label: 'Alamat (opsional)',
                icon: Icons.location_on,
                maxLines: 2,
              ),
              const SizedBox(height: 16),
              _buildTextField(
                controller: _noTelpController,
                label: 'Kontak (opsional)',
                icon: Icons.phone,
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: 16),
              _buildTextField(
                controller: _deskripsiController,
                label: 'Deskripsi (opsional)',
                icon: Icons.description,
                maxLines: 3,
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _saveForm,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF176B57),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    elevation: 0,
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : Text(
                          _isEditMode ? 'Perbarui Data' : 'Simpan UMKM',
                          style: const TextStyle(fontSize: 16),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    bool required = false,
    int maxLines = 1,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Color(0xFF718078)),
        prefixIcon: Icon(icon, color: const Color(0xFF718078)),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Color(0xFFE3E9E5)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Color(0xFFE3E9E5)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Color(0xFF176B57), width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Colors.red),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Colors.red, width: 1.5),
        ),
      ),
      validator: required
          ? (value) {
              if (value == null || value.trim().isEmpty) {
                return '$label wajib diisi';
              }
              return null;
            }
          : null,
    );
  }
}
