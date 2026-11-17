import 'dart:async';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:web3dart/web3dart.dart';
import 'package:wallet/wallet.dart';
import '../config/app_config.dart';
import '../models/tugas.dart';

class ChainTodoService {
  late final Web3Client _client;
  late final DeployedContract _contract;
  late final EthPrivateKey _credentials;

  Future<void> init() async {
    _client = Web3Client(AppConfig.rpcUrl, http.Client());
    final abiJson = await rootBundle.loadString('assets/abi/ChainTodo.json');
    _contract = DeployedContract(
      ContractAbi.fromJson(abiJson, 'ChainTodo'),
      EthereumAddress.fromHex(AppConfig.contractAddress),
    );
    _credentials = EthPrivateKey.fromHex(AppConfig.privateKey);
  }

  /// Alamat wallet aplikasi (huruf kecil) untuk dibandingkan dengan pembuat tugas.
  String get alamatSaya => _credentials.address.toString().toLowerCase();

  // ---------- BACA (gratis, tanpa gas) ----------

  Future<int> jumlahTugas() async {
    final res = await _client.call(
      contract: _contract,
      function: _contract.function('jumlahTugas'),
      params: [],
    );
    return (res.first as BigInt).toInt();
  }

  Future<List<Tugas>> ambilSemua() async {
    final jumlah = await jumlahTugas();
    final fn = _contract.function('ambilTugas');
    return Future.wait(List.generate(jumlah, (i) async {
      final r = await _client.call(
        contract: _contract,
        function: fn,
        params: [BigInt.from(i)],
      );
      return Tugas(
        id: i,
        judul: r[0] as String,
        selesai: r[1] as bool,
        dibuat: DateTime.fromMillisecondsSinceEpoch(
            (r[2] as BigInt).toInt() * 1000),
        pembuat: r[3].toString(),
      );
    }));
  }

  // ---------- TULIS (butuh gas, ditandatangani) ----------

  Future<String> tambahTugas(String judul) {
    return _client.sendTransaction(
      _credentials,
      Transaction.callContract(
        contract: _contract,
        function: _contract.function('tambahTugas'),
        parameters: [judul],
      ),
      chainId: AppConfig.chainId,
    );
  }

  Future<String> tandaiSelesai(int id) {
    return _client.sendTransaction(
      _credentials,
      Transaction.callContract(
        contract: _contract,
        function: _contract.function('tandaiSelesai'),
        parameters: [BigInt.from(id)],
      ),
      chainId: AppConfig.chainId,
    );
  }

  /// Menunggu transaksi masuk blok. true = sukses, false = ditolak kontrak.
  Future<bool> tungguReceipt(String hash) async {
    for (var i = 0; i < 40; i++) {
      final r = await _client.getTransactionReceipt(hash);
      if (r != null) return r.status == true;
      await Future.delayed(const Duration(seconds: 3));
    }
    throw TimeoutException('Transaksi belum terkonfirmasi setelah 2 menit.');
  }
}