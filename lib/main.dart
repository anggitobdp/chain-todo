import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'models/tugas.dart';
import 'screens/add_todo_page.dart';
import 'services/chain_todo_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: '.env');
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) => const MaterialApp(
        title: 'ChainTodo',
        home: TodoListPage(),
      );
}

enum TxStatus { idle, memproses, berhasil, gagal }

class TodoListPage extends StatefulWidget {
  const TodoListPage({super.key});

  @override
  State<TodoListPage> createState() => _TodoListPageState();
}

class _TodoListPageState extends State<TodoListPage> {
  final _service = ChainTodoService();
  late Future<List<Tugas>> _future;

  TxStatus _status = TxStatus.idle;
  String? _hash;
  String? _error;

  @override
  void initState() {
    super.initState();
    _future = _muat();
  }

  Future<List<Tugas>> _muat() async {
    await _service.init();
    return _service.ambilSemua();
  }

  Future<void> _refresh() async {
    setState(() {
      _future = _service.ambilSemua();
    });
    await _future;
  }

  /// Menjalankan transaksi dan memperbarui indikator status.
  Future<void> _kirim(Future<String> Function() aksi) async {
    if (_status == TxStatus.memproses) return; // cegah kirim ganda
    setState(() {
      _status = TxStatus.memproses;
      _hash = null;
      _error = null;
    });
    try {
      final hash = await aksi();
      if (!mounted) return;
      setState(() => _hash = hash);
      final ok = await _service.tungguReceipt(hash);
      if (!mounted) return;
      if (ok) {
        setState(() => _status = TxStatus.berhasil);
        await _refresh();
      } else {
        setState(() {
          _status = TxStatus.gagal;
          _error = 'Transaksi ditolak oleh kontrak (revert).';
        });
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _status = TxStatus.gagal;
        _error = e.toString();
      });
    }
  }

  Future<void> _bukaFormTambah() async {
    final judul = await Navigator.push<String>(
      context,
      MaterialPageRoute(builder: (_) => const AddTodoPage()),
    );
    if (!mounted || judul == null || judul.isEmpty) return;
    _kirim(() => _service.tambahTugas(judul));
  }

  Widget _banner() {
    switch (_status) {
      case TxStatus.idle:
        return const SizedBox.shrink();
      case TxStatus.memproses:
        return Container(
          width: double.infinity,
          color: Colors.amber.shade100,
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              const SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(_hash == null
                    ? 'Memproses: menunggu tanda tangan...'
                    : 'Memproses: menunggu konfirmasi blok...\n$_hash'),
              ),
            ],
          ),
        );
      case TxStatus.berhasil:
        return Container(
          width: double.infinity,
          color: Colors.green.shade100,
          padding: const EdgeInsets.all(12),
          child: SelectableText('Berhasil\nHash transaksi: $_hash'),
        );
      case TxStatus.gagal:
        return Container(
          width: double.infinity,
          color: Colors.red.shade100,
          padding: const EdgeInsets.all(12),
          child: SelectableText('Gagal\n$_error'),
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('ChainTodo'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Muat ulang',
            onPressed: _refresh,
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _bukaFormTambah,
        tooltip: 'Tambah tugas',
        child: const Icon(Icons.add),
      ),
      body: Column(
        children: [
          _banner(),
          Expanded(
            child: FutureBuilder<List<Tugas>>(
              future: _future,
              builder: (context, snap) {
                if (snap.connectionState != ConnectionState.done) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snap.hasError) {
                  return Center(child: Text('Gagal memuat: ${snap.error}'));
                }
                final data = snap.data!;
                return RefreshIndicator(
                  onRefresh: _refresh,
                  child: data.isEmpty
                      ? ListView(
                          children: const [
                            SizedBox(height: 200),
                            Center(child: Text('Belum ada tugas')),
                          ],
                        )
                      : ListView.builder(
                          itemCount: data.length,
                          itemBuilder: (_, i) => _item(data[i]),
                        ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _item(Tugas t) {
    final milikSaya = t.pembuat.toLowerCase() == _service.alamatSaya;
    return ListTile(
      leading: Icon(
        t.selesai ? Icons.check_circle : Icons.radio_button_unchecked,
        color: t.selesai ? Colors.green : null,
      ),
      title: Text(
        t.judul,
        style: TextStyle(
          decoration: t.selesai ? TextDecoration.lineThrough : null,
        ),
      ),
      subtitle: Text('${t.dibuat}'),
      trailing: (!t.selesai && milikSaya)
          ? IconButton(
              icon: const Icon(Icons.done),
              tooltip: 'Tandai selesai',
              onPressed: _status == TxStatus.memproses
                  ? null
                  : () => _kirim(() => _service.tandaiSelesai(t.id)),
            )
          : null,
    );
  }
}