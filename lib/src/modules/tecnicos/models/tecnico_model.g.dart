// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'tecnico_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TecnicoModel _$TecnicoModelFromJson(Map<String, dynamic> json) => TecnicoModel(
      id: (json['id'] as num?)?.toInt(),
      nombre: json['nombre'] as String,
      apellido: json['apellido'] as String,
      documento: json['documento'] as String,
      telefono: json['telefono'] as String?,
      especialidad: json['especialidad'] as String?,
      estado: json['estado'] as bool? ?? true,
    );

Map<String, dynamic> _$TecnicoModelToJson(TecnicoModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'nombre': instance.nombre,
      'apellido': instance.apellido,
      'documento': instance.documento,
      'telefono': instance.telefono,
      'especialidad': instance.especialidad,
      'estado': instance.estado,
    };
