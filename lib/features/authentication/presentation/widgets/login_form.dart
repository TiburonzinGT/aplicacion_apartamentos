import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart'; // Asegúrate de importar firebase_auth

class LoginForm extends StatefulWidget {
  const LoginForm({super.key});

  @override
  LoginFormState createState() => LoginFormState();
}

class LoginFormState extends State<LoginForm> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  // Colores personalizados (adaptados a tu aplicación)
  final Color primaryColor = Color(0xFF05F29B); // Ejemplo de color primario
  final Color accentColor = Color(0xFF05F29B); // Ejemplo de color de acento
  final Color backgroundColor = Color(0xFF325259); // Fondo oscuro
  final Color buttonTextColor = Colors.white;
  final Color errorColor = Colors.redAccent;

  void _login() async {
    if (_formKey.currentState?.validate() ?? false) {
      try {
        final email = _emailController.text.trim();
        final password = _passwordController.text.trim();

        // Autenticación con Firebase
        UserCredential userCredential =
            await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: email,
          password: password,
        );

        // Verifica si el widget sigue montado antes de usar el BuildContext
        if (!mounted) return;

        // Si la autenticación es exitosa, redirige al dashboard
        Navigator.pushReplacementNamed(context, '/dashboard');
      } on FirebaseAuthException catch (e) {
        String message;
        if (e.code == 'user-not-found') {
          message = 'No se encontró un usuario con ese correo.';
        } else if (e.code == 'wrong-password') {
          message = 'Contraseña incorrecta.';
        } else {
          message = 'Error al iniciar sesión: ${e.message}';
        }

        // Verifica si el widget sigue montado antes de usar el BuildContext
        if (!mounted) return;

        // Muestra un mensaje de error
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(message)),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Obtener las dimensiones de la pantalla
    final size = MediaQuery.of(context).size;

    return Scaffold(
      body: Container(
        width: size.width, // Ocupa todo el ancho de la pantalla
        height: size.height, // Ocupa todo el alto de la pantalla
        color: backgroundColor, // Color de fondo en todo el espacio
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(18.0),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  Form(
                    key: _formKey,
                    child: Column(
                      children: <Widget>[
                        TextFormField(
                          controller: _emailController,
                          decoration: InputDecoration(
                            labelText: 'Correo Electrónico',
                            labelStyle: TextStyle(
                                color: primaryColor), // Color del texto
                            focusedBorder: UnderlineInputBorder(
                              borderSide: BorderSide(color: primaryColor),
                            ),
                          ),
                          keyboardType: TextInputType.emailAddress,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Por favor, ingrese su correo';
                            }
                            if (!RegExp(r'^[^@]+@[^@]+\.[^@]+')
                                .hasMatch(value)) {
                              return 'Por favor, ingrese un correo válido';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _passwordController,
                          decoration: InputDecoration(
                            labelText: 'Contraseña',
                            labelStyle: TextStyle(color: primaryColor),
                            focusedBorder: UnderlineInputBorder(
                              borderSide: BorderSide(color: primaryColor),
                            ),
                          ),
                          obscureText: true,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Por favor, ingrese su contraseña';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 40),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor:
                                primaryColor, // Color de fondo del botón
                            foregroundColor:
                                buttonTextColor, // Color del texto en el botón
                            padding: const EdgeInsets.symmetric(
                                horizontal: 50, vertical: 15),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(
                                  8), // Bordes redondeados
                            ),
                          ),
                          onPressed: _login,
                          child: const Text('Iniciar Sesión'),
                        ),
                        const SizedBox(height: 35),
                        TextButton(
                          onPressed: () =>
                              Navigator.of(context).pushNamed('/register'),
                          child: Text(
                            '¿No tienes cuenta? Regístrate',
                            style: TextStyle(
                                color: accentColor), // Color del texto
                          ),
                        ),
                        TextButton(
                          onPressed: () =>
                              Navigator.of(context).pushNamed('/recover'),
                          child: Text(
                            '¿Olvidaste tu contraseña?',
                            style: TextStyle(
                                color: accentColor), // Color del texto
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
