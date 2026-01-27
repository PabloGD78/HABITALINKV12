import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../theme/colors.dart'; // Asegúrate de que esta ruta sea correcta

class ParticularDashboard extends StatefulWidget {
  const ParticularDashboard({super.key});

  @override
  State<ParticularDashboard> createState() => _ParticularDashboardState();
}

class _ParticularDashboardState extends State<ParticularDashboard> {
  final Color _backgroundColor = const Color(0xFFF3E5CD);
  String userName = "Usuario";
  bool isLoading = true;

  // 1. ESTA VARIABLE CONTROLA QUÉ PANTALLA SE VE
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      userName = prefs.getString('userName') ?? 'Usuario';
      isLoading = false;
    });
  }

  // 2. TÍTULOS DINÁMICOS SEGÚN LA SECCIÓN
  String get _currentTitle {
    switch (_selectedIndex) {
      case 0:
        return 'Mi Gestión';
      case 1:
        return 'Mis Anuncios';
      case 2:
        return 'Estadísticas';
      case 3:
        return 'Configuración';
      default:
        return 'Mi Gestión';
    }
  }

  // 3. AQUÍ DEFINIMOS LAS VISTAS
  Widget _getBodyContent() {
    if (isLoading)
      return Center(child: CircularProgressIndicator(color: AppColors.primary));

    switch (_selectedIndex) {
      case 0:
        return _buildDashboardView();
      case 1:
        return const MisAnunciosView();
      case 2:
        return const EstadisticasView();
      case 3:
        return const ConfiguracionView();
      default:
        return _buildDashboardView();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _backgroundColor,
      appBar: AppBar(
        backgroundColor: _backgroundColor,
        elevation: 0,
        centerTitle: false,
        title: Text(
          _currentTitle,
          style: TextStyle(
            color: AppColors.primary,
            fontWeight: FontWeight.bold,
          ),
        ),
        iconTheme: IconThemeData(color: AppColors.primary),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_none_rounded, size: 28),
            onPressed: () {},
          ),
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: CircleAvatar(
              backgroundColor: AppColors.primary.withOpacity(0.1),
              child: Text(
                userName.isNotEmpty ? userName[0].toUpperCase() : "U",
                style: TextStyle(
                  color: AppColors.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
      drawer: _buildDrawer(context),
      body: _getBodyContent(),
      floatingActionButton: _selectedIndex == 1
          ? FloatingActionButton.extended(
              onPressed: () {},
              label: const Text(
                "Nuevo Anuncio",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              icon: const Icon(Icons.add),
              backgroundColor: AppColors.primary,
            )
          : null,
    );
  }

  // --- VISTA PRINCIPAL (DASHBOARD) ---
  Widget _buildDashboardView() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Hola, $userName",
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w800,
              color: AppColors.primary,
              letterSpacing: -0.5,
            ),
          ),
          Text(
            "Resumen general de tu actividad.",
            style: TextStyle(
              color: AppColors.primary.withOpacity(0.6),
              fontSize: 15,
            ),
          ),
          const SizedBox(height: 25),
          Row(
            children: [
              Expanded(
                child: StatCard(
                  title: "Visitas Totales",
                  value: "842",
                  icon: Icons.visibility_outlined,
                  color: Colors.blue.shade700,
                  bgColor: Colors.white,
                ),
              ),
              const SizedBox(width: 15),
              Expanded(
                child: StatCard(
                  title: "Interesados",
                  value: "24",
                  icon: Icons.chat_bubble_outline,
                  color: Colors.green.shade700,
                  bgColor: Colors.white,
                ),
              ),
            ],
          ),
          const SizedBox(height: 30),
          // Botón grande hacia Estadísticas
          GestureDetector(
            onTap: () {
              setState(() => _selectedIndex = 2);
            },
            child: Container(
              height: 120,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.orange.shade50,
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Icon(
                      Icons.auto_graph_rounded,
                      size: 40,
                      color: Colors.orange,
                    ),
                  ),
                  const SizedBox(width: 20),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "Ver Rendimiento",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primary,
                          ),
                        ),
                        const SizedBox(height: 5),
                        Text(
                          "Consulta la evolución detallada.",
                          style: TextStyle(color: Colors.grey, fontSize: 13),
                        ),
                      ],
                    ),
                  ),
                  Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
                ],
              ),
            ),
          ),
          const SizedBox(height: 30),
          Text(
            "Propiedades destacadas",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: 10),
          AdCard(
            title: "Ático reformado en Centro",
            price: "240.000€",
            views: 152,
            contacts: 8,
            daysLeft: 65,
            imageUrl:
                "https://images.unsplash.com/photo-1512917774080-9991f1c4c750?auto=format&fit=crop&w=300",
            primaryColor: AppColors.primary,
          ),
        ],
      ),
    );
  }

  // --- MENÚ LATERAL (DRAWER) ---
  Drawer _buildDrawer(BuildContext context) {
    return Drawer(
      child: Column(
        children: [
          UserAccountsDrawerHeader(
            decoration: BoxDecoration(
              color: AppColors.primary,
              image: DecorationImage(
                image: NetworkImage(
                  "https://images.unsplash.com/photo-1560518883-ce09059eeffa?auto=format&fit=crop&w=500&q=60",
                ),
                fit: BoxFit.cover,
                colorFilter: ColorFilter.mode(
                  AppColors.primary.withOpacity(0.8),
                  BlendMode.darken,
                ),
              ),
            ),
            accountName: Text(
              userName,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            accountEmail: const Text("Panel de Control"),
            currentAccountPicture: CircleAvatar(
              backgroundColor: Colors.white,
              child: Text(
                userName.isNotEmpty ? userName[0].toUpperCase() : "U",
                style: TextStyle(
                  fontSize: 24,
                  color: AppColors.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          ListTile(
            leading: Icon(
              Icons.dashboard_rounded,
              color: _selectedIndex == 0 ? AppColors.primary : Colors.grey,
            ),
            title: Text(
              'Panel Principal',
              style: TextStyle(
                color: _selectedIndex == 0 ? AppColors.primary : Colors.black87,
                fontWeight: _selectedIndex == 0
                    ? FontWeight.bold
                    : FontWeight.normal,
              ),
            ),
            selected: _selectedIndex == 0,
            onTap: () {
              setState(() => _selectedIndex = 0);
              Navigator.pop(context);
            },
          ),
          ListTile(
            leading: Icon(
              Icons.home_work_outlined,
              color: _selectedIndex == 1 ? AppColors.primary : Colors.grey,
            ),
            title: Text(
              'Mis Anuncios',
              style: TextStyle(
                color: _selectedIndex == 1 ? AppColors.primary : Colors.black87,
                fontWeight: _selectedIndex == 1
                    ? FontWeight.bold
                    : FontWeight.normal,
              ),
            ),
            selected: _selectedIndex == 1,
            onTap: () {
              setState(() => _selectedIndex = 1);
              Navigator.pop(context);
            },
          ),
          ListTile(
            leading: Icon(
              Icons.bar_chart_rounded,
              color: _selectedIndex == 2 ? AppColors.primary : Colors.grey,
            ),
            title: Text(
              'Estadísticas',
              style: TextStyle(
                color: _selectedIndex == 2 ? AppColors.primary : Colors.black87,
                fontWeight: _selectedIndex == 2
                    ? FontWeight.bold
                    : FontWeight.normal,
              ),
            ),
            selected: _selectedIndex == 2,
            onTap: () {
              setState(() => _selectedIndex = 2);
              Navigator.pop(context);
            },
          ),
          const Spacer(),
          const Divider(),
          ListTile(
            leading: Icon(
              Icons.settings_outlined,
              color: _selectedIndex == 3 ? AppColors.primary : Colors.grey,
            ),
            title: Text(
              'Configuración',
              style: TextStyle(
                color: _selectedIndex == 3 ? AppColors.primary : Colors.black87,
                fontWeight: _selectedIndex == 3
                    ? FontWeight.bold
                    : FontWeight.normal,
              ),
            ),
            selected: _selectedIndex == 3,
            onTap: () {
              setState(() => _selectedIndex = 3);
              Navigator.pop(context);
            },
          ),

          // --- AQUÍ ESTÁ EL CAMBIO ---
          ListTile(
            leading: const Icon(Icons.exit_to_app, color: Colors.redAccent),
            title: const Text(
              'Salir', // CAMBIADO DE "Cerrar Sesión" A "Salir"
              style: TextStyle(color: Colors.redAccent),
            ),
            onTap: () {
              Navigator.pop(context); // Cierra el Drawer
              Navigator.pop(context); // Sale de la pantalla (vuelve atrás)
            },
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}

// --- VISTAS INDIVIDUALES ---

class MisAnunciosView extends StatelessWidget {
  const MisAnunciosView({super.key});
  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        AdCard(
          title: "Ático reformado en Centro",
          price: "240.000€",
          views: 152,
          contacts: 8,
          daysLeft: 65,
          imageUrl:
              "https://images.unsplash.com/photo-1512917774080-9991f1c4c750?auto=format&fit=crop&w=300",
          primaryColor: AppColors.primary,
        ),
        AdCard(
          title: "Piso luminoso con terraza",
          price: "185.000€",
          views: 450,
          contacts: 23,
          daysLeft: 5,
          imageUrl:
              "https://images.unsplash.com/photo-1493809842364-78817add7ffb?auto=format&fit=crop&w=300",
          primaryColor: AppColors.primary,
        ),
      ],
    );
  }
}

// --- ESTADÍSTICAS (SOLO GRÁFICO LINEAL) ---
class EstadisticasView extends StatelessWidget {
  const EstadisticasView({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Rendimiento Anual",
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            "Evolución de visitas en los últimos meses",
            style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
          ),
          const SizedBox(height: 20),

          // GRÁFICO DE LÍNEAS
          Container(
            height: 350, // Un poco más alto ahora que está solo
            padding: const EdgeInsets.only(
              right: 20,
              left: 10,
              top: 20,
              bottom: 10,
            ),
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
            child: LineChart(
              LineChartData(
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  getDrawingHorizontalLine: (value) =>
                      FlLine(color: Colors.grey.shade100, strokeWidth: 1),
                ),
                titlesData: FlTitlesData(
                  show: true,
                  rightTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  topTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 30,
                      interval: 1,
                      getTitlesWidget: (value, meta) {
                        const style = TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                          color: Colors.grey,
                        );
                        switch (value.toInt()) {
                          case 0:
                            return const Text('ENE', style: style);
                          case 2:
                            return const Text('MAR', style: style);
                          case 4:
                            return const Text('MAY', style: style);
                          case 6:
                            return const Text('JUL', style: style);
                          case 8:
                            return const Text('SEP', style: style);
                          case 10:
                            return const Text('NOV', style: style);
                        }
                        return const Text('');
                      },
                    ),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      interval: 20,
                      reservedSize: 40,
                      getTitlesWidget: (value, meta) => Text(
                        '${value.toInt()}',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                          color: Colors.grey,
                        ),
                      ),
                    ),
                  ),
                ),
                borderData: FlBorderData(show: false),
                minX: 0,
                maxX: 11,
                minY: 0,
                maxY: 100,
                lineBarsData: [
                  LineChartBarData(
                    spots: const [
                      FlSpot(0, 20),
                      FlSpot(1, 35),
                      FlSpot(2, 28),
                      FlSpot(3, 45),
                      FlSpot(4, 40),
                      FlSpot(5, 60),
                      FlSpot(6, 55),
                      FlSpot(7, 70),
                      FlSpot(8, 65),
                      FlSpot(9, 85),
                      FlSpot(10, 90),
                      FlSpot(11, 80),
                    ],
                    isCurved: true,
                    gradient: LinearGradient(
                      colors: [AppColors.primary, Colors.blueAccent],
                    ),
                    barWidth: 4,
                    isStrokeCapRound: true,
                    dotData: const FlDotData(show: false),
                    belowBarData: BarAreaData(
                      show: true,
                      gradient: LinearGradient(
                        colors: [
                          AppColors.primary.withOpacity(0.3),
                          Colors.blueAccent.withOpacity(0.0),
                        ],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
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

class ConfiguracionView extends StatelessWidget {
  const ConfiguracionView({super.key});
  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        ListTile(
          leading: const Icon(Icons.person),
          title: const Text("Editar Perfil"),
          onTap: () {},
        ),
        ListTile(
          leading: const Icon(Icons.lock),
          title: const Text("Cambiar Contraseña"),
          onTap: () {},
        ),
        ListTile(
          leading: const Icon(Icons.notifications),
          title: const Text("Notificaciones"),
          trailing: Switch(value: true, onChanged: (v) {}),
        ),
      ],
    );
  }
}

// --- WIDGETS AUXILIARES ---

class StatCard extends StatelessWidget {
  final String title, value;
  final IconData icon;
  final Color color, bgColor;
  const StatCard({
    super.key,
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
    required this.bgColor,
  });
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(height: 15),
          Text(
            value,
            style: TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.bold,
              color: Colors.blueGrey.shade900,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            title,
            style: TextStyle(
              color: Colors.blueGrey.shade400,
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
          ),
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
    bool isUrgent = daysLeft <= 7;
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(15),
            child: Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.network(
                    imageUrl,
                    width: 90,
                    height: 90,
                    fit: BoxFit.cover,
                  ),
                ),
                const SizedBox(width: 15),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: Colors.blueGrey.shade900,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        price,
                        style: TextStyle(
                          color: primaryColor,
                          fontWeight: FontWeight.w800,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          _MetricPill(
                            icon: Icons.visibility,
                            value: "$views",
                            color: Colors.blue.shade600,
                          ),
                          const SizedBox(width: 8),
                          _MetricPill(
                            icon: Icons.chat_bubble,
                            value: "$contacts",
                            color: Colors.green.shade600,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(20),
                bottomRight: Radius.circular(20),
              ),
              border: Border(top: BorderSide(color: Colors.grey.shade100)),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.access_time_rounded,
                  size: 14,
                  color: isUrgent ? Colors.orange : Colors.green,
                ),
                const SizedBox(width: 4),
                Text(
                  isUrgent ? "¡Caduca pronto!" : "Activo",
                  style: TextStyle(
                    color: isUrgent ? Colors.orange : Colors.green,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                Text(
                  "Gestión rápida",
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _MetricPill extends StatelessWidget {
  final IconData icon;
  final String value;
  final Color color;
  const _MetricPill({
    required this.icon,
    required this.value,
    required this.color,
  });
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
