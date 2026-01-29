import 'package:flutter/material.dart';
import '../../theme/colors.dart';
import '../../services/admin_service.dart';

class ClientsView extends StatefulWidget {
  const ClientsView({super.key});

  @override
  State<ClientsView> createState() => _ClientsViewState();
}

class _ClientsViewState extends State<ClientsView> {
  final AdminService _adminService = AdminService();
  List<Map<String, dynamic>> _users = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUsers();
  }

  Future<void> _loadUsers() async {
    setState(() => _isLoading = true);

    try {
      final allUsers = await _adminService.getUsers();

      if (mounted) {
        setState(() {
          // ✅ FILTRO EXACTO: Solo dejamos pasar a los que en la BD pone 'comprador'
          _users = allUsers.where((u) {
            final tipo = u['tipo']?.toString().toLowerCase().trim() ?? '';
            return tipo == 'comprador'; 
          }).toList();
          
          _isLoading = false;
        });
      }
    } catch (e) {
      print("Error: $e");
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _confirmarBorrado(String id, int index) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Eliminar Comprador"),
        content: const Text("¿Estás seguro de que quieres eliminar a este usuario?"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancelar")),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text("ELIMINAR", style: TextStyle(color: Colors.white)),
            onPressed: () async {
              bool success = await _adminService.deleteUser(id);
              if (success && mounted) {
                setState(() => _users.removeAt(index));
                Navigator.pop(context);
              }
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppColors.kPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Gestión de Compradores",
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppColors.primary),
          ),
          const SizedBox(height: 20),
          Expanded(
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)],
              ),
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _users.isEmpty
                      ? const Center(child: Text("No hay usuarios tipo 'comprador' en la base de datos."))
                      : SingleChildScrollView(
                          scrollDirection: Axis.vertical,
                          child: SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: DataTable(
                              headingRowColor: MaterialStateProperty.all(AppColors.primary.withOpacity(0.1)),
                              dataRowHeight: 60,
                              columns: const [
                                DataColumn(label: Text("ID", style: TextStyle(fontWeight: FontWeight.bold))),
                                DataColumn(label: Text("Usuario", style: TextStyle(fontWeight: FontWeight.bold))),
                                DataColumn(label: Text("Email", style: TextStyle(fontWeight: FontWeight.bold))),
                                DataColumn(label: Text("Teléfono", style: TextStyle(fontWeight: FontWeight.bold))),
                                DataColumn(label: Text("Estado", style: TextStyle(fontWeight: FontWeight.bold))),
                                DataColumn(label: Center(child: Text("Acciones", style: TextStyle(fontWeight: FontWeight.bold)))),
                              ],
                              rows: _users.asMap().entries.map((entry) {
                                int index = entry.key;
                                var client = entry.value;
                                
                                String idDisplay = client['id'].toString();
                                String nombre = client['nombre'] ?? "Sin Nombre";
                                String apellido = client['apellidos'] ?? "";
                                String email = client['correo'] ?? "---";
                                String tlf = client['tlf'] ?? "---";

                                return DataRow(cells: [
                                  DataCell(Text(idDisplay)), 
                                  DataCell(
                                    Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        const Icon(Icons.person, size: 20, color: AppColors.primary),
                                        const SizedBox(width: 8),
                                        Container(
                                          constraints: const BoxConstraints(maxWidth: 150),
                                          child: Text(
                                            "$nombre $apellido", 
                                            style: const TextStyle(fontWeight: FontWeight.bold),
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  DataCell(Text(email)),
                                  DataCell(Text(tlf)),
                                  DataCell(_buildStatusBadge("Activo")),
                                  DataCell(
                                    IconButton(
                                      icon: const Icon(Icons.delete, color: Colors.red),
                                      onPressed: () => _confirmarBorrado(idDisplay, index),
                                    ),
                                  ),
                                ]);
                              }).toList(),
                            ),
                          ),
                        ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusBadge(String status) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: Colors.green.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.green),
      ),
      child: Text(status, style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold, fontSize: 12)),
    );
  }
}