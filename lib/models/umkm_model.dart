class Umkm {
  final int? id;
  final String namaUmkm;
  final String kategori;
  final String pemilik;
  final String alamat;
  final String kontak;
  final String deskripsi;

  Umkm({
    this.id,
    required this.namaUmkm,
    required this.kategori,
    required this.pemilik,
    required this.alamat,
    required this.kontak,
    required this.deskripsi,
  });

  factory Umkm.fromJson(Map<String, dynamic> json) {
    return Umkm(
      id: json['id'] is int ? json['id'] : int.tryParse(json['id'].toString()),
      namaUmkm: json['nama_umkm'] ?? '',
      kategori: json['kategori'] ?? json['jenis_usaha'] ?? '',
      pemilik: json['pemilik'] ?? '',
      alamat: json['alamat'] ?? '',
      kontak: json['kontak'] ?? json['no_telp'] ?? '',
      deskripsi: json['deskripsi'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'nama_umkm': namaUmkm,
      'kategori': kategori,
      'pemilik': pemilik,
      'alamat': alamat,
      'kontak': kontak,
      'deskripsi': deskripsi,
    };
  }
}

