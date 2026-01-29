import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:math';

// ---------------- MODELO ----------------
class Anuncio {
  final String id;
  final String title;
  final double price;
  final int views;
  final int contacts;
  final DateTime expirationDate;
  final String imageUrl;
  final String status;
  final String tipo;

  Anuncio({
    required this.id,
    required this.title,
    required this.price,
    required this.views,
    required this.contacts,
    required this.expirationDate,
    required this.imageUrl,
    required this.status,
    required this.tipo,
  });
}

// ---------------- DASHBOARD ÚNICO (MÉTRICAS) ----------------
class ParticularDashboard extends StatefulWidget {
  const ParticularDashboard({super.key});

  @override
  State<ParticularDashboard> createState() => _ParticularDashboardState();
}

class _ParticularDashboardState extends State<ParticularDashboard> {
  final Color _primaryColor = const Color(0xFF0D47A1);
  final Color _backgroundColor = const Color(0xFFF5F7FA);

  String userName = "Cargando...";
  String? userId;
  bool isLoadingAnuncios = true;
  List<Anuncio> misAnuncios = [];

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    String? finalId =
        prefs.getString('idUsuario') ??
        prefs.getString('userId') ??
        prefs.getString('id');

    String storedName = prefs.getString('userName') ?? 'Usuario';

    if (mounted) {
      setState(() {
        userName = storedName;
        userId = finalId;
      });

      if (finalId != null && finalId.isNotEmpty) {
        _cargarAnunciosDelBackend(finalId);
      } else {
        setState(() => isLoadingAnuncios = false);
      }
    }
  }

  Future<void> _cargarAnunciosDelBackend(String idUsuario) async {
    const String baseUrl = "http://localhost:3000";
    final url = Uri.parse('$baseUrl/api/propiedades/usuario/$idUsuario');

    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        List<dynamic> listaJson = (data is Map && data.containsKey('data'))
            ? data['data']
            : (data is List ? data : []);

        List<Anuncio> tempAnuncios = listaJson.map((item) {
          return Anuncio(
            id: item['id'].toString(),
            title: item['nombre'] ?? item['titulo'] ?? 'Sin título',
            price: double.tryParse((item['precio'] ?? 0).toString()) ?? 0.0,
            views: int.tryParse((item['visitas'] ?? 0).toString()) ?? 0,
            contacts: int.tryParse((item['contactos'] ?? 0).toString()) ?? 0,
            expirationDate: DateTime.now(),
            imageUrl: 'https://via.placeholder.com/150',
            status: item['estado'] ?? 'Activo',
            tipo: item['tipo'] ?? 'Desconocido',
          );
        }).toList();

        if (mounted) {
          setState(() {
            misAnuncios = tempAnuncios;
            isLoadingAnuncios = false;
          });
        }
      } else {
        if (mounted) setState(() => isLoadingAnuncios = false);
      }
    } catch (e) {
      if (mounted) setState(() => isLoadingAnuncios = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _backgroundColor,
      appBar: AppBar(
        title: const Text(
          'Análisis de Cartera',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        foregroundColor: _primaryColor,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              setState(() => isLoadingAnuncios = true);
              _loadUserData();
            },
          ),
        ],
      ),
      drawer: Drawer(
        child: ListView(
          children: [
            UserAccountsDrawerHeader(
              accountName: Text(userName),
              accountEmail: Text(userId ?? "Sin ID"),
              decoration: BoxDecoration(color: _primaryColor),
            ),
            ListTile(
              leading: const Icon(Icons.exit_to_app, color: Colors.red),
              title: const Text("Cerrar Sesión"),
              onTap: () async {
                final prefs = await SharedPreferences.getInstance();
                await prefs.clear();
                Navigator.of(context).pushReplacementNamed('/login');
              },
            ),
          ],
        ),
      ),
      body: isLoadingAnuncios
          ? const Center(child: CircularProgressIndicator())
          : EstadisticasView(misAnuncios: misAnuncios),
    );
  }
}

// =========================================================
//            VISTA DE ESTADÍSTICAS (CORREGIDA)
// =========================================================

class EstadisticasView extends StatelessWidget {
  final List<Anuncio> misAnuncios;
  const EstadisticasView({super.key, required this.misAnuncios});

  @override
  Widget build(BuildContext context) {
    if (misAnuncios.isEmpty) {
      return const Center(child: Text("No hay datos para mostrar gráficos"));
    }

    // Agrupación de datos
    Map<String, int> conteoTipos = {};
    for (var anuncio in misAnuncios) {
      String rawTipo = anuncio.tipo.trim();
      if (rawTipo.isEmpty) rawTipo = "Otros";
      String tipoNormalizado =
          rawTipo[0].toUpperCase() + rawTipo.substring(1).toLowerCase();
      conteoTipos[tipoNormalizado] = (conteoTipos[tipoNormalizado] ?? 0) + 1;
    }

    final List<String> tipos = conteoTipos.keys.toList();
    final List<int> valores = conteoTipos.values.toList();
    double techoY = (valores.reduce(max) + 1).toDouble();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          const Text(
            "Distribución por Tipo",
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          const Text(
            "Cantidad de inmuebles registrados",
            style: TextStyle(color: Colors.grey),
          ),
          const SizedBox(height: 40),

          AspectRatio(
            aspectRatio: 1.5,
            child: BarChart(
              BarChartData(
                alignment: BarChartAlignment.spaceAround,
                maxY: techoY,
                barTouchData: BarTouchData(enabled: true),
                titlesData: FlTitlesData(
                  show: true,
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 40,
                      getTitlesWidget: (value, meta) {
                        int index = value.toInt();
                        if (index >= 0 && index < tipos.length) {
                          // CORRECCIÓN AQUÍ: Uso seguro de SideTitleWidget
                          return SideTitleWidget(
                            meta: meta,
                            space: 8,
                            child: Text(
                              tipos[index],
                              style: const TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          );
                        }
                        return const SizedBox.shrink();
                      },
                    ),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      interval: 1,
                      reservedSize: 30,
                      getTitlesWidget: (value, meta) => Text(
                        value.toInt().toString(),
                        style: const TextStyle(fontSize: 10),
                      ),
                    ),
                  ),
                  topTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  rightTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                ),
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  horizontalInterval: 1,
                ),
                borderData: FlBorderData(show: false),
                barGroups: List.generate(tipos.length, (index) {
                  return BarChartGroupData(
                    x: index,
                    barRods: [
                      BarChartRodData(
                        toY: valores[index].toDouble(),
                        color: Colors.blueAccent,
                        width: 25,
                        borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(4),
                        ),
                      ),
                    ],
                  );
                }),
              ),
            ),
          ),

          const SizedBox(height: 30),
          _buildTableDetail(conteoTipos),
        ],
      ),
    );
  }

  Widget _buildTableDetail(Map<String, int> conteoTipos) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const Text(
              "Resumen de Inventario",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const Divider(height: 20),
            ...conteoTipos.entries.map(
              (e) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 6),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(e.key, style: const TextStyle(fontSize: 15)),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFF0D47A1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        "${e.value}",
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
