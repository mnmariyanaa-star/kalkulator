import 'package:supabase_flutter/supabase_flutter.dart';

class CalculatorHistoryService {
  final SupabaseClient supabase = Supabase.instance.client;

  Future<void> simpanRiwayat({
    required String angkaPertama,
    required String operator,
    required String angkaKedua,
    required String hasil, required String operatorHitung,
  }) async {
    await supabase.from('riwayat_kalkulator').insert({
      'angka_pertama': angkaPertama,
      'operator': operator,
      'angka_kedua': angkaKedua,
      'hasil': hasil,
    });
  }

  Future<List<Map<String, dynamic>>> ambilRiwayat() async {
    final data = await supabase
        .from('riwayat_kalkulator')
        .select()
        .order('created_at', ascending: false);

    return List<Map<String, dynamic>>.from(data);
  }
}