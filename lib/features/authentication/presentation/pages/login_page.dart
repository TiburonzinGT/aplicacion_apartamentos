import 'package:flutter/material.dart';
import '../widgets/login_form.dart'; // Importa el formulario de login

class LoginPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Iniciar Sesión'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: LoginForm(), // Aquí se coloca el formulario de login
      ),
    );
  }
}
