import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:shared_preferences/shared_preferences.dart';

// CORRECCIÓN 1: Importamos los colores de tu proyecto real para evitar el conflicto
// Si este import da error, asegúrate de que la ruta sea correcta según tu estructura de carpetas
import 'package:di_habitalink/theme/colors.dart';

class ParticularDashboard extends StatefulWidget {
  const ParticularDashboard({super.key});

  @override
  State<ParticularDashboard> createState() => _ParticularDashboardState();
}

class _ParticularDashboardState extends State<ParticularDashboard> {
  // Usamos un color de fondo seguro por si AppColors.background no existe en tu tema
  final Color _backgroundColor = const Color(0xFFF5F7FA);

  String userName = "Usuario";
  bool isLoading = true;
  int _selectedIndex = 0; // 0: Dashboard, 1: Estadísticas, 2: Config

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    // Simulación de carga
    await Future.delayed(const Duration(milliseconds: 500));
    if (mounted) {
      setState(() {
        userName = prefs.getString('userName') ?? 'Alberto';
        isLoading = false;
      });
    }
  }

  String get _currentTitle {
    switch (_selectedIndex) {
      case 0:
        return 'Mi Gestión';
      case 1:
        return 'Estadísticas';
      case 2:
        return 'Configuración';
      default:
        return 'Mi Gestión';
    }
  }

  Widget _getBodyContent() {
    if (isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: AppColors.primary),
      );
    }

    switch (_selectedIndex) {
      case 0:
        return _buildDashboardView();
      case 1:
        return const EstadisticasView();
      case 2:
        return const Center(child: Text("Configuración de Cuenta"));
      default:
        return _buildDashboardView();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _backgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        title: Text(
          _currentTitle,
          style: const TextStyle(
            color: AppColors.primary,
            fontWeight: FontWeight.w800,
            fontSize: 20,
          ),
        ),
        iconTheme: const IconThemeData(color: AppColors.primary),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: CircleAvatar(
              radius: 18,
              backgroundColor: AppColors.primary.withOpacity(0.1),
              child: const Icon(
                Icons.person,
                size: 20,
                color: AppColors.primary,
              ),
            ),
          ),
        ],
      ),
      drawer: _buildDrawer(context),
      body: _getBodyContent(),
    );
  }

  // --- VISTA 1: DASHBOARD GENERAL ---
  Widget _buildDashboardView() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Hola, $userName",
            style: TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.w800,
              color: Colors.blueGrey[900],
            ),
          ),
          const SizedBox(height: 5),
          Text(
            "Resumen de rendimiento de tu inmueble.",
            style: TextStyle(color: Colors.blueGrey[400], fontSize: 14),
          ),

          const SizedBox(height: 24),

          // 1. ALERTA DE CADUCIDAD (Banner)
          _buildAlertBanner(),

          const SizedBox(height: 24),

          // 2. TARJETAS DE KPI (Datos rápidos)
          const Row(
            children: [
              Expanded(
                child: StatCard(
                  title: "Visitas Totales",
                  value: "842",
                  icon: Icons.visibility,
                  color: Colors.blue,
                ),
              ),
              SizedBox(width: 16),
              Expanded(
                child: StatCard(
                  title: "Interesados",
                  value: "24",
                  icon: Icons.chat,
                  color: Colors.green,
                ),
              ),
            ],
          ),

          const SizedBox(height: 32),

          const Text(
            "Rendimiento Inmediato",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: 16),

          // Tarjeta de resumen del anuncio principal
          const AdCard(
            title: "Ático reformado en Centro",
            price: "240.000€",
            views: 152,
            contacts: 8,
            daysLeft: 5,
            imageUrl:
                "https://images.unsplash.com/photo-1512917774080-9991f1c4c750?auto=format&fit=crop&w=300",
            primaryColor: AppColors.primary,
          ),
        ],
      ),
    );
  }

  Widget _buildAlertBanner() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF4E5), // Fondo naranja suave
        border: Border.all(color: const Color(0xFFFFCC80)),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.warning_amber_rounded,
            color: Colors.orange,
            size: 28,
          ),
          const SizedBox(width: 16),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Atención requerida",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.orange,
                  ),
                ),
                Text(
                  "Tu anuncio caduca en 5 días.",
                  style: TextStyle(fontSize: 12, color: Colors.black54),
                ),
              ],
            ),
          ),
          TextButton(
            onPressed: () {},
            child: const Text(
              "Renovar",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.orange,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Drawer _buildDrawer(BuildContext context) {
    return Drawer(
      backgroundColor: Colors.white,
      child: Column(
        children: [
          UserAccountsDrawerHeader(
            decoration: const BoxDecoration(color: AppColors.primary),
            accountName: Text(
              userName,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            accountEmail: const Text("Particular Premium"),
            currentAccountPicture: const CircleAvatar(
              backgroundColor: Colors.white,
              child: Icon(Icons.person, size: 30, color: Colors.black87),
            ),
          ),
          _buildDrawerItem(Icons.dashboard, "Mi Gestión", 0),
          _buildDrawerItem(Icons.bar_chart, "Estadísticas", 1),
          _buildDrawerItem(Icons.settings, "Configuración", 2),

          const Spacer(),
          const Divider(),
          _buildDrawerItem(Icons.exit_to_app, "Salir", -1, isDestructive: true),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildDrawerItem(
    IconData icon,
    String title,
    int index, {
    bool isDestructive = false,
  }) {
    bool isSelected = _selectedIndex == index;
    return ListTile(
      leading: Icon(
        icon,
        color: isDestructive
            ? Colors.red
            : (isSelected ? AppColors.primary : Colors.grey),
      ),
      title: Text(
        title,
        style: TextStyle(
          color: isDestructive
              ? Colors.red
              : (isSelected ? AppColors.primary : Colors.black87),
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        ),
      ),
      onTap: () {
        Navigator.pop(context); // Cerrar drawer
        if (index != -1) {
          setState(() => _selectedIndex = index);
        } else {
          // Lógica de salir
          Navigator.pop(context);
        }
      },
    );
  }
}

// --- VISTA DE ESTADÍSTICAS (BAR CHART) ---
class EstadisticasView extends StatelessWidget {
  const EstadisticasView({super.key});

  // CORRECCIÓN: Definimos un color local si AppColors.accent no existe en tu archivo de tema
  Color get _accentColor => const Color(0xFFD4AF37);

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Estadísticas Detalladas",
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
          const Text(
            "Comparativa: Visitas vs Contactos Recibidos",
            style: TextStyle(color: Colors.grey),
          ),
          const SizedBox(height: 24),

          Container(
            height: 350,
            padding: const EdgeInsets.fromLTRB(16, 24, 16, 10),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: BarChart(
              BarChartData(
                alignment: BarChartAlignment.spaceAround,
                maxY: 100,
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
                            text = 'Ene';
                            break;
                          case 1:
                            text = 'Feb';
                            break;
                          case 2:
                            text = 'Mar';
                            break;
                          case 3:
                            text = 'Abr';
                            break;
                          default:
                            text = '';
                        }
                        // CORRECCIÓN 2: Se usa 'meta' en lugar de 'axisSide'
                        // para cumplir con la nueva versión de fl_chart
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
                  rightTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  topTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                ),
                borderData: FlBorderData(show: false),
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  getDrawingHorizontalLine: (_) =>
                      FlLine(color: Colors.grey.shade100),
                ),
                barGroups: [
                  _makeGroupData(0, 65, 12),
                  _makeGroupData(1, 45, 8),
                  _makeGroupData(2, 85, 20),
                  _makeGroupData(3, 55, 15),
                ],
              ),
            ),
          ),

          const SizedBox(height: 24),

          // Leyenda del gráfico
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildLegend(AppColors.primary, "Visitas"),
              const SizedBox(width: 20),
              _buildLegend(_accentColor, "Contactos"),
            ],
          ),

          const SizedBox(height: 30),

          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.blue.shade50,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.blue.shade100),
            ),
            child: Row(
              children: [
                const Icon(Icons.info_outline, color: AppColors.primary),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    "Tu anuncio tiene un 15% más de visibilidad que el mes anterior.",
                    style: TextStyle(color: Colors.blue.shade900),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLegend(Color color, String text) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 6),
        Text(
          text,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.grey,
          ),
        ),
      ],
    );
  }

  BarChartGroupData _makeGroupData(int x, double y1, double y2) {
    return BarChartGroupData(
      barsSpace: 4,
      x: x,
      barRods: [
        BarChartRodData(
          toY: y1,
          color: AppColors.primary,
          width: 12,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
        ),
        BarChartRodData(
          toY: y2,
          color: _accentColor,
          width: 12,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
        ),
      ],
    );
  }
}

