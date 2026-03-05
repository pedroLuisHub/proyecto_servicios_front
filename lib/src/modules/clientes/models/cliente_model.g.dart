// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'cliente_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ClienteModel _$ClienteModelFromJson(Map<String, dynamic> json) => ClienteModel(
      id: (json['id'] as num?)?.toInt(),
      ruc: json['ruc'] as String?,
      nombre: json['nombre'] as String,
      telefono: json['telefono'] as String?,
      email: json['email'] as String?,
      direccion: json['direccion'] as String?,
      latitud: (json['latitud'] as num?)?.toDouble(),
      longitud: (json['longitud'] as num?)?.toDouble(),
      estado: json['estado'] as bool? ?? true,
    );

Map<String, dynamic> _$ClienteModelToJson(ClienteModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'ruc': instance.ruc,
      'nombre': instance.nombre,
      'telefono': instance.telefono,
      'email': instance.email,
      'direccion': instance.direccion,
      'latitud': instance.latitud,
      'longitud': instance.longitud,
      'estado': instance.estado,
    };
