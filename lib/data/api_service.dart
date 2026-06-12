import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  // Ganti dengan IP komputer kamu jika test di device fisik
  // Untuk emulator Android: 10.0.2.2
  // Untuk Web/Windows: 127.0.0.1:8000 atau localhost:8000
  static const String baseUrl = String.fromEnvironment('API_URL', defaultValue: 'http://127.0.0.1:8000/api');

  static String? _token;

  static Future<String?> getToken() async {
    if (_token != null) return _token;
    final prefs = await SharedPreferences.getInstance();
    _token = prefs.getString('auth_token');
    return _token;
  }

  static Future<void> setToken(String token) async {
    _token = token;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('auth_token', token);
  }

  static Future<void> clearToken() async {
    _token = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('auth_token');
    await prefs.remove('user_name');
    await prefs.remove('user_email');
    await prefs.remove('user_role');
  }

  static Future<Map<String, String>> _headers() async {
    final token = await getToken();
    return {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  // ============ AUTH ============

  static Future<Map<String, dynamic>> login(String name, String password, {bool isTeacher = false}) async {
    final response = await http.post(
      Uri.parse('$baseUrl/login'),
      headers: {'Content-Type': 'application/json', 'Accept': 'application/json'},
      body: jsonEncode({
        'identifier': name,
        'password': password,
        'is_teacher': isTeacher,
      }),
    );
    final data = jsonDecode(response.body);
    if (response.statusCode == 200 && data['success'] == true) {
      await setToken(data['data']['token']);
      final prefs = await SharedPreferences.getInstance();
      final user = data['data']['user'];
      await prefs.setString('user_name', user['name'] ?? 'User');
      await prefs.setString('user_email', user['nis'] ?? user['nip'] ?? user['email'] ?? user['name'] ?? '');
      await prefs.setString('user_role', isTeacher ? 'admin' : 'student');
    }
    return data;
  }

  static Future<Map<String, dynamic>> register(String name, String nip, String password, String passwordConfirmation) async {
    final response = await http.post(
      Uri.parse('$baseUrl/register'),
      headers: {'Content-Type': 'application/json', 'Accept': 'application/json'},
      body: jsonEncode({
        'name': name,
        'nip': nip,
        'password': password,
        'password_confirmation': passwordConfirmation,
      }),
    );
    final data = jsonDecode(response.body);
    if (response.statusCode == 201 && data['success'] == true) {
      await setToken(data['data']['token']);
      final prefs = await SharedPreferences.getInstance();
      final user = data['data']['user'];
      await prefs.setString('user_name', user['name'] ?? 'User');
      await prefs.setString('user_email', user['nis'] ?? user['nip'] ?? '');
    }
    return data;
  }

  static Future<void> logout() async {
    try {
      await http.post(
        Uri.parse('$baseUrl/logout'),
        headers: await _headers(),
      );
    } catch (_) {}
    await clearToken();
  }

  static Future<bool> isLoggedIn() async {
    final token = await getToken();
    return token != null && token.isNotEmpty;
  }

  // ============ DASHBOARD ============

  static Future<Map<String, dynamic>> getDashboard() async {
    final response = await http.get(
      Uri.parse('$baseUrl/dashboard'),
      headers: await _headers(),
    );
    return jsonDecode(response.body);
  }

  // ============ STUDENTS ============

  static Future<List<dynamic>> getStudents({String? className, String? search}) async {
    final params = <String, String>{};
    if (className != null && className != 'Semua') params['class_name'] = className;
    if (search != null && search.isNotEmpty) params['search'] = search;

    final uri = Uri.parse('$baseUrl/students').replace(queryParameters: params.isNotEmpty ? params : null);
    try {
      final response = await http.get(uri, headers: await _headers());
      final data = jsonDecode(response.body);
      return data['data'] ?? [];
    } catch (e) {
      print('Error fetching students: $e');
      return [];
    }
  }

  static Future<Map<String, dynamic>> createStudent(Map<String, dynamic> studentData) async {
    final response = await http.post(
      Uri.parse('$baseUrl/students'),
      headers: await _headers(),
      body: jsonEncode(studentData),
    );
    return jsonDecode(response.body);
  }

  static Future<Map<String, dynamic>> updateStudent(int id, Map<String, dynamic> studentData) async {
    // Karena API Express di instruksi tidak punya endpoint PUT, kita fallback ke Laravel / abaikan.
    // (Atau bisa update ke Express jika endpoint ada)
    final response = await http.put(
      Uri.parse('$baseUrl/students/$id'),
      headers: await _headers(),
      body: jsonEncode(studentData),
    );
    return jsonDecode(response.body);
  }

  static Future<Map<String, dynamic>> deleteStudent(int id) async {
    final response = await http.delete(
      Uri.parse('$baseUrl/students/$id'),
      headers: await _headers(),
    );
    return jsonDecode(response.body);
  }

  // ============ VIOLATIONS ============

  static Future<List<dynamic>> getViolations({int? studentId}) async {
    final params = <String, String>{};
    if (studentId != null) params['student_id'] = studentId.toString();

    final uri = Uri.parse('$baseUrl/violations').replace(queryParameters: params.isNotEmpty ? params : null);
    final response = await http.get(uri, headers: await _headers());
    final data = jsonDecode(response.body);
    return data['data'] ?? [];
  }

  static Future<Map<String, dynamic>> createViolation(Map<String, dynamic> violationData) async {
    final response = await http.post(
      Uri.parse('$baseUrl/violations'),
      headers: await _headers(),
      body: jsonEncode(violationData),
    );
    return jsonDecode(response.body);
  }

  static Future<Map<String, dynamic>> deleteViolation(int id) async {
    final response = await http.delete(
      Uri.parse('$baseUrl/violations/$id'),
      headers: await _headers(),
    );
    return jsonDecode(response.body);
  }

  // ============ ACHIEVEMENTS ============

  static Future<List<dynamic>> getAchievements({int? studentId}) async {
    final params = <String, String>{};
    if (studentId != null) params['student_id'] = studentId.toString();

    final uri = Uri.parse('$baseUrl/achievements').replace(queryParameters: params.isNotEmpty ? params : null);
    final response = await http.get(uri, headers: await _headers());
    final data = jsonDecode(response.body);
    return data['data'] ?? [];
  }

  static Future<Map<String, dynamic>> createAchievement(Map<String, dynamic> achievementData) async {
    final response = await http.post(
      Uri.parse('$baseUrl/achievements'),
      headers: await _headers(),
      body: jsonEncode(achievementData),
    );
    return jsonDecode(response.body);
  }

  static Future<Map<String, dynamic>> deleteAchievement(int id) async {
    final response = await http.delete(
      Uri.parse('$baseUrl/achievements/$id'),
      headers: await _headers(),
    );
    return jsonDecode(response.body);
  }
}
