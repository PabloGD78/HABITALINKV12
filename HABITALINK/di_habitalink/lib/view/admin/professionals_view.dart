import 'package:flutter/material.dart';
import '../../theme/colors.dart';
import '../../services/admin_service.dart';

class ProfessionalsView extends StatefulWidget {
  const ProfessionalsView({super.key});

  @override
  State<ProfessionalsView> createState() => _ProfessionalsViewState();
}

class _ProfessionalsViewState extends State<ProfessionalsView> {
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
      _users = allUsers.where((u) => u['tipo'].toString().toLowerCase() == 'profesional').toList();
      _isLoading = false;
    });
  }

  void _confirmarBorrado(String id, int index) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Eliminar Profesional"),
        content: const Text("¿Seguro que quieres borrar este profesional de la base de datos?"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancelar")),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text("BORRAR", style: TextStyle(color: Colors.white)),
            onPressed: () async {
              if (await _adminService.deleteUser(id)) {
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
            "Listado de Profesionales",
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
                            DataColumn(label: Text("Nombre / Empresa", style: TextStyle(fontWeight: FontWeight.bold))),
                            DataColumn(label: Text("Email", style: TextStyle(fontWeight: FontWeight.bold))),
                            DataColumn(label: Text("Teléfono", style: TextStyle(fontWeight: FontWeight.bold))),
                            DataColumn(label: Text("Estado", style: TextStyle(fontWeight: FontWeight.bold))),
                            DataColumn(label: Center(child: Text("Acciones", style: TextStyle(fontWeight: FontWeight.bold)))),
                          ],
                          rows: _users.asMap().entries.map((entry) {
                            int index = entry.key;
                            var pro = entry.value;
                            return DataRow(cells: [
                              DataCell(Text(pro['id'].toString().substring(0, 5))),
                              DataCell(Row(
                                children: [
                                  const CircleAvatar(radius: 15, backgroundColor: AppColors.primaryLight, child: Icon(Icons.business, size: 16, color: AppColors.primary)),
                                  const SizedBox(width: 10),
                                  Text("${pro['nombre']} ${pro['apellidos']}", style: const TextStyle(fontWeight: FontWeight.bold)),
                                ],
                              )),
                              DataCell(Text(pro['correo'])),
                              DataCell(Text(pro['tlf'] ?? "---")),
                              DataCell(_buildStatusBadge("Activo")),
                              DataCell(
                                Center(
                                  child: IconButton(
                                    icon: const Icon(Icons.delete, color: Colors.red),
                                    onPressed: () => _confirmarBorrado(pro['id'].toString(), index),
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
    Color color = Colors.green;
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