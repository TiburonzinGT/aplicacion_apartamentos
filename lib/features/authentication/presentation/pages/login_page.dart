import 'package:flutter/material.dart';
import '../widgets/login_form.dart'; // Importa el formulario de login

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    // Colores personalizados
    final Color primaryColor = Color(0xFF05F29B); // Ejemplo de color primario
    final Color backgroundColor = Color(0xFF325259); // Fondo oscuro

    return Scaffold(
      appBar: AppBar(
        title: const Text(''),
        backgroundColor: backgroundColor, // Color del AppBar
        foregroundColor: Colors.white, // Color del texto en el AppBar
      ),
      body: Container(
        color: backgroundColor, // Fondo de la pantalla completa
        child: const Padding(
          padding: EdgeInsets.all(16.0),
          child: LoginForm(), // Aquí se coloca el formulario de login
        ),
      ),
    );
  }
}
