import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';

class NetworkService {
  NetworkService._();
  static final NetworkService instance = NetworkService._();

  final Connectivity _connectivity = Connectivity();
  final InternetConnection _internetConnection = InternetConnection();

  /// Stream emitting true if internet access is available, false otherwise.
  Stream<bool> get onConnectivityChanged {
    return _connectivity.onConnectivityChanged.asyncMap((results) async {
      if (results.isEmpty || results.contains(ConnectivityResult.none)) {
        return false;
      }
      return await _internetConnection.hasInternetAccess;
    });
  }

  /// Manually checks if the device is currently connected to the internet.
  Future<bool> checkInternet() async {
    final results = await _connectivity.checkConnectivity();
    if (results.isEmpty || results.contains(ConnectivityResult.none)) {
      return false;
    }
    return await _internetConnection.hasInternetAccess;
  }
}
