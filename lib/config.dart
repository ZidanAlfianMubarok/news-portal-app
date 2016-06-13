class Config {
  // Opsi 1 (Default): Untuk testing di Chrome/Web di laptop yang sama
  static const String baseUrl = 'http://127.0.0.1:8000/api';

  // Opsi 2: Untuk testing di HP Asli
  // Ganti [IP_LAPTOP_ANDA] dengan IP LAN laptop jika tes di HP (misal: 192.168.1.5)
  // static const String baseUrl = 'http://192.168.100.49:8000/api';
}
