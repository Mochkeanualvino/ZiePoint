import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../core/theme.dart';
import '../core/constants.dart';
import '../providers/app_provider.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<AppProvider>(context);
    return provider.isStudent
        ? _StudentDashboard(provider: provider)
        : _TeacherDashboard(provider: provider);
  }
}

// ===================== STUDENT DASHBOARD =====================
class _StudentDashboard extends StatelessWidget {
  final AppProvider provider;
  const _StudentDashboard({required this.provider});

  @override
  Widget build(BuildContext context) {
    final isDark = provider.isDarkMode;
    final student = provider.currentStudent;

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(10),
                              child: Image.asset('assets/images/logo.png', width: 32, height: 32, errorBuilder: (c,e,s) => const Icon(Icons.location_on_rounded, color: AppColors.primary)),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text('Dashboard Siswa',
                                  style: Theme.of(context).textTheme.headlineMedium, overflow: TextOverflow.ellipsis),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(DateFormat('EEEE, d MMMM yyyy', 'id_ID').format(DateTime.now()),
                            style: Theme.of(context).textTheme.bodyMedium),
                      ],
                    ),
                  ),
                  Row(children: [
                    _iconBtn(context, isDark,
                        icon: isDark ? Icons.light_mode_rounded : Icons.dark_mode_rounded,
                        onTap: () => provider.toggleTheme()),
                    const SizedBox(width: 8),
                    _iconBtn(context, isDark,
                        icon: Icons.notifications_none_rounded,
                        onTap: () => _showNotificationsSheet(context, provider, isDark),
                        badge: provider.recentActivities.isNotEmpty ? provider.recentActivities.length : null),
                  ]),
                ],
              ),
              const SizedBox(height: 20),

              // QR Code Card
              if (student != null)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    gradient: AppColors.primaryGradient,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [BoxShadow(color: AppColors.primary.withOpacity(0.3), blurRadius: 20, offset: const Offset(0, 8))],
                  ),
                  child: Column(
                    children: [
                      const Text('QR Code Kamu', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w700)),
                      const SizedBox(height: 4),
                      Text('Tunjukkan ke Guru untuk input poin', style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 12)),
                      const SizedBox(height: 16),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
                        child: QrImageView(data: student.nis, version: QrVersions.auto, size: 180, backgroundColor: Colors.white),
                      ),
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), borderRadius: BorderRadius.circular(10)),
                        child: Text('NIS: ${student.nis} • ${student.className}',
                            style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w600)),
                      ),
                    ],
                  ),
                ),
              const SizedBox(height: 20),

              // Points Cards
              Row(
                children: [
                  Expanded(child: _pointCard('Poin Pelanggaran', '${provider.totalViolationPoints}', Icons.warning_amber_rounded, AppColors.violationGradient)),
                  const SizedBox(width: 12),
                  Expanded(child: _pointCard('Poin Prestasi', '${provider.totalAchievementPoints}', Icons.emoji_events_rounded, AppColors.achievementGradient)),
                ],
              ),
              const SizedBox(height: 20),

              // Behavior Score
              if (student != null)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.cardDark : AppColors.card,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: isDark ? AppColors.borderDark : AppColors.border),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 56, height: 56,
                        decoration: BoxDecoration(
                          color: _gradeColor(student.behaviorGrade).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Center(child: Text(student.behaviorGrade,
                            style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800, color: _gradeColor(student.behaviorGrade)))),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Nilai Perilaku', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600,
                                color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary)),
                            Text('Skor: ${student.behaviorScore}', style: TextStyle(fontSize: 12,
                                color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondary)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              const SizedBox(height: 20),

              // Menu: Jenis Pelanggaran
              _menuCard(context, isDark,
                  icon: Icons.gavel_rounded,
                  title: 'Jenis Pelanggaran',
                  subtitle: '${AppConstants.violationCategories.length} kategori pelanggaran',
                  color: AppColors.violation,
                  onTap: () => Navigator.push(context, MaterialPageRoute(
                      builder: (_) => const _CategoryListPage(isViolation: true)))),
              const SizedBox(height: 12),

              // Menu: Jenis Prestasi
              _menuCard(context, isDark,
                  icon: Icons.workspace_premium_rounded,
                  title: 'Kriteria Jenis Prestasi',
                  subtitle: '${AppConstants.achievementCategories.length} kategori prestasi',
                  color: AppColors.achievement,
                  onTap: () => Navigator.push(context, MaterialPageRoute(
                      builder: (_) => const _CategoryListPage(isViolation: false)))),
              const SizedBox(height: 20),

              // Recent Activity
              Text('Riwayat Aktivitas', style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 12),
              if (provider.recentActivities.isEmpty)
                Center(child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Text('Belum ada aktivitas', style: TextStyle(color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondary)),
                ))
              else
                ...provider.recentActivities.map((a) => _activityTile(context, a, isDark)),
              const SizedBox(height: 80),
            ],
          ),
        ),
      ),
    );
  }

  Widget _pointCard(String title, String value, IconData icon, LinearGradient gradient) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(gradient: gradient, borderRadius: BorderRadius.circular(16),
          boxShadow: [BoxShadow(color: gradient.colors.first.withOpacity(0.3), blurRadius: 12, offset: const Offset(0, 6))]),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), borderRadius: BorderRadius.circular(10)),
            child: Icon(icon, color: Colors.white, size: 20)),
        const SizedBox(height: 12),
        Text(value, style: const TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.w800)),
        const SizedBox(height: 4),
        Text(title, style: TextStyle(color: Colors.white.withOpacity(0.85), fontSize: 11, fontWeight: FontWeight.w500)),
      ]),
    );
  }

  Color _gradeColor(String g) => switch (g) { 'A' => AppColors.achievement, 'B' => AppColors.primary, 'C' => Colors.orange, _ => AppColors.violation };

  Widget _menuCard(BuildContext context, bool isDark,
      {required IconData icon, required String title, required String subtitle, required Color color, required VoidCallback onTap}) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isDark ? AppColors.cardDark : AppColors.card,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: isDark ? AppColors.borderDark : AppColors.border),
          ),
          child: Row(children: [
            Container(
              width: 48, height: 48,
              decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(14)),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(width: 14),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(title, style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary)),
              const SizedBox(height: 2),
              Text(subtitle, style: TextStyle(fontSize: 12, color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondary)),
            ])),
            Icon(Icons.chevron_right_rounded, color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondary),
          ]),
        ),
      ),
    );
  }
}

