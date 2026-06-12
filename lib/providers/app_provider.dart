import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../data/models/student.dart';
import '../data/models/violation.dart';
import '../data/models/achievement.dart';
import '../data/api_service.dart';
import '../data/dummy_data.dart';

class AppProvider extends ChangeNotifier {
  bool _isDarkMode = false;
  int _currentIndex = 0;
  List<Student> _students = [];
  List<Violation> _violations = [];
  List<Achievement> _achievements = [];
  String _searchQuery = '';
  String _selectedClassFilter = 'Semua';
  bool _isLoading = false;
  bool _useApi = true; // true = use Laravel API, false = use dummy data
  String _userName = '';
  String _userEmail = '';
  String _userRole = 'admin'; // Default to admin for safety
  Map<String, dynamic> _dashboardData = {};

  AppProvider() {
    Future.microtask(() => _loadData());
  }

  // Getters
  bool get isDarkMode => _isDarkMode;
  int get currentIndex => _currentIndex;
  List<Student> get students => _students;
  List<Violation> get violations => _violations;
  List<Achievement> get achievements => _achievements;
  String get searchQuery => _searchQuery;
  String get selectedClassFilter => _selectedClassFilter;
  bool get isLoading => _isLoading;
  String get userName => _userName;
  String get userEmail => _userEmail;
  String get userRole => _userRole;
  bool get isAdmin => _userRole == 'admin';
  bool get isStudent => _userRole == 'student';
  Map<String, dynamic> get dashboardData => _dashboardData;

  // Filtered students
  List<Student> get filteredStudents {
    var filtered = _students.toList();
    if (_selectedClassFilter != 'Semua') {
      filtered = filtered.where((s) => s.className == _selectedClassFilter).toList();
    }
    if (_searchQuery.isNotEmpty) {
      filtered = filtered.where((s) =>
        s.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
        s.nis.contains(_searchQuery)
      ).toList();
    }
    return filtered;
  }

  Student? get currentStudent {
    if (!isStudent) return null;
    try {
      final s = _students.firstWhere((s) => s.nis == _userEmail);
      s.totalViolationPoints = _violations.where((v) => v.studentId == s.id).fold(0, (sum, v) => sum + v.points);
      s.totalAchievementPoints = _achievements.where((a) => a.studentId == s.id).fold(0, (sum, a) => sum + a.points);
      return s;
    } catch (_) {
      return null;
    }
  }

  // Stats
  int get totalStudents {
    try {
      return (_dashboardData['total_students'] ?? _students.length).toInt();
    } catch (_) {
      return _students.length;
    }
  }
  
  int get totalViolations {
    try {
      return (_dashboardData['total_violations'] ?? _violations.length).toInt();
    } catch (_) {
      return _violations.length;
    }
  }
  
  int get totalAchievements {
    try {
      return (_dashboardData['total_achievements'] ?? _achievements.length).toInt();
    } catch (_) {
      return _achievements.length;
    }
  }
  
  int get totalViolationPoints {
    if (isStudent) return currentStudent?.totalViolationPoints ?? 0;
    return _dashboardData['total_violation_points'] ?? _violations.fold(0, (sum, v) => sum + v.points);
  }
  
  int get totalAchievementPoints {
    if (isStudent) return currentStudent?.totalAchievementPoints ?? 0;
    return _dashboardData['total_achievement_points'] ?? _achievements.fold(0, (sum, a) => sum + a.points);
  }

  // Recent activities (combined and sorted by date)
  List<Map<String, dynamic>> get recentActivities {
    if (_dashboardData.containsKey('recent_activities') && isAdmin) {
      final rawActivities = _dashboardData['recent_activities'];
      if (rawActivities is List) {
        try {
          return List<Map<String, dynamic>>.from(rawActivities.map((a) {
            if (a is Map) {
              final Map<String, dynamic> item = Map<String, dynamic>.from(a);
              try {
                item['date'] = DateTime.parse(item['date'].toString());
              } catch (_) {
                item['date'] = DateTime.now();
              }
              return item;
            }
            return <String, dynamic>{};
          }).where((item) => item.isNotEmpty));
        } catch (e) {
          debugPrint('Error parsing recent activities: $e');
        }
      }
    }
    
    final List<Map<String, dynamic>> activities = [];
    final studentId = currentStudent?.id;
    
    for (var v in _violations) {
      if (isStudent && v.studentId != studentId) continue;
      activities.add({
        'type': 'violation',
        'title': v.category,
        'subtitle': v.studentName,
        'className': v.className,
        'points': v.points,
        'date': v.date,
        'severity': v.severity,
        'description': v.description,
      });
    }
    for (var a in _achievements) {
      if (isStudent && a.studentId != studentId) continue;
      activities.add({
        'type': 'achievement',
        'title': a.title,
        'subtitle': a.studentName,
        'className': a.className,
        'points': a.points,
        'date': a.date,
        'level': a.level,
        'description': a.description,
      });
    }
    activities.sort((a, b) => (b['date'] as DateTime).compareTo(a['date'] as DateTime));
    return activities.take(10).toList();
  }

  // Violations for a student
  List<Violation> getStudentViolations(String studentId) {
    return _violations.where((v) => v.studentId == studentId).toList();
  }

  // Achievements for a student
  List<Achievement> getStudentAchievements(String studentId) {
    return _achievements.where((a) => a.studentId == studentId).toList();
  }

  // Weekly violation data for chart
  List<double> get weeklyViolationData {
    if (_dashboardData.containsKey('weekly_violations')) {
      final data = _dashboardData['weekly_violations'];
      if (data is List) {
        return data.map((v) => (v as num).toDouble()).toList();
      }
    }
    
    final now = DateTime.now();
    final List<double> data = List.filled(7, 0.0);
    for (var v in _violations) {
      final diff = now.difference(v.date).inDays;
      if (diff < 7 && diff >= 0) {
        data[6 - diff] += 1;
      }
    }
    return data;
  }

  // Weekly achievement data for chart
  List<double> get weeklyAchievementData {
    if (_dashboardData.containsKey('weekly_achievements')) {
      final data = _dashboardData['weekly_achievements'];
      if (data is List) {
        return data.map((a) => (a as num).toDouble()).toList();
      }
    }

    final now = DateTime.now();
    final List<double> data = List.filled(7, 0.0);
    for (var a in _achievements) {
      final diff = now.difference(a.date).inDays;
      if (diff < 7 && diff >= 0) {
        data[6 - diff] += 1;
      }
    }
    return data;
  }

  // Violation category distribution
  Map<String, int> get violationCategoryDistribution {
    if (_dashboardData.containsKey('violation_distribution')) {
      return Map<String, int>.from(_dashboardData['violation_distribution']);
    }
    final Map<String, int> dist = {};
    for (var v in _violations) {
      dist[v.category] = (dist[v.category] ?? 0) + 1;
    }
    return dist;
  }

  // Class stats
  Map<String, Map<String, int>> get classStats {
    if (_dashboardData.containsKey('class_stats')) {
      try {
        final Map<String, Map<String, int>> stats = {};
        for (var s in _dashboardData['class_stats']) {
          final className = (s['class_name'] ?? 'N/A').toString();
          stats[className] = {
            'students': (s['student_count'] ?? 0).toInt(),
            'violations': (s['total_violations'] ?? 0).toInt(),
            'achievements': (s['total_achievements'] ?? 0).toInt(),
          };
        }
        if (stats.isNotEmpty) return stats;
      } catch (e) {
        debugPrint('Error parsing class_stats: $e');
      }
    }
    final Map<String, Map<String, int>> stats = {};
    for (var s in _students) {
      if (!stats.containsKey(s.className)) {
        stats[s.className] = {'students': 0, 'violations': 0, 'achievements': 0};
      }
      stats[s.className]!['students'] = stats[s.className]!['students']! + 1;
      stats[s.className]!['violations'] = stats[s.className]!['violations']! + s.violationCount;
      stats[s.className]!['achievements'] = stats[s.className]!['achievements']! + s.achievementCount;
    }
    return stats;
  }

  // ============ DATA LOADING ============

  Future<void> _loadData() async {
    _isLoading = true;
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      _userName = prefs.getString('user_name') ?? '';
      _userEmail = prefs.getString('user_email') ?? '';
      _userRole = prefs.getString('user_role') ?? 'admin';
      
      if (_useApi) {
        await _loadFromApi();
      } else {
        _loadFromDummy();
      }
    } catch (e) {
      debugPrint('Error loading data: $e');
      // Fallback to dummy data if API fails completely
      if (_students.isEmpty) {
        _loadFromDummy();
      }
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> _loadFromApi() async {
    try {
      final studentsData = await ApiService.getStudents();
      _students = studentsData.map((s) => Student.fromJson(Map<String, dynamic>.from(s as Map))).toList();

      final violationsData = await ApiService.getViolations();
      _violations = violationsData.map((v) => Violation.fromJson(Map<String, dynamic>.from(v as Map))).toList();

      final achievementsData = await ApiService.getAchievements();
      _achievements = achievementsData.map((a) => Achievement.fromJson(Map<String, dynamic>.from(a as Map))).toList();

      // Load dashboard data for more efficient stats
      final dashboardResponse = await ApiService.getDashboard();
      if (dashboardResponse['success'] == true) {
        _dashboardData = Map<String, dynamic>.from(dashboardResponse['data'] as Map);
      }
    } catch (e) {
      rethrow;
    }
  }

  void _loadFromDummy() {
    _students = DummyData.getStudents();
    _violations = DummyData.getViolations();
    _achievements = DummyData.getAchievements();
  }

  Future<void> refreshData() async {
    await _loadData();
  }

  // ============ THEME & NAV ============

  void toggleTheme() {
    _isDarkMode = !_isDarkMode;
    notifyListeners();
  }

  void setCurrentIndex(int index) {
    _currentIndex = index;
    notifyListeners();
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  void setClassFilter(String className) {
    _selectedClassFilter = className;
    notifyListeners();
  }

  void setUserInfo(String name, String email) {
    _userName = name;
    _userEmail = email;
    notifyListeners();
  }

  // ============ STUDENT CRUD ============

  Future<void> addStudent({
    required String name,
    required String nis,
    required String className,
    required String gender,
  }) async {
    try {
      if (_useApi) {
        final result = await ApiService.createStudent({
          'name': name,
          'nis': nis,
          'class_name': className,
          'gender': gender,
        });
        if (result['success'] == true) {
          await refreshData();
        } else {
          throw Exception(result['message'] ?? 'Gagal menambah siswa');
        }
      } else {
        _students.add(Student(
          id: 's${DateTime.now().millisecondsSinceEpoch}',
          name: name,
          nis: nis,
          className: className,
          gender: gender,
        ));
        notifyListeners();
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<void> deleteStudent(String id) async {
    try {
      if (_useApi) {
        final result = await ApiService.deleteStudent(int.parse(id));
        if (result['success'] == true) {
          await refreshData();
        }
      } else {
        _students.removeWhere((s) => s.id == id);
        _violations.removeWhere((v) => v.studentId == id);
        _achievements.removeWhere((a) => a.studentId == id);
        notifyListeners();
      }
    } catch (e) {
      rethrow;
    }
  }

  // ============ VIOLATION CRUD ============

  Future<void> addViolation(Violation violation) async {
    try {
      if (_useApi) {
        final result = await ApiService.createViolation(violation.toJson());
        if (result['success'] == true) {
          await refreshData();
        } else {
          throw Exception(result['message'] ?? 'Gagal menambah pelanggaran');
        }
      } else {
        _violations.insert(0, violation);
        final student = _students.firstWhere((s) => s.id == violation.studentId);
        student.totalViolationPoints += violation.points;
        student.violationCount += 1;
        notifyListeners();
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<void> deleteViolation(String id) async {
    try {
      if (_useApi) {
        final result = await ApiService.deleteViolation(int.parse(id));
        if (result['success'] == true) {
          await refreshData();
        }
      } else {
        final violation = _violations.firstWhere((v) => v.id == id);
        final student = _students.firstWhere((s) => s.id == violation.studentId);
        student.totalViolationPoints -= violation.points;
        student.violationCount -= 1;
        _violations.removeWhere((v) => v.id == id);
        notifyListeners();
      }
    } catch (e) {
      rethrow;
    }
  }

  // ============ ACHIEVEMENT CRUD ============

  Future<void> addAchievement(Achievement achievement) async {
    try {
      if (_useApi) {
        final result = await ApiService.createAchievement(achievement.toJson());
        if (result['success'] == true) {
          await refreshData();
        } else {
          throw Exception(result['message'] ?? 'Gagal menambah prestasi');
        }
      } else {
        _achievements.insert(0, achievement);
        final student = _students.firstWhere((s) => s.id == achievement.studentId);
        student.totalAchievementPoints += achievement.points;
        student.achievementCount += 1;
        notifyListeners();
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<void> deleteAchievement(String id) async {
    try {
      if (_useApi) {
        final result = await ApiService.deleteAchievement(int.parse(id));
        if (result['success'] == true) {
          await refreshData();
        }
      } else {
        final achievement = _achievements.firstWhere((a) => a.id == id);
        final student = _students.firstWhere((s) => s.id == achievement.studentId);
        student.totalAchievementPoints -= achievement.points;
        student.achievementCount -= 1;
        _achievements.removeWhere((a) => a.id == id);
        notifyListeners();
      }
    } catch (e) {
      rethrow;
    }
  }

  // ============ AUTH ============

  Future<void> logout() async {
    await ApiService.logout();
    _students = [];
    _violations = [];
    _achievements = [];
    _currentIndex = 0;
    notifyListeners();
  }
}
