import 'package:flutter/material.dart';
import '../../theme/colors.dart';
import '../../services/admin_service.dart';

class ParticularesView extends StatefulWidget {
  const ParticularesView({super.key});

  @override
  State<ParticularesView> createState() => _ParticularesViewState();
}

class _ParticularesViewState extends State<ParticularesView> {
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
    final allUsers = await _adminService.getUsers();
    setState(() {
      // Filtramos por tipo Particular según tu base de datos
      _users = allUsers.where((u) => u['tipo'].toString().toLowerCase() == 'particular').toList();
      _isLoading = false;
    });
  }

  void _confirmarBorrado(String id, int index) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Confirmar eliminación"),
        content: const Text("¿Estás seguro de que quieres borrar a este particular?"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancelar")),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text("ELIMINAR", style: TextStyle(color: Colors.white)),
            onPressed: () async {
              bool success = await _adminService.deleteUser(id);
              if (success) {
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
            "Listado de Particulares",
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
                : ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: SingleChildScrollView(
                      scrollDirection: Axis.vertical,
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: DataTable(
                          columnSpacing: 40, 
                          horizontalMargin: 30, 
                          headingRowColor: MaterialStateProperty.all(AppColors.primary.withOpacity(0.1)),
                          dataRowHeight: 60,
                          columns: const [
                            DataColumn(label: Text("ID", style: TextStyle(fontWeight: FontWeight.bold))),
                            DataColumn(label: Text("Nombre Completo", style: TextStyle(fontWeight: FontWeight.bold))),
                            DataColumn(label: Text("Email", style: TextStyle(fontWeight: FontWeight.bold))),
                            DataColumn(label: Text("Teléfono", style: TextStyle(fontWeight: FontWeight.bold))),
                            DataColumn(label: Text("Estado", style: TextStyle(fontWeight: FontWeight.bold))),
                            DataColumn(label: Center(child: Text("Acciones", style: TextStyle(fontWeight: FontWeight.bold)))),
                          ],
                          rows: _users.asMap().entries.map((entry) {
                            int index = entry.key;
                            var user = entry.value;
                            return DataRow(cells: [
                              DataCell(Text(user['id'].toString().substring(0, 5))),
                              DataCell(Row(
                                children: [
                                  const CircleAvatar(
                                    radius: 15, 
                                    backgroundColor: AppColors.accent, 
                                    child: Icon(Icons.person, size: 16, color: Colors.white),
                                  ),
                                  const SizedBox(width: 10),
                                  Text("${user['nombre']} ${user['apellidos']}", style: const TextStyle(fontWeight: FontWeight.bold)),
                                ],
                              )),
                              DataCell(Text(user['correo'])),
                              DataCell(Text(user['tlf'] ?? "---")),
                              DataCell(_buildStatusBadge("Activo")), // Puedes mapear estados reales aquí
                              DataCell(
                                Center(
                                  child: IconButton(
                                    icon: const Icon(Icons.delete, color: Colors.red),
                                    onPressed: () => _confirmarBorrado(user['id'].toString(), index),
                                  ),
                                ),
                              ),
                            ]);
                          }).toList(),
                        ),
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
    Color color = Colors.green; // Por defecto activo al estar en la BD
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color),
      ),
      child: Text(status, style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 12)),
    );
  }
}