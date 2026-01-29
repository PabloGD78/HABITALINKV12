import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../theme/colors.dart';

class AgencyDashboardPage extends StatefulWidget {
  const AgencyDashboardPage({super.key});

  @override
  State<AgencyDashboardPage> createState() => _AgencyDashboardPageState();
}

class _AgencyDashboardPageState extends State<AgencyDashboardPage> {
  List<FlSpot> visitSpots = [];
  int totalVisitas = 0;
  int totalContactos = 0;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchStats();
  }

  // --- Función para obtener datos reales del Backend ---
  Future<void> _fetchStats() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String? userId = prefs.getString(
        'userId',
      ); // El ID que guardaste al hacer login

      if (userId == null) {
        setState(() => isLoading = false);
        return;
      }

      // ⚠️ Cambia 'localhost' por tu IP local si pruebas en un móvil físico
      final response = await http.get(
        Uri.parse('http://localhost:3000/api/stats/agencia/$userId'),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonData = json.decode(response.body);
        final List<dynamic> data = jsonData['data'];

        List<FlSpot> tempSpots = [];
        int tempVisitas = 0;
        int tempContactos = 0;

        for (int i = 0; i < data.length; i++) {
          double visitas = double.parse(data[i]['total_visitas'].toString());
          tempVisitas += visitas.toInt();
          tempContactos += int.parse(data[i]['total_contactos'].toString());

          // X = Índice del día, Y = Cantidad de visitas
          tempSpots.add(FlSpot(i.toDouble(), visitas));
        }

        setState(() {
          visitSpots = tempSpots;
          totalVisitas = tempVisitas;
          totalContactos = tempContactos;
          isLoading = false;
        });
      }
    } catch (e) {
      print("Error cargando estadísticas: $e");
      setState(() => isLoading = false);
    }
  }

  Future<void> _logout(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.pageBackground,
      appBar: AppBar(
        title: const Text(
          'Panel Inmobiliario',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: AppColors.primary,
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => _logout(context),
          ),
        ],
      ),
      body: isLoading
          ? const Center(
              child: CircularProgressIndicator(),
            ) // Rueda de carga mientras llegan los datos
          : RefreshIndicator(
              onRefresh:
                  _fetchStats, // Permite arrastrar hacia abajo para actualizar
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Rendimiento de tus Anuncios",
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                      ),
                    ),
                    const Text(
                      "Datos reales de los últimos 30 días",
                      style: TextStyle(color: Colors.grey, fontSize: 14),
                    ),
                    const SizedBox(height: 20),

                    // --- GRÁFICO DINÁMICO ---
                    Container(
                      height: 300,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 10,
                          ),
                        ],
                      ),
                      child: visitSpots.isEmpty
                          ? const Center(
                              child: Text("Sin datos de visitas todavía"),
                            )
                          : LineChart(
                              LineChartData(
                                gridData: const FlGridData(show: false),
                                titlesData: const FlTitlesData(
                                  show: true,
                                  rightTitles: AxisTitles(
                                    sideTitles: SideTitles(showTitles: false),
                                  ),
                                  topTitles: AxisTitles(
                                    sideTitles: SideTitles(showTitles: false),
                                  ),
                                ),
                                borderData: FlBorderData(show: false),
                                lineBarsData: [
                                  LineChartBarData(
                                    spots: visitSpots,
                                    isCurved: true,
                                    color: AppColors.primary,
                                    barWidth: 4,
                                    dotData: const FlDotData(show: true),
                                    belowBarData: BarAreaData(
                                      show: true,
                                      color: AppColors.primary.withOpacity(0.1),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                    ),
                    const SizedBox(height: 30),

                    // --- TARJETAS CON VALORES REALES ---
                    Row(
                      children: [
                        _buildMetricCard(
                          "Visitas Totales",
                          totalVisitas.toString(),
                          Icons.visibility,
                        ),
                        const SizedBox(width: 15),
                        _buildMetricCard(
                          "Contactos",
                          totalContactos.toString(),
                          Icons.message,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildMetricCard(String title, String value, IconData icon) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppColors.primary,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          children: [
            Icon(icon, color: Colors.white, size: 30),
            Text(
              value,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 26,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.white70, fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }
}
