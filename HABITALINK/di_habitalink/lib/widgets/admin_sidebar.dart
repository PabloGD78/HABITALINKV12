import 'package:flutter/material.dart';
import '../theme/colors.dart';
import '/view/admin/properties_view.dart';
import '/view/admin/admin_dashboard_screen.dart';

class AdminSidebar extends StatelessWidget {
  final int selectedIndex;

  const AdminSidebar({
    super.key,
    required this.selectedIndex,
  });

  @override
  Widget build(BuildContext context) {
    // Usamos un Material para asegurarnos de que los ListTile detecten el tap
    return Material(
      color: Colors.white,
      child: Container(
        width: 250,
        decoration: BoxDecoration(
          border: Border(right: BorderSide(color: Colors.grey.shade200)),
        ),
        child: Column(
          children: [
            // LOGO
            Container(
              height: 120,
              padding: const EdgeInsets.all(20),
              child: Image.asset("assets/logo/LogoSinFondo.png", fit: BoxFit.contain),
            ),
            const Divider(height: 1),
            
            // MENU
            Expanded(
              child: ListView(
                children: [
                  _buildMenuItem(context, 0, "Dashboard", Icons.dashboard),
                  _buildMenuItem(context, 1, "Profesionales", Icons.business),
                  _buildMenuItem(context, 2, "Particulares", Icons.person),
                  _buildMenuItem(context, 3, "Clientes", Icons.shopping_bag),
                  _buildMenuItem(context, 4, "Inmuebles", Icons.home_work),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuItem(BuildContext context, int index, String title, IconData icon) {
    final isSelected = selectedIndex == index;
    
    return ListTile(
      selected: isSelected,
      leading: Icon(icon, color: isSelected ? AppColors.primary : Colors.grey),
      title: Text(
        title,
        style: TextStyle(
          color: isSelected ? AppColors.primary : Colors.black87,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        ),
      ),
      tileColor: isSelected ? AppColors.primary.withOpacity(0.1) : null,
      onTap: () {
        print("Boton pulsado: $index"); // ESTO DEBE APARECER EN TU CONSOLA

        if (index == selectedIndex) return;

        Widget nextPage;
        switch (index) {
          case 0:
            nextPage = const AdminDashboardScreen();
            break;
          case 4:
            nextPage = const PropertiesView();
            break;
          default:
            _showSnackBar(context, title);
            return;
        }

        // SALTO LIMPIO: Esto evita que las pantallas se amontonen
        Navigator.pushAndRemoveUntil(
          context,
          PageRouteBuilder(
            pageBuilder: (context, animation, secondaryAnimation) => nextPage,
            transitionDuration: Duration.zero, // Estilo Web: instantáneo
          ),
          (route) => false, // Borra el historial para que no se bloquee
        );
      },
    );
  }

  void _showSnackBar(BuildContext context, String title) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Sección $title en desarrollo"), duration: const Duration(milliseconds: 500)),
    );
  }
}