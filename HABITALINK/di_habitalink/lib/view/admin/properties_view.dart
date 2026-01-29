import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../theme/colors.dart';
import '../../widgets/master_layout.dart'; 
import '../../widgets/admin_sidebar.dart'; 

class PropertiesView extends StatefulWidget {
  const PropertiesView({super.key});

  @override
  State<PropertiesView> createState() => _PropertiesViewState();
}

class _PropertiesViewState extends State<PropertiesView> {
  List<dynamic> _properties = [];
  bool _isLoading = true;

  final String _baseUrl = "http://localhost:3000/api"; 
  final String _baseImgUrl = "http://localhost:3000/uploads/"; 

  @override
  void initState() {
    super.initState();
    _fetchProperties();
  }

  Future<void> _fetchProperties() async {
    if (!mounted) return;
    setState(() => _isLoading = true);
    try {
      final response = await http.get(Uri.parse('$_baseUrl/properties'));
      if (response.statusCode == 200 && mounted) {
        final data = json.decode(response.body);
        setState(() {
          _properties = data['data'] ?? []; 
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _aprobarPropiedad(String id) async {
    try {
      await http.put(Uri.parse('$_baseUrl/properties/$id/approve'));
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("✅ Inmueble Aprobado"), backgroundColor: Colors.green),
        );
      }
      _fetchProperties(); 
    } catch (e) {
      print(e);
    }
  }

  void _confirmarBorrado(String id) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Eliminar Inmueble"),
        content: const Text("Se borrará permanentemente."),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancelar")),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () async {
              Navigator.pop(context);
              await http.delete(Uri.parse('$_baseUrl/properties/$id'));
              _fetchProperties();
            },
            child: const Text("ELIMINAR", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return MasterLayout(
      title: "Control de Inmuebles",
      // ✅ AQUÍ ESTABA EL CAMBIO IMPORTANTE:
      // Ya no pasamos funciones, solo le decimos "Soy la pantalla 4"
      sidebar: const AdminSidebar(selectedIndex: 4), 
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)],
          ),
          child: _isLoading
              ? const Center(child: Padding(padding: EdgeInsets.all(40), child: CircularProgressIndicator()))
              : _properties.isEmpty 
                  ? const Center(child: Padding(padding: EdgeInsets.all(40), child: Text("No hay propiedades.")))
                  : ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: SingleChildScrollView(
                        scrollDirection: Axis.vertical,
                        child: SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: DataTable(
                            columnSpacing: 25,
                            headingRowColor: MaterialStateProperty.all(AppColors.primary.withOpacity(0.1)),
                            dataRowMinHeight: 70,
                            dataRowMaxHeight: 80,
                            columns: const [
                              DataColumn(label: Text("ID", style: TextStyle(fontWeight: FontWeight.bold))),
                              DataColumn(label: Text("Inmueble", style: TextStyle(fontWeight: FontWeight.bold))),
                              DataColumn(label: Text("Precio", style: TextStyle(fontWeight: FontWeight.bold))),
                              DataColumn(label: Text("Estado", style: TextStyle(fontWeight: FontWeight.bold))),
                              DataColumn(label: Text("Acciones", style: TextStyle(fontWeight: FontWeight.bold))),
                            ],
                            rows: _buildRows(),
                          ),
                        ),
                      ),
                    ),
        ),
      ),
    );
  }

  List<DataRow> _buildRows() {
    return _properties.map((prop) {
      String id = prop['id'].toString();
      String titulo = prop['titulo'] ?? "Sin título";
      String precio = prop['precio']?.toString() ?? "0";
      String estado = prop['estado'] ?? "pendiente";
      String tipo = prop['tipo_operacion'] ?? "Venta";
      
      String? imagenUrl;
      if (prop['imagen_principal'] != null) {
        imagenUrl = "$_baseImgUrl${prop['imagen_principal']}";
      }
      bool isPending = estado == 'pendiente';

      return DataRow(cells: [
        DataCell(Text("#$id", style: const TextStyle(color: Colors.grey, fontSize: 12))),
        
        DataCell(Row(
          mainAxisSize: MainAxisSize.min, 
          children: [
            Container(
              width: 50, height: 50,
              decoration: BoxDecoration(
                color: Colors.grey.shade200,
                borderRadius: BorderRadius.circular(5),
                image: imagenUrl != null
                    ? DecorationImage(image: NetworkImage(imagenUrl), fit: BoxFit.cover)
                    : null,
              ),
              child: imagenUrl == null ? const Icon(Icons.home, color: Colors.grey, size: 20) : null,
            ),
            const SizedBox(width: 10),
            SizedBox(
              width: 140, 
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(titulo, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13), maxLines: 1, overflow: TextOverflow.ellipsis),
                  Text(tipo.toUpperCase(), style: const TextStyle(color: Colors.grey, fontSize: 10)),
                ],
              ),
            ),
          ],
        )),

        DataCell(Text("$precio €", style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.primary))),
        
        DataCell(Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: isPending ? Colors.orange.shade100 : Colors.green.shade100,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Text(
            estado.toUpperCase(),
            style: TextStyle(color: isPending ? Colors.orange.shade800 : Colors.green.shade800, fontSize: 10, fontWeight: FontWeight.bold),
          ),
        )),

        DataCell(Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (isPending)
              IconButton(icon: const Icon(Icons.check_circle, color: Colors.green), onPressed: () => _aprobarPropiedad(id)),
            IconButton(icon: const Icon(Icons.delete, color: Colors.red), onPressed: () => _confirmarBorrado(id)),
          ],
        )),
      ]);
    }).toList();
  }
}