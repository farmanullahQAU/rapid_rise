import 'dart:async';
import 'dart:convert';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:mssql_connection/mssql_connection.dart';
import 'package:rapid_rise/models/employee.dart';

class DatabaseService {
  static final DatabaseService _instance = DatabaseService._internal();
  factory DatabaseService() => _instance;
  DatabaseService._internal();

  MssqlConnection? _connection;
  final _secureStorage = const FlutterSecureStorage();

  // Save connection parameters securely
  Future<void> saveConnectionParams({
    required String ip,
    required String port,
    required String username,
    required String password,
    required String databaseName,
  }) async {
    await _secureStorage.write(key: 'db_ip', value: ip);
    await _secureStorage.write(key: 'db_port', value: port);
    await _secureStorage.write(key: 'db_username', value: username);
    await _secureStorage.write(key: 'db_password', value: password);
    await _secureStorage.write(key: 'db_name', value: databaseName);
  }

  // Retrieve saved connection parameters
  Future<Map<String, String?>> getConnectionParams() async {
    return {
      'ip': await _secureStorage.read(key: 'db_ip'),
      'port': await _secureStorage.read(key: 'db_port'),
      'username': await _secureStorage.read(key: 'db_username'),
      'password': await _secureStorage.read(key: 'db_password'),
      'databaseName': await _secureStorage.read(key: 'db_name'),
    };
  }

  // Check network connectivity
  Future<bool> checkNetworkConnectivity() async {
    var connectivityResult = await Connectivity().checkConnectivity();
    return !connectivityResult.contains(ConnectivityResult.none);
  }

  // Ensure connection is established

  // Connect to database with robust error handling
  Future<bool> connect({
    required String ip,
    required String port,
    required String username,
    required String password,
    required String databaseName,
  }) async {
    // Dispose of existing connection
    await _connection?.disconnect();
    _connection = MssqlConnection.getInstance();

    try {
      // Validate input parameters
      if (ip.isEmpty ||
          port.isEmpty ||
          username.isEmpty ||
          databaseName.isEmpty) {
        debugPrint("Invalid connection parameters");
        return false;
      }

      // Attempt connection with timeout
      final connected = await _connection!
          .connect(
        ip: ip,
        port: port,
        databaseName: databaseName,
        username: username,
        password: password,
      )
          .timeout(
        const Duration(seconds: 10),
        onTimeout: () {
          debugPrint("Connection attempt timed out");
          return false;
        },
      );

      if (connected) {
        // Save successful connection parameters
        await saveConnectionParams(
          ip: ip,
          port: port,
          username: username,
          password: password,
          databaseName: databaseName,
        );
        debugPrint("Successfully connected to SQL Server");
        return true;
      } else {
        debugPrint("Connection failed");
        return false;
      }
    } catch (e) {
      debugPrint("Connection error: $e");
      return false;
    }
  }

  // Close the database connection
  Future<void> disconnect() async {
    await _connection?.disconnect();
    _connection = null;
  }

  Future<Employee?> login(
    String username,
    String password,
  ) async {
    try {
      final String query =
          "SELECT * FROM TblEmployees WHERE Password = '$password' AND FirstName = '$username'";

      final result = await _connection?.getData(query);
      List<dynamic> data = jsonDecode(result ?? "[]");

      if (data.isNotEmpty) {
        return Employee.fromJson(data.first);
      } else {
        throw Exception("Invalid username or password");
      }
    } catch (e) {
      debugPrint("Login query error: $e");
      rethrow;
    }
  }

  Future<String?> checkAndInsertComponentScan({
    required String componentId, // Station ID
    required String flightId,
    required String userId,
  }) async {
    try {
      // await _connection?.writeData(
      //     "DELETE FROM TblComponentsScan WHERE Component = '$componentId' AND FlightID = '$flightId'");
      // return "deleted";
      // Check 1: Validate Station ID exists in TblStations
      final stationCheckResult = await _connection?.getData(
          "SELECT * FROM TblStations WHERE StationID = '$componentId'");
      List<dynamic> stationData = jsonDecode(stationCheckResult ?? "[]");

      if (stationData.isEmpty) {
        throw Exception("Invalid Station ID: $componentId");
      }

      // Check 2: Validate Flight ID exists in TblProductionFlights
      final flightCheckResult = await _connection?.getData(
          "SELECT * FROM TblProductionFlights WHERE ID = '$flightId'");
      List<dynamic> flightData = jsonDecode(flightCheckResult ?? "[]");

      if (flightData.isEmpty) {
        throw Exception("Invalid Flight ID: $flightId");
      }

      // Check 3: Check for existing scan (previously implemented)
      final existingScanResult = await _connection?.getData(
          "SELECT * FROM TblComponentsScan WHERE Component = '$componentId' AND FlightID = '$flightId'");
      List<dynamic> existingScanData = jsonDecode(existingScanResult ?? "[]");

      if (existingScanData.isNotEmpty) {
        throw Exception(
            "Component $componentId for Flight $flightId has already been scanned.");
      }

      // Process-specific update based on Station ID
      await _updateProcessSpecificColumns(componentId, flightId, userId);
      // Insert scan record
      if (componentId != '11' && componentId != '12' && componentId != '13') {
        await _connection?.writeData(
            'INSERT INTO TblComponentsScan (ScanDate, ScannedBy, Component, FlightID, ScanTime) VALUES (GETDATE(), $userId, $componentId, $flightId, GETDATE())');
      }
      return 'Component $componentId for Flight $flightId has been successfully scanned.';
    } catch (e) {
      debugPrint("Component scan error: $e");
      throw Exception("$e");
    }
  }

// New method to handle process-specific updates

