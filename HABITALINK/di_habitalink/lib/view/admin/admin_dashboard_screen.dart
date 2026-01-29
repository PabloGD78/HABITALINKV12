import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../theme/colors.dart';
import '../../widgets/stat_card.dart'; 
import '../../widgets/admin_sidebar.dart';
import '../../widgets/master_layout.dart'; 
import '/view/login_page.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  bool _autoApproveProperties = false; 
  bool _isLoading = true;
  int _totalPropiedades = 0;
  int _totalUsuarios = 0; 
  List<dynamic> _actividadReciente = []; 

  final String _baseUrl = "http://localhost:3000/api";

  @override
  void initState() {
    super.initState();
    _fetchDashboardData();
  }

  Future<void> _fetchDashboardData() async {
    try {
      final statsResponse = await http.get(Uri.parse('$_baseUrl/stats/admin'));
      final propResponse = await http.get(Uri.parse('$_baseUrl/propiedades'));

      if (statsResponse.statusCode == 200) {
        final statsJson = json.decode(statsResponse.body);
        final data = statsJson['data'];

        int totalUsers = 0;
        if (data != null && data['distribucionUsuarios'] != null) {
          for (var item in data['distribucionUsuarios']) {
            // SOLUCIÓN AL ERROR DE TIPO: Convertimos cualquier cosa a String y luego a int
            final cantidadValue = item['cantidad'];
            totalUsers += int.tryParse(cantidadValue.toString()) ?? 0;
          }
        }

        int totalProps = 0;
        if (propResponse.statusCode == 200) {
          final propJson = json.decode(propResponse.body);
          if (propJson['success'] == true && propJson['properties'] != null) {
            totalProps = (propJson['properties'] as List).length;
          }
        }

        if (mounted) {
          setState(() {
            _totalUsuarios = totalUsers;
            _totalPropiedades = totalProps;
            _actividadReciente = data['actividadReciente'] ?? [];
            _isLoading = false;
          });
        }
      } else {
        if (mounted) setState(() => _isLoading = false);
      }
    } catch (e) {
      debugPrint("❌ Error cargando dashboard: $e");
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _handleLogout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    if (mounted) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const LoginPage()), 
        (route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return MasterLayout(
      title: "Mesa de Control",
      sidebar: const AdminSidebar(selectedIndex: 0),
      actions: [
        IconButton(
          icon: const Icon(Icons.person, color: AppColors.primary),
          onPressed: () => _showAdminProfileDialog(context),
        )
      ],
      body: _isLoading 
        ? const Center(child: CircularProgressIndicator()) 
        : ListView( // Cambiado a ListView para evitar errores de layout y permitir scroll
            padding: const EdgeInsets.all(20),
            children: [
              if (_autoApproveProperties) _buildAutoApproveBadge(),

              // TARJETAS
              Wrap(
                spacing: 16,
                runSpacing: 16,
                children: [
                  StatCard(
                    title: "Anuncios", 
                    value: _totalPropiedades.toString(), 
                    icon: Icons.home, 
                    iconColor: Colors.blue
                  ),
                  StatCard(
                    title: "Usuarios", 
                    value: _totalUsuarios.toString(), 
                    icon: Icons.people_outline, 
                    iconColor: Colors.green
                  ),
                ],
              ),
              
              const SizedBox(height: 30),
              
              // TABLA
              _buildActivityTable(),
            ],
          ),
    );
  }

  Widget _buildAutoApproveBadge() {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.orange.withOpacity(0.1),
        border: Border.all(color: Colors.orange),
        borderRadius: BorderRadius.circular(10),
      ),
      child: const Row(
        children: [
          Icon(Icons.warning_amber_rounded, color: Colors.orange),
          SizedBox(width: 10),
          Text(
            "Modo Aprobación Automática ACTIVADO.",
            style: TextStyle(color: Colors.deepOrange, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Widget _buildActivityTable() {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)],
      ),
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("Últimos Registros", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.primary)),
              Icon(Icons.access_time, color: Colors.grey, size: 20),
            ],
          ),
          const SizedBox(height: 20),
          if (_actividadReciente.isEmpty)
            const Text("No hay actividad reciente.")
          else
            // Usamos Column en lugar de ListView para evitar conflictos de scroll dentro del MasterLayout
            Column(
              children: _actividadReciente.map((user) {
                final esComprador = user['tipo'] == 'comprador';
                return ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: CircleAvatar(
                    backgroundColor: esComprador ? Colors.green.shade50 : Colors.blue.shade50,
                    child: Icon(
                      esComprador ? Icons.person : Icons.business,
                      color: esComprador ? Colors.green : Colors.blue,
                      size: 20,
                    ),
                  ),
                  title: Text(user['nombre'] ?? 'Usuario', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                  subtitle: Text("${user['correo']}", style: const TextStyle(fontSize: 12)),
                  trailing: Chip(
                    label: Text(user['tipo'].toString().toUpperCase(), style: const TextStyle(fontSize: 10, color: Colors.white)),
                    backgroundColor: esComprador ? Colors.green : Colors.blue,
                  ),
                );
              }).toList(),
            ),
        ],
      ),
    );
  }

  void _showAdminProfileDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Perfil Admin"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const ListTile(
              leading: CircleAvatar(child: Text("A")),
              title: Text("Super Admin"),
              subtitle: Text("admin@habitalink.com"),
            ),
            SwitchListTile(
              title: const Text("Aprobación Auto"),
              value: _autoApproveProperties,
              onChanged: (val) => setState(() => _autoApproveProperties = val),
            ),
            ElevatedButton(
              onPressed: _handleLogout,
              child: const Text("CERRAR SESIÓN"),
            )
          ],
        ),
      ),
    );
  }
}