import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'core/theme.dart';
import 'providers/app_provider.dart';
import 'screens/splash_screen.dart';
import 'screens/login_screen.dart';
import 'screens/register_screen.dart';
import 'screens/dashboard_screen.dart';
import 'screens/student_list_screen.dart';
import 'screens/student_detail_screen.dart';
import 'screens/add_violation_screen.dart';
import 'screens/add_achievement_screen.dart';
import 'screens/add_student_screen.dart';
import 'screens/report_screen.dart';
import 'screens/scan_qr_screen.dart';
import 'data/models/student.dart';
import 'data/api_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('id_ID', null);
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
    ),
  );
  runApp(const EduTrackApp());
}

class EduTrackApp extends StatelessWidget {
  const EduTrackApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => AppProvider(),
      child: Consumer<AppProvider>(
        builder: (context, provider, _) {
          return MaterialApp(
            title: 'AMPoint',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.lightTheme(),
            darkTheme: AppTheme.darkTheme(),
            themeMode: provider.isDarkMode ? ThemeMode.dark : ThemeMode.light,
            initialRoute: '/',
            onGenerateRoute: (settings) {
              switch (settings.name) {
                case '/':
                  return _buildPageRoute(const SplashScreen());
                case '/login':
                  return _buildPageRoute(const LoginScreen());
                case '/register':
                  return _buildPageRoute(const RegisterScreen());
                case '/home':
                  return _buildPageRoute(const HomeScreen());
                case '/student-detail':
                  final student = settings.arguments as Student;
                  return _buildPageRoute(StudentDetailScreen(student: student));
                case '/add-violation':
                  return _buildPageRoute(const AddViolationScreen());
                case '/add-achievement':
                  return _buildPageRoute(const AddAchievementScreen());
                case '/add-student':
                  return _buildPageRoute(const AddStudentScreen());
                case '/scan-qr':
                  return _buildPageRoute(const ScanQrScreen());
                default:
                  return _buildPageRoute(const HomeScreen());
              }
            },
          );
        },
      ),
    );
  }

  PageRouteBuilder _buildPageRoute(Widget page) {
    return PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        return FadeTransition(
          opacity: CurvedAnimation(parent: animation, curve: Curves.easeInOut),
          child: child,
        );
      },
      transitionDuration: const Duration(milliseconds: 300),
    );
  }
}

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<AppProvider>(context);
    final isDark = provider.isDarkMode;

    return Scaffold(
      body: IndexedStack(
        index: provider.currentIndex == 2 ? 0 : provider.currentIndex > 2 ? provider.currentIndex - 1 : provider.currentIndex,
        children: [
          const DashboardScreen(),
          const StudentListScreen(),
          const ReportScreen(),
        ],
      ),
      floatingActionButton: provider.isAdmin ? Container(
        width: 58,
        height: 58,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: AppColors.primaryGradient,
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withOpacity(0.4),
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: FloatingActionButton(
          onPressed: () => _showAddOptions(context),
          elevation: 0,
          backgroundColor: Colors.transparent,
          child: const Icon(Icons.add_rounded, size: 28, color: Colors.white),
        ),
      ) : null,
      floatingActionButtonLocation: provider.isAdmin ? FloatingActionButtonLocation.centerDocked : null,
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: isDark ? AppColors.cardDark : AppColors.card,
          border: Border(
            top: BorderSide(
              color: isDark ? AppColors.borderDark : AppColors.border,
              width: 1,
            ),
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
            child: provider.isAdmin 
            ? Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildNavItem(context, 0, Icons.dashboard_rounded, 'Dashboard', provider),
                  _buildNavItem(context, 1, Icons.people_rounded, 'Siswa', provider),
                  const SizedBox(width: 56), // Space for FAB
                  _buildNavItem(context, 3, Icons.assessment_rounded, 'Laporan', provider),
                  _buildNavItem(context, 4, Icons.settings_rounded, 'Lainnya', provider),
                ],
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildNavItem(context, 0, Icons.dashboard_rounded, 'Dashboard', provider),
                  _buildNavItem(context, 4, Icons.settings_rounded, 'Lainnya', provider),
                ],
              ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(BuildContext context, int index, IconData icon, String label, AppProvider provider) {
    // Map nav index to actual screen index
    int screenIndex;
    if (index <= 1) {
      screenIndex = index;
    } else if (index == 3) {
      screenIndex = 3;
    } else {
      screenIndex = index;
    }

    final isSelected = provider.currentIndex == screenIndex;
    final isDark = provider.isDarkMode;
    final color = isSelected
        ? AppColors.primary
        : isDark ? AppColors.textSecondaryDark : AppColors.textSecondary;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          if (index == 4) {
            _showSettingsSheet(context, provider);
          } else {
            provider.setCurrentIndex(screenIndex);
          }
        },
        borderRadius: BorderRadius.circular(12),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary.withOpacity(0.1) : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 22, color: color),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(
                fontSize: 10,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                color: color,
              ),
            ),
          ],
        ),
      ),
    ));
  }

  void _showAddOptions(BuildContext context) {
    final isDark = Provider.of<AppProvider>(context, listen: false).isDarkMode;
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: isDark ? AppColors.cardDark : AppColors.card,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Handle bar
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: isDark ? AppColors.borderDark : AppColors.border,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                'Tambah Data Baru',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: _buildAddOption(
                      context,
                      icon: Icons.warning_amber_rounded,
                      label: 'Pelanggaran',
                      color: AppColors.violation,
                      gradient: AppColors.violationGradient,
                      onTap: () {
                        Navigator.pop(context);
                        Navigator.pushNamed(context, '/add-violation');
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildAddOption(
                      context,
                      icon: Icons.emoji_events_rounded,
                      label: 'Prestasi',
                      color: AppColors.achievement,
                      gradient: AppColors.achievementGradient,
                      onTap: () {
                        Navigator.pop(context);
                        Navigator.pushNamed(context, '/add-achievement');
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildAddOption(
                      context,
                      icon: Icons.person_add_rounded,
                      label: 'Siswa',
                      color: AppColors.primary,
                      gradient: AppColors.primaryGradient,
                      onTap: () {
                        Navigator.pop(context);
                        Navigator.pushNamed(context, '/add-student');
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
            ],
          ),
        );
      },
    );
  }

  Widget _buildAddOption(BuildContext context, {
    required IconData icon,
    required String label,
    required Color color,
    required LinearGradient gradient,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 24),
        decoration: BoxDecoration(
          gradient: gradient,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.3),
              blurRadius: 12,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Column(
          children: [
            Icon(icon, color: Colors.white, size: 32),
            const SizedBox(height: 8),
            Text(
              label,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    ));
  }

  void _showSettingsSheet(BuildContext context, AppProvider provider) {
    final isDark = provider.isDarkMode;
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: isDark ? AppColors.cardDark : AppColors.card,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 40, height: 4,
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.borderDark : AppColors.border,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  'Pengaturan',
                  style: TextStyle(
                    fontSize: 18, fontWeight: FontWeight.w700,
                    color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 20),
                _buildSettingsTile(
                  isDark: isDark,
                  icon: isDark ? Icons.light_mode_rounded : Icons.dark_mode_rounded,
                  title: 'Mode Gelap',
                  trailing: Switch(
                    value: isDark,
                    onChanged: (_) => provider.toggleTheme(),
                    activeColor: AppColors.primary,
                  ),
                ),
                _buildSettingsTile(
                  isDark: isDark,
                  icon: Icons.refresh_rounded,
                  title: 'Refresh Data',
                  trailing: Icon(
                    Icons.chevron_right_rounded,
                    color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondary,
                  ),
                  onTap: () {
                    Navigator.pop(context);
                    provider.refreshData();
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: const Text('Data berhasil diperbarui'),
                        backgroundColor: AppColors.achievement,
                        behavior: SnackBarBehavior.floating,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                    );
                  },
                ),
                _buildSettingsTile(
                  isDark: isDark,
                  icon: Icons.info_outline_rounded,
                  title: 'Tentang Aplikasi',
                  trailing: Icon(
                    Icons.chevron_right_rounded,
                    color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 8),
                // Logout Button
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton.icon(
                    onPressed: () async {
                      final navigator = Navigator.of(context, rootNavigator: true);
                      navigator.pop(); // Close bottom sheet
                      await provider.logout();
                      navigator.pushNamedAndRemoveUntil('/login', (route) => false);
                    },
                    icon: const Icon(Icons.logout_rounded, size: 20),
                    label: const Text('Keluar', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.violation.withOpacity(0.1),
                      foregroundColor: AppColors.violation,
                      elevation: 0,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'AMPoint v1.0.0',
                  style: TextStyle(
                    fontSize: 12,
                    color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 10),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildSettingsTile({
    required bool isDark,
    required IconData icon,
    required String title,
    required Widget trailing,
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: isDark ? AppColors.surfaceDark : AppColors.surface,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Icon(icon, size: 22, color: AppColors.primary),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  fontSize: 14, fontWeight: FontWeight.w500,
                  color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
                ),
              ),
            ),
            trailing,
          ],
        ),
      ),
    );
  }
}
