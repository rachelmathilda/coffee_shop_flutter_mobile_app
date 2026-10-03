import 'package:flutter/material.dart';
import 'transaction_view.dart';

class SuccessScreen extends StatelessWidget {
  const SuccessScreen({super.key});

  @override
  Widget build(BuildContext context) => const TransactionView(success: true);
}
