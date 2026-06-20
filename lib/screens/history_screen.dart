import 'package:flutter/material.dart';
import '../services/calculator_history_service.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  final CalculatorHistoryService historyService = CalculatorHistoryService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Riwayat Perhitungan'),
        backgroundColor: const Color(0xFF4A55A2),
        foregroundColor: Colors.white,
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: historyService.ambilRiwayat(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (snapshot.hasError) {
            return const Center(
              child: Text('Gagal mengambil riwayat'),
            );
          }

          final riwayat = snapshot.data ?? [];

          if (riwayat.isEmpty) {
            return const Center(
              child: Text('Belum ada riwayat perhitungan'),
            );
          }

          return ListView.builder(
            itemCount: riwayat.length,
            itemBuilder: (context, index) {
              final item = riwayat[index];

              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                child: ListTile(
                  title: Text(
                    '${item['angka_pertama']} ${item['operator']} ${item['angka_kedua']} = ${item['hasil']}',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  subtitle: Text(
                    item['created_at'].toString(),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}