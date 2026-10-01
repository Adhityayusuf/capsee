/// Data wilayah CONTOH untuk dropdown bertingkat
/// (Provinsi -> Kota/Kabupaten -> Kecamatan).
///
/// Ini hanya sebagian kecil untuk keperluan tampilan. Untuk aplikasi
/// sesungguhnya, ambil data lengkap dari API wilayah Indonesia atau
/// dari backend Capsee sendiri.
const Map<String, Map<String, List<String>>> wilayahData = {
  'Jawa Barat': {
    'Kab. Bandung': ['Ciwidey', 'Kertasari', 'Pangalengan', 'Rancabali'],
    'Kab. Bandung Barat': [
      'Cililin',
      'Cisarua',
      'Lembang',
      'Ngamprah',
      'Parongpong',
    ],
    'Kab. Garut': ['Cikajang', 'Cisurupan', 'Pasirwangi', 'Samarang'],
  },
  'Jawa Tengah': {
    'Kab. Magelang': ['Dukun', 'Grabag', 'Ngablak', 'Sawangan'],
    'Kab. Semarang': ['Ambarawa', 'Bandungan', 'Getasan', 'Sumowono'],
    'Kab. Temanggung': ['Kandangan', 'Kledung', 'Ngadirejo', 'Parakan'],
  },
  'Jawa Timur': {
    'Kab. Malang': [
      'Dau',
      'Karangploso',
      'Lawang',
      'Ngantang',
      'Pakis',
      'Poncokusumo',
      'Pujon',
      'Singosari',
      'Tumpang',
      'Wajak',
    ],
    'Kota Batu': ['Batu', 'Bumiaji', 'Junrejo'],
    'Kota Malang': [
      'Blimbing',
      'Kedungkandang',
      'Klojen',
      'Lowokwaru',
      'Sukun',
    ],
  },
};