// ===================== CATEGORY LIST PAGE =====================
class _CategoryListPage extends StatelessWidget {
  final bool isViolation;
  const _CategoryListPage({required this.isViolation});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final categories = isViolation ? AppConstants.violationCategories : AppConstants.achievementCategories;
    final pointsMap = isViolation ? AppConstants.violationPoints : AppConstants.achievementPoints;
    final descriptionsMap = isViolation ? AppConstants.violationDescriptions : AppConstants.achievementDescriptions;
    final color = isViolation ? AppColors.violation : AppColors.achievement;
    final title = isViolation ? 'Pelanggaran' : 'Prestasi';

    return Scaffold(
      backgroundColor: isDark ? AppColors.backgroundDark : const Color(0xFFF5F6FA),
      appBar: AppBar(
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w700)),
        centerTitle: true,
        elevation: 0,
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: ListView.builder(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        itemCount: categories.length,
        itemBuilder: (context, index) {
          final cat = categories[index];
          final points = pointsMap[cat] ?? 5;
          final desc = descriptionsMap[cat] ?? '';
          return Container(
            margin: const EdgeInsets.only(bottom: 10),
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
            decoration: BoxDecoration(
              color: isDark ? AppColors.cardDark : Colors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: isDark ? AppColors.borderDark : const Color(0xFFE8EAF0)),
              boxShadow: isDark ? [] : [
                BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8, offset: const Offset(0, 2)),
              ],
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(cat, style: TextStyle(
                        fontSize: 14, fontWeight: FontWeight.w700,
                        color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
                      )),
                      if (desc.isNotEmpty) ...[
                        const SizedBox(height: 4),
                        Text(desc, style: TextStyle(
                          fontSize: 12, height: 1.4,
                          color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondary,
                        )),
                      ],
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Container(
                  width: 46, height: 46,
                  decoration: BoxDecoration(
                    color: color,
                    shape: BoxShape.circle,
                    boxShadow: [BoxShadow(color: color.withOpacity(0.35), blurRadius: 8, offset: const Offset(0, 3))],
                  ),
                  child: Center(
                    child: Text(
                      '+$points',
                      style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w800),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

// ===================== TEACHER DASHBOARD =====================
class _TeacherDashboard extends StatelessWidget {
  final AppProvider provider;
  const _TeacherDashboard({required this.provider});

  @override
  Widget build(BuildContext context) {
    final isDark = provider.isDarkMode;

    return Scaffold(
      body: SafeArea(
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            // Header
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Row(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: Image.asset('assets/images/logo.png', width: 32, height: 32, errorBuilder: (c,e,s) => const Icon(Icons.location_on_rounded, color: AppColors.primary)),
                          ),
                          const SizedBox(width: 12),
                          Text('Dashboard Guru', style: Theme.of(context).textTheme.headlineMedium),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(DateFormat('EEEE, d MMMM yyyy', 'id_ID').format(DateTime.now()), style: Theme.of(context).textTheme.bodyMedium),
                    ]),
                    Row(children: [
                      _iconBtn(context, isDark, icon: isDark ? Icons.light_mode_rounded : Icons.dark_mode_rounded, onTap: () => provider.toggleTheme()),
                      const SizedBox(width: 8),
                      _iconBtn(context, isDark, icon: Icons.notifications_none_rounded,
                          onTap: () => _showNotificationsSheet(context, provider, isDark),
                          badge: provider.recentActivities.isNotEmpty ? provider.recentActivities.length.clamp(0, 9) : null),
                    ]),
                  ],
                ),
              ),
            ),

            // Scan QR Button
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(20),
                    onTap: () => Navigator.pushNamed(context, '/scan-qr'),
                    child: Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        gradient: AppColors.primaryGradient,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [BoxShadow(color: AppColors.primary.withOpacity(0.3), blurRadius: 20, offset: const Offset(0, 8))],
                      ),
                      child: Row(children: [
                        Container(padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), borderRadius: BorderRadius.circular(16)),
                            child: const Icon(Icons.qr_code_scanner_rounded, color: Colors.white, size: 32)),
                        const SizedBox(width: 16),
                        const Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                          Text('Scan QR Siswa', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w700)),
                          SizedBox(height: 4),
                          Text('Input poin pelanggaran atau prestasi siswa', style: TextStyle(color: Colors.white70, fontSize: 12)),
                        ])),
                        const Icon(Icons.arrow_forward_ios_rounded, color: Colors.white70, size: 18),
                      ]),
                    ),
                  ),
                ),
              ),
            ),

            // Stats Cards
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                child: Row(children: [
                  Expanded(child: _statCard(Icons.people_rounded, 'Total Siswa', '${provider.totalStudents}', AppColors.primaryGradient)),
                  const SizedBox(width: 12),
                  Expanded(child: _statCard(Icons.warning_amber_rounded, 'Pelanggaran', '${provider.totalViolations}', AppColors.violationGradient)),
                  const SizedBox(width: 12),
                  Expanded(child: _statCard(Icons.emoji_events_rounded, 'Prestasi', '${provider.totalAchievements}', AppColors.achievementGradient)),
                ]),
              ),
            ),

            // Quick Actions
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                child: Row(children: [
                  Expanded(child: _quickAction(context, Icons.add_circle_outline_rounded, 'Tambah\nPelanggaran', AppColors.violation, isDark,
                      () => Navigator.pushNamed(context, '/add-violation'))),
                  const SizedBox(width: 12),
                  Expanded(child: _quickAction(context, Icons.star_outline_rounded, 'Tambah\nPrestasi', AppColors.achievement, isDark,
                      () => Navigator.pushNamed(context, '/add-achievement'))),
                  const SizedBox(width: 12),
                  Expanded(child: _quickAction(context, Icons.person_add_rounded, 'Tambah\nSiswa', AppColors.primary, isDark,
                      () => Navigator.pushNamed(context, '/add-student'))),
                ]),
              ),
            ),

            // Chart
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(color: isDark ? AppColors.cardDark : AppColors.card, borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: isDark ? AppColors.borderDark : AppColors.border)),
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                      Text('Tren Mingguan', style: Theme.of(context).textTheme.titleLarge),
                      Row(children: [_legendDot(AppColors.violation, 'Pelanggaran'), const SizedBox(width: 12), _legendDot(AppColors.achievement, 'Prestasi')]),
                    ]),
                    const SizedBox(height: 24),
                    SizedBox(height: 180, child: _chart(provider, isDark)),
                  ]),
                ),
              ),
            ),

            // Recent Activities Header
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 24, 20, 8),
                child: Text('Aktivitas Terbaru', style: Theme.of(context).textTheme.titleLarge),
              ),
            ),

            // Activity List
            SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  final activities = provider.recentActivities;
                  if (index >= activities.length) return null;
                  return Padding(
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 10),
                    child: _activityTile(context, activities[index], isDark),
                  );
                },
                childCount: provider.recentActivities.length,
              ),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 100)),
          ],
        ),
      ),
    );
  }

  Widget _statCard(IconData icon, String title, String value, LinearGradient gradient) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(gradient: gradient, borderRadius: BorderRadius.circular(16),
          boxShadow: [BoxShadow(color: gradient.colors.first.withOpacity(0.3), blurRadius: 12, offset: const Offset(0, 6))]),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), borderRadius: BorderRadius.circular(10)),
            child: Icon(icon, color: Colors.white, size: 20)),
        const SizedBox(height: 12),
        Text(value, style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.w800)),
        const SizedBox(height: 4),
        Text(title, style: TextStyle(color: Colors.white.withOpacity(0.85), fontSize: 11, fontWeight: FontWeight.w500)),
      ]),
    );
  }

  Widget _quickAction(BuildContext context, IconData icon, String label, Color color, bool isDark, VoidCallback onTap) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(color: isDark ? AppColors.cardDark : AppColors.card, borderRadius: BorderRadius.circular(16),
            border: Border.all(color: isDark ? AppColors.borderDark : AppColors.border)),
        child: Column(children: [
          Container(padding: const EdgeInsets.all(10), decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
              child: Icon(icon, color: color, size: 24)),
          const SizedBox(height: 8),
          Text(label, textAlign: TextAlign.center, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600,
              color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary, height: 1.3)),
        ]),
      ),
    ));
  }

  Widget _legendDot(Color color, String label) {
    return Row(mainAxisSize: MainAxisSize.min, children: [
      Container(width: 8, height: 8, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
      const SizedBox(width: 4),
      Text(label, style: const TextStyle(fontSize: 10)),
    ]);
  }

  Widget _chart(AppProvider provider, bool isDark) {
    final days = ['Sen', 'Sel', 'Rab', 'Kam', 'Jum', 'Sab', 'Min'];
    final vData = provider.weeklyViolationData;
    final aData = provider.weeklyAchievementData;
    return BarChart(BarChartData(
      alignment: BarChartAlignment.spaceAround, maxY: 5,
      barTouchData: BarTouchData(enabled: true),
      titlesData: FlTitlesData(
        show: true,
        bottomTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, reservedSize: 28,
            getTitlesWidget: (v, _) => Padding(padding: const EdgeInsets.only(top: 8),
                child: Text(days[v.toInt()], style: TextStyle(fontSize: 10, color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondary))))),
        leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
      ),
      gridData: const FlGridData(show: false),
      borderData: FlBorderData(show: false),
      barGroups: List.generate(7, (i) => BarChartGroupData(x: i, barRods: [
        BarChartRodData(toY: vData[i], color: AppColors.violation, width: 8, borderRadius: const BorderRadius.vertical(top: Radius.circular(4))),
        BarChartRodData(toY: aData[i], color: AppColors.achievement, width: 8, borderRadius: const BorderRadius.vertical(top: Radius.circular(4))),
      ])),
    ));
  }
}

