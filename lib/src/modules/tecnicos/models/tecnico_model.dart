import 'package:json_annotation/json_annotation.dart';

part 'tecnico_model.g.dart';

@JsonSerializable()
class TecnicoModel {
  final int? id;
  final String nombre;
  final String? apellido;
  final String? documento;
  final String? telefono;
  final String? especialidad;
  final bool estado;

  TecnicoModel({
    this.id,
    required this.nombre,
    this.apellido,
    this.documento,
    this.telefono,
    this.especialidad,
    this.estado = true,
  });

  factory TecnicoModel.fromJson(Map<String, dynamic> json) => _$TecnicoModelFromJson(json);
  Map<String, dynamic> toJson() => _$TecnicoModelToJson(this);

  // Helper para el nombre completo
  String get nombreCompleto => apellido != null ? '$nombre $apellido' : nombre;
}
