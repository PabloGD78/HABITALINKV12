import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../theme/colors.dart';
import '../../widgets/stat_card.dart'; 
import '../../widgets/admin_sidebar.dart';
// IMPORTANTE: Importamos el MasterLayout para mantener el diseño igual en todas partes
import '../../widgets/master_layout.dart'; 
import '/view/login_page.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  // Ya no necesitamos _selectedIndex aquí porque cada página sabe cuál es su índice
  bool _autoApproveProperties = false; 
  bool _isLoading = true;
  int _totalPropiedades = 0;
  int _totalUsuarios = 0; 
  List<dynamic> _actividadReciente = []; 

  final String _baseUrl = "http://localhost:3000/api"; // Ajusta esto si usas emulador

  @override
  void initState() {
    super.initState();
    _fetchDashboardData();
  }

  Future<void> _fetchDashboardData() async {
    try {
      final response = await http.get(Uri.parse('$_baseUrl/stats/admin'));
      
      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);
        final data = jsonResponse['data'];

        int totalUsers = 0;
        if (data['distribucionUsuarios'] != null) {
          for (var item in data['distribucionUsuarios']) {
            totalUsers += (item['cantidad'] as int);
          }
        }

        if (mounted) {
          setState(() {
            _totalPropiedades = data['totalPropiedades'] ?? 0;
            _totalUsuarios = totalUsers;
            _actividadReciente = data['actividadReciente'] ?? [];
            _isLoading = false;
          });
        }
      } else {
         if (mounted) setState(() => _isLoading = false);
      }
    } catch (e) {
      print("Error cargando dashboard: $e");
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
    // ✅ USAMOS MASTERLAYOUT: Esto arregla el error de "onItemSelected"
    // y mantiene el diseño consistente con la pantalla de Inmuebles.
    return MasterLayout(
      title: "Mesa de Control",
      sidebar: const AdminSidebar(selectedIndex: 0), // Índice 0 es el Dashboard
      actions: [
        IconButton(
          icon: const Icon(Icons.person, color: AppColors.primary),
          onPressed: () => _showAdminProfileDialog(context),
        )
      ],
      body: _isLoading 
        ? const Center(child: CircularProgressIndicator()) 
        : SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ALERTA DE MODO AUTOMÁTICO
                if (_autoApproveProperties)
                  Container(
                    margin: const EdgeInsets.only(bottom: 20),
                    padding: const EdgeInsets.all(15),
                    decoration: BoxDecoration(
                      color: Colors.orange.withOpacity(0.1),
                      border: Border.all(color: Colors.orange),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      children: const [
                        Icon(Icons.warning_amber_rounded, color: Colors.orange),
                        SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            "Modo Aprobación Automática ACTIVADO.",
                            style: TextStyle(color: Colors.deepOrange, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    ),
                  ),

                // TARJETAS DE ESTADÍSTICAS
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
                
                // TABLA DE ACTIVIDAD RECIENTE
                Container(
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
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: const [
                          Text("Últimos Registros", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.primary)),
                          Icon(Icons.access_time, color: Colors.grey, size: 20),
                        ],
                      ),
                      const SizedBox(height: 20),
                      
                      _actividadReciente.isEmpty
                          ? const Padding(
                              padding: EdgeInsets.all(20),
                              child: Text("No hay actividad reciente."),
                            )
                          : ListView.separated(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: _actividadReciente.length,
                              separatorBuilder: (c, i) => const Divider(height: 1),
                              itemBuilder: (context, index) {
                                final user = _actividadReciente[index];
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
                                  title: Text(
                                    user['nombre'] ?? 'Usuario',
                                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                                  ),
                                  subtitle: Text(
                                    "${user['correo']}",
                                    style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
                                  ),
                                  trailing: Chip(
                                    label: Text(
                                      user['tipo'].toString().toUpperCase(),
                                      style: const TextStyle(fontSize: 10, color: Colors.white),
                                    ),
                                    backgroundColor: esComprador ? Colors.green : Colors.blue,
                                    padding: EdgeInsets.zero,
                                  ),
                                );
                              },
                            ),
                    ],
                  ),
                ),
              ],
            ),
          ),
    );
  }

  void _showAdminProfileDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setStateDialog) {
            return AlertDialog(
              scrollable: true,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
              title: Row(
                children: const [
                  Icon(Icons.admin_panel_settings, color: AppColors.primary),
                  SizedBox(width: 10),
                  Text("Perfil Admin"),
                ],
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min, 
                children: [
                    // ... (Tu código del diálogo se mantiene igual)
                    ListTile(
                      leading: const CircleAvatar(child: Text("A")),
                      title: const Text("Super Admin"),
                      subtitle: const Text("admin@habitalink.com"),
                    ),
                    const Divider(),
                    SwitchListTile(
                     title: const Text("Aprobación Auto"),
                     value: _autoApproveProperties,
                     onChanged: (val) {
                       setStateDialog(() => _autoApproveProperties = val);
                       setState(() => _autoApproveProperties = val);
                     },
                    ),
                    const SizedBox(height: 10),
                    ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.red.shade50, foregroundColor: Colors.red),
                      icon: const Icon(Icons.logout),
                      label: const Text("CERRAR SESIÓN"),
                      onPressed: () {
                        Navigator.pop(context); 
                        _handleLogout(); 
                      },
                    ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}