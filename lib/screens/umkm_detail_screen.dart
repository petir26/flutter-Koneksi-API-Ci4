import 'package:flutter/material.dart';

import '../models/umkm_model.dart';
import '../services/api_service.dart';
import 'umkm_form_screen.dart';

class UmkmDetailScreen extends StatefulWidget {
  final int umkmId;

  const UmkmDetailScreen({super.key, required this.umkmId});

  @override
  State<UmkmDetailScreen> createState() => _UmkmDetailScreenState();
}

class _UmkmDetailScreenState extends State<UmkmDetailScreen> {
  final ApiService _apiService = ApiService();
  Umkm? _umkm;
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadDetail();
  }

  Future<void> _loadDetail() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    try {
      final data = await _apiService.getById(widget.umkmId);
      if (!mounted) return;
      setState(() {
        _umkm = data;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage = e.toString().replaceFirst('Exception: ', '');
        _isLoading = false;
      });
    }
  }

  Future<void> _deleteUmkm() async {
    bool? confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hapus UMKM ini?'),
        content: Text('Yakin ingin menghapus "${_umkm?.namaUmkm}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Batal', style: TextStyle(color: Colors.black54)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Hapus', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        final success = await _apiService.delete(widget.umkmId);
        if (!mounted) return;
        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('UMKM berhasil dihapus'),
              backgroundColor: Color(0xFF26342E),
            ),
          );
          Navigator.pop(context, true);
        }
      } catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Gagal menghapus: ${e.toString().replaceFirst('Exception: ', '')}',
              style: const TextStyle(color: Colors.white),
            ),
            backgroundColor: Colors.red.shade700,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Detail UMKM'),
        actions: [
          if (_umkm != null) ...[
            IconButton(
              icon: const Icon(Icons.edit),
              tooltip: 'Edit UMKM',
              onPressed: () async {
                final result = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => UmkmFormScreen(umkm: _umkm),
                  ),
                );
                if (result == true) {
                  _loadDetail();
                }
              },
            ),
            IconButton(
              icon: const Icon(Icons.delete),
              tooltip: 'Hapus UMKM',
              onPressed: _deleteUmkm,
            ),
          ],
        ],
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return Center(
        child: CircularProgressIndicator(
          color: Theme.of(context).colorScheme.primary,
        ),
      );
    }

    if (_errorMessage != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.error_outline,
                size: 48,
                color: Color(0xFF9AA9A1),
              ),
              const SizedBox(height: 16),
              Text(
                _errorMessage!,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Color(0xFF718078), fontSize: 14),
              ),
              const SizedBox(height: 20),
              ElevatedButton.icon(
                onPressed: _loadDetail,
                icon: const Icon(Icons.refresh, size: 18),
                label: const Text('Coba Lagi'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF176B57),
                  foregroundColor: Colors.white,
                ),
              ),
            ],
          ),
        ),
      );
    }

    if (_umkm == null) {
      return const Center(child: Text('Data tidak ditemukan'));
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Card(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: const BorderSide(color: Color(0xFFE7ECE9)),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Center(
                child: Column(
                  children: [
                    Container(
                      width: 64,
                      height: 64,
                      decoration: BoxDecoration(
                        color: const Color(0xFFE5F1EC),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Icon(
                        Icons.storefront,
                        color: Color(0xFF176B57),
                        size: 32,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      _umkm!.namaUmkm,
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF17201D),
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF3F8F5),
                        border: Border.all(color: const Color(0xFFC9DDD3)),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        _umkm!.kategori,
                        style: const TextStyle(
                          fontSize: 13,
                          color: Color(0xFF176B57),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              const Divider(color: Color(0xFFE7ECE9)),
              const SizedBox(height: 16),

              // Detail fields
              _buildDetailRow(Icons.person_outline, 'Pemilik', _umkm!.pemilik),
              const Divider(color: Color(0xFFE7ECE9)),
              _buildDetailRow(
                Icons.location_on_outlined,
                'Alamat',
                _umkm!.alamat,
              ),
              const Divider(color: Color(0xFFE7ECE9)),
              _buildDetailRow(Icons.phone_outlined, 'Kontak', _umkm!.kontak),
              const Divider(color: Color(0xFFE7ECE9)),
              _buildDetailRow(Icons.notes, 'Deskripsi', _umkm!.deskripsi),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: const Color(0xFF176B57)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF718078),
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value.isNotEmpty ? value : '-',
                  style: const TextStyle(
                    fontSize: 15,
                    color: Color(0xFF26342E),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