// ===================== SHARED HELPERS =====================

Widget _iconBtn(BuildContext context, bool isDark, {required IconData icon, required VoidCallback onTap, int? badge}) {
  return GestureDetector(
    behavior: HitTestBehavior.opaque,
    onTap: onTap,
    child: Stack(children: [
      Container(width: 44, height: 44, decoration: BoxDecoration(
          color: isDark ? AppColors.cardDark : AppColors.card, borderRadius: BorderRadius.circular(12),
          border: Border.all(color: isDark ? AppColors.borderDark : AppColors.border)),
          child: Icon(icon, size: 22)),
      if (badge != null) Positioned(right: 0, top: 0, child: Container(width: 18, height: 18,
          decoration: const BoxDecoration(color: AppColors.violation, shape: BoxShape.circle),
          child: Center(child: Text('$badge', style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w700))))),
    ]),
  );
}

Widget _activityTile(BuildContext context, Map<String, dynamic> activity, bool isDark) {
  final isV = activity['type'] == 'violation';
  final color = isV ? AppColors.violation : AppColors.achievement;
  final diff = DateTime.now().difference(activity['date'] as DateTime);
  final timeAgo = diff.inDays > 0 ? '${diff.inDays} hari lalu' : diff.inHours > 0 ? '${diff.inHours} jam lalu' : diff.inMinutes > 0 ? '${diff.inMinutes} menit lalu' : 'Baru saja';
  final title = activity['title'] ?? 'Tidak diketahui';
  final subtitle = activity['subtitle'] ?? '';
  final className = activity['className'] ?? '';
  final description = activity['description'] ?? '';

  return Container(
    margin: const EdgeInsets.only(bottom: 10),
    padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
    decoration: BoxDecoration(
      color: isDark ? AppColors.cardDark : Colors.white,
      borderRadius: BorderRadius.circular(14),
      border: Border.all(color: isDark ? AppColors.borderDark : const Color(0xFFE8EAF0)),
      boxShadow: isDark ? [] : [
        BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8, offset: const Offset(0, 2)),
      ],
    ),
    child: Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: TextStyle(
                fontSize: 14, fontWeight: FontWeight.w700,
                color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
              )),
              const SizedBox(height: 4),
              if (subtitle.isNotEmpty || className.isNotEmpty)
                Text(subtitle.isNotEmpty ? '$subtitle • $className' : className, style: TextStyle(
                  fontSize: 12, height: 1.4,
                  color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondary,
                )),
              if (description.isNotEmpty) ...[
                const SizedBox(height: 4),
                Text('"$description"', style: TextStyle(
                  fontSize: 12, fontStyle: FontStyle.italic,
                  color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondary,
                )),
              ],
              const SizedBox(height: 6),
              Text(timeAgo, style: TextStyle(
                fontSize: 11, fontStyle: FontStyle.italic,
                color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondary,
              )),
            ],
          ),
        ),
        const SizedBox(width: 12),
        Container(
          width: 46, height: 46,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
            boxShadow: [BoxShadow(color: color.withOpacity(0.35), blurRadius: 8, offset: const Offset(0, 3))],
          ),
          child: Center(
            child: Text(
              '${isV ? '-' : '+'}${activity['points'] ?? 0}',
              style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w800),
            ),
          ),
        ),
      ],
    ),
  );
}

