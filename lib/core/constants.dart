class AppConstants {
  static const String appName = 'i\'amPoint';
  static const String appTagline = 'Pantau Pelanggaran & Prestasi Siswa';

  // Violation Categories
  static const List<String> violationCategories = [
    'Terlambat dibawah 15 Menit',
    'Terlambat diatas 15 Menit',
    'Bolos / Alpha',
    'Tidak Berseragam',
    'Melanggar Kebersihan',
    'Berkelahi',
    'Merokok',
    'Merusak Fasilitas',
    'Bullying',
    'Membawa HP',
    'Mengganggu Pembelajaran',
    'Meninggalkan Kelas Tanpa Izin',
    'Tidak Mengerjakan Tugas',
    'Lainnya',
  ];

  // Violation Descriptions
  static const Map<String, String> violationDescriptions = {
    'Terlambat dibawah 15 Menit': 'Siswa yang terlambat mengikuti pelajaran tidak lebih 15 menit melapor kepada petugas piket (ijin masuk)',
    'Terlambat diatas 15 Menit': 'Siswa terlambat mengikuti pelajaran lebih dari 15 menit, tidak boleh mengikuti pelajaran jam pertama',
    'Bolos / Alpha': 'Siswa yang tidak masuk sekolah tanpa keterangan',
    'Tidak Berseragam': 'Tidak memakai seragam lengkap sesuai ketentuan sekolah',
    'Melanggar Kebersihan': 'Siswa yang melanggar kelancaran, keamanan kebersihan/kerapihan kelas dan lingkungan sekolah',
    'Berkelahi': 'Terlibat perkelahian dengan sesama siswa di lingkungan sekolah',
    'Merokok': 'Kedapatan merokok atau membawa rokok di lingkungan sekolah',
    'Merusak Fasilitas': 'Merusak fasilitas atau sarana prasarana milik sekolah',
    'Bullying': 'Melakukan perundungan atau intimidasi terhadap siswa lain',
    'Membawa HP': 'Membawa atau menggunakan handphone saat jam pelajaran tanpa izin guru',
    'Mengganggu Pembelajaran': 'Melakukan perbuatan yang mengganggu pelajaran/suasana kelas',
    'Meninggalkan Kelas Tanpa Izin': 'Meninggalkan pelajaran/kelas tanpa izin guru/petugas piket',
    'Tidak Mengerjakan Tugas': 'Tidak mengumpulkan atau mengerjakan tugas yang diberikan guru',
    'Lainnya': 'Pelanggaran lain yang tidak termasuk dalam kategori di atas',
  };

  // Violation Points (negative)
  static const Map<String, int> violationPoints = {
    'Terlambat dibawah 15 Menit': 3,
    'Terlambat diatas 15 Menit': 5,
    'Bolos / Alpha': 20,
    'Tidak Berseragam': 5,
    'Melanggar Kebersihan': 3,
    'Berkelahi': 30,
    'Merokok': 25,
    'Merusak Fasilitas': 20,
    'Bullying': 35,
    'Membawa HP': 10,
    'Mengganggu Pembelajaran': 3,
    'Meninggalkan Kelas Tanpa Izin': 5,
    'Tidak Mengerjakan Tugas': 5,
    'Lainnya': 5,
  };

  // Achievement Categories
  static const List<String> achievementCategories = [
    'Juara 1 Kabupaten',
    'Juara 2 Kabupaten',
    'Juara 3 Kabupaten',
    'Juara 1 Provinsi',
    'Juara 2 Provinsi',
    'Juara 3 Provinsi',
    'Juara 1 Nasional',
    'Juara 2 Nasional',
    'Juara 3 Nasional',
    'Ketua OSIS',
    'Hafidz Quran',
    'Lainnya',
  ];

  // Achievement Descriptions
  static const Map<String, String> achievementDescriptions = {
    'Juara 1 Kabupaten': 'Meraih juara 1 dalam kompetisi tingkat Kabupaten/Kota',
    'Juara 2 Kabupaten': 'Meraih juara 2 dalam kompetisi tingkat Kabupaten/Kota',
    'Juara 3 Kabupaten': 'Meraih juara 3 dalam kompetisi tingkat Kabupaten/Kota',
    'Juara 1 Provinsi': 'Meraih juara 1 dalam kompetisi tingkat Provinsi',
    'Juara 2 Provinsi': 'Meraih juara 2 dalam kompetisi tingkat Provinsi',
    'Juara 3 Provinsi': 'Meraih juara 3 dalam kompetisi tingkat Provinsi',
    'Juara 1 Nasional': 'Meraih juara 1 dalam kompetisi tingkat Nasional',
    'Juara 2 Nasional': 'Meraih juara 2 dalam kompetisi tingkat Nasional',
    'Juara 3 Nasional': 'Meraih juara 3 dalam kompetisi tingkat Nasional',
    'Ketua OSIS': 'Terpilih sebagai Ketua OSIS periode berjalan',
    'Hafidz Quran': 'Telah menghafal minimal 5 Juz Al-Quran',
    'Lainnya': 'Prestasi lain yang diakui oleh sekolah',
  };

  // Achievement Points (positive)
  static const Map<String, int> achievementPoints = {
    'Juara 1 Kabupaten': 50,
    'Juara 2 Kabupaten': 40,
    'Juara 3 Kabupaten': 30,
    'Juara 1 Provinsi': 80,
    'Juara 2 Provinsi': 70,
    'Juara 3 Provinsi': 60,
    'Juara 1 Nasional': 120,
    'Juara 2 Nasional': 100,
    'Juara 3 Nasional': 90,
    'Ketua OSIS': 30,
    'Hafidz Quran': 50,
    'Lainnya': 10,
  };

  // Achievement Levels
  static const List<String> achievementLevels = [
    'Sekolah',
    'Kecamatan',
    'Kabupaten/Kota',
    'Provinsi',
    'Nasional',
    'Internasional',
  ];

  // Classes
  static const List<String> classes = [
    '7-A', '7-B', '7-C', '7-D', '7-E', '7-F', '7-G', '7-H', '7-I', '7-J',
    '8-A', '8-B', '8-C', '8-D', '8-E', '8-F', '8-G', '8-H', '8-I', '8-J',
    '9-A', '9-B', '9-C', '9-D', '9-E', '9-F', '9-G', '9-H', '9-I', '9-J',
  ];

  // Violation Severity
  static const Map<String, String> violationSeverity = {
    'Terlambat dibawah 15 Menit': 'Ringan',
    'Terlambat diatas 15 Menit': 'Ringan',
    'Bolos / Alpha': 'Berat',
    'Tidak Berseragam': 'Ringan',
    'Melanggar Kebersihan': 'Ringan',
    'Berkelahi': 'Berat',
    'Merokok': 'Berat',
    'Merusak Fasilitas': 'Sedang',
    'Bullying': 'Berat',
    'Membawa HP': 'Ringan',
    'Mengganggu Pembelajaran': 'Ringan',
    'Meninggalkan Kelas Tanpa Izin': 'Sedang',
    'Tidak Mengerjakan Tugas': 'Ringan',
    'Lainnya': 'Ringan',
  };
}
