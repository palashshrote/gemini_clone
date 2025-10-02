import 'package:connectivity_plus/connectivity_plus.dart';

Future<bool> isConnected() async {
  final List<ConnectivityResult> connectivityResult = await (Connectivity()
      .checkConnectivity());
  return (!connectivityResult.contains(ConnectivityResult.none));
}
