import 'package:flutter/material.dart';
import '../theme/colors.dart';
// Importa aquí tu vista de propiedades
import '/view/admin/properties_view.dart';

class AdminSidebar extends StatelessWidget {
  final int selectedIndex;

  // Ya no pedimos 'onItemSelected', el sidebar se manda solo
  const AdminSidebar({
    super.key,
    required this.selectedIndex,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 250,
      color: Colors.white,
      child: Column(
        children: [
          // LOGO
          Container(
            height: 150,
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            alignment: Alignment.center,
            child: Image.asset(
              "assets/logo/LogoSinFondo.png",
              fit: BoxFit.contain,
            ),
          ),
          const Divider(height: 1),
          
          // MENU
          _buildMenuItem(context, 0, "Dashboard", Icons.dashboard),
          _buildMenuItem(context, 1, "Profesionales", Icons.business),
          _buildMenuItem(context, 2, "Particulares", Icons.person),
          _buildMenuItem(context, 3, "Clientes", Icons.shopping_bag),
          _buildMenuItem(context, 4, "Inmuebles", Icons.home_work),
        ],
      ),
    );
  }

  Widget _buildMenuItem(BuildContext context, int index, String title, IconData icon) {
    final isSelected = selectedIndex == index;
    
    return ListTile(
      leading: Icon(icon, color: isSelected ? AppColors.primary : Colors.grey),
      title: Text(
        title,
        style: TextStyle(
          color: isSelected ? AppColors.primary : Colors.grey,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        ),
      ),
      tileColor: isSelected ? AppColors.primary.withOpacity(0.1) : null,
      onTap: () {
        // SI YA ESTAMOS EN LA PÁGINA, NO HACEMOS NADA
        if (index == selectedIndex) return;

        // LÓGICA DE NAVEGACIÓN
        Widget nextPage;
        switch (index) {
          case 4:
            nextPage = const PropertiesView();
            break;
          // Agrega aquí los otros casos cuando crees las pantallas:
          // case 0: nextPage = const DashboardView(); break;
          default:
            return; // Si no hay página, no hace nada
        }

        // CAMBIO DE PANTALLA SIN ANIMACIÓN (ESTILO WEB)
        Navigator.pushReplacement(
          context,
          PageRouteBuilder(
            pageBuilder: (_, __, ___) => nextPage,
            transitionDuration: Duration.zero,
            reverseTransitionDuration: Duration.zero,
          ),
        );
      },
    );
  }
}