import 'package:flutter/material.dart';
import '../widgets/calculator_button.dart';
import '../services/calculator_history_service.dart';

class CalculatorScreen extends StatefulWidget {
  const CalculatorScreen({super.key});

  @override
  State<CalculatorScreen> createState() => _CalculatorScreenState();
}

class _CalculatorScreenState extends State<CalculatorScreen> {
  String tampilan = '0';
  String riwayat = '';

  double? angkaPertama;
  String? operatorDipilih;
  bool mulaiInputBaru = false;

  final CalculatorHistoryService historyService = CalculatorHistoryService();

  Future<void> tombolDitekan(String nilai) async {
    if (nilai == '=') {
      await hitungHasil();
      return;
    }

    setState(() {
      if (nilai == 'C') {
        hapusSemua();
      } else if (nilai == 'DEL') {
        hapusSatuAngka();
      } else if (nilai == '+' || nilai == '-' || nilai == '×' || nilai == '÷') {
        pilihOperator(nilai);
      } else if (nilai == '%') {
        ubahKePersen();
      } else if (nilai == '±') {
        ubahPositifNegatif();
      } else {
        inputAngka(nilai);
      }
    });
  }

  void inputAngka(String nilai) {
    if (tampilan == 'Error') {
      tampilan = '0';
      riwayat = '';
    }

    if (mulaiInputBaru) {
      tampilan = nilai == '.' ? '0.' : nilai;
      mulaiInputBaru = false;
      return;
    }

    if (nilai == '.') {
      if (!tampilan.contains('.')) {
        tampilan += '.';
      }
      return;
    }

    if (tampilan == '0') {
      tampilan = nilai;
    } else {
      tampilan += nilai;
    }
  }

  void pilihOperator(String operatorBaru) {
    double angkaSekarang = double.tryParse(tampilan) ?? 0;

    if (angkaPertama != null && operatorDipilih != null && !mulaiInputBaru) {
      double hasilSementara = prosesHitung(
        angkaPertama!,
        angkaSekarang,
        operatorDipilih!,
      );

      if (hasilSementara.isNaN) {
        tampilan = 'Error';
        riwayat = '';
        angkaPertama = null;
        operatorDipilih = null;
        mulaiInputBaru = true;
        return;
      }

      tampilan = formatHasil(hasilSementara);
      angkaPertama = hasilSementara;
    } else {
      angkaPertama = angkaSekarang;
    }

    operatorDipilih = operatorBaru;
    riwayat = '${formatHasil(angkaPertama!)} $operatorBaru';
    mulaiInputBaru = true;
  }

  Future<void> hitungHasil() async {
    if (angkaPertama == null || operatorDipilih == null) {
      return;
    }

    double angkaKedua = double.tryParse(tampilan) ?? 0;

    double hasil = prosesHitung(
      angkaPertama!,
      angkaKedua,
      operatorDipilih!,
    );

    if (hasil.isNaN) {
      setState(() {
        tampilan = 'Error';
        riwayat = '';
        angkaPertama = null;
        operatorDipilih = null;
        mulaiInputBaru = true;
      });
      return;
    }

    String angkaPertamaText = formatHasil(angkaPertama!);
    String angkaKeduaText = formatHasil(angkaKedua);
    String hasilText = formatHasil(hasil);
    String operatorText = operatorDipilih!;

    setState(() {
      riwayat = '$angkaPertamaText $operatorText $angkaKeduaText =';
      tampilan = hasilText;

      angkaPertama = null;
      operatorDipilih = null;
      mulaiInputBaru = true;
    });

    try {
      await historyService.simpanRiwayat(
        angkaPertama: angkaPertamaText,
        operatorHitung: operatorText,
        angkaKedua: angkaKeduaText,
        hasil: hasilText, operator: '',
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Hasil muncul, tapi riwayat gagal disimpan ke Supabase'),
        ),
      );
    }
  }

  double prosesHitung(double angka1, double angka2, String operator) {
    if (operator == '+') {
      return angka1 + angka2;
    } else if (operator == '-') {
      return angka1 - angka2;
    } else if (operator == '×') {
      return angka1 * angka2;
    } else if (operator == '÷') {
      if (angka2 == 0) {
        return double.nan;
      }
      return angka1 / angka2;
    }

    return angka2;
  }

  void hapusSemua() {
    tampilan = '0';
    riwayat = '';
    angkaPertama = null;
    operatorDipilih = null;
    mulaiInputBaru = false;
  }

  void hapusSatuAngka() {
    if (tampilan == 'Error') {
      tampilan = '0';
      riwayat = '';
      return;
    }

    if (mulaiInputBaru) {
      return;
    }

    if (tampilan.length == 1) {
      tampilan = '0';
    } else {
      tampilan = tampilan.substring(0, tampilan.length - 1);
    }
  }

  void ubahKePersen() {
    if (tampilan == 'Error') {
      return;
    }

    double angka = double.tryParse(tampilan) ?? 0;
    tampilan = formatHasil(angka / 100);
  }

  void ubahPositifNegatif() {
    if (tampilan == '0' || tampilan == 'Error') {
      return;
    }

    if (tampilan.startsWith('-')) {
      tampilan = tampilan.substring(1);
    } else {
      tampilan = '-$tampilan';
    }
  }

  String formatHasil(double angka) {
    if (angka % 1 == 0) {
      return angka.toInt().toString();
    }

    return angka
        .toStringAsFixed(8)
        .replaceAll(RegExp(r'0+$'), '')
        .replaceAll(RegExp(r'\.$'), '');
  }

  bool cekOperator(String nilai) {
    return nilai == '+' ||
        nilai == '-' ||
        nilai == '×' ||
        nilai == '÷' ||
        nilai == '=';
  }

  bool cekTombolFitur(String nilai) {
    return nilai == 'C' || nilai == 'DEL' || nilai == '%' || nilai == '±';
  }

  Widget barisTombol(List<String> daftarTombol) {
    return Expanded(
      child: Row(
        children: daftarTombol.map((teks) {
          bool tombolOperator = cekOperator(teks);
          bool tombolFitur = cekTombolFitur(teks);

          return CalculatorButton(
            teks: teks,
            warnaTombol: tombolOperator
                ? const Color(0xFF4A55A2)
                : tombolFitur
                ? const Color(0xFFFFD6A5)
                : const Color(0xFFF2F2F2),
            warnaTeks: tombolOperator ? Colors.white : Colors.black,
            onTap: () {
              tombolDitekan(teks);
            },
          );
        }).toList(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F7F7),
      appBar: AppBar(
        title: const Text('Kalkulator Sederhana'),
        centerTitle: true,
        backgroundColor: const Color(0xFF4A55A2),
        foregroundColor: Colors.white,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Expanded(
                flex: 2,
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  alignment: Alignment.bottomRight,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        reverse: true,
                        child: Text(
                          riwayat,
                          style: const TextStyle(
                            fontSize: 22,
                            color: Colors.grey,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        reverse: true,
                        child: Text(
                          tampilan,
                          style: const TextStyle(
                            fontSize: 46,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 18),
              Expanded(
                flex: 5,
                child: Column(
                  children: [
                    barisTombol(['C', 'DEL', '%', '÷']),
                    barisTombol(['7', '8', '9', '×']),
                    barisTombol(['4', '5', '6', '-']),
                    barisTombol(['1', '2', '3', '+']),
                    barisTombol(['0', '.', '±', '=']),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}