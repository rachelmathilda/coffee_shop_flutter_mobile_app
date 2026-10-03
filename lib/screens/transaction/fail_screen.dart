import 'package:flutter/material.dart';
import 'transaction_view.dart';

class FailScreen extends StatelessWidget {
  const FailScreen({super.key});

  @override
  Widget build(BuildContext context) => const TransactionView(success: false);
}
