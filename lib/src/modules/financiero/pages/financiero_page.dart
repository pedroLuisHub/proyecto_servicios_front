import 'package:flutter/material.dart';
import 'package:flutter_modular/flutter_modular.dart';

class FinancieroPage extends StatelessWidget {
  const FinancieroPage({super.key});

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.inversePrimary;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Módulo Financiero'),
        backgroundColor: primary,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: GridView.count(
          shrinkWrap: true,
          crossAxisCount: 2,
          crossAxisSpacing: 20,
          mainAxisSpacing: 20,
          children: [
            _FinCard(
              title: 'Cuentas\npor Cobrar',
              icon: Icons.receipt_long,
              color: Colors.deepPurple,
              onTap: () => Modular.to.pushNamed('/cuentas/'),
            ),
          ],
        ),
      ),
    );
  }
}

class _FinCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _FinCard({
    required this.title,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(15),
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 50, color: color),
            const SizedBox(height: 10),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
            ),
          ],
        ),
      ),
    );
  }
}
