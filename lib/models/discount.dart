import 'package:cloud_firestore/cloud_firestore.dart';

class Discount {
  final String id;
  final String label;
  final String description;
  final DateTime validUntil;

  const Discount({
    required this.id,
    required this.label,
    required this.description,
    required this.validUntil,
  });

  factory Discount.fromMap(Map<String, dynamic> map, String id) {
    return Discount(
      id: id,
      label: map['label'] ?? '',
      description: map['description'] ?? '',
      validUntil: (map['validUntil'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'label': label,
      'description': description,
      'validUntil': Timestamp.fromDate(validUntil),
    };
  }
}
