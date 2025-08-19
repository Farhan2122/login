class VisitModel {
  final String email;
  final String name;
  final int id;
  final String address;
  final String postalCode;
  final String ville;

  VisitModel({
    required this.email,
    required this.name,
    required this.id,
    required this.address,
    required this.postalCode,
    required this.ville,
  });

  factory VisitModel.fromJson(Map<String, dynamic> json) {
    return VisitModel(
      email: json['email'] ?? 'No Email',
      name: json['nombre_titular'] ?? 'No Name',
      id: json['id'] ?? 0,
      address: json['localidad'] ?? 'No Address',
      postalCode: json['codigo_postal'] ?? '',
      ville: json['provincia_dom'] ?? '',
    );
  }
}
