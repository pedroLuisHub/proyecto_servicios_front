class CuentaCobrarModel {
  final int? id;
  final int? servicioId;
  final int clienteId;
  final String nombreCliente;
  final String? rucCliente;
  final String fechaEmision;
  final String fechaVencimiento;
  final double total;
  final double saldo;
  final String estado;

  CuentaCobrarModel({
    this.id,
    this.servicioId,
    required this.clienteId,
    required this.nombreCliente,
    this.rucCliente,
    required this.fechaEmision,
    required this.fechaVencimiento,
    required this.total,
    required this.saldo,
    required this.estado,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'servicioId': servicioId,
      'clienteId': clienteId,
      'nombreCliente': nombreCliente,
      'rucCliente': rucCliente,
      'fechaEmision': fechaEmision,
      'fechaVencimiento': fechaVencimiento,
      'total': total,
      'saldo': saldo,
      'estado': estado,
    };
  }

  factory CuentaCobrarModel.fromMap(Map<String, dynamic> map) {
    return CuentaCobrarModel(
      id: map['id'],
      servicioId: map['servicioId'],
      clienteId: map['clienteId'],
      nombreCliente: map['nombreCliente'] ?? '',
      rucCliente: map['rucCliente'],
      fechaEmision: map['fechaEmision'] ?? '',
      fechaVencimiento: map['fechaVencimiento'] ?? '',
      total: (map['total'] ?? 0.0).toDouble(),
      saldo: (map['saldo'] ?? 0.0).toDouble(),
      estado: map['estado'] ?? 'PENDIENTE',
    );
  }

  CuentaCobrarModel copyWith({
    int? id,
    int? servicioId,
    int? clienteId,
    String? nombreCliente,
    String? rucCliente,
    String? fechaEmision,
    String? fechaVencimiento,
    double? total,
    double? saldo,
    String? estado,
  }) {
    return CuentaCobrarModel(
      id: id ?? this.id,
      servicioId: servicioId ?? this.servicioId,
      clienteId: clienteId ?? this.clienteId,
      nombreCliente: nombreCliente ?? this.nombreCliente,
      rucCliente: rucCliente ?? this.rucCliente,
      fechaEmision: fechaEmision ?? this.fechaEmision,
      fechaVencimiento: fechaVencimiento ?? this.fechaVencimiento,
      total: total ?? this.total,
      saldo: saldo ?? this.saldo,
      estado: estado ?? this.estado,
    );
  }
}
