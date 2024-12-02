import 'package:rapid_rise/models/station.dart';

class ComponentScan {
  final int scanID;
  final DateTime scanDate;
  final int scannedBy;
  final int stationID; // Updated to reflect the relationship
  final int flightID;
  final DateTime scanTime;
  final Station? station;

  ComponentScan({
    required this.scanID,
    required this.scanDate,
    required this.scannedBy,
    required this.stationID,
    required this.flightID,
    required this.scanTime,
    this.station,
  });

  factory ComponentScan.fromJson(Map<String, dynamic> json) {
    return ComponentScan(
      scanID: json['ScanID'],
      scanDate: DateTime.parse(json['ScanDate']),
      scannedBy: json['ScannedBy'],
      stationID: json['StationID'], // Updated to match query alias
      flightID: json['FlightID'],
      scanTime: DateTime.parse(json['ScanTime']),
      station: json['StationDescription'] != null
          ? Station.fromJson({
              'StationID': json['StationID'],
              'StationDescription': json['StationDescription'],
              'LeadTime': json['LeadTime'],
            })
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'ScanID': scanID,
      'ScanDate': scanDate.toIso8601String(),
      'ScannedBy': scannedBy,
      'StationID': stationID,
      'FlightID': flightID,
      'ScanTime': scanTime.toIso8601String(),
      'Station': station?.toJson(),
    };
  }
}
