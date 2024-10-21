import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AddTenantPage extends StatefulWidget {
  @override
  _AddTenantPageState createState() => _AddTenantPageState();
}

class _AddTenantPageState extends State<AddTenantPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _dpiController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();

  Future<void> _addTenant() async {
    if (_formKey.currentState!.validate()) {
      // Crear un nuevo inquilino en Firebase
      await FirebaseFirestore.instance.collection('tenants').add({
        'name': _nameController.text,
        'dpi': _dpiController.text,
        'phone': _phoneController.text,
      });

      // Mostrar mensaje de éxito y regresar a la lista de inquilinos
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Inquilino agregado correctamente')),
      );
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title:
            Text('Agregar Inquilino', style: TextStyle(fontFamily: 'Poppins')),
        backgroundColor: Colors.teal,
      ),
      body: Container(
        color: const Color(0xFF325259), // Color de fondo
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: 'Nombre',
                  labelStyle: TextStyle(
                      color: Colors.white,
                      fontFamily: 'Poppins'), // Color y fuente
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor, ingrese un nombre';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _dpiController,
                decoration: InputDecoration(
                  labelText: 'DPI',
                  labelStyle: TextStyle(
                      color: Colors.white,
                      fontFamily: 'Poppins'), // Color y fuente
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor, ingrese un DPI';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _phoneController,
                decoration: InputDecoration(
                  labelText: 'Teléfono',
                  labelStyle: TextStyle(
                      color: Colors.white,
                      fontFamily: 'Poppins'), // Color y fuente
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor, ingrese un teléfono';
                  }
                  return null;
                },
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _addTenant,
                child: Text('Agregar Inquilino',
                    style: TextStyle(fontFamily: 'Poppins')),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF05F29B),
                  foregroundColor: Colors.black,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _dpiController.dispose();
    _phoneController.dispose();
    super.dispose();
  }
}
