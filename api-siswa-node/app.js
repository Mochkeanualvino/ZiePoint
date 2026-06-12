const express = require('express');
const mysql = require('mysql2');
const cors = require('cors');
const bodyParser = require('body-parser');

const app = express();

// Middleware
app.use(cors());
app.use(bodyParser.json());

// Koneksi ke database
const db = mysql.createConnection({
    host: 'localhost',
    user: 'root',
    password: '', // sesuaikan dengan password XAMPP kamu
    database: 'db_sekolah'
});

// Connect DB
db.connect((err) => {
    if (err) {
        console.error('Koneksi gagal: ' + err.stack);
        return;
    }
    console.log('Terhubung ke database');
});


// =====================
// GET (ambil semua siswa)
// =====================
app.get('/siswa', (req, res) => {
    const sql = "SELECT * FROM siswa";
    db.query(sql, (err, result) => {
        if (err) {
            res.status(500).json({ error: err });
        } else {
            res.json(result);
        }
    });
});


// =====================
// POST (tambah siswa)
// =====================
app.post('/siswa', (req, res) => {
    const { nama, kelas, nis } = req.body;

    const sql = "INSERT INTO siswa (nama, kelas, nis) VALUES (?, ?, ?)";
    db.query(sql, [nama, kelas, nis], (err, result) => {
        if (err) {
            res.status(500).json({ error: err });
        } else {
            res.json({
                message: "Data berhasil ditambahkan",
                id: result.insertId
            });
        }
    });
});

// =====================
// PUT (update siswa)
// =====================
app.put('/siswa/:id', (req, res) => {
    const { id } = req.params;
    const { nama, kelas, nis } = req.body;

    const sql = "UPDATE siswa SET nama=?, kelas=?, nis=? WHERE id=?";
    db.query(sql, [nama, kelas, nis, id], (err, result) => {
        if (err) {
            res.status(500).json({ error: err });
        } else {
            res.json({ message: "Data berhasil diupdate" });
        }
    });
});


// =====================
// DELETE (hapus siswa)
// =====================
app.delete('/siswa/:id', (req, res) => {
    const { id } = req.params;

    const sql = "DELETE FROM siswa WHERE id=?";
    db.query(sql, [id], (err, result) => {
        if (err) {
            res.status(500).json({ error: err });
        } else {
            res.json({ message: "Data berhasil dihapus" });
        }
    });
});

app.get('/jenis_catatan/:tipe', (req, res) => {
    const { tipe } = req.params;

    const sql = "SELECT * FROM jenis_catatan WHERE tipe = ?";

    db.query(sql, [tipe], (err, result) => {
        if (err) {
            return res.json(err);
        }
        res.json(result);
    });
});


// Jalankan server
app.listen(3000, () => {
    console.log('Server berjalan di http://localhost:3000');
});