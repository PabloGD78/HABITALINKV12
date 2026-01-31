import 'package:flutter/material.dart';
import '../../theme/colors.dart';
import '../../services/admin_service.dart';
import '../../widgets/master_layout.dart';
import '../../widgets/admin_sidebar.dart';

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
          _users = allUsers.where((u) => u['tipo'].toString().toLowerCase() == 'comprador').toList();
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return MasterLayout(
      title: "Gestión de Clientes (Compradores)",
      // Marcamos índice 3
      sidebar: const AdminSidebar(selectedIndex: 3),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: SizedBox(
                    width: double.infinity,
                    child: DataTable(
                      columns: const [
                        DataColumn(label: Text("Cliente")),
                        DataColumn(label: Text("Correo")),
                        DataColumn(label: Text("Acciones")),
                      ],
                      rows: _users.map((user) {
                        return DataRow(cells: [
                          DataCell(Text("${user['nombre']} ${user['apellidos']}")),
                          DataCell(Text(user['correo'] ?? "")),
                          DataCell(const Icon(Icons.delete, color: Colors.grey)),
                        ]);
                      }).toList(),
                    ),
                  ),
                ),
              ),
            ),
    );
  }
}