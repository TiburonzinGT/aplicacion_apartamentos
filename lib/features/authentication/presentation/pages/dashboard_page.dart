import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../widgets/login_form.dart';

class DashboardPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF325259),
      appBar: AppBar(
        title: Text(
          'Dashboard',
          style: TextStyle(
            fontSize: 30,
            color: Colors.white,
          ),
        ),
        backgroundColor: Color.fromARGB(255, 39, 62, 66),
        toolbarHeight: 150.0,
        leading: Builder(
          builder: (context) {
            return IconButton(
              icon: const Icon(
                Icons.menu,
                color: Colors.white,
                size: 40,
              ),
              onPressed: () {
                Scaffold.of(context).openDrawer(); // Abre el Drawer
              },
            );
          },
        ),
      ),
      drawer: Drawer(
        child: Container(
          color: Color(0xFF325259), // Color de fondo del Drawer
          child: ListView(
            padding: EdgeInsets.zero,
            children: <Widget>[
              DrawerHeader(
                child: Text(
                  'Menú',
                  style: TextStyle(
                    color: Colors.black, // Color del texto del DrawerHeader
                    fontSize: 30.0,
                  ),
                ),
                decoration: BoxDecoration(
                  color: Color(0xFF05F29B), // Color de fondo del DrawerHeader
                ),
              ),
              ListTile(
                leading: Icon(Icons.home, color: Colors.white),
                title: Text(
                  'Inicio',
                  style: TextStyle(color: Colors.white),
                ),
                onTap: () {
                  Navigator.pop(context);
                },
              ),
              ListTile(
                leading: Icon(Icons.exit_to_app, color: Colors.red),
                title: Text(
                  'Cerrar Sesión',
                  style: TextStyle(color: Colors.red),
                ),
                onTap: () async {
                  // Lógica para cerrar sesión con Firebase
                  await FirebaseAuth.instance.signOut();

                  // Verifica si el widget sigue montado antes de navegar
                  if (context.mounted) {
                    // Redirigir al usuario a la página de login
                    Navigator.of(context).pushAndRemoveUntil(
                      MaterialPageRoute(
                          builder: (context) => const LoginForm()),
                      (Route<dynamic> route) => false,
                    );
                  }
                },
              ),
            ],
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: GridView.count(
          crossAxisCount: 2,
          children: <Widget>[
            _buildDashboardItem(
                context, 'Propiedades', Icons.home, '/properties'),
            _buildDashboardItem(
                context, 'Inquilinos', Icons.people, '/tenants'),
            _buildDashboardItem(context, 'Pagos', Icons.payment, '/payments'),
            _buildDashboardItem(
                context, 'Reportes', Icons.bar_chart, '/reports'),
          ],
        ),
      ),
    );
  }

  Widget _buildDashboardItem(
      BuildContext context, String title, IconData icon, String route) {
    return Card(
      color: Color(0xFF05F29B),
      margin: EdgeInsets.all(15.0),
      child: InkWell(
        onTap: () {
          Navigator.pushNamed(context, route);
        },
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Icon(icon, size: 50.0, color: const Color.fromARGB(255, 2, 7, 4)),
              SizedBox(height: 16.0),
              Text(title, style: TextStyle(fontSize: 18.0)),
            ],
          ),
        ),
      ),
    );
  }
}
