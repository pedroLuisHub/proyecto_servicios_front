import 'package:json_annotation/json_annotation.dart';

part 'cliente_model.g.dart';

@JsonSerializable()
class ClienteModel {
  final int? id;
  final String ruc;
  final String nombre;
  final String? telefono;
  final String? email;
  final String? direccion;
  final double? latitud;
  final double? longitud;
  final bool estado;

  ClienteModel({
    this.id,
    required this.ruc,
    required this.nombre,
    this.telefono,
    this.email,
    this.direccion,
    this.latitud,
    this.longitud,
    this.estado = true,
  });

  factory ClienteModel.fromJson(Map<String, dynamic> json) =>
      _$ClienteModelFromJson(json);
  Map<String, dynamic> toJson() => _$ClienteModelToJson(this);
}
