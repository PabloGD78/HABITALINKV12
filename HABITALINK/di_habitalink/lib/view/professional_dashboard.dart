import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

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

// ---------------- DASHBOARD PROFESIONAL (SOLO MÉTRICAS) ----------------
class ProfessionalDashboard extends StatefulWidget {
  const ProfessionalDashboard({super.key});

  @override
  State<ProfessionalDashboard> createState() => _ProfessionalDashboardState();
}

class _ProfessionalDashboardState extends State<ProfessionalDashboard> {
  final Color _primaryColor = const Color(0xFF0D47A1);
  final Color _accentColor = const Color(0xFFD4AF37);
  final Color _backgroundColor = const Color(0xFFF5F7FA);

  String userName = "Cargando...";
  String? userId;
  bool isLoading = true;
  bool isLoadingAnuncios = true;
  String debugMessage = "";

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

    String storedName = prefs.getString('userName') ?? 'Agente Inmobiliario';

    if (mounted) {
      setState(() {
        userName = storedName;
        userId = finalId;
        isLoading = false;

        if (finalId == null) {
          debugMessage = "ERROR: No se encontró ID. Cierra sesión.";
          isLoadingAnuncios = false;
        }
      });

      if (finalId != null && finalId.isNotEmpty) {
        _cargarAnunciosDelBackend(finalId);
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
        List<dynamic> listaJson = [];
        if (data is Map && data.containsKey('data')) {
          listaJson = data['data'];
        } else if (data is List) {
          listaJson = data;
        }

        List<Anuncio> tempAnuncios = [];
        for (var item in listaJson) {
          String finalImgUrl = 'https://via.placeholder.com/150';
          var rawImg = item['imagenes'] ?? item['imagenPrincipal'];
          // ... Lógica de imagen mantenida
          tempAnuncios.add(
            Anuncio(
              id: item['id'].toString(),
              title: item['nombre'] ?? item['titulo'] ?? 'Sin título',
              price: double.tryParse((item['precio'] ?? 0).toString()) ?? 0.0,
              views: int.tryParse((item['visitas'] ?? 0).toString()) ?? 0,
              contacts: int.tryParse((item['contactos'] ?? 0).toString()) ?? 0,
              expirationDate: DateTime.now(),
              imageUrl: finalImgUrl,
              status: item['estado'] ?? 'Activo',
              tipo: item['tipo'] ?? 'Desconocido',
            ),
          );
        }

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
      if (mounted) {
        setState(() {
          debugMessage = "Error de conexión: $e";
          isLoadingAnuncios = false;
        });
      }
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
              setState(() {
                isLoadingAnuncios = true;
              });
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
              accountEmail: Text(userId ?? "ID Profesional"),
              decoration: BoxDecoration(color: _primaryColor),
              currentAccountPicture: CircleAvatar(
                backgroundColor: Colors.white,
                child: Text(
                  userName.isNotEmpty ? userName[0] : "P",
                  style: TextStyle(color: _primaryColor, fontSize: 24),
                ),
              ),
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
      // EL BODY AHORA SOLO MUESTRA LA VISTA DE ANÁLISIS
      body: isLoadingAnuncios
          ? const Center(child: CircularProgressIndicator())
          : AnalisisCarteraView(
              misAnuncios: misAnuncios,
              primaryColor: _primaryColor,
              accentColor: _accentColor,
            ),
    );
  }
}

// ---------------- VISTA DE ANÁLISIS (SIN CAMBIOS EN LÓGICA) ----------------
class AnalisisCarteraView extends StatelessWidget {
  final List<Anuncio> misAnuncios;
  final Color primaryColor;
  final Color accentColor;

  const AnalisisCarteraView({
    super.key,
    required this.misAnuncios,
    required this.primaryColor,
    required this.accentColor,
  });

  @override
  Widget build(BuildContext context) {
    if (misAnuncios.isEmpty) {
      return const Center(
        child: Text("No hay datos suficientes para el análisis"),
      );
    }

    Map<String, int> conteoTipos = {};
    for (var anuncio in misAnuncios) {
      String rawTipo = anuncio.tipo.trim();
      if (rawTipo.isEmpty) rawTipo = "Otros";
      String tipoKey =
          rawTipo[0].toUpperCase() + rawTipo.substring(1).toLowerCase();
      conteoTipos[tipoKey] = (conteoTipos[tipoKey] ?? 0) + 1;
    }

    var sortedEntries = conteoTipos.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    var maxEntry = sortedEntries.first;
    var minEntry = sortedEntries.last;
    int totalAnuncios = misAnuncios.length;

    List<PieChartSectionData> sections = sortedEntries.map((entry) {
      bool isMax = entry.key == maxEntry.key;
      bool isMin = entry.key == minEntry.key;
      return PieChartSectionData(
        color: isMax
            ? primaryColor
            : (isMin && sortedEntries.length > 1
                  ? accentColor
                  : Colors.grey.shade300),
        value: entry.value.toDouble(),
        title: '${((entry.value / totalAnuncios) * 100).toInt()}%',
        radius: isMax ? 55 : 45,
        titleStyle: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.bold,
          color: (isMax || isMin) ? Colors.white : Colors.black54,
        ),
      );
    }).toList();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          const Text(
            "Distribución de Cartera",
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          const Text(
            "Análisis de volumen por tipo de propiedad",
            style: TextStyle(color: Colors.grey, fontSize: 13),
          ),
          const SizedBox(height: 40),
          SizedBox(
            height: 200,
            child: PieChart(
              PieChartData(
                sections: sections,
                centerSpaceRadius: 40,
                sectionsSpace: 2,
              ),
            ),
          ),
          const SizedBox(height: 40),
          _buildExtremosCard(maxEntry, minEntry, sortedEntries),
        ],
      ),
    );
  }

  Widget _buildExtremosCard(maxEntry, minEntry, List sortedEntries) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "EXTREMOS DE CARTERA",
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: Colors.grey,
            ),
          ),
          const Divider(height: 20),
          _buildResumenRow(
            "Mayor Volumen",
            maxEntry.key,
            maxEntry.value,
            primaryColor,
            Icons.arrow_upward,
          ),
          if (sortedEntries.length > 1) ...[
            const SizedBox(height: 16),
            _buildResumenRow(
              "Oportunidad / Escasez",
              minEntry.key,
              minEntry.value,
              accentColor,
              Icons.star,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildResumenRow(
    String label,
    String tipo,
    int cantidad,
    Color color,
    IconData icon,
  ) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: color, size: 20),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(fontSize: 11, color: Colors.grey),
              ),
              Text(
                tipo,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            "$cantidad",
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }
}
