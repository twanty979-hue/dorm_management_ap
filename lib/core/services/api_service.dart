import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

/// Production-ready API Service connecting Flutter to Go Gin Backend API & Supabase
class ApiService {
  /// Override this at build time for a physical device or a deployed API.
  /// Example: --dart-define=GO_API_BASE_URL=http://127.0.0.1:8080/api/v1
  static const String _configuredGoApiBaseUrl = String.fromEnvironment(
    'GO_API_BASE_URL',
  );

  // Go Gin Backend API Base URL
  static String? _discoveredBaseUrl;

  static List<String> get _candidateUrls {
    if (_configuredGoApiBaseUrl.isNotEmpty) {
      return [_configuredGoApiBaseUrl];
    }
    if (kIsWeb) return ['http://localhost:8080/api/v1', 'http://127.0.0.1:8080/api/v1'];
    try {
      if (Platform.isAndroid) {
        return [
          'http://127.0.0.1:8080/api/v1',     // Physical device via adb reverse tcp:8080 tcp:8080
          'http://192.168.0.103:8080/api/v1', // LAN Wi-Fi direct connection
          'http://10.0.2.2:8080/api/v1',      // Android Studio Emulator
          'http://localhost:8080/api/v1',
        ];
      }
    } catch (_) {}
    return ['http://localhost:8080/api/v1', 'http://127.0.0.1:8080/api/v1'];
  }

  // Go Gin Backend API Base URL
  static String get goApiBaseUrl => _discoveredBaseUrl ?? _candidateUrls.first;

  // Supabase Cloud Fallback Direct URL
  static const String supabaseUrl = 'https://jexqgxqawcgdrnvrgovl.supabase.co';
  static const String supabaseAnonKey =
      'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImpleHFneHFhd2NnZHJudnJnb3ZsIiwicm9sZSI6ImFub24iLCJpYXQiOjE3ODc4NDg2NzMsImV4cCI6MjEwMzQyNDY3M30.wftJ4dLmR0t8n1G-i1yyhQw_gMGsktZrvo8g4vgeJVQ';

  static String? _authToken;
  static String? get authToken => _authToken;

  // Clean Headers for Go API
  static Map<String, String> get _goHeaders => {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
    if (_authToken != null) 'Authorization': 'Bearer $_authToken',
  };

  // Direct Supabase Headers
  static Map<String, String> get _supabaseHeaders => {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
    'apikey': supabaseAnonKey,
    'Authorization': 'Bearer $supabaseAnonKey',
  };

  // ==========================================
  // 0. AUTHENTICATION (STRICT API LOGIN WITH AUTO-DISCOVERY)
  // ==========================================
  static Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    final targets = _discoveredBaseUrl != null ? [_discoveredBaseUrl!] : _candidateUrls;

    for (final base in targets) {
      try {
        final url = '$base/auth/login';
        debugPrint('🚀 [AUTH API] Trying POST $url with email: $email');

        final response = await http
            .post(
              Uri.parse(url),
              headers: {
                'Content-Type': 'application/json',
                'Accept': 'application/json',
              },
              body: jsonEncode({
                'email': email.trim(),
                'password': password.trim(),
              }),
            )
            .timeout(const Duration(seconds: 4));

        final body = jsonDecode(response.body);

        if (response.statusCode == 200 && body['success'] == true) {
          _discoveredBaseUrl = base;
          _authToken = body['data']?['token'];
          debugPrint('✅ [AUTH SUCCESS] Connected to $base! Token received');
          return {
            'success': true,
            'message': body['message'] ?? 'เข้าสู่ระบบสำเร็จ',
            'data': body['data'],
          };
        } else if (response.statusCode == 400 || response.statusCode == 401) {
          // Connected successfully to the server, but invalid credentials
          _discoveredBaseUrl = base;
          final errorMsg =
              body['error']?['message'] ?? 'อีเมลหรือรหัสผ่านไม่ถูกต้อง';
          return {'success': false, 'message': errorMsg};
        }
      } catch (e) {
        debugPrint('⚠️ [AUTH] Candidate $base failed: $e, checking next candidate...');
      }
    }

