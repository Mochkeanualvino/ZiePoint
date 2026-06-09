import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/theme.dart';
import '../core/constants.dart';
import '../data/models/achievement.dart';
import '../providers/app_provider.dart';

class AddAchievementScreen extends StatefulWidget {
  const AddAchievementScreen({super.key});

  @override
  State<AddAchievementScreen> createState() => _AddAchievementScreenState();
}

class _AddAchievementScreenState extends State<AddAchievementScreen> {
  final _formKey = GlobalKey<FormState>();
  String? _selectedClass;
  String? _selectedStudentId;
  String? _selectedCategory;
  String? _selectedLevel;
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _verifiedByController = TextEditingController();
  DateTime _selectedDate = DateTime.now();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = Provider.of<AppProvider>(context, listen: false);
      _verifiedByController.text = provider.userName;
    });
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _verifiedByController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<AppProvider>(context);
    final isDark = provider.isDarkMode;
    final classes = provider.students.map((s) => s.className).toSet().toList()..sort();
    final filteredStudents = _selectedClass == null 
        ? provider.students 
        : provider.students.where((s) => s.className == _selectedClass).toList();

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Tambah Prestasi'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        physics: const BouncingScrollPhysics(),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: AppColors.achievementGradient,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.achievement.withOpacity(0.3),
                      blurRadius: 16,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: const Icon(Icons.emoji_events_rounded, color: Colors.white, size: 28),
                    ),
                    const SizedBox(width: 16),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Catat Prestasi',
                            style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w700),
                          ),
                          SizedBox(height: 4),
                          Text(
                            'Isi form berikut untuk mencatat prestasi siswa',
                            style: TextStyle(color: Colors.white70, fontSize: 12),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Class Selection
              _buildLabel('Pilih Kelas (Opsional)', isDark),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                value: _selectedClass,
                decoration: const InputDecoration(
                  hintText: 'Semua Kelas',
                  prefixIcon: Icon(Icons.class_outlined),
                ),
                isExpanded: true,
                items: [
                  const DropdownMenuItem(value: null, child: Text('Semua Kelas')),
                  ...classes.map((c) => DropdownMenuItem(value: c, child: Text(c))),
                ],
                onChanged: (val) {
                  setState(() {
                    _selectedClass = val;
                    _selectedStudentId = null;
                  });
                },
              ),
              const SizedBox(height: 20),

              // Student Selection
              _buildLabel('Pilih Siswa', isDark),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                value: _selectedStudentId,
                decoration: InputDecoration(
                  hintText: filteredStudents.isEmpty ? 'Data siswa belum tersedia' : 'Pilih siswa...',
                  prefixIcon: const Icon(Icons.person_outline_rounded),
                  enabled: filteredStudents.isNotEmpty,
                ),
                isExpanded: true,
                items: filteredStudents.isEmpty 
                  ? null 
                  : filteredStudents.map((s) {
                      return DropdownMenuItem(
                        value: s.id,
                        child: Text('${s.name} (${s.className})', style: const TextStyle(fontSize: 14)),
                      );
                    }).toList(),
                onChanged: (val) => setState(() => _selectedStudentId = val),
                validator: (val) => val == null ? 'Pilih siswa' : null,
              ),
              const SizedBox(height: 20),

              // Title
              _buildLabel('Judul Prestasi', isDark),
              const SizedBox(height: 8),
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(
                  hintText: 'Contoh: Juara 1 Olimpiade Matematika',
                  prefixIcon: Icon(Icons.title_rounded),
                ),
                validator: (val) => val == null || val.isEmpty ? 'Masukkan judul prestasi' : null,
              ),
              const SizedBox(height: 20),

              // Category & Level Row
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildLabel('Kategori', isDark),
                        const SizedBox(height: 8),
                        DropdownButtonFormField<String>(
                          value: _selectedCategory,
                          decoration: const InputDecoration(
                            hintText: 'Kategori...',
                            contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                          ),
                          isExpanded: true,
                          items: AppConstants.achievementCategories.map((c) {
                            return DropdownMenuItem(value: c, child: Text(c, style: const TextStyle(fontSize: 13)));
                          }).toList(),
                          onChanged: (val) => setState(() => _selectedCategory = val),
                          validator: (val) => val == null ? 'Pilih kategori' : null,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildLabel('Tingkat', isDark),
                        const SizedBox(height: 8),
                        DropdownButtonFormField<String>(
                          value: _selectedLevel,
                          decoration: const InputDecoration(
                            hintText: 'Tingkat...',
                            contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                          ),
                          isExpanded: true,
                          items: AppConstants.achievementLevels.map((l) {
                            return DropdownMenuItem(value: l, child: Text(l, style: const TextStyle(fontSize: 13)));
                          }).toList(),
                          onChanged: (val) => setState(() => _selectedLevel = val),
                          validator: (val) => val == null ? 'Pilih tingkat' : null,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Date
              _buildLabel('Tanggal', isDark),
              const SizedBox(height: 8),
              GestureDetector(
                onTap: () async {
                  final date = await showDatePicker(
                    context: context,
                    initialDate: _selectedDate,
                    firstDate: DateTime(2024),
                    lastDate: DateTime.now(),
                  );
                  if (date != null) setState(() => _selectedDate = date);
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.surfaceDark : AppColors.surface,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: isDark ? AppColors.borderDark : AppColors.border),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.calendar_today_rounded, size: 18,
                        color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondary),
                      const SizedBox(width: 12),
                      Text(
                        '${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}',
                        style: TextStyle(
                          fontSize: 14,
                          color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Verified By
              _buildLabel('Diverifikasi Oleh', isDark),
              const SizedBox(height: 8),
              TextFormField(
                controller: _verifiedByController,
                decoration: const InputDecoration(
                  hintText: 'Nama verifikator (contoh: Kepala Sekolah)',
                  prefixIcon: Icon(Icons.verified_user_outlined),
                ),
                validator: (val) => val == null || val.isEmpty ? 'Masukkan nama verifikator' : null,
              ),
              const SizedBox(height: 20),

              // Description
              _buildLabel('Deskripsi', isDark),
              const SizedBox(height: 8),
              TextFormField(
                controller: _descriptionController,
                maxLines: 3,
                decoration: const InputDecoration(
                  hintText: 'Deskripsikan prestasi yang diraih...',
                  prefixIcon: Padding(
                    padding: EdgeInsets.only(bottom: 48),
                    child: Icon(Icons.description_outlined),
                  ),
                ),
                validator: (val) => val == null || val.isEmpty ? 'Masukkan deskripsi' : null,
              ),
              const SizedBox(height: 12),

              // Points Preview
              if (_selectedCategory != null)
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: AppColors.achievement.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.achievement.withOpacity(0.2)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.info_outline_rounded, color: AppColors.achievement, size: 18),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          'Poin yang akan ditambahkan: +${AppConstants.achievementPoints[_selectedCategory] ?? 5} poin',
                          style: const TextStyle(fontSize: 12, color: AppColors.achievement, fontWeight: FontWeight.w500),
                        ),
                      ),
                    ],
                  ),
                ),
              const SizedBox(height: 32),

              // Submit Button
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _submit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.achievement,
                    foregroundColor: Colors.white,
                    disabledBackgroundColor: AppColors.achievement.withOpacity(0.6),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    elevation: 0,
                  ),
                  child: _isLoading
                      ? const SizedBox(width: 22, height: 22, child: CircularProgressIndicator(strokeWidth: 2.5, valueColor: AlwaysStoppedAnimation(Colors.white)))
                      : const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.save_rounded, size: 20),
                            SizedBox(width: 8),
                            Text('Simpan Prestasi', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
                          ],
                        ),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLabel(String text, bool isDark) {
    return Text(
      text,
      style: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
      ),
    );
  }

  void _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final provider = Provider.of<AppProvider>(context, listen: false);
      final student = provider.students.firstWhere((s) => s.id == _selectedStudentId);
      final points = AppConstants.achievementPoints[_selectedCategory] ?? 5;

      final achievement = Achievement(
        id: 'a${DateTime.now().millisecondsSinceEpoch}',
        studentId: student.id,
        studentName: student.name,
        className: student.className,
        category: _selectedCategory!,
        level: _selectedLevel!,
        points: points,
        title: _titleController.text,
        description: _descriptionController.text,
        date: _selectedDate,
        verifiedBy: _verifiedByController.text.trim(),
      );

      await provider.addAchievement(achievement);

      if (!mounted) return;
      Navigator.pop(context);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Prestasi berhasil dicatat'),
          backgroundColor: AppColors.achievement,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Gagal: $e'),
          backgroundColor: AppColors.violation,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }
}