// ===================== NOTIFICATION BOTTOM SHEET =====================

void _showNotificationsSheet(BuildContext context, AppProvider provider, bool isDark) {
  final activities = provider.recentActivities;
  final isStudent = provider.isStudent;

  // For teachers: add warning notifications for students with low scores
  final List<Map<String, dynamic>> notifications = [];

  if (!isStudent) {
    // Warning: students with behavior score below 60
    for (var s in provider.students) {
      if (s.behaviorScore < 60) {
        notifications.add({
          'type': 'warning',
          'title': 'Peringatan Skor Rendah',
          'subtitle': '${s.name} (${s.className})',
          'description': 'Skor perilaku: ${s.behaviorScore}. Perlu perhatian khusus.',
          'points': s.behaviorScore,
          'date': DateTime.now(),
        });
      }
    }
  }

  // Add recent activities as notifications
  notifications.addAll(activities);

  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (ctx) {
      return DraggableScrollableSheet(
        initialChildSize: 0.65,
        maxChildSize: 0.9,
        minChildSize: 0.3,
        builder: (_, scrollController) {
          return Container(
            decoration: BoxDecoration(
              color: isDark ? AppColors.backgroundDark : Colors.white,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
            ),
            child: Column(
              children: [
                // Handle bar
                Container(
                  margin: const EdgeInsets.only(top: 12),
                  width: 40, height: 4,
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.borderDark : AppColors.border,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                // Title
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(Icons.notifications_rounded, color: AppColors.primary, size: 22),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Notifikasi',
                              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700,
                                color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary)),
                            Text(
                              isStudent
                                  ? 'Riwayat pelanggaran & prestasi kamu'
                                  : 'Aktivitas terbaru & peringatan siswa',
                              style: TextStyle(fontSize: 12,
                                color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondary),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text('${notifications.length}',
                          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.primary)),
                      ),
                    ],
                  ),
                ),
                Divider(color: isDark ? AppColors.borderDark : AppColors.border, height: 1),
                // List
                Expanded(
                  child: notifications.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.notifications_off_outlined, size: 56,
                                color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondary),
                              const SizedBox(height: 12),
                              Text('Belum ada notifikasi',
                                style: TextStyle(fontSize: 14,
                                  color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondary)),
                            ],
                          ),
                        )
                      : ListView.builder(
                          controller: scrollController,
                          padding: const EdgeInsets.fromLTRB(16, 8, 16, 20),
                          itemCount: notifications.length,
                          itemBuilder: (context, index) {
                            final notif = notifications[index];
                            return _buildNotifItem(context, notif, isDark, isStudent);
                          },
                        ),
                ),
              ],
            ),
          );
        },
      );
    },
  );
}