    return {
      'success': false,
      'message':
          'ไม่สามารถเชื่อมต่อเซิร์ฟเวอร์ Go ได้ (กรุณาตรวจสอบว่าเปิด Go API หรือยัง)',
    };
  }

  // ==========================================
  // 1. DORM PROPERTIES / BRANCHES & SETTINGS
  // ==========================================
  static Future<List<Map<String, dynamic>>> getProperties() async {
    try {
      debugPrint('🚀 [API] GET $goApiBaseUrl/properties');
      final resp = await http
          .get(Uri.parse('$goApiBaseUrl/properties'), headers: _goHeaders)
          .timeout(const Duration(seconds: 8));

      if (resp.statusCode == 200) {
        final body = jsonDecode(resp.body);
        if (body['data'] is List) {
          return List<Map<String, dynamic>>.from(body['data']);
        }
      }
    } catch (e) {
      debugPrint('⚠️ Fallback to direct Supabase: $e');
      try {
        final uri = Uri.parse(
          '$supabaseUrl/rest/v1/dorm_properties?select=*&order=id.asc',
        );
        final response = await http
            .get(uri, headers: _supabaseHeaders)
            .timeout(const Duration(seconds: 8));
        if (response.statusCode == 200) {
          final List<dynamic> data = jsonDecode(response.body);
          return data.map((e) => Map<String, dynamic>.from(e)).toList();
        }
      } catch (_) {}
    }
    return [];
  }

  static Future<Map<String, dynamic>> updatePropertySettings(
    int propertyId,
    Map<String, dynamic> updateData,
  ) async {
    try {
      debugPrint('🚀 [API] PATCH $goApiBaseUrl/properties/$propertyId');
      final resp = await http.patch(
        Uri.parse('$goApiBaseUrl/properties/$propertyId'),
        headers: _goHeaders,
        body: jsonEncode(updateData),
      );

      final body = jsonDecode(resp.body);
      if (resp.statusCode == 200) {
        return {
          'success': true,
          'message': body['message'] ?? 'บันทึกการตั้งค่าสำเร็จ',
        };
      } else {
        return {
          'success': false,
          'message':
              body['error']?['message'] ?? 'ไม่สามารถบันทึกการตั้งค่าได้',
        };
      }
    } catch (e) {
      return {'success': false, 'message': 'เกิดข้อผิดพลาดในการเชื่อมต่อ: $e'};
    }
  }

  // ==========================================
  // 2. ROOMS
  // ==========================================
  static Future<List<Map<String, dynamic>>> getRooms({String? status}) async {
    try {
      String url = '$goApiBaseUrl/rooms';
      if (status != null && status.isNotEmpty) {
        url += '?status=$status';
      }
      debugPrint('🚀 [API] GET $url');
      final resp = await http
          .get(Uri.parse(url), headers: _goHeaders)
          .timeout(const Duration(seconds: 8));

      if (resp.statusCode == 200) {
        final body = jsonDecode(resp.body);
        if (body['data'] is List) {
          return List<Map<String, dynamic>>.from(body['data']);
        }
      }
    } catch (e) {
      debugPrint('⚠️ Fallback to direct Supabase: $e');
      try {
        String url =
            '$supabaseUrl/rest/v1/rooms?select=*&order=room_number.asc';
        if (status != null && status.isNotEmpty) {
          url += '&status=eq.$status';
        }
        final response = await http
            .get(Uri.parse(url), headers: _supabaseHeaders)
            .timeout(const Duration(seconds: 8));
        if (response.statusCode == 200) {
          final List<dynamic> data = jsonDecode(response.body);
          return data.map((e) => Map<String, dynamic>.from(e)).toList();
        }
      } catch (_) {}
    }
    return [];
  }

  static Future<Map<String, dynamic>> createRoom(
    Map<String, dynamic> roomData,
  ) async {
    try {
      debugPrint('🚀 [API] POST $goApiBaseUrl/rooms');
      final resp = await http.post(
        Uri.parse('$goApiBaseUrl/rooms'),
        headers: _goHeaders,
        body: jsonEncode(roomData),
      );

      final body = jsonDecode(resp.body);
      if (resp.statusCode == 201 || resp.statusCode == 200) {
        return {'success': true, 'message': 'เพิ่มห้องพักสำเร็จ'};
      } else {
        final msg = body['error']?['message'] ?? 'ไม่สามารถเพิ่มห้องพักได้';
        return {'success': false, 'message': msg};
      }
    } catch (e) {
      return {'success': false, 'message': 'เกิดข้อผิดพลาดในการเชื่อมต่อ: $e'};
    }
  }

  // ==========================================
  // 3. TENANTS & LEASES
  // ==========================================
  static Future<List<Map<String, dynamic>>> getTenants() async {
    try {
      debugPrint('🚀 [API] GET $goApiBaseUrl/tenants');
      final resp = await http
          .get(Uri.parse('$goApiBaseUrl/tenants'), headers: _goHeaders)
          .timeout(const Duration(seconds: 8));

      if (resp.statusCode == 200) {
        final body = jsonDecode(resp.body);
        if (body['data'] is List) {
          return List<Map<String, dynamic>>.from(body['data']);
        }
      }
    } catch (e) {
      debugPrint('⚠️ Fallback to direct Supabase: $e');
      try {
        final uri = Uri.parse(
          '$supabaseUrl/rest/v1/tenants?select=*&order=id.desc',
        );
        final response = await http
            .get(uri, headers: _supabaseHeaders)
            .timeout(const Duration(seconds: 8));
        if (response.statusCode == 200) {
          final List<dynamic> data = jsonDecode(response.body);
          return data.map((e) => Map<String, dynamic>.from(e)).toList();
        }
      } catch (_) {}
    }
    return [];
  }

  static Future<Map<String, dynamic>> createTenantWithLease({
    required Map<String, dynamic> tenantData,
    required Map<String, dynamic> leaseData,
  }) async {
    try {
      debugPrint('🚀 [API] POST $goApiBaseUrl/leases');
      final resp = await http.post(
        Uri.parse('$goApiBaseUrl/leases'),
        headers: _goHeaders,
        body: jsonEncode({
          'roomId': leaseData['roomId'],
          'dormId': leaseData['dormId'] ?? 1,
          'fullName': tenantData['fullName'],
          'phone': tenantData['phone'],
          'idCardNumber': tenantData['idCardNumber'] ?? '',
          'startDate': leaseData['startDate'],
          'endDate': leaseData['endDate'],
          'monthlyRent': leaseData['monthlyRent'],
          'depositAmount': leaseData['depositAmount'],
          'waterRate': leaseData['waterRate'],
          'electricRate': leaseData['electricRate'],
        }),
      );

      final body = jsonDecode(resp.body);
      if (resp.statusCode == 201 || resp.statusCode == 200) {
        return {'success': true, 'message': 'เพิ่มผู้เช่าสำเร็จ'};
      } else {
        final msg = body['error']?['message'] ?? 'ไม่สามารถเพิ่มผู้เช่าได้';
        return {'success': false, 'message': msg};
      }
    } catch (e) {
      return {'success': false, 'message': 'เกิดข้อผิดพลาดในการเชื่อมต่อ: $e'};
    }
  }

  static Future<Map<String, dynamic>> terminateLease(String tenantId) async {
    try {
      debugPrint('🚀 [API] DELETE $goApiBaseUrl/tenants/$tenantId');
      final resp = await http.delete(
        Uri.parse('$goApiBaseUrl/tenants/$tenantId'),
        headers: _goHeaders,
      );

      final body = jsonDecode(resp.body);
      if (resp.statusCode == 200) {
        return {
          'success': true,
          'message': body['message'] ?? 'ย้ายออกเรียบร้อย',
        };
      } else {
        return {
          'success': false,
          'message':
              body['error']?['message'] ?? 'ไม่สามารถดำเนินการย้ายออกได้',
        };
      }
    } catch (e) {
      return {'success': false, 'message': 'เกิดข้อผิดพลาดในการเชื่อมต่อ: $e'};
    }
  }

  // ==========================================
  // 4. MAINTENANCE TICKETS
  // ==========================================
  static Future<List<Map<String, dynamic>>> getMaintenanceTickets() async {
    try {
      debugPrint('🚀 [API] GET $goApiBaseUrl/maintenance');
      final resp = await http
          .get(Uri.parse('$goApiBaseUrl/maintenance'), headers: _goHeaders)
          .timeout(const Duration(seconds: 8));

      if (resp.statusCode == 200) {
        final body = jsonDecode(resp.body);
        if (body['data'] is List) {
          return List<Map<String, dynamic>>.from(body['data']);
        }
      }
    } catch (e) {
      debugPrint('⚠️ Fallback to direct Supabase: $e');
      try {
        final uri = Uri.parse(
          '$supabaseUrl/rest/v1/maintenance_tickets?select=*&order=created_at.desc',
        );
        final response = await http
            .get(uri, headers: _supabaseHeaders)
            .timeout(const Duration(seconds: 8));
        if (response.statusCode == 200) {
          final List<dynamic> data = jsonDecode(response.body);
          return data.map((e) => Map<String, dynamic>.from(e)).toList();
        }
      } catch (_) {}
    }
    return [];
  }

  static Future<Map<String, dynamic>> createMaintenanceTicket(
    Map<String, dynamic> ticketData,
  ) async {
    try {
      debugPrint('🚀 [API] POST $goApiBaseUrl/maintenance');
      final resp = await http.post(
        Uri.parse('$goApiBaseUrl/maintenance'),
        headers: _goHeaders,
        body: jsonEncode(ticketData),
      );

      final body = jsonDecode(resp.body);
      if (resp.statusCode == 201 || resp.statusCode == 200) {
        return {'success': true, 'message': 'เพิ่มรายการแจ้งซ่อมสำเร็จ'};
      } else {
        final msg =
            body['error']?['message'] ?? 'ไม่สามารถเพิ่มรายการแจ้งซ่อมได้';
        return {'success': false, 'message': msg};
      }
    } catch (e) {
      return {'success': false, 'message': 'เกิดข้อผิดพลาดในการเชื่อมต่อ: $e'};
    }
  }

  // ==========================================
  // 5. INVOICES & BILLING
  // ==========================================
  static Future<List<Map<String, dynamic>>> getInvoices() async {
    try {
      debugPrint('🚀 [API] GET $goApiBaseUrl/invoices');
      final resp = await http
          .get(Uri.parse('$goApiBaseUrl/invoices'), headers: _goHeaders)
          .timeout(const Duration(seconds: 8));

      if (resp.statusCode == 200) {
        final body = jsonDecode(resp.body);
        if (body['data'] is List) {
          return List<Map<String, dynamic>>.from(body['data']);
        }
      }
    } catch (_) {}
    return [];
  }

  static Future<Map<String, dynamic>> createInvoice(
    Map<String, dynamic> invoiceData,
  ) async {
    try {
      debugPrint('🚀 [API] POST $goApiBaseUrl/invoices');
      final resp = await http.post(
        Uri.parse('$goApiBaseUrl/invoices'),
        headers: _goHeaders,
        body: jsonEncode(invoiceData),
      );

      final body = jsonDecode(resp.body);
      if (resp.statusCode == 201 || resp.statusCode == 200) {
        return {
          'success': true,
          'message': body['message'] ?? 'ออกใบแจ้งหนี้สำเร็จ',
        };
      } else {
        return {
          'success': false,
          'message': body['error']?['message'] ?? 'ไม่สามารถออกใบแจ้งหนี้ได้',
        };
      }
    } catch (e) {
      return {'success': false, 'message': 'เกิดข้อผิดพลาดในการเชื่อมต่อ: $e'};
    }
  }

  static Future<Map<String, dynamic>> updateInvoiceStatus(
    int invoiceId,
    String status,
  ) async {
    try {
      debugPrint('🚀 [API] PATCH $goApiBaseUrl/invoices/$invoiceId/status');
      final resp = await http.patch(
        Uri.parse('$goApiBaseUrl/invoices/$invoiceId/status'),
        headers: _goHeaders,
        body: jsonEncode({'status': status}),
      );

      final body = jsonDecode(resp.body);
      if (resp.statusCode == 200) {
        return {
          'success': true,
          'message': body['message'] ?? 'อัปเดตสถานะสำเร็จ',
        };
      } else {
        return {
          'success': false,
          'message': body['error']?['message'] ?? 'ไม่สามารถอัปเดตสถานะได้',
        };
      }
    } catch (e) {
      return {'success': false, 'message': 'เกิดข้อผิดพลาดในการเชื่อมต่อ: $e'};
    }
  }

  // ==========================================
  // 6. METER READINGS
  // ==========================================
  static Future<Map<String, dynamic>> getMeters() async {
    try {
      debugPrint('🚀 [API] GET $goApiBaseUrl/meters');
      final resp = await http
          .get(Uri.parse('$goApiBaseUrl/meters'), headers: _goHeaders)
          .timeout(const Duration(seconds: 8));

      if (resp.statusCode == 200) {
        final body = jsonDecode(resp.body);
        return {
          'success': true,
          'data': body['data'] is List
              ? List<Map<String, dynamic>>.from(body['data'])
              : [],
          'rates': body['rates'] ?? {'electricRate': 8.0, 'waterRate': 18.0},
        };
      }
    } catch (e) {
      debugPrint('⚠️ Error fetching meters from Go API: $e');
    }
    return {
      'success': false,
      'data': [],
      'rates': {'electricRate': 8.0, 'waterRate': 18.0},
    };
  }

  static Future<Map<String, dynamic>> recordMeters(
    List<Map<String, dynamic>> readings,
  ) async {
    try {
      debugPrint('🚀 [API] POST $goApiBaseUrl/meters/batch-record');
      final resp = await http.post(
        Uri.parse('$goApiBaseUrl/meters/batch-record'),
        headers: _goHeaders,
        body: jsonEncode({
          'dormId': 1,
          'billingMonth': DateTime.now().toIso8601String().substring(0, 10),
          'readings': readings,
        }),
      );

      final body = jsonDecode(resp.body);
      if (resp.statusCode == 200) {
        return {
          'success': true,
          'message': body['message'] ?? 'บันทึกมิเตอร์สำเร็จ',
        };
      } else {
        return {
          'success': false,
          'message': body['error']?['message'] ?? 'ไม่สามารถบันทึกมิเตอร์ได้',
        };
      }
    } catch (e) {
      return {'success': false, 'message': 'เกิดข้อผิดพลาดในการเชื่อมต่อ: $e'};
    }
  }
}
