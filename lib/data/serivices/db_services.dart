import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:mssql_connection/mssql_connection.dart';
import 'package:rapid_rise/models/employee.dart';

class DatabaseService {
  static final DatabaseService _instance = DatabaseService._internal();
  factory DatabaseService() => _instance;
  DatabaseService._internal();

  MssqlConnection? _connection;

  Future<bool> connect({
    required String ip,
    required String port,
    required String username,
    required String password,
    required String databaseName,
  }) async {
    _connection = MssqlConnection.getInstance();

    try {
      final connected = await _connection?.connect(
        ip: ip,
        port: port,
        databaseName: databaseName,
        username: username,
        password: password,
      );

      debugPrint(connected! ? "Connected to SQL Server" : "Connection failed");
      return connected;
    } catch (e) {
      debugPrint("Connection error: $e");
      return false;
    }
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

  // Future<String?> checkAndInsertComponentScan({
  //   required String componentId,
  //   required String flightId,
  //   required String userId,
  // }) async {
  //   try {
  //     final checkResult = await _connection?.getData(
  //       "SELECT * FROM TblComponentsScan WHERE Component = '$componentId' AND FlightID = '$flightId' ",
  //     );

  //     List<dynamic> data = jsonDecode(checkResult ?? "[]");

  //     if (data.isNotEmpty) {
  //       throw Exception(
  //           "Component $componentId for Flight $flightId has already been scanned.");
  //     }

  //     await _connection?.writeData(
  //       'INSERT INTO TblComponentsScan (ScanDate, ScannedBy, Component, FlightID, ScanTime) VALUES (GETDATE(), $userId, $componentId, $flightId, GETDATE())',
  //     );

  //     return 'Component $componentId for Flight $flightId has been successfully scanned.';
  //   } catch (e) {
  //     debugPrint("Component scan error: $e");
  //     throw Exception(" $e"); // Throw a custom error
  //   }
  // }
  Future<String?> checkAndInsertComponentScan({
    required String componentId, // Station ID
    required String flightId,
    required String userId,
  }) async {
    try {
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

      // Insert scan record
      await _connection?.writeData(
          'INSERT INTO TblComponentsScan (ScanDate, ScannedBy, Component, FlightID, ScanTime) VALUES (GETDATE(), $userId, $componentId, $flightId, GETDATE())');

      // Process-specific update based on Station ID
      await _updateProcessSpecificColumns(componentId, flightId, userId);

      return 'Component $componentId for Flight $flightId has been successfully scanned.';
    } catch (e) {
      debugPrint("Component scan error: $e");
      throw Exception("$e");
    }
  }

// New method to handle process-specific updates

  Future<void> _updateProcessSpecificColumns(
      String componentId, String flightId, String userId) async {
    try {
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
        // Additional cases for processes 11, 12, 13 can be added based on the document's specifications
      }
    } catch (e) {
      debugPrint("Process-specific update error: $e");
      throw Exception("Failed to update process-specific columns: $e");
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

      String idShaft = shaftData[0]['IDShaft'];
      String startLevel = shaftData[0]['StartLevelName'];

      // Find related flights
      final relatedFlightsResult = await _connection?.getData(
          "SELECT ID FROM TblProductionFlights WHERE IDShaft = '$idShaft' AND StartLevelName = '$startLevel'");
      List<dynamic> relatedFlights = jsonDecode(relatedFlightsResult ?? "[]");

      // Process each related flight
      for (var flight in relatedFlights) {
        String relatedFlightId = flight['ID'].toString();

        // Perform standard scan checks
        await checkAndInsertComponentScan(
            componentId: '11', flightId: relatedFlightId, userId: userId);

        // Update packaging information
        await _connection?.writeData("""
        UPDATE TblProductionFlights 
        SET DatePackaged = GETDATE(), PackagedBy = $userId 
        WHERE ID = $relatedFlightId;
        
        UPDATE TblProductionLandings 
        SET DatePackaged = GETDATE(), PackagedBy = $userId 
        WHERE AssociatedProjectFlightID = (
          SELECT ProjectFlightID 
          FROM TblProductionFlights 
          WHERE ID = $relatedFlightId
        )
        """);
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
          "SELECT DISTINCT FlightID FROM TblDelDocketDetail WHERE IDDelDocket = '$delDocketId' AND IDAssembly <> 4");
      List<dynamic> flights = jsonDecode(flightsResult ?? "[]");

      if (flights.isEmpty) {
        throw Exception("No flights found for delivery docket $delDocketId");
      }

      // Process each flight
      for (var flight in flights) {
        String flightId = flight['FlightID'].toString();

        // Perform standard scan checks
        await checkAndInsertComponentScan(
            componentId: '12', flightId: flightId, userId: userId);

        // Update despatch information
        await _connection?.writeData("""
        UPDATE TblProductionLandings 
        SET 
          DateDespatched = GETDATE(), 
          DespatchedBy = $userId,
          DateRailDespatched = GETDATE(),
          RailDespatchedBy = $userId
        WHERE AssociatedProjectFlightID = (
          SELECT ProjectFlightID 
          FROM TblProductionFlights 
          WHERE ID = $flightId
        );
        
        UPDATE TblProductionFlights 
        SET 
          DateDespatched = GETDATE(), 
          DespatchedBy = $userId
        WHERE ID = $flightId
        """);
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
          "SELECT DISTINCT FlightID FROM TblDelDocketDetail WHERE IDDelDocket = '$delDocketId' AND IDAssembly = 4");
      List<dynamic> flights = jsonDecode(flightsResult ?? "[]");

      if (flights.isEmpty) {
        throw Exception(
            "No bends flights found for delivery docket $delDocketId");
      }

      // Process each flight
      for (var flight in flights) {
        String flightId = flight['FlightID'].toString();

        // Perform standard scan checks
        await checkAndInsertComponentScan(
            componentId: '13', flightId: flightId, userId: userId);

        // Update bends despatch information
        await _connection?.writeData("""
        UPDATE TblProductionFlights 
        SET 
          DateBendsDespatched = GETDATE(), 
          BendsDespatchedBy = $userId
        WHERE ID = $flightId
        """);
      }

      return 'Bends delivery process completed for docket $delDocketId';
    } catch (e) {
      debugPrint("Bends delivery process error: $e");
      throw Exception("Bends delivery process failed: $e");
    }
  }

// Utility method to validate barcode format
  bool validateBarcodeFormat(String barcode) {
    // Check basic barcode format s-fffff
    RegExp barcodePattern = RegExp(r'^\d+-\d{5}$');
    return barcodePattern.hasMatch(barcode);
  }

// Method to get detailed scan history
  Future<List<dynamic>> getScanHistory({
    String? componentId,
    String? flightId,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      String whereClause = '';
      List<String> conditions = [];

      if (componentId != null) conditions.add("Component = '$componentId'");
      if (flightId != null) conditions.add("FlightID = '$flightId'");
      if (startDate != null)
        conditions.add("ScanDate >= '${startDate.toIso8601String()}'");
      if (endDate != null)
        conditions.add("ScanDate <= '${endDate.toIso8601String()}'");

      if (conditions.isNotEmpty) {
        whereClause = 'WHERE ${conditions.join(' AND ')}';
      }

      final result = await _connection?.getData(
          "SELECT * FROM TblComponentsScan $whereClause ORDER BY ScanDate DESC");

      return jsonDecode(result ?? "[]");
    } catch (e) {
      debugPrint("Scan history retrieval error: $e");
      throw Exception("Failed to retrieve scan history: $e");
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
