class AppSettings {
  final double deliveryFee;
  final double addInPrice;
  final double sizeM;
  final double sizeL;
  final double customBase;
  final double customSizeM;
  final double customSizeL;
  final double toppingPrice;
  final double pointsPerDollar;

  const AppSettings({
    this.deliveryFee = 1.40,
    this.addInPrice = 0.80,
    this.sizeM = 0.30,
    this.sizeL = 0.60,
    this.customBase = 1.50,
    this.customSizeM = 0.15,
    this.customSizeL = 0.30,
    this.toppingPrice = 0.20,
    this.pointsPerDollar = 1000,
  });

  double sizeExtra(String size) => size == 'L' ? sizeL : (size == 'M' ? sizeM : 0);
  double customSizeExtra(String size) =>
      size == 'L' ? customSizeL : (size == 'M' ? customSizeM : 0);

  factory AppSettings.fromMap(Map<String, dynamic>? m) {
    if (m == null) return const AppSettings();
    double d(String k, double def) => ((m[k] ?? def) as num).toDouble();
    return AppSettings(
      deliveryFee: d('deliveryFee', 1.40),
      addInPrice: d('addInPrice', 0.80),
      sizeM: d('sizeM', 0.30),
      sizeL: d('sizeL', 0.60),
      customBase: d('customBase', 1.50),
      customSizeM: d('customSizeM', 0.15),
      customSizeL: d('customSizeL', 0.30),
      toppingPrice: d('toppingPrice', 0.20),
      pointsPerDollar: d('pointsPerDollar', 1000),
    );
  }
}
