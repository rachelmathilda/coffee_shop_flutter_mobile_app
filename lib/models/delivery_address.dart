class DeliveryAddress {
  final String address;
  final String detail;
  final double lat;
  final double lng;

  const DeliveryAddress({
    required this.address,
    required this.lat,
    required this.lng,
    this.detail = '',
  });

  DeliveryAddress copyWith({
    String? address,
    String? detail,
    double? lat,
    double? lng,
  }) {
    return DeliveryAddress(
      address: address ?? this.address,
      detail: detail ?? this.detail,
      lat: lat ?? this.lat,
      lng: lng ?? this.lng,
    );
  }
}
