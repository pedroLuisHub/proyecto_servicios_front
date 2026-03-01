import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:flutter_modular/flutter_modular.dart';
import '../home_controller.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final controller = Modular.get<HomeController>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gestión de Servicios'),
        centerTitle: true,
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 20),
            // Área del Logo
            Observer(
              builder: (_) => GestureDetector(
                onTap: controller.selectLogo,
                child: Container(
                  height: 150,
                  width: 150,
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(75),
                    border: Border.all(color: Colors.blueGrey),
                  ),
                  child: controller.logoPath == null
                      ? const Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.add_a_photo, size: 40, color: Colors.blueGrey),
                            Text('Seleccionar Logo', style: TextStyle(fontSize: 12)),
                          ],
                        )
                      : ClipRRect(
                          borderRadius: BorderRadius.circular(75),
                          child: Image.file(
                            File(controller.logoPath!),
                            fit: BoxFit.cover,
                          ),
                        ),
                ),
              ),
            ),
            const SizedBox(height: 40),
            // Cuadrícula de Menú
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: 2,
                crossAxisSpacing: 20,
                mainAxisSpacing: 20,
                children: [
                  _MenuCard(
                    title: 'Técnicos',
                    icon: Icons.engineering,
                    color: Colors.blue,
                    onTap: () => Modular.to.pushNamed('/tecnicos/'),
                  ),
                  _MenuCard(
                    title: 'Servicios',
                    icon: Icons.handyman,
                    color: Colors.orange,
                    onTap: () => Modular.to.pushNamed('/servicios/'),
                  ),
                  _MenuCard(
                    title: 'Clientes',
                    icon: Icons.people,
                    color: Colors.green,
                    onTap: () => Modular.to.pushNamed('/clientes/'),
                  ),
                  _MenuCard(
                    title: 'Presupuestos',
                    icon: Icons.request_quote,
                    color: Colors.purple,
                    onTap: () => Modular.to.pushNamed('/presupuestos/'),
                  ),
                  _MenuCard(
                    title: 'Inventario',
                    icon: Icons.inventory_2,
                    color: Colors.teal,
                    onTap: () => Modular.to.pushNamed('/productos/'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MenuCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _MenuCard({
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
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }
}
