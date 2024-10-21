import 'package:flutter/material.dart';

class LoginForm extends StatefulWidget {
  @override
  _LoginFormState createState() => _LoginFormState();
}

class _LoginFormState extends State<LoginForm> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  void _login() {
    if (_formKey.currentState?.validate() ?? false) {
      final email = _emailController.text;
      final password = _passwordController.text;
      // Aquí llamarías a tu lógica de autenticación (por ejemplo, usando Firebase)
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Iniciando sesión con $email')),
      );
    }
  }

  void _navigateToRegister() {
    Navigator.of(context).pushNamed('/register');
  }

  void _navigateToRecoverPassword() {
    Navigator.of(context).pushNamed('/recover');
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        children: <Widget>[
          TextFormField(
            controller: _emailController,
            decoration: InputDecoration(labelText: 'Correo Electrónico'),
            keyboardType: TextInputType.emailAddress,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Por favor, ingrese su correo';
              }
              if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
                return 'Por favor, ingrese un correo válido';
              }
              return null;
            },
          ),
          TextFormField(
            controller: _passwordController,
            decoration: InputDecoration(labelText: 'Contraseña'),
            obscureText: true,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Por favor, ingrese su contraseña';
              }
              return null;
            },
          ),
          SizedBox(height: 60),
          ElevatedButton(
            onPressed: _login,
            child: Text('Iniciar Sesión'),
          ),
          TextButton(
            onPressed: _navigateToRegister,
            child: Text('¿No tienes cuenta? Regístrate'),
          ),
          TextButton(
            onPressed: _navigateToRecoverPassword,
            child: Text('¿Olvidaste tu contraseña?'),
          ),
        ],
      ),
    );
  }
}
