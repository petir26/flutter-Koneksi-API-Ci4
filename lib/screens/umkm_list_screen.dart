import 'package:flutter/material.dart';

import '../models/umkm_model.dart';
import '../services/api_service.dart';
import 'umkm_detail_screen.dart';
import 'umkm_form_screen.dart';

class UmkmListScreen extends StatefulWidget {
  const UmkmListScreen({super.key});

  @override
  State<UmkmListScreen> createState() => _UmkmListScreenState();
}

class _UmkmListScreenState extends State<UmkmListScreen> {
  final ApiService _apiService = ApiService();
  final TextEditingController _searchController = TextEditingController();
  List<Umkm> _umkmList = [];
  bool _isLoading = true;
  String? _errorMessage;
  String _query = '';

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    try {
      final data = await _apiService.getAll();
      if (!mounted) return;
      setState(() {
        _umkmList = data;
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

  Future<void> _deleteUmkm(int id) async {
    try {
      final success = await _apiService.delete(id);
      if (!mounted) return;
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('UMKM berhasil dihapus'),
            backgroundColor: Color(0xFF26342E),
          ),
        );
        _loadData();
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            e.toString().replaceFirst('Exception: ', ''),
            style: const TextStyle(color: Colors.white),
          ),
          backgroundColor: Colors.red.shade700,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ruang UMKM'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Muat ulang',
            onPressed: _loadData,
          ),
        ],
      ),
      body: _buildBody(),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const UmkmFormScreen()),
          );
          if (result == true) {
            _loadData();
          }
        },
        tooltip: 'Tambah UMKM',
        child: const Icon(Icons.add),
      ),
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
                onPressed: _loadData,
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

    if (_umkmList.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.store_outlined,
              size: 64,
              color: Color(0xFF9AA9A1),
            ),
            const SizedBox(height: 16),
            const Text(
              'Belum ada data UMKM',
              style: TextStyle(fontSize: 18, color: Color(0xFF718078)),
            ),
            const SizedBox(height: 16),
            OutlinedButton.icon(
              onPressed: () async {
                final result = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const UmkmFormScreen(),
                  ),
                );
                if (result == true) {
                  _loadData();
                }
              },
              icon: const Icon(Icons.add),
              label: const Text('Tambah UMKM'),
              style: OutlinedButton.styleFrom(
                foregroundColor: const Color(0xFF176B57),
              ),
            ),
          ],
        ),
      );
    }

    final filteredList = _umkmList.where((umkm) {
      final query = _query.trim().toLowerCase();
      return query.isEmpty ||
          umkm.namaUmkm.toLowerCase().contains(query) ||
          umkm.pemilik.toLowerCase().contains(query) ||
          umkm.kategori.toLowerCase().contains(query);
    }).toList();

    return RefreshIndicator(
      color: const Color(0xFF176B57),
      onRefresh: _loadData,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 100),
        children: [
          const Text(
            'Usaha lokal,\ncerita luar biasa.',
            style: TextStyle(
              fontSize: 28,
              height: 1.15,
              fontWeight: FontWeight.w800,
              color: Color(0xFF17201D),
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Temukan dan kelola usaha di sekitarmu.',
            style: TextStyle(fontSize: 14, color: Color(0xFF718078)),
          ),
          const SizedBox(height: 20),
          TextField(
            controller: _searchController,
            onChanged: (value) => setState(() => _query = value),
            decoration: InputDecoration(
              hintText: 'Cari nama, pemilik, atau kategori',
              prefixIcon: const Icon(Icons.search, color: Color(0xFF718078)),
              suffixIcon: _query.isEmpty
                  ? null
                  : IconButton(
                      tooltip: 'Hapus pencarian',
                      icon: const Icon(Icons.close),
                      onPressed: () {
                        _searchController.clear();
                        setState(() => _query = '');
                      },
                    ),
            ),
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              const Expanded(
                child: Text(
                  'Daftar UMKM',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF17201D),
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 5,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFE5F1EC),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '${filteredList.length} usaha',
                  style: const TextStyle(
                    color: Color(0xFF176B57),
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (filteredList.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 40),
              child: Column(
                children: [
                  const Icon(
                    Icons.search_off,
                    size: 42,
                    color: Color(0xFF9AA9A1),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    _query.isEmpty
                        ? 'Belum ada data UMKM'
                        : 'Tidak ada hasil untuk "$_query"',
                    style: const TextStyle(color: Color(0xFF718078)),
                  ),
                ],
              ),
            ),
          ...filteredList.asMap().entries.map((entry) {
            final index = entry.key;
            final umkm = entry.value;
            return Dismissible(
              key: Key('umkm_${umkm.id ?? index}'),
              direction: DismissDirection.endToStart,
              background: Container(
                alignment: Alignment.centerRight,
                padding: const EdgeInsets.only(right: 20),
                margin: const EdgeInsets.only(bottom: 12),
                decoration: BoxDecoration(
                  color: Colors.red,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.delete, color: Colors.white),
              ),
              confirmDismiss: (direction) async {
                bool? confirm = await showDialog<bool>(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('Hapus UMKM ini?'),
                    content: Text('Yakin ingin menghapus "${umkm.namaUmkm}"?'),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context, false),
                        child: const Text(
                          'Batal',
                          style: TextStyle(color: Colors.black54),
                        ),
                      ),
                      TextButton(
                        onPressed: () => Navigator.pop(context, true),
                        child: const Text(
                          'Hapus',
                          style: TextStyle(color: Colors.red),
                        ),
                      ),
                    ],
                  ),
                );
                return confirm ?? false;
              },
              onDismissed: (direction) {
                if (umkm.id != null) {
                  _deleteUmkm(umkm.id!);
                }
              },
              child: _buildUmkmCard(umkm),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildUmkmCard(Umkm umkm) {
    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: Color(0xFFE7ECE9)),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () async {
          if (umkm.id == null) return;
          final result = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => UmkmDetailScreen(umkmId: umkm.id!),
            ),
          );
          if (result == true) {
            _loadData();
          }
        },
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: const Color(0xFFE5F1EC),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(
                  Icons.storefront,
                  color: Color(0xFF176B57),
                  size: 24,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      umkm.namaUmkm,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF17201D),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            border: Border.all(color: Color(0xFFC9DDD3)),
                            color: Color(0xFFF3F8F5),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            umkm.kategori,
                            style: const TextStyle(
                              fontSize: 11,
                              color: Color(0xFF176B57),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Flexible(
                          child: Text(
                            umkm.pemilik,
                            style: const TextStyle(
                              fontSize: 13,
                              color: Color(0xFF718078),
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right, color: Color(0xFF9AA9A1)),
            ],
          ),
        ),
      ),
    );
  }
}
