import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../theme/colors.dart';

class ProfessionalDashboard extends StatefulWidget {
  const ProfessionalDashboard({super.key});

  @override
  State<ProfessionalDashboard> createState() => _ProfessionalDashboardState();
}

class _ProfessionalDashboardState extends State<ProfessionalDashboard> {
  final Color _backgroundColor = const Color(0xFFF5F7FA); // Gris suave
  String agencyName = "Agencia InmoElite";
  bool isLoading = true;
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      agencyName = prefs.getString('agencyName') ?? 'Agencia InmoElite';
      isLoading = false;
    });
  }

  String get _currentTitle {
    switch (_selectedIndex) {
      case 0:
        return 'Panel de Control';
      case 1:
        return 'Cartera de Inmuebles';
      case 2:
        return 'Reportes y Análisis';
      case 3:
        return 'Configuración';
      default:
        return 'Panel de Control';
    }
  }

  Widget _getBodyContent() {
    if (isLoading) {
      return Center(child: CircularProgressIndicator(color: AppColors.primary));
    }
    switch (_selectedIndex) {
      case 0:
        return _buildOverviewView();
      case 1:
        return const ProfessionalListingsView();
      case 2:
        return const ProfessionalReportsView();
      case 3:
        return const Center(child: Text("Configuración"));
      default:
        return _buildOverviewView();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _backgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        title: Text(
          _currentTitle,
          style: TextStyle(
            color: AppColors.primary,
            fontWeight: FontWeight.bold,
          ),
        ),
        iconTheme: IconThemeData(color: AppColors.primary),
        actions: [
          IconButton(icon: const Icon(Icons.search), onPressed: () {}),
          IconButton(
            icon: const Icon(Icons.notifications_active_outlined),
            onPressed: () {},
          ),
          const SizedBox(width: 10),
          CircleAvatar(
            backgroundColor: AppColors.primary,
            radius: 18,
            child: const Text(
              "AG",
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
          ),
          const SizedBox(width: 20),
        ],
      ),
      drawer: _buildDrawer(context), // LLAMADA AL NUEVO DRAWER
      body: _getBodyContent(),
      floatingActionButton: _selectedIndex == 1
          ? FloatingActionButton.extended(
              onPressed: () {},
              backgroundColor: AppColors.primary,
              icon: const Icon(Icons.add_business_rounded),
              label: const Text("Nuevo Inmueble"),
            )
          : null,
    );
  }

  // --- DRAWER ACTUALIZADO ---
  Widget _buildDrawer(BuildContext context) {
    final Color drawerBgColor = const Color(0xFFF4F3F8);
    final Color activeColor = const Color(0xFF2D5D52);
    final Color inactiveColor = const Color(0xFF5E6368);
    final Color logoutColor = const Color(0xFFFF6B6B);

    return Drawer(
      backgroundColor: drawerBgColor,
      child: Column(
        children: [
          // 1. CABECERA
          Container(
            height: 200,
            width: double.infinity,
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: NetworkImage(
                  "https://images.unsplash.com/photo-1560518883-ce09059eeffa?ixlib=rb-4.0.3&auto=format&fit=crop&w=800&q=80",
                ),
                fit: BoxFit.cover,
                colorFilter: ColorFilter.mode(Colors.black45, BlendMode.darken),
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CircleAvatar(
                    radius: 32,
                    backgroundColor: Colors.white,
                    child: Text(
                      "P",
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w500,
                        color: activeColor,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    "Pablo",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    agencyName,
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // 2. LISTA DE ÍTEMS
          const SizedBox(height: 15),

          _buildDrawerItem(
            icon: Icons.grid_view_rounded,
            text: "Panel Principal",
            isSelected: _selectedIndex == 0,
            activeColor: activeColor,
            inactiveColor: inactiveColor,
            onTap: () {
              setState(() => _selectedIndex = 0);
              Navigator.pop(context);
            },
          ),

          _buildDrawerItem(
            icon: Icons.apartment_rounded,
            text: "Cartera de Inmuebles", // <--- NOMBRE CAMBIADO AQUÍ
            isSelected: _selectedIndex == 1,
            activeColor: activeColor,
            inactiveColor: inactiveColor,
            onTap: () {
              setState(() => _selectedIndex = 1);
              Navigator.pop(context);
            },
          ),

          _buildDrawerItem(
            icon: Icons.bar_chart_rounded,
            text: "Estadísticas",
            isSelected: _selectedIndex == 2,
            activeColor: activeColor,
            inactiveColor: inactiveColor,
            onTap: () {
              setState(() => _selectedIndex = 2);
              Navigator.pop(context);
            },
          ),

          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
            child: Divider(color: Colors.black12),
          ),

          _buildDrawerItem(
            icon: Icons.settings_outlined,
            text: "Configuración",
            isSelected: _selectedIndex == 3,
            activeColor: activeColor,
            inactiveColor: inactiveColor,
            onTap: () {
              setState(() => _selectedIndex = 3);
              Navigator.pop(context);
            },
          ),

          const Spacer(),

          // 3. BOTÓN SALIR CON FUNCIONALIDAD
          Padding(
            padding: const EdgeInsets.only(bottom: 30, left: 10, right: 10),
            child: ListTile(
              leading: Icon(Icons.logout_rounded, color: logoutColor, size: 26),
              title: Text(
                "Salir",
                style: TextStyle(
                  color: logoutColor,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
              onTap: () {
                Navigator.pop(context); // Cierra el Drawer
                Navigator.pop(context); // Sale de la pantalla (vuelve atrás)
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDrawerItem({
    required IconData icon,
    required String text,
    required bool isSelected,
    required Color activeColor,
    required Color inactiveColor,
    required VoidCallback onTap,
  }) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 2),
      leading: Icon(
        icon,
        color: isSelected ? activeColor : inactiveColor,
        size: 26,
      ),
      title: Text(
        text,
        style: TextStyle(
          color: isSelected ? activeColor : inactiveColor,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
          fontSize: 16,
        ),
      ),
      onTap: onTap,
    );
  }

  // --- VISTA 1: DASHBOARD ---
  Widget _buildOverviewView() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Resumen Global",
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.blueGrey.shade800,
            ),
          ),
          const SizedBox(height: 15),
          Row(
            children: const [
              Expanded(
                child: KpiCard(
                  title: "Activos",
                  value: "42",
                  icon: Icons.apartment,
                  trend: "+2",
                  isPositive: true,
                ),
              ),
              SizedBox(width: 10),
              Expanded(
                child: KpiCard(
                  title: "Leads (Mes)",
                  value: "128",
                  icon: Icons.people_alt,
                  trend: "+15%",
                  isPositive: true,
                ),
              ),
              SizedBox(width: 10),
              Expanded(
                child: KpiCard(
                  title: "Conversión",
                  value: "3.2%",
                  icon: Icons.pie_chart,
                  trend: "-0.5%",
                  isPositive: false,
                ),
              ),
            ],
          ),
          const SizedBox(height: 25),
          Container(
            padding: const EdgeInsets.all(15),
            decoration: BoxDecoration(
              color: Colors.orange.shade50,
              border: Border.all(color: Colors.orange.shade200),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.warning_amber_rounded,
                  color: Colors.orange,
                  size: 30,
                ),
                const SizedBox(width: 15),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Atención requerida",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.orange,
                        ),
                      ),
                      Text(
                        "5 Anuncios tienen bajo rendimiento y 2 caducan en 48h.",
                        style: TextStyle(
                          color: Colors.orange.shade800,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
                TextButton(onPressed: () {}, child: const Text("Ver")),
              ],
            ),
          ),
          const SizedBox(height: 25),
          Text(
            "Evolución Semanal de Contactos",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.blueGrey.shade800,
            ),
          ),
          const SizedBox(height: 15),
          Container(
            height: 200,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                ),
              ],
            ),
            child: LineChart(
              LineChartData(
                gridData: FlGridData(show: false),
                titlesData: FlTitlesData(show: false),
                borderData: FlBorderData(show: false),
                lineBarsData: [
                  LineChartBarData(
                    spots: const [
                      FlSpot(0, 10),
                      FlSpot(1, 15),
                      FlSpot(2, 12),
                      FlSpot(3, 25),
                      FlSpot(4, 30),
                      FlSpot(5, 28),
                      FlSpot(6, 40),
                    ],
                    isCurved: true,
                    color: AppColors.primary,
                    barWidth: 3,
                    dotData: const FlDotData(show: false),
                    belowBarData: BarAreaData(
                      show: true,
                      color: AppColors.primary.withOpacity(0.1),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// --- VISTA 2: LISTADO DE INMUEBLES ---
class ProfessionalListingsView extends StatelessWidget {
  const ProfessionalListingsView({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.all(15),
      itemCount: 5,
      itemBuilder: (context, index) {
        return Card(
          margin: const EdgeInsets.only(bottom: 15),
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Container(
                    color: Colors.grey.shade300,
                    width: 80,
                    height: 80,
                    child: const Icon(Icons.image, color: Colors.white),
                  ),
                ),
                const SizedBox(width: 15),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Ref: 00${index + 1} - Piso en Centro",
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                        ),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        "240.000€ • 3 Hab • 90m²",
                        style: TextStyle(
                          color: Colors.grey.shade600,
                          fontSize: 13,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          _StatusTag(
                            text: index == 1 ? "Bajo Rendimiento" : "Activo",
                            color: index == 1 ? Colors.orange : Colors.green,
                          ),
                          const Spacer(),
                          Text(
                            "Caduca: 12 días",
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey.shade500,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                IconButton(icon: const Icon(Icons.more_vert), onPressed: () {}),
              ],
            ),
          ),
        );
      },
    );
  }
}

// --- VISTA 3: REPORTES ---
class ProfessionalReportsView extends StatefulWidget {
  const ProfessionalReportsView({super.key});

  @override
  State<ProfessionalReportsView> createState() =>
      _ProfessionalReportsViewState();
}

class _ProfessionalReportsViewState extends State<ProfessionalReportsView> {
  int touchedIndex = -1;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _FilterChip(label: "Últimos 30 días", isSelected: true),
                const SizedBox(width: 8),
                _FilterChip(label: "Por Provincia", isSelected: false),
                const SizedBox(width: 8),
                _FilterChip(label: "Tipo Inmueble", isSelected: false),
                const SizedBox(width: 8),
                _FilterChip(label: "Agente", isSelected: false),
              ],
            ),
          ),
          const SizedBox(height: 25),
          Text(
            "Análisis de Tráfico por Tipo",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.blueGrey.shade800,
            ),
          ),
          const SizedBox(height: 15),
          Container(
            height: 300,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(15),
              boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10)],
            ),
            child: BarChart(
              BarChartData(
                alignment: BarChartAlignment.spaceAround,
                maxY: 20,
                barTouchData: BarTouchData(enabled: true),
                titlesData: FlTitlesData(
                  show: true,
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        switch (value.toInt()) {
                          case 0:
                            return const Text(
                              "Pisos",
                              style: TextStyle(fontSize: 10),
                            );
                          case 1:
                            return const Text(
                              "Casas",
                              style: TextStyle(fontSize: 10),
                            );
                          case 2:
                            return const Text(
                              "Locales",
                              style: TextStyle(fontSize: 10),
                            );
                          case 3:
                            return const Text(
                              "Terrenos",
                              style: TextStyle(fontSize: 10),
                            );
                        }
                        return const Text("");
                      },
                    ),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(showTitles: true, reservedSize: 30),
                  ),
                  topTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  rightTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                ),
                borderData: FlBorderData(show: false),
                barGroups: [
                  BarChartGroupData(
                    x: 0,
                    barRods: [
                      BarChartRodData(toY: 15, color: Colors.blue, width: 15),
                    ],
                  ),
                  BarChartGroupData(
                    x: 1,
                    barRods: [
                      BarChartRodData(toY: 10, color: Colors.blue, width: 15),
                    ],
                  ),
                  BarChartGroupData(
                    x: 2,
                    barRods: [
                      BarChartRodData(toY: 5, color: Colors.blue, width: 15),
                    ],
                  ),
                  BarChartGroupData(
                    x: 3,
                    barRods: [
                      BarChartRodData(toY: 8, color: Colors.blue, width: 15),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 30),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Top Rendimiento",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.blueGrey.shade800,
                ),
              ),
              TextButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.download, size: 16),
                label: const Text("Exportar CSV"),
              ),
            ],
          ),
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: DataTable(
              columnSpacing: 20,
              headingRowHeight: 40,
              columns: const [
                DataColumn(
                  label: Text(
                    "Ref",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                DataColumn(
                  label: Text(
                    "Tipo",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                DataColumn(
                  label: Text(
                    "Visitas",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                DataColumn(
                  label: Text(
                    "Conv %",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ],
              rows: const [
                DataRow(
                  cells: [
                    DataCell(Text("001")),
                    DataCell(Text("Ático")),
                    DataCell(Text("1,240")),
                    DataCell(
                      Text(
                        "2.4%",
                        style: TextStyle(
                          color: Colors.green,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                DataRow(
                  cells: [
                    DataCell(Text("004")),
                    DataCell(Text("Local")),
                    DataCell(Text("850")),
                    DataCell(Text("1.8%")),
                  ],
                ),
                DataRow(
                  cells: [
                    DataCell(Text("012")),
                    DataCell(Text("Chalet")),
                    DataCell(Text("620")),
                    DataCell(
                      Text(
                        "3.1%",
                        style: TextStyle(
                          color: Colors.green,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 50),
        ],
      ),
    );
  }
}

// --- WIDGETS AUXILIARES ---

class KpiCard extends StatelessWidget {
  final String title, value, trend;
  final IconData icon;
  final bool isPositive;
  const KpiCard({
    super.key,
    required this.title,
    required this.value,
    required this.icon,
    required this.trend,
    required this.isPositive,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 4),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 16, color: Colors.grey),
              const Spacer(),
              Text(
                trend,
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: isPositive ? Colors.green : Colors.red,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
          Text(title, style: const TextStyle(fontSize: 11, color: Colors.grey)),
        ],
      ),
    );
  }
}

class _StatusTag extends StatelessWidget {
  final String text;
  final Color color;
  const _StatusTag({required this.text, required this.color});
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: color.withOpacity(0.5)),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.bold,
          color: color,
        ),
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  const _FilterChip({required this.label, required this.isSelected});
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: isSelected ? AppColors.primary : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isSelected ? AppColors.primary : Colors.grey.shade300,
        ),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: isSelected ? Colors.white : Colors.grey.shade700,
          fontSize: 13,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}
