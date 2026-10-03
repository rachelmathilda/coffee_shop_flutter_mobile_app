import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../l10n/strings.dart';
import '../../providers/providers.dart';
import '../../theme/app_theme.dart';
import '../../widgets/buttons.dart';
import '../../widgets/simple_app_bar.dart';

enum PayMethod { card, googlePay, paypal }

class PaymentScreen extends ConsumerStatefulWidget {
  const PaymentScreen({super.key});

  @override
  ConsumerState<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends ConsumerState<PaymentScreen> {
  PayMethod _method = PayMethod.card;
  final _numberCtrl = TextEditingController();
  final _expCtrl = TextEditingController();
  final _cvvCtrl = TextEditingController();
  final _nameCtrl = TextEditingController();
  bool _loading = false;

  @override
  void dispose() {
    _numberCtrl.dispose();
    _expCtrl.dispose();
    _cvvCtrl.dispose();
    _nameCtrl.dispose();
    super.dispose();
  }

  static bool _luhn(String digits) {
    int sum = 0;
    bool alt = false;
    for (int i = digits.length - 1; i >= 0; i--) {
      int n = digits.codeUnitAt(i) - 48;
      if (alt) {
        n *= 2;
        if (n > 9) n -= 9;
      }
      sum += n;
      alt = !alt;
    }
    return sum % 10 == 0;
  }

  static String _brand(String d) {
    if (d.startsWith('4')) return 'visa';
    final two = d.length >= 2 ? int.tryParse(d.substring(0, 2)) ?? 0 : 0;
    final four = d.length >= 4 ? int.tryParse(d.substring(0, 4)) ?? 0 : 0;
    if ((two >= 51 && two <= 55) || (four >= 2221 && four <= 2720)) return 'mastercard';
    if (two == 34 || two == 37) return 'amex';
    if (d.startsWith('35')) return 'jcb';
    return 'card';
  }

  String? _validateCard() {
    final digits = _numberCtrl.text.replaceAll(RegExp(r'\D'), '');
    if (digits.length < 13 || digits.length > 19 || !_luhn(digits)) return 'invalidCard';
    final m = RegExp(r'^(\d{2})/(\d{2})$').firstMatch(_expCtrl.text.trim());
    if (m == null) return 'invalidExpiry';
    final month = int.parse(m.group(1)!);
    final year = 2000 + int.parse(m.group(2)!);
    if (month < 1 || month > 12) return 'invalidExpiry';
    final now = DateTime.now();
    final endOfMonth = DateTime(year, month + 1, 1);
    if (!endOfMonth.isAfter(now)) return 'invalidExpiry';
    final cvv = _cvvCtrl.text.trim();
    if (!RegExp(r'^\d{3,4}$').hasMatch(cvv)) return 'invalidCvv';
    if (_nameCtrl.text.trim().length < 2) return 'invalidName';
    return null;
  }

  Future<void> _pay() async {
    final t = ref.read(stringsProvider);
    final items = ref.read(cartProvider);
    final address = ref.read(deliveryAddressProvider);
    final user = ref.read(authServiceProvider).currentUser;
    if (items.isEmpty || user == null) {
      showMessage(context, t('emptyCart'));
      return;
    }
    if (address == null) {
      showMessage(context, t('chooseAddress'));
      return;
    }
    Map<String, dynamic> payment;
    if (_method == PayMethod.card) {
      final err = _validateCard();
      if (err != null) {
        showMessage(context, t(err));
        return;
      }
      final digits = _numberCtrl.text.replaceAll(RegExp(r'\D'), '');
      payment = {
        'method': 'credit_card',
        'brand': _brand(digits),
        'last4': digits.substring(digits.length - 4),
        'holder': _nameCtrl.text.trim(),
      };
    } else {
      payment = {'method': _method == PayMethod.googlePay ? 'google_pay' : 'paypal'};
    }

    final summary = ref.read(checkoutSummaryProvider);
    final settings = ref.read(appSettingsProvider);
    setState(() => _loading = true);
    try {
      await ref.read(authServiceProvider).placeOrder(
            uid: user.uid,
            items: items,
            subtotal: summary.subtotal,
            discount: summary.discount,
            discountId: summary.appliedDiscount?.id ?? '',
            deliveryFee: summary.deliveryFee,
            total: double.parse(summary.total.toStringAsFixed(2)),
            address: address,
            payment: payment,
            status: 'processing',
            pointsEarned: (summary.total * settings.pointsPerDollar).round(),
          );
      ref.read(cartProvider.notifier).clear();
      ref.read(lastCartKeyProvider.notifier).state = null;
      if (mounted) context.go('/transaction/success');
    } catch (_) {
      if (mounted) context.go('/transaction/fail');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Widget _logo(PayMethod m) {
    switch (m) {
      case PayMethod.card:
        return Image.asset('assets/images/mastercard.png', width: 50, height: 38);
      case PayMethod.googlePay:
        return Image.asset('assets/images/google.png', width: 46, height: 46);
      case PayMethod.paypal:
        return SizedBox(
          width: 46,
          child: Center(
            child: Text(
              'P',
              style: AppText.s(36, weight: FontWeight.w900, color: const Color(0xFF003087)).copyWith(
                fontStyle: FontStyle.italic,
                shadows: const [Shadow(color: Color(0xFF009CDE), offset: Offset(4, -2))],
              ),
            ),
          ),
        );
    }
  }

  String _label(PayMethod m, Strings t) {
    switch (m) {
      case PayMethod.card:
        return t('creditCard');
      case PayMethod.googlePay:
        return 'Google Pay';
      case PayMethod.paypal:
        return 'Paypal';
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = ref.watch(stringsProvider);
    final summary = ref.watch(checkoutSummaryProvider);
    final bottom = MediaQuery.of(context).padding.bottom;
    final others = PayMethod.values.where((m) => m != _method).toList();

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            SimpleTopBar(title: t('payment')),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(26, 0, 26, 20),
                children: [
                  Text(t('totalPrice'), style: AppText.s(20)),
                  Text(money(summary.total), style: AppText.s(30, weight: FontWeight.w600, color: AppColors.terracotta)),
                  const SizedBox(height: 16),
                  Text(t('paymentMethod'), style: AppText.s(20)),
                  const SizedBox(height: 18),
                  Container(
                    height: 78,
                    decoration: BoxDecoration(color: AppColors.creamLight, borderRadius: BorderRadius.circular(10)),
                    padding: const EdgeInsets.symmetric(horizontal: 22),
                    child: Row(
                      children: [
                        _logo(_method),
                        const SizedBox(width: 28),
                        Text(_label(_method, t), style: AppText.s(18)),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),
                  ...others.map((m) => Padding(
                        padding: const EdgeInsets.fromLTRB(20, 0, 20, 10),
                        child: Material(
                          color: AppColors.creamLight,
                          borderRadius: BorderRadius.circular(10),
                          child: InkWell(
                            borderRadius: BorderRadius.circular(10),
                            onTap: () => setState(() => _method = m),
                            child: SizedBox(
                              height: 76,
                              child: Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 26),
                                child: Row(
                                  children: [
                                    _logo(m),
                                    const SizedBox(width: 18),
                                    Expanded(child: Text(_label(m, t), style: AppText.s(18))),
                                    Container(
                                      width: 18,
                                      height: 18,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        border: Border.all(color: AppColors.terracotta, width: 1.4),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      )),
                  if (_method == PayMethod.card) ...[
                    const SizedBox(height: 14),
                    _label2(t('cardNumber')),
                    _Box(
                      controller: _numberCtrl,
                      keyboardType: TextInputType.number,
                      formatters: [FilteringTextInputFormatter.digitsOnly, _CardNumberFormatter()],
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _label2(t('expired')),
                              _Box(
                                controller: _expCtrl,
                                hint: 'MM/YY',
                                keyboardType: TextInputType.number,
                                formatters: [FilteringTextInputFormatter.digitsOnly, _ExpiryFormatter()],
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 28),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _label2(t('cvv')),
                              _Box(
                                controller: _cvvCtrl,
                                obscure: true,
                                keyboardType: TextInputType.number,
                                formatters: [
                                  FilteringTextInputFormatter.digitsOnly,
                                  LengthLimitingTextInputFormatter(4),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    _label2(t('name')),
                    _Box(controller: _nameCtrl, keyboardType: TextInputType.name, caps: true),
                  ],
                ],
              ),
            ),
            Padding(
              padding: EdgeInsets.fromLTRB(19, 0, 25, 16 + bottom),
              child: PrimaryButton(label: t('pay'), onTap: _pay, loading: _loading),
            ),
          ],
        ),
      ),
    );
  }

  Widget _label2(String s) => Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Text(s, style: AppText.s(14)),
      );
}

class _Box extends StatelessWidget {
  final TextEditingController controller;
  final String? hint;
  final bool obscure;
  final bool caps;
  final TextInputType? keyboardType;
  final List<TextInputFormatter>? formatters;

  const _Box({
    required this.controller,
    this.hint,
    this.obscure = false,
    this.caps = false,
    this.keyboardType,
    this.formatters,
  });

  @override
  Widget build(BuildContext context) {
    final border = OutlineInputBorder(
      borderRadius: BorderRadius.circular(10),
      borderSide: const BorderSide(color: Colors.black, width: 1),
    );
    return SizedBox(
      height: 54,
      child: TextField(
        controller: controller,
        obscureText: obscure,
        keyboardType: keyboardType,
        inputFormatters: formatters,
        textCapitalization: caps ? TextCapitalization.characters : TextCapitalization.none,
        style: AppText.s(16),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: AppText.s(16, color: const Color(0xFFB0B0B0)),
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          border: border,
          enabledBorder: border,
          focusedBorder: border.copyWith(borderSide: const BorderSide(color: AppColors.brown, width: 1.4)),
        ),
      ),
    );
  }
}

class _CardNumberFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    var digits = newValue.text.replaceAll(RegExp(r'\D'), '');
    if (digits.length > 19) digits = digits.substring(0, 19);
    final buf = StringBuffer();
    for (int i = 0; i < digits.length; i++) {
      if (i > 0 && i % 4 == 0) buf.write(' ');
      buf.write(digits[i]);
    }
    final text = buf.toString();
    return TextEditingValue(text: text, selection: TextSelection.collapsed(offset: text.length));
  }
}

class _ExpiryFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    var digits = newValue.text.replaceAll(RegExp(r'\D'), '');
    if (digits.length > 4) digits = digits.substring(0, 4);
    final text = digits.length > 2 ? '${digits.substring(0, 2)}/${digits.substring(2)}' : digits;
    return TextEditingValue(text: text, selection: TextSelection.collapsed(offset: text.length));
  }
}