// --- WIDGETS REUTILIZABLES ---

class StatCard extends StatelessWidget {
  final String title, value;
  final IconData icon;
  final Color color;
  const StatCard({
    super.key,
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
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
          CircleAvatar(
            backgroundColor: color.withOpacity(0.1),
            radius: 18,
            child: Icon(icon, size: 20, color: color),
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          Text(title, style: const TextStyle(fontSize: 12, color: Colors.grey)),
        ],
      ),
    );
  }
}

class AdCard extends StatelessWidget {
  final String title, price, imageUrl;
  final int views, contacts, daysLeft;
  final Color primaryColor;

  const AdCard({
    super.key,
    required this.title,
    required this.price,
    required this.views,
    required this.contacts,
    required this.daysLeft,
    required this.imageUrl,
    required this.primaryColor,
  });

  @override
  Widget build(BuildContext context) {
    bool isExpired = daysLeft <= 0;
    bool isUrgent = daysLeft > 0 && daysLeft <= 7;

    Color statusColor = isExpired
        ? Colors.red
        : (isUrgent ? Colors.orange : Colors.green);
    String statusText = isExpired
        ? "Caducado"
        : (isUrgent ? "Caduca pronto" : "Activo");

    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: Image.network(
                    imageUrl,
                    width: 80,
                    height: 80,
                    fit: BoxFit.cover,
                    errorBuilder: (c, o, s) => Container(
                      width: 80,
                      height: 80,
                      color: Colors.grey[200],
                      child: const Icon(Icons.home),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        price,
                        style: TextStyle(
                          color: primaryColor,
                          fontWeight: FontWeight.w900,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Icon(
                            Icons.visibility,
                            size: 14,
                            color: Colors.grey[400],
                          ),
                          const SizedBox(width: 4),
                          Text(
                            "$views",
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                            ),
                          ),
                          const SizedBox(width: 12),
                          Icon(
                            Icons.chat_bubble,
                            size: 14,
                            color: Colors.grey[400],
                          ),
                          const SizedBox(width: 4),
                          Text(
                            "$contacts",
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    statusText,
                    style: TextStyle(
                      color: statusColor,
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const Spacer(),
                if (isUrgent || isExpired)
                  TextButton(
                    onPressed: () {},
                    child: Text(
                      "Renovar",
                      style: TextStyle(color: statusColor, fontSize: 12),
                    ),
                  )
                else
                  TextButton(
                    onPressed: () {},
                    child: const Text(
                      "Ver detalles",
                      style: TextStyle(fontSize: 12),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
