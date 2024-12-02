class Station {
  final int stationID;
  final String stationDescription;
  final int leadTime;

  Station({
    required this.stationID,
    required this.stationDescription,
    required this.leadTime,
  });

  factory Station.fromJson(Map<String, dynamic> json) {
    return Station(
      stationID: json['StationID'],
      stationDescription: json['StationDescription'],
      leadTime: json['LeadTime'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'StationID': stationID,
      'StationDescription': stationDescription,
      'LeadTime': leadTime,
    };
  }
}
