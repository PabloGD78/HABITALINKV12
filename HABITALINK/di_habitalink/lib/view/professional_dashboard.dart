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
  final Color _backgroundColor = const Color(0xFFF5F7FA);
  final Color _cardColor = Colors.white;

  // Paleta basada en la App para gráficas (Variantes del primario y acentos)
  // Asumimos que AppColors.primary es el verde oscuro/petróleo corporativo.
  late Color _chartColorMain;
  late Color _chartColorSecondary;
  final Color _accentColor = const Color(
    0xFFD4AF37,
  ); // Dorado elegante para destacar

  String agencyName = "Agencia InmoElite";
  String userName = "Usuario";
  bool isLoading = true;
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    _chartColorMain = AppColors.primary;
    _chartColorSecondary = AppColors.primary.withOpacity(0.6);
    _loadData();
  }

  Future<void> _loadData() async {
    final prefs = await SharedPreferences.getInstance();
    await Future.delayed(const Duration(milliseconds: 500));
    if (mounted) {
      setState(() {
        agencyName = prefs.getString('agencyName') ?? 'Agencia InmoElite';
        userName = prefs.getString('userName') ?? 'Pablo';
        isLoading = false;
      });
    }
  }

  String get _currentTitle {
    switch (_selectedIndex) {
      case 0:
        return 'Panel General';
      case 1:
        return 'Rendimiento';
      case 2:
        return 'Leads';
      case 3:
        return 'Configuración';
      default:
        return 'Panel de Control';
    }
  }

  // --- CONTENIDO DEL CUERPO ---
  Widget _getBodyContent() {
    if (isLoading) {
      return Center(child: CircularProgressIndicator(color: AppColors.primary));
    }
    switch (_selectedIndex) {
      case 0:
        return _buildOverviewView();
      case 1:
        return _buildAdsStatsView();
      case 2:
        return _buildLeadsStatsView();
      case 3:
        return const Center(
          child: Text("Configuración", style: TextStyle(color: Colors.grey)),
        );
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
        elevation: 0,
        scrolledUnderElevation: 2,
        centerTitle:
            true, // Título centrado para más elegancia al no tener iconos
        title: Text(
          _currentTitle,
          style: TextStyle(
            color: AppColors.primary,
            fontWeight: FontWeight.w800,
            fontSize: 20,
            letterSpacing: -0.5,
          ),
        ),
        iconTheme: IconThemeData(color: AppColors.primary),
        // Eliminados actions: [] para quitar campanita y avatar
      ),
      drawer: _buildDrawer(context),
      body: _getBodyContent(),
    );
  }

  // --- DRAWER (MENÚ LATERAL) ---
  Widget _buildDrawer(BuildContext context) {
    return Drawer(
      backgroundColor: Colors.white,
      surfaceTintColor: Colors.white,
      child: Column(
        children: [
          _buildDrawerHeader(),
          const SizedBox(height: 10),
          _buildDrawerItem(Icons.dashboard_rounded, "Panel General", 0),
          _buildDrawerItem(Icons.bar_chart_rounded, "Métricas de Anuncios", 1),
          _buildDrawerItem(Icons.people_alt_rounded, "Análisis de Leads", 2),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            child: Divider(color: Colors.black12),
          ),
          _buildDrawerItem(Icons.settings_outlined, "Configuración", 3),
          const Spacer(),
          _buildLogoutButton(),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildDrawerHeader() {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 60, 24, 24),
      decoration: BoxDecoration(color: AppColors.primary),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(2),
            decoration: const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
            child: CircleAvatar(
              radius: 26,
              backgroundColor: Colors.grey[200],
              child: Text(
                userName.isNotEmpty ? userName[0].toUpperCase() : "U",
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  userName,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  agencyName,
                  style: const TextStyle(color: Colors.white70, fontSize: 13),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDrawerItem(IconData icon, String text, int index) {
    bool isSelected = _selectedIndex == index;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      child: ListTile(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        tileColor: isSelected
            ? AppColors.primary.withOpacity(0.08)
            : Colors.transparent,
        leading: Icon(
          icon,
          color: isSelected ? AppColors.primary : Colors.grey[600],
          size: 22,
        ),
        title: Text(
          text,
          style: TextStyle(
            color: isSelected ? AppColors.primary : Colors.grey[700],
            fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
            fontSize: 15,
          ),
        ),
        onTap: () {
          setState(() => _selectedIndex = index);
          Navigator.pop(context);
        },
      ),
    );
  }

  Widget _buildLogoutButton() {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 24),
      leading: const Icon(
        Icons.logout_rounded,
        color: Colors.redAccent,
        size: 22,
      ),
      title: const Text(
        "Salir",
        style: TextStyle(
          color: Colors.redAccent,
          fontWeight: FontWeight.bold,
          fontSize: 15,
        ),
      ),
      onTap: () {
        Navigator.pop(context);
        Navigator.pop(context);
      },
    );
  }

  // ===========================================================================
  // VISTA 1: OVERVIEW
  // ===========================================================================
  Widget _buildOverviewView() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      physics: const BouncingScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Hola, $userName",
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.blueGrey[900],
            ),
          ),
          Text(
            "Resumen de actividad diaria.",
            style: TextStyle(color: Colors.blueGrey[400], fontSize: 14),
          ),
          const SizedBox(height: 24),

          // KPI CARDS - Usando colores de la marca
          Row(
            children: [
              Expanded(
                child: KpiCard(
                  title: "Activos",
                  value: "12",
                  icon: Icons.home_work,
                  trend: "+2",
                  isPositive: true,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: KpiCard(
                  title: "Visitas",
                  value: "1.4k",
                  icon: Icons.visibility,
                  trend: "+12%",
                  isPositive: true,
                  color: _accentColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: KpiCard(
                  title: "Leads",
                  value: "28",
                  icon: Icons.people,
                  trend: "+5",
                  isPositive: true,
                  color: AppColors.primary.withOpacity(0.7),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: KpiCard(
                  title: "Ratio",
                  value: "3.2%",
                  icon: Icons.pie_chart,
                  trend: "-0.4%",
                  isPositive: false,
                  color: Colors.blueGrey,
                ),
              ),
            ],
          ),

          const SizedBox(height: 32),
          _buildSectionTitle("Tráfico Semanal"),
          const SizedBox(height: 16),
          _buildLineChartContainer(),

          const SizedBox(height: 32),
          _buildSectionTitle("Avisos"),
          const SizedBox(height: 16),
          _buildAlertCard(
            "Renovación Pendiente",
            "2 anuncios premium caducan mañana.",
            Icons.timer,
            _accentColor,
          ),
        ],
      ),
    );
  }

  // ===========================================================================
  // VISTA 2: MÉTRICAS DE ANUNCIOS
  // ===========================================================================
  Widget _buildAdsStatsView() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionTitle("Rendimiento por Propiedad"),
          const SizedBox(height: 8),
          const Text(
            "Visitas vs Contactos en top propiedades.",
            style: TextStyle(color: Colors.grey),
          ),
          const SizedBox(height: 24),

          Container(
            height: 300,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: _cardColor,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.04),
                  blurRadius: 15,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: BarChart(
              BarChartData(
                alignment: BarChartAlignment.spaceAround,
                maxY: 20,
                barTouchData: BarTouchData(
                  touchTooltipData: BarTouchTooltipData(
                    getTooltipColor: (_) => Colors.blueGrey,
                  ),
                ),
                titlesData: FlTitlesData(
                  show: true,
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        const style = TextStyle(
                          color: Colors.grey,
                          fontWeight: FontWeight.bold,
                          fontSize: 10,
                        );
                        String text;
                        switch (value.toInt()) {
                          case 0:
                            text = 'Ref-01';
                            break;
                          case 1:
                            text = 'Ref-02';
                            break;
                          case 2:
                            text = 'Ref-03';
                            break;
                          case 3:
                            text = 'Ref-04';
                            break;
                          case 4:
                            text = 'Ref-05';
                            break;
                          default:
                            text = '';
                        }
                        // CORRECCIÓN APLICADA AQUÍ:
                        return SideTitleWidget(
                          meta: meta,
                          space: 4,
                          child: Text(text, style: style),
                        );
                      },
                    ),
                  ),
                  leftTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  topTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  rightTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                ),
                gridData: const FlGridData(show: false),
                borderData: FlBorderData(show: false),
                barGroups: [
                  _makeBarGroup(0, 8, AppColors.primary),
                  _makeBarGroup(1, 15, _accentColor), // Destacado
                  _makeBarGroup(2, 5, Colors.grey.shade400),
                  _makeBarGroup(3, 12, AppColors.primary),
                  _makeBarGroup(4, 9, AppColors.primary.withOpacity(0.6)),
                ],
              ),
            ),
          ),

          const SizedBox(height: 30),
          _buildSectionTitle("Detalle de Actividad"),
          const SizedBox(height: 15),
          Column(
            children: List.generate(
              4,
              (index) => Card(
                elevation: 0,
                color: Colors.white,
                margin: const EdgeInsets.only(bottom: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: BorderSide(color: Colors.grey.shade200),
                ),
                child: ListTile(
                  leading: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      Icons.home_work_outlined,
                      color: AppColors.primary,
                    ),
                  ),
                  title: Text(
                    "Piso en Centro #${index + 20}",
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                  subtitle: Text(
                    "${150 + (index * 20)} visitas",
                    style: const TextStyle(fontSize: 12),
                  ),
                  trailing: const Icon(
                    Icons.trending_up,
                    color: Colors.green,
                    size: 20,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  BarChartGroupData _makeBarGroup(int x, double y, Color color) {
    return BarChartGroupData(
      x: x,
      barRods: [
        BarChartRodData(
          toY: y,
          color: color,
          width: 16,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(6)),
          backDrawRodData: BackgroundBarChartRodData(
            show: true,
            toY: 20,
            color: const Color(0xFFF0F0F0),
          ),
        ),
      ],
    );
  }

  // ===========================================================================
  // VISTA 3: MÉTRICAS DE LEADS
  // ===========================================================================
  Widget _buildLeadsStatsView() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionTitle("Origen de Contactos"),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: Container(
                  height: 120,
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "65%",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        "App Móvil",
                        style: TextStyle(color: Colors.white70),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Container(
                  height: 120,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border.all(color: AppColors.primary),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "35%",
                        style: TextStyle(
                          color: AppColors.primary,
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Text(
                        "Web / Portal",
                        style: TextStyle(color: Colors.grey),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 32),
          _buildSectionTitle("Últimos Interesados"),
          const SizedBox(height: 16),
          Column(
            children: List.generate(
              5,
              (index) => Container(
                margin: const EdgeInsets.only(bottom: 12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.03),
                      blurRadius: 5,
                    ),
                  ],
                ),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: AppColors.primary.withOpacity(0.05),
                    child: Icon(Icons.person, color: AppColors.primary),
                  ),
                  title: Text(
                    "Cliente Potencial ${index + 1}",
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: const Text(
                    "Mensaje: Hola, estoy interesado...",
                    overflow: TextOverflow.ellipsis,
                  ),
                  trailing: Text(
                    "${index + 2}m",
                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // --- WIDGETS AUXILIARES ---

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w800,
        color: Color(0xFF102A43),
      ),
    );
  }

  Widget _buildAlertCard(
    String title,
    String subtitle,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        border: Border.all(color: color.withOpacity(0.3)),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(icon, color: color),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: color.withOpacity(0.9),
                  ),
                ),
                Text(
                  subtitle,
                  style: TextStyle(fontSize: 12, color: color.withOpacity(0.9)),
                ),
              ],
            ),
          ),
          Icon(Icons.arrow_forward_ios, size: 14, color: color),
        ],
      ),
    );
  }

  Widget _buildLineChartContainer() {
    return Container(
      height: 240,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: LineChart(
        LineChartData(
          gridData: FlGridData(
            show: true,
            drawVerticalLine: false,
            getDrawingHorizontalLine: (_) =>
                FlLine(color: Colors.grey.shade100, strokeWidth: 1),
          ),
          titlesData: const FlTitlesData(show: false),
          borderData: FlBorderData(show: false),
          minX: 0,
          maxX: 6,
          minY: 0,
          maxY: 6,
          lineBarsData: [
            LineChartBarData(
              spots: const [
                FlSpot(0, 1),
                FlSpot(1, 3),
                FlSpot(2, 2.5),
                FlSpot(3, 4),
                FlSpot(4, 3.5),
                FlSpot(5, 5),
                FlSpot(6, 4.5),
              ],
              isCurved: true,
              // Gradiente usando el color primario
              gradient: LinearGradient(
                colors: [AppColors.primary, AppColors.primary.withOpacity(0.5)],
              ),
              barWidth: 4,
              isStrokeCapRound: true,
              dotData: const FlDotData(show: false),
              belowBarData: BarAreaData(
                show: true,
                gradient: LinearGradient(
                  colors: [
                    AppColors.primary.withOpacity(0.15),
                    AppColors.primary.withOpacity(0.0),
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class KpiCard extends StatelessWidget {
  final String title, value, trend;
  final IconData icon;
  final bool isPositive;
  final Color color;

  const KpiCard({
    super.key,
    required this.title,
    required this.value,
    required this.icon,
    required this.trend,
    required this.isPositive,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, size: 20, color: color),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: isPositive
                      ? Colors.green.withOpacity(0.1)
                      : Colors.red.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  children: [
                    Icon(
                      isPositive ? Icons.arrow_upward : Icons.arrow_downward,
                      size: 10,
                      color: isPositive ? Colors.green : Colors.red,
                    ),
                    const SizedBox(width: 2),
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
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            value,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w900,
              color: Colors.blueGrey[900],
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: TextStyle(
              fontSize: 12,
              color: Colors.blueGrey[400],
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
