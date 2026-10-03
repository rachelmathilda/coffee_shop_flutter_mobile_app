class AppConfig {
  static const syntheticEmailDomain = 'users.grind.app';

  static const emailJsServiceId = '';
  static const emailJsTemplateId = '';
  static const emailJsPublicKey = '';
  static const emailJsPrivateKey = '';

  static bool get emailJsConfigured =>
      emailJsServiceId.isNotEmpty &&
      emailJsTemplateId.isNotEmpty &&
      emailJsPublicKey.isNotEmpty;

  static const defaultLat = -6.4027;
  static const defaultLng = 106.9744;

  static const tileUrl =
      'https://{s}.basemaps.cartocdn.com/rastertiles/voyager/{z}/{x}/{y}{r}.png';
  static const tileSubdomains = ['a', 'b', 'c', 'd'];
  static const packageName = 'com.example.coffee_shop';
}
