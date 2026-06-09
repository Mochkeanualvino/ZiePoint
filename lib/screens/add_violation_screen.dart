import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/theme.dart';
import '../core/constants.dart';
import '../data/models/violation.dart';
import '../providers/app_provider.dart';

class AddViolationScreen extends StatefulWidget {
  const AddViolationScreen({super.key});

  @override
  State<AddViolationScreen> createState() => _AddViolationScreenState();
}

class _AddViolationScreenState extends State<AddViolationScreen> {
  final _formKey = GlobalKey<FormState>();
  String? _selectedClass;
  String? _selectedStudentId;
  String? _selectedCategory;
  final _descriptionController = TextEditingController();
  final _reportedByController = TextEditingController();
  DateTime _selectedDate = DateTime.now();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = Provider.of<AppProvider>(context, listen: false);
      _reportedByController.text = provider.userName;
    });
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    _reportedByController.dispose();
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
        title: const Text('Tambah Pelanggaran'),
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
                  gradient: AppColors.violationGradient,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.violation.withOpacity(0.3),
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
                      child: const Icon(Icons.warning_amber_rounded, color: Colors.white, size: 28),
                    ),
                    const SizedBox(width: 16),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Catat Pelanggaran',
                            style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w700),
                          ),
                          SizedBox(height: 4),
                          Text(
                            'Isi form berikut untuk mencatat pelanggaran siswa',
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

              // Category Selection
              _buildLabel('Jenis Pelanggaran', isDark),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                value: _selectedCategory,
                decoration: const InputDecoration(
                  hintText: 'Pilih jenis pelanggaran...',
                  prefixIcon: Icon(Icons.category_outlined),
                ),
                isExpanded: true,
                items: AppConstants.violationCategories.map((c) {
                  final severity = AppConstants.violationSeverity[c] ?? 'Ringan';
                  final points = AppConstants.violationPoints[c] ?? 5;
                  return DropdownMenuItem(
                    value: c,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Flexible(child: Text(c, style: const TextStyle(fontSize: 14), overflow: TextOverflow.ellipsis)),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: _getSeverityColor(severity).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            '$severity • -$points',
                            style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: _getSeverityColor(severity)),
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
                onChanged: (val) => setState(() => _selectedCategory = val),
                validator: (val) => val == null ? 'Pilih jenis pelanggaran' : null,
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

              // Reported By
              _buildLabel('Dilaporkan Oleh', isDark),
              const SizedBox(height: 8),
              TextFormField(
                controller: _reportedByController,
                decoration: const InputDecoration(
                  hintText: 'Nama guru/petugas pelapor',
                  prefixIcon: Icon(Icons.person_pin_outlined),
                ),
                validator: (val) => val == null || val.isEmpty ? 'Masukkan nama pelapor' : null,
              ),
              const SizedBox(height: 20),

              // Description
              _buildLabel('Keterangan', isDark),
              const SizedBox(height: 8),
              TextFormField(
                controller: _descriptionController,
                maxLines: 3,
                decoration: const InputDecoration(
                  hintText: 'Deskripsikan pelanggaran...',
                  prefixIcon: Padding(
                    padding: EdgeInsets.only(bottom: 48),
                    child: Icon(Icons.description_outlined),
                  ),
                ),
                validator: (val) => val == null || val.isEmpty ? 'Masukkan keterangan' : null,
              ),
              const SizedBox(height: 12),

              // Points Preview
              if (_selectedCategory != null)
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: AppColors.violation.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.violation.withOpacity(0.2)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.info_outline_rounded, color: AppColors.violation, size: 18),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          'Poin yang akan dikurangi: ${AppConstants.violationPoints[_selectedCategory] ?? 5} poin (${AppConstants.violationSeverity[_selectedCategory] ?? "Ringan"})',
                          style: const TextStyle(fontSize: 12, color: AppColors.violation, fontWeight: FontWeight.w500),
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
                    backgroundColor: AppColors.violation,
                    foregroundColor: Colors.white,
                    disabledBackgroundColor: AppColors.violation.withOpacity(0.6),
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
                            Text('Simpan Pelanggaran', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
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

  Color _getSeverityColor(String severity) {
    switch (severity) {
      case 'Berat': return AppColors.violation;
      case 'Sedang': return AppColors.warning;
      default: return const Color(0xFF06B6D4);
    }
  }

  void _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final provider = Provider.of<AppProvider>(context, listen: false);
      final student = provider.students.firstWhere((s) => s.id == _selectedStudentId);
      final points = AppConstants.violationPoints[_selectedCategory] ?? 5;
      final severity = AppConstants.violationSeverity[_selectedCategory] ?? 'Ringan';

      final violation = Violation(
        id: 'v${DateTime.now().millisecondsSinceEpoch}',
        studentId: student.id,
        studentName: student.name,
        className: student.className,
        category: _selectedCategory!,
        severity: severity,
        points: points,
        description: _descriptionController.text,
        date: _selectedDate,
        reportedBy: _reportedByController.text.trim(),
      );

      await provider.addViolation(violation);

      if (!mounted) return;
      Navigator.pop(context);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Pelanggaran berhasil dicatat'),
          backgroundColor: AppColors.violation,
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
