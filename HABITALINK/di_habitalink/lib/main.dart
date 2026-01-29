import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'view/home_page.dart';
import 'view/login_page.dart';
import 'view/register_page.dart';
import 'view/search_results_page.dart';
import 'view/admin/admin_dashboard_screen.dart';
import 'theme/colors.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final prefs = await SharedPreferences.getInstance();
  
  // 1. Leemos el estado del login y el rol guardado
  final bool userLoggedIn = prefs.getBool('userLoggedIn') ?? false;
  final String? userRole = prefs.getString('rol'); // Leemos 'rol'

  runApp(MyApp(userLoggedIn: userLoggedIn, userRole: userRole));
}

class MyApp extends StatelessWidget {
  final bool userLoggedIn;
  final String? userRole;

  const MyApp({super.key, required this.userLoggedIn, this.userRole});

  @override
  Widget build(BuildContext context) {
    // 2. LÓGICA DE RUTA INICIAL
    String initialRoute = '/login';
    
    if (userLoggedIn) {
      if (userRole == 'admin') {
        initialRoute = '/admin_dashboard_screen'; // Si es admin, al panel
      } else {
        initialRoute = '/'; // Si es normal, a la Home
      }
    }

    return MaterialApp(
      title: 'Habitalink Inmobiliaria',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryColor: AppColors.primary,
        appBarTheme: const AppBarTheme(backgroundColor: AppColors.primary),
        fontFamily: 'Roboto',
      ),
      initialRoute: initialRoute, // Usamos la lógica de arriba
      routes: {
        '/': (context) => const HomePage(),
        '/login': (context) => const LoginPage(),
        '/registro': (context) => const RegisterPage(),
        '/search_results': (context) => const SearchResultsPage(),
        '/admin_dashboard_screen': (context) => const AdminDashboardScreen(),
      },
    );
  }
}