Widget _buildNotifItem(BuildContext context, Map<String, dynamic> notif, bool isDark, bool isStudent) {
  final type = notif['type'] ?? 'unknown';
  final isViolation = type == 'violation';
  final isWarning = type == 'warning';
  final isAchievement = type == 'achievement';

  Color color;
  IconData icon;
  String label;

  if (isViolation) {
    color = AppColors.violation;
    icon = Icons.warning_amber_rounded;
    label = 'Pelanggaran';
  } else if (isAchievement) {
    color = AppColors.achievement;
    icon = Icons.emoji_events_rounded;
    label = 'Prestasi';
  } else if (isWarning) {
    color = Colors.orange;
    icon = Icons.report_problem_rounded;
    label = 'Peringatan';
  } else {
    color = AppColors.primary;
    icon = Icons.info_outline_rounded;
    label = 'Info';
  }

  final title = notif['title'] ?? '';
  final subtitle = notif['subtitle'] ?? '';
  final description = notif['description'] ?? '';
  final points = notif['points'];
  final date = notif['date'] as DateTime?;

  String timeAgo = '';
  if (date != null) {
    final diff = DateTime.now().difference(date);
    timeAgo = diff.inDays > 0 ? '${diff.inDays} hari lalu'
        : diff.inHours > 0 ? '${diff.inHours} jam lalu'
        : diff.inMinutes > 0 ? '${diff.inMinutes} menit lalu'
        : 'Baru saja';
  }

  return GestureDetector(
    onTap: () => _showNotifDetail(context, notif, isDark, color, icon, label),
    child: Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isDark ? AppColors.cardDark : Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withOpacity(0.3)),
        boxShadow: isDark ? [] : [
          BoxShadow(color: color.withOpacity(0.08), blurRadius: 8, offset: const Offset(0, 2)),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 44, height: 44,
            decoration: BoxDecoration(
              color: color.withOpacity(0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 22),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(color: color.withOpacity(0.12), borderRadius: BorderRadius.circular(6)),
                      child: Text(label, style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: color)),
                    ),
                    const Spacer(),
                    if (timeAgo.isNotEmpty)
                      Text(timeAgo, style: TextStyle(fontSize: 10, color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondary)),
                  ],
                ),
                const SizedBox(height: 6),
                Text(title, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600,
                    color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary)),
                if (subtitle.isNotEmpty)
                  Text(subtitle, style: TextStyle(fontSize: 11,
                      color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondary)),
              ],
            ),
          ),
          if (points != null && !isWarning) ...[
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(20)),
              child: Text(
                '${isViolation ? '-' : '+'}$points',
                style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w800),
              ),
            ),
          ],
          const SizedBox(width: 4),
          Icon(Icons.chevron_right_rounded, size: 18,
            color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondary),
        ],
      ),
    ),
  );
}

void _showNotifDetail(BuildContext context, Map<String, dynamic> notif, bool isDark, Color color, IconData icon, String label) {
  final title = notif['title'] ?? '';
  final subtitle = notif['subtitle'] ?? '';
  final description = notif['description'] ?? '';
  final points = notif['points'];
  final severity = notif['severity'] ?? '';
  final className = notif['className'] ?? '';
  final date = notif['date'] as DateTime?;

  showDialog(
    context: context,
    builder: (ctx) {
      return AlertDialog(
        backgroundColor: isDark ? AppColors.cardDark : Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        contentPadding: const EdgeInsets.all(24),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Icon
            Container(
              width: 64, height: 64,
              decoration: BoxDecoration(
                color: color.withOpacity(0.12),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 32),
            ),
            const SizedBox(height: 16),
            // Label badge
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(color: color.withOpacity(0.12), borderRadius: BorderRadius.circular(20)),
              child: Text(label, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: color)),
            ),
            const SizedBox(height: 14),
            // Title
            Text(title, textAlign: TextAlign.center,
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700,
                color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary)),
            const SizedBox(height: 8),
            // Subtitle & class
            if (subtitle.isNotEmpty || className.isNotEmpty)
              Text(
                [subtitle, className].where((s) => s.isNotEmpty).join(' • '),
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 13, color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondary),
              ),
            // Points
            if (points != null) ...[
              const SizedBox(height: 14),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(30)),
                child: Text(
                  notif['type'] == 'warning' ? 'Skor: $points' : '${notif['type'] == 'violation' ? '-' : '+'}$points poin',
                  style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w800),
                ),
              ),
            ],
            // Severity
            if (severity.isNotEmpty) ...[
              const SizedBox(height: 10),
              Text('Tingkat: $severity', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600,
                  color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondary)),
            ],
            // Description
            if (description.isNotEmpty) ...[
              const SizedBox(height: 14),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: isDark ? AppColors.surfaceDark : AppColors.surface,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(description, textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 13, height: 1.5,
                    color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondary)),
              ),
            ],
            // Date
            if (date != null) ...[
              const SizedBox(height: 10),
              Text(
                '${date.day}/${date.month}/${date.year} ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}',
                style: TextStyle(fontSize: 11, color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondary),
              ),
            ],
          ],
        ),
        actions: [
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => Navigator.pop(ctx),
              style: ElevatedButton.styleFrom(
                backgroundColor: color,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
              child: const Text('Tutup', style: TextStyle(fontWeight: FontWeight.w600)),
            ),
          ),
        ],
      );
    },
  );
}