  Future<void> _updateProcessSpecificColumns(
      String componentId, String flightId, String userId) async {
    switch (componentId) {
      case '1':
        await _connection?.writeData(
            "UPDATE TblProductionFlights SET DateRailsCut = GETDATE(), RailsCutBy = $userId WHERE ID = $flightId");
        break;
      case '2':
        await _connection?.writeData(
            "UPDATE TblProductionFlights SET DateRailsWelded = GETDATE(), RailsWeldedBy = $userId WHERE ID = $flightId");
        break;
      case '3':
        await _connection?.writeData(
            "UPDATE TblProductionFlights SET DateTreadsCut = GETDATE(), TreadsCutBy = $userId WHERE ID = $flightId");
        break;
      case '4':
        await _connection?.writeData(
            "UPDATE TblProductionFlights SET DateStingersCut = GETDATE(), StringersCutBy = $userId WHERE ID = $flightId");
        break;
      case '5':
        await _connection?.writeData(
            "UPDATE TblProductionFlights SET DateAssembled = GETDATE(), AssembledBy = $userId WHERE ID = $flightId");
        break;
      case '6':
        // Special handling for TblProductionLandings with join
        await _connection?.writeData(
            "UPDATE TblProductionLandings SET DateAssembled = GETDATE(), AssembledBy = $userId WHERE AssociatedProjectFlightID = (SELECT ProjectFlightID FROM TblProductionFlights WHERE ID = $flightId)");
        break;
      case '7':
        await _connection?.writeData(
            "UPDATE TblProductionFlights SET DateAnglesCut = GETDATE() WHERE ID = $flightId");
        break;
      case '9':
        await _connection?.writeData(
            "UPDATE TblProductionFlights SET DateBendsCut = GETDATE(), BendsCutBy = $userId WHERE ID = $flightId");
        break;
      case '10':
        await _connection?.writeData(
            "UPDATE TblProductionFlights SET DateBendsCompleted = GETDATE(), BendsCompletedBy = $userId WHERE ID = $flightId");
        break;
      case '11':
        await handlePackagingProcess('11-$flightId', userId);
        break;

      case '12':
        await handleStairDeliveryProcess('12-$flightId', userId);
        break;

      case '13':
        await handleBendsDeliveryProcess('13-$flightId', userId);
        break;
      default:
        throw Exception("Invalid component ID: $componentId");
    }
  }
// Add these methods to the DatabaseService class

// Process 11: Packaging Process
  Future<String?> handlePackagingProcess(String barcode, String userId) async {
    try {
      // Split barcode
      List<String> parts = barcode.split('-');
      if (parts.length != 2 || parts[0] != '11') {
        throw Exception("Invalid packaging barcode format");
      }

      String flightId = parts[1];

      // Lookup IDShaft and StartLevelName
      final shaftResult = await _connection?.getData(
          "SELECT IDShaft, StartLevelName FROM TblProductionFlights WHERE ID = '$flightId'");
      List<dynamic> shaftData = jsonDecode(shaftResult ?? "[]");

      if (shaftData.isEmpty) {
        throw Exception("No flight found with ID $flightId");
      }

      int idShaft = shaftData[0]['IDShaft'];
      String startLevel = shaftData[0]['StartLevelName'];

      // Find related flights
      final relatedFlightsResult = await _connection?.getData(
          "SELECT ID FROM TblProductionFlights WHERE IDShaft = '$idShaft' AND StartLevelName = '$startLevel'");
      List<dynamic> relatedFlights = jsonDecode(relatedFlightsResult ?? "[]");

      // Process each related flight
      for (var flight in relatedFlights) {
        String relatedFlightId = flight['ID'].toString();

        // Perform standard scan checks
        await _connection?.writeData(
            'INSERT INTO TblComponentsScan (ScanDate, ScannedBy, Component, FlightID, ScanTime) VALUES (GETDATE(), $userId, 11, $relatedFlightId, GETDATE())');

        // Update packaging information
        await _connection?.writeData(
            "UPDATE TblProductionFlights SET DatePackaged = GETDATE(), PackagedBy = $userId WHERE ID = $relatedFlightId");

        await _connection?.writeData(
            "UPDATE TblProductionLandings SET DatePackaged = GETDATE(), PackagedBy = $userId WHERE AssociatedProjectFlightID = (SELECT ProjectFlightID FROM TblProductionFlights WHERE ID = $relatedFlightId)");
      }

      return 'Packaging process completed for flights related to $flightId';
    } catch (e) {
      debugPrint("Packaging process error: $e");
      throw Exception("Packaging process failed: $e");
    }
  }

// Process 12: Stair Delivery Process
  Future<String?> handleStairDeliveryProcess(
      String barcode, String userId) async {
    try {
      // Split barcode
      List<String> parts = barcode.split('-');
      if (parts.length != 2 || parts[0] != '12') {
        throw Exception("Invalid stair delivery barcode format");
      }

      String delDocketId = parts[1];

      // Query for flight IDs in delivery docket (excluding assembly type 4)
      final flightsResult = await _connection?.getData(
          "SELECT DISTINCT ProjectFlightID FROM TblDelDocketDetail WHERE IDDelDocket = '$delDocketId' AND IDAssembly <> 4");
      List<dynamic> flights = jsonDecode(flightsResult ?? "[]");

      if (flights.isEmpty) {
        throw Exception("No flights found for delivery docket $delDocketId");
      }

      // Process each flight
      for (var flight in flights) {
        String flightId = flight['FlightID'].toString();

        await _connection?.writeData(
            'INSERT INTO TblComponentsScan (ScanDate, ScannedBy, Component, FlightID, ScanTime) VALUES (GETDATE(), $userId, 12, $flightId, GETDATE())');

        // Update despatch information
        await _connection?.writeData(
            "UPDATE TblProductionLandings SET DateDespatched = GETDATE(), DespatchedBy = $userId, DateRailDespatched = GETDATE(), RailDespatchedBy = $userId WHERE AssociatedProjectFlightID = (SELECT ProjectFlightID FROM TblProductionFlights WHERE ID = $flightId)");

        await _connection?.writeData(
            "UPDATE TblProductionFlights SET DateDespatched = GETDATE(), DespatchedBy = $userId WHERE ID = $flightId");
      }

      return 'Stair delivery process completed for docket $delDocketId';
    } catch (e) {
      debugPrint("Stair delivery process error: $e");
      throw Exception("Stair delivery process failed: $e");
    }
  }

// Process 13: Bends Delivery Process
  Future<String?> handleBendsDeliveryProcess(
      String barcode, String userId) async {
    try {
      // Split barcode
      List<String> parts = barcode.split('-');
      if (parts.length != 2 || parts[0] != '13') {
        throw Exception("Invalid bends delivery barcode format");
      }

      String delDocketId = parts[1];

      // Query for flight IDs in delivery docket (only assembly type 4)
      final flightsResult = await _connection?.getData(
          "SELECT DISTINCT ProjectFlightID FROM TblDelDocketDetail WHERE IDDelDocket = '$delDocketId' AND IDAssembly = 4");
      List<dynamic> flights = jsonDecode(flightsResult ?? "[]");

      if (flights.isEmpty) {
        throw Exception(
            "No bends flights found for delivery docket $delDocketId");
      }

      // Process each flight
      for (var flight in flights) {
        String flightId = flight['FlightID'].toString();

        // Perform standard scan checks
        await _connection?.writeData(
            'INSERT INTO TblComponentsScan (ScanDate, ScannedBy, Component, FlightID, ScanTime) VALUES (GETDATE(), $userId, 13, $flightId, GETDATE())');

        // Update bends despatch information
        await _connection?.writeData(
            "UPDATE TblProductionFlights SET DateBendsDespatched = GETDATE(), BendsDespatchedBy = $userId WHERE ID = $flightId");
      }

      return 'Bends delivery process completed for docket $delDocketId';
    } catch (e) {
      debugPrint("Bends delivery process error: $e");
      throw Exception("Bends delivery process failed: $e");
    }
  }

  Future<void> logout() async {
    try {
      await _connection?.disconnect();
      debugPrint("Connection closed");
    } catch (e) {
      debugPrint("Closing connection error: $e");
    }
  }
}
