import 'dart:convert';
import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:http/http.dart' as http;
import '../models/umkm_model.dart';

class ApiService {
  /// Anda bisa mengganti customHost jika menggunakan device fisik (misal: '192.168.1.100:8080')
  static String? customHost;

  static String get baseUrl {
    if (customHost != null && customHost!.isNotEmpty) {
      return 'http://$customHost/api/umkm';
    }

    if (kIsWeb) {
      return 'http://127.0.0.1:8080/api/umkm';
    }

    try {
      if (Platform.isAndroid) {
        // 10.0.2.2 adalah alias localhost host machine untuk Android Emulator
        return 'http://10.0.2.2:8080/api/umkm';
      }
    } catch (_) {}

    // Default untuk Windows desktop, macOS, Linux
    return 'http://127.0.0.1:8080/api/umkm';
  }

  Future<List<Umkm>> getAll() async {
    try {
      final response = await http.get(
        Uri.parse(baseUrl),
        headers: {'Accept': 'application/json'},
      );
      if (response.statusCode == 200) {
        final body = json.decode(response.body);
        if (body['success'] == true) {
          final List data = body['data'] ?? [];
          return data.map((item) => Umkm.fromJson(item)).toList();
        }
        throw Exception(body['message'] ?? 'Gagal memuat data');
      }
      throw Exception('Status server: ${response.statusCode}');
    } catch (e) {
      throw Exception('Gagal terhubung ke API ($baseUrl): $e');
    }
  }

  Future<Umkm> getById(int id) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/$id'),
        headers: {'Accept': 'application/json'},
      );
      if (response.statusCode == 200) {
        final body = json.decode(response.body);
        if (body['success'] == true) {
          return Umkm.fromJson(body['data']);
        }
        throw Exception(body['message'] ?? 'Data tidak ditemukan');
      }
      throw Exception('Status server: ${response.statusCode}');
    } catch (e) {
      throw Exception('Gagal memuat detail ($baseUrl/$id): $e');
    }
  }

  Future<bool> create(Umkm umkm) async {
    try {
      final response = await http.post(
        Uri.parse(baseUrl),
        headers: {
          'Content-Type': 'application/json; charset=UTF-8',
          'Accept': 'application/json',
        },
        body: json.encode(umkm.toJson()),
      );

      final body = json.decode(response.body);
      if ((response.statusCode == 201 || response.statusCode == 200) &&
          body['success'] == true) {
        return true;
      }

      throw Exception(body['message'] ?? 'Error status: ${response.statusCode}');
    } catch (e) {
      throw Exception('Gagal menambah data: $e');
    }
  }

  Future<bool> update(int id, Umkm umkm) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/$id'),
        headers: {
          'Content-Type': 'application/json; charset=UTF-8',
          'Accept': 'application/json',
        },
        body: json.encode(umkm.toJson()),
      );

      final body = json.decode(response.body);
      if (response.statusCode == 200 && body['success'] == true) {
        return true;
      }

      throw Exception(body['message'] ?? 'Error status: ${response.statusCode}');
    } catch (e) {
      throw Exception('Gagal memperbarui data: $e');
    }
  }

  Future<bool> delete(int id) async {
    try {
      final response = await http.delete(
        Uri.parse('$baseUrl/$id'),
        headers: {'Accept': 'application/json'},
      );

      final body = json.decode(response.body);
      if (response.statusCode == 200 && body['success'] == true) {
        return true;
      }

      throw Exception(body['message'] ?? 'Error status: ${response.statusCode}');
    } catch (e) {
      throw Exception('Gagal menghapus data: $e');
    }
  }
}
