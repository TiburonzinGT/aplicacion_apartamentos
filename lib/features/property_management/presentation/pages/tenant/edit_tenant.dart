import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class EditTenantPage extends StatefulWidget {
  final String tenantId;
  final String tenantName;
  final String tenantDpi;
  final String tenantPhone;

  EditTenantPage({
    required this.tenantId,
    required this.tenantName,
    required this.tenantDpi,
    required this.tenantPhone,
  });

  @override
  _EditTenantPageState createState() => _EditTenantPageState();
}

class _EditTenantPageState extends State<EditTenantPage> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _dpiController;
  late TextEditingController _phoneController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.tenantName);
    _dpiController = TextEditingController(text: widget.tenantDpi);
    _phoneController = TextEditingController(text: widget.tenantPhone);
  }

  Future<void> _updateTenant() async {
    if (_formKey.currentState!.validate()) {
      // Actualizar el inquilino en Firebase
      await FirebaseFirestore.instance
          .collection('tenants')
          .doc(widget.tenantId)
          .update({
        'name': _nameController.text,
        'dpi': _dpiController.text,
        'phone': _phoneController.text,
      });

      // Mostrar mensaje de éxito y regresar a la lista de inquilinos
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Inquilino actualizado correctamente')),
      );
      Navigator.pop(context);
    }
  }

  Future<void> _deleteTenant() async {
    // Eliminar el inquilino de Firebase
    await FirebaseFirestore.instance
        .collection('tenants')
        .doc(widget.tenantId)
        .delete();

    // Mostrar mensaje de éxito y regresar a la lista de inquilinos
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Inquilino eliminado correctamente')),
    );
    Navigator.pop(context);
  }

  void _confirmDeleteTenant() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Eliminar Inquilino'),
          content: Text(
              '¿Estás seguro de que deseas eliminar a este inquilino? Esta acción no se puede deshacer.'),
          actions: <Widget>[
            TextButton(
              child: Text('Cancelar', style: TextStyle(fontFamily: 'Poppins')),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('Eliminar',
                  style: TextStyle(color: Colors.red, fontFamily: 'Poppins')),
              onPressed: () {
                Navigator.of(context).pop(); // Cerrar el diálogo
                _deleteTenant(); // Llamar a la función para eliminar
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Editar Inquilino',
          style: TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.teal,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: 'Nombre',
                  labelStyle: TextStyle(fontFamily: 'Poppins'),
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
                  labelStyle: TextStyle(fontFamily: 'Poppins'),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor, ingrese el DPI';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _phoneController,
                decoration: InputDecoration(
                  labelText: 'Teléfono',
                  labelStyle: TextStyle(fontFamily: 'Poppins'),
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
                onPressed: _updateTenant,
                child: Text(
                  'Actualizar Inquilino',
                  style: TextStyle(fontFamily: 'Poppins'),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.teal,
                  foregroundColor: Colors.black,
                ),
              ),
              SizedBox(height: 50),
              ElevatedButton(
                onPressed: _confirmDeleteTenant,
                child: Text(
                  'Eliminar Inquilino',
                  style: TextStyle(fontFamily: 'Poppins'),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
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
