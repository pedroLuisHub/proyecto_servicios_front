class CobroModel {
  final int? id;
  final int cuentaCobrarId;
  final String fecha;
  final double monto;
  final String metodoPago;

  CobroModel({
    this.id,
    required this.cuentaCobrarId,
    required this.fecha,
    required this.monto,
    required this.metodoPago,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'cuentaCobrarId': cuentaCobrarId,
      'fecha': fecha,
      'monto': monto,
      'metodoPago': metodoPago,
    };
  }

  factory CobroModel.fromMap(Map<String, dynamic> map) {
    return CobroModel(
      id: map['id'],
      cuentaCobrarId: map['cuentaCobrarId'],
      fecha: map['fecha'] ?? '',
      monto: (map['monto'] ?? 0.0).toDouble(),
      metodoPago: map['metodoPago'] ?? 'EFECTIVO',
    );
  }
}
