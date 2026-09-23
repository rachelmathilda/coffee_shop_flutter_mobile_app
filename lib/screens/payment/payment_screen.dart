import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:go_router/go_router.dart';
import 'package:http/http.dart' as http;
import '../../providers/providers.dart';
import '../../theme/app_theme.dart';

const _paymentWorkerUrl =
    'https://coffee-shop-payment.YOUR_SUBDOMAIN.workers.dev';

class PaymentScreen extends ConsumerStatefulWidget {
  final double total;
  const PaymentScreen({super.key, required this.total});

  @override
  ConsumerState<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends ConsumerState<PaymentScreen> {
  bool _loading = false;

  Future<void> _pay() async {
    setState(() => _loading = true);
    try {
      final amountInCents = (widget.total * 100).round();
      final response = await http.post(
        Uri.parse(_paymentWorkerUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'amount': amountInCents, 'currency': 'usd'}),
      );

      if (response.statusCode != 200) {
        throw Exception('Payment server error: ${response.body}');
      }

      final data = jsonDecode(response.body) as Map<String, dynamic>;
      final clientSecret = data['clientSecret'] as String;

      await Stripe.instance.initPaymentSheet(
        paymentSheetParameters: SetupPaymentSheetParameters(
          paymentIntentClientSecret: clientSecret,
          merchantDisplayName: 'Grind Coffee',
        ),
      );
      await Stripe.instance.presentPaymentSheet();

      ref.read(cartProvider.notifier).clear();
      ref.read(deliveryAddressProvider.notifier).state = null;
      if (mounted) context.go('/transaction/success');
    } on StripeException catch (e) {
      if (e.error.code == FailureCode.Canceled) return;
      if (mounted) context.go('/transaction/fail');
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(e.toString())));
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios,
            color: AppColors.textPrimary,
            size: 20,
          ),
          onPressed: () => context.pop(),
        ),
        title: const Text(
          'Payment',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Total Price',
              style: TextStyle(color: AppColors.textSecondary),
            ),
            const SizedBox(height: 4),
            Text(
              '\$ ${widget.total.toStringAsFixed(2)}',
              style: const TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.w700,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'You will choose a payment method (card, Google Pay, etc.) in the next step.',
              style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
            ),
            const Spacer(),
            ElevatedButton(
              onPressed: _loading ? null : _pay,
              child: _loading
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text('Pay'),
            ),
          ],
        ),
      ),
    );
  }
}
