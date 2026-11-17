import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:web3dart/web3dart.dart';
import 'package:wallet/wallet.dart';
import '../config/app_config.dart';
import '../models/tugas.dart';

class ChainTodoService {
  late final Web3Client _client;
  late final DeployedContract _contract;

  Future<void> init() async {
    _client = Web3Client(AppConfig.rpcUrl, http.Client());
    final abiJson = await rootBundle.loadString('assets/abi/ChainTodo.json');
    _contract = DeployedContract(
      ContractAbi.fromJson(abiJson, 'ChainTodo'),
      EthereumAddress.fromHex(AppConfig.contractAddress),
    );
  }

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
}