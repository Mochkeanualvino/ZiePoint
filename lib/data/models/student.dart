class Student {
  final String id;
  final String name;
  final String nis;
  final String className;
  final String gender;
  final String? photoUrl;
  int totalViolationPoints;
  int totalAchievementPoints;
  int violationCount;
  int achievementCount;

  Student({
    required this.id,
    required this.name,
    required this.nis,
    required this.className,
    required this.gender,
    this.photoUrl,
    this.totalViolationPoints = 0,
    this.totalAchievementPoints = 0,
    this.violationCount = 0,
    this.achievementCount = 0,
  });

  factory Student.fromJson(Map<String, dynamic> json) {
    return Student(
      id: json['id'].toString(),
      name: json['name'] ?? '',
      nis: json['nis'] ?? '',
      className: json['class_name'] ?? '',
      gender: json['gender'] ?? 'L',
      photoUrl: json['photo_url'],
      totalViolationPoints: json['total_violation_points'] ?? 0,
      totalAchievementPoints: json['total_achievement_points'] ?? 0,
      violationCount: json['violation_count'] ?? 0,
      achievementCount: json['achievement_count'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'nis': nis,
      'class_name': className,
      'gender': gender,
      'photo_url': photoUrl,
    };
  }

  int get behaviorScore => 100 - totalViolationPoints + totalAchievementPoints;

  String get behaviorGrade {
    final score = behaviorScore;
    if (score >= 90) return 'A';
    if (score >= 80) return 'B';
    if (score >= 70) return 'C';
    if (score >= 60) return 'D';
    return 'E';
  }

  String get initials {
    if (name.isEmpty) return '??';
    final parts = name.trim().split(' ');
    if (parts.length >= 2 && parts[0].isNotEmpty && parts[1].isNotEmpty) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return name.length >= 2 ? name.substring(0, 2).toUpperCase() : name.toUpperCase();
  }
}
