import 'package:flutter_dotenv/flutter_dotenv.dart';

class AppConfig {
  static const contractAddress =
      '0xb8548Dc8898Cf260fed451cbF763ebF690197542';
  static const chainId = 11155111; // Sepolia

  static String get rpcUrl => dotenv.env['RPC_URL']!;
}