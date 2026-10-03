import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class BottomNav extends StatelessWidget {
  final int index;
  final ValueChanged<int> onTap;
  final List<String> labels;

  const BottomNav({super.key, required this.index, required this.onTap, required this.labels});

  static const _icons = [
    Icons.home_outlined,
    Icons.discount_outlined,
    Icons.add_box_outlined,
    Icons.person_outline,
  ];

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.of(context).padding.bottom;
    return Container(
      height: 76 + bottom,
      padding: EdgeInsets.only(bottom: bottom),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(26)),
        border: Border(top: BorderSide(color: Color(0xFF9E9E9E), width: 1)),
      ),
      child: Row(
        children: List.generate(4, (i) {
          final active = i == index;
          final color = active ? AppColors.charcoal : AppColors.navGrey;
          return Expanded(
            child: InkWell(
              onTap: () => onTap(i),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(_icons[i], size: 30, color: color),
                  const SizedBox(height: 2),
                  Text(labels[i], style: AppText.s(11, color: color)),
                ],
              ),
            ),
          );
        }),
      ),
    );
  }
}
