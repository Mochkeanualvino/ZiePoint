import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/theme.dart';
import '../core/constants.dart';
import '../providers/app_provider.dart';

class AddStudentScreen extends StatefulWidget {
  const AddStudentScreen({super.key});

  @override
  State<AddStudentScreen> createState() => _AddStudentScreenState();
}

class _AddStudentScreenState extends State<AddStudentScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _nisController = TextEditingController();
  String? _selectedClass;
  String _selectedGender = 'L';
  bool _isLoading = false;

  @override
  void dispose() {
    _nameController.dispose();
    _nisController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<AppProvider>(context);
    final isDark = provider.isDarkMode;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Tambah Siswa'),
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
                  gradient: AppColors.primaryGradient,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withOpacity(0.3),
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
                      child: const Icon(Icons.person_add_rounded, color: Colors.white, size: 28),
                    ),
                    const SizedBox(width: 16),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Tambah Siswa Baru',
                            style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w700),
                          ),
                          SizedBox(height: 4),
                          Text(
                            'Isi data siswa baru yang akan didaftarkan',
                            style: TextStyle(color: Colors.white70, fontSize: 12),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Nama
              _buildLabel('Nama Lengkap', isDark),
              const SizedBox(height: 8),
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  hintText: 'Masukkan nama lengkap siswa',
                  prefixIcon: Icon(Icons.person_outline_rounded),
                ),
                validator: (val) => val == null || val.isEmpty ? 'Masukkan nama siswa' : null,
              ),
              const SizedBox(height: 20),

              // NIS
              _buildLabel('NIS (Nomor Induk Siswa)', isDark),
              const SizedBox(height: 8),
              TextFormField(
                controller: _nisController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  hintText: 'Contoh: 2024011',
                  prefixIcon: Icon(Icons.badge_outlined),
                ),
                validator: (val) => val == null || val.isEmpty ? 'Masukkan NIS' : null,
              ),
              const SizedBox(height: 20),

              // Kelas
              _buildLabel('Kelas', isDark),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                value: _selectedClass,
                decoration: const InputDecoration(
                  hintText: 'Pilih kelas...',
                  prefixIcon: Icon(Icons.class_outlined),
                ),
                isExpanded: true,
                items: AppConstants.classes.map((c) {
                  return DropdownMenuItem(value: c, child: Text(c, style: const TextStyle(fontSize: 14)));
                }).toList(),
                onChanged: (val) => setState(() => _selectedClass = val),
                validator: (val) => val == null ? 'Pilih kelas' : null,
              ),
              const SizedBox(height: 20),

              // Gender
              _buildLabel('Jenis Kelamin', isDark),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: () => setState(() => _selectedGender = 'L'),
                        borderRadius: BorderRadius.circular(14),
                        child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        decoration: BoxDecoration(
                          color: _selectedGender == 'L'
                              ? AppColors.primary.withOpacity(0.1)
                              : isDark ? AppColors.surfaceDark : AppColors.surface,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: _selectedGender == 'L'
                                ? AppColors.primary
                                : isDark ? AppColors.borderDark : AppColors.border,
                            width: _selectedGender == 'L' ? 2 : 1,
                          ),
                        ),
                        child: Column(
                          children: [
                            Icon(
                              Icons.male_rounded,
                              size: 32,
                              color: _selectedGender == 'L' ? AppColors.primary : AppColors.textSecondary,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Laki-laki',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: _selectedGender == 'L' ? FontWeight.w600 : FontWeight.w400,
                                color: _selectedGender == 'L'
                                    ? AppColors.primary
                                    : isDark ? AppColors.textSecondaryDark : AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: () => setState(() => _selectedGender = 'P'),
                        borderRadius: BorderRadius.circular(14),
                        child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        decoration: BoxDecoration(
                          color: _selectedGender == 'P'
                              ? const Color(0xFFEC4899).withOpacity(0.1)
                              : isDark ? AppColors.surfaceDark : AppColors.surface,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: _selectedGender == 'P'
                                ? const Color(0xFFEC4899)
                                : isDark ? AppColors.borderDark : AppColors.border,
                            width: _selectedGender == 'P' ? 2 : 1,
                          ),
                        ),
                        child: Column(
                          children: [
                            Icon(
                              Icons.female_rounded,
                              size: 32,
                              color: _selectedGender == 'P' ? const Color(0xFFEC4899) : AppColors.textSecondary,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Perempuan',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: _selectedGender == 'P' ? FontWeight.w600 : FontWeight.w400,
                                color: _selectedGender == 'P'
                                    ? const Color(0xFFEC4899)
                                    : isDark ? AppColors.textSecondaryDark : AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32),

              // Submit Button
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _submit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    disabledBackgroundColor: AppColors.primary.withOpacity(0.6),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    elevation: 0,
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          width: 22, height: 22,
                          child: CircularProgressIndicator(strokeWidth: 2.5, valueColor: AlwaysStoppedAnimation(Colors.white)),
                        )
                      : const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.save_rounded, size: 20),
                            SizedBox(width: 8),
                            Text('Simpan Siswa', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
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
      await provider.addStudent(
        name: _nameController.text.trim(),
        nis: _nisController.text.trim(),
        className: _selectedClass!,
        gender: _selectedGender,
      );

      if (!mounted) return;
      Navigator.pop(context);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Siswa berhasil ditambahkan'),
          backgroundColor: AppColors.achievement,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
    } catch (e) {
      final errorMsg = e.toString().replaceAll('Exception: ', '');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(errorMsg),
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
