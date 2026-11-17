import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'models/tugas.dart';
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

class TodoListPage extends StatefulWidget {
  const TodoListPage({super.key});

  @override
  State<TodoListPage> createState() => _TodoListPageState();
}

class _TodoListPageState extends State<TodoListPage> {
  final _service = ChainTodoService();
  late Future<List<Tugas>> _future;

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
    setState(() => _future = _service.ambilSemua());
    await _future;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('ChainTodo')),
      body: FutureBuilder<List<Tugas>>(
        future: _future,
        builder: (context, snap) {
          if (snap.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snap.hasError) {
            return Center(child: Text('Gagal memuat: ${snap.error}'));
          }
          final data = snap.data!;
          if (data.isEmpty) {
            return const Center(child: Text('Belum ada tugas'));
          }
          return RefreshIndicator(
            onRefresh: _refresh,
            child: ListView.builder(
              itemCount: data.length,
              itemBuilder: (_, i) {
                final t = data[i];
                return ListTile(
                  leading: Icon(t.selesai
                      ? Icons.check_circle
                      : Icons.radio_button_unchecked),
                  title: Text(
                    t.judul,
                    style: TextStyle(
                      decoration:
                          t.selesai ? TextDecoration.lineThrough : null,
                    ),
                  ),
                  subtitle: Text('${t.dibuat}'),
                );
              },
            ),
          );
        },
      ),
    );
  }
}