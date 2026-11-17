import 'package:flutter/material.dart';

class AddTodoPage extends StatefulWidget {
  const AddTodoPage({super.key});

  @override
  State<AddTodoPage> createState() => _AddTodoPageState();
}

class _AddTodoPageState extends State<AddTodoPage> {
  final _controller = TextEditingController();
  String? _error;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _kirim() {
    final judul = _controller.text.trim();
    if (judul.isEmpty) {
      setState(() => _error = 'Judul tidak boleh kosong');
      return;
    }
    Navigator.pop(context, judul);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Tambah Tugas')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: _controller,
              decoration: InputDecoration(
                labelText: 'Judul tugas',
                border: const OutlineInputBorder(),
                errorText: _error,
              ),
              onChanged: (_) {
                if (_error != null) setState(() => _error = null);
              },
              onSubmitted: (_) => _kirim(),
            ),
            const SizedBox(height: 16),
            FilledButton(
              onPressed: _kirim,
              child: const Text('Kirim ke blockchain'),
            ),
            const SizedBox(height: 8),
            const Text(
              'Transaksi butuh gas (Sepolia ETH) dan memakan waktu sekitar 12 detik.',
              style: TextStyle(fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }
}