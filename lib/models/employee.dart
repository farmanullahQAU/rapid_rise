class Employee {
  final int employeeID;
  final String firstName;
  final String lastName;
  final String? position;
  final double rate;
  final int? idDepartment;
  final bool isAdminStaff;
  final String password;

  Employee({
    required this.employeeID,
    required this.firstName,
    required this.lastName,
    this.position,
    required this.rate,
    this.idDepartment,
    required this.isAdminStaff,
    required this.password,
  });

  // Factory constructor to create an Employee object from a JSON map
  factory Employee.fromJson(dynamic json) {
    return Employee(
      employeeID: json['EmployeeID'],
      firstName: json['FirstName'],
      lastName: json['LastName'],
      position: json['Position'],
      rate: (json['Rate'] as num).toDouble(),
      idDepartment: json['IDDepartment'],
      isAdminStaff: json['IsAdminStaff'] == 1 ? true : false,
      password: json['Password'],
    );
  }

  // Method to convert an Employee object to a JSON map
  Map<String, dynamic> toJson() {
    return {
      'EmployeeID': employeeID,
      'FirstName': firstName,
      'LastName': lastName,
      'Position': position,
      'Rate': rate,
      'IDDepartment': idDepartment,
      'IsAdminStaff': isAdminStaff,
      'Password': password,
    };
  }
}
