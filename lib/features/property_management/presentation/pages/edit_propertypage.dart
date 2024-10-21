import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class EditPropertyPage extends StatefulWidget {
  final String propertyId; // ID de la propiedad en Firebase
  final String propertyName; // Nombre de la propiedad
  final String propertyDescription; // Descripción de la propiedad
  final String tenant; // ID del inquilino
  final String propertyAddress; // Dirección de la propiedad
  final double propertyPrice; // Precio de la propiedad

  EditPropertyPage({
    required this.propertyId,
    required this.propertyName,
    required this.propertyDescription,
    required this.tenant, // Agregar parámetro para inquilino
    required this.propertyAddress, // Agregar parámetro para dirección
    required this.propertyPrice, // Agregar parámetro para precio
  });

  @override
  _EditPropertyPageState createState() => _EditPropertyPageState();
}

class _EditPropertyPageState extends State<EditPropertyPage> {
  final TextEditingController _propertyNameController = TextEditingController();
  final TextEditingController _propertyDescriptionController =
      TextEditingController();
  final TextEditingController _tenantController =
      TextEditingController(); // Controlador para mostrar el nombre del inquilino
  final TextEditingController _propertyAddressController =
      TextEditingController();
  final TextEditingController _propertyPriceController =
      TextEditingController();

  bool _isOccupied = false;

  @override
  void initState() {
    super.initState();
    // Rellenar los controladores con los datos existentes
    _propertyNameController.text = widget.propertyName;
    _propertyDescriptionController.text = widget.propertyDescription;
    _propertyAddressController.text = widget.propertyAddress;
    _propertyPriceController.text = widget.propertyPrice.toString();
    _isOccupied = widget.tenant.isNotEmpty;

    // Si hay un inquilino, obtener el nombre del inquilino basado en su ID
    if (widget.tenant.isNotEmpty) {
      _getTenantName(widget.tenant).then((tenantName) {
        setState(() {
          _tenantController.text = tenantName ?? 'Sin inquilino';
        });
      });
    }
  }

  // Función para obtener el nombre del inquilino basado en su ID
  Future<String?> _getTenantName(String tenantId) async {
    if (tenantId.isNotEmpty) {
      DocumentSnapshot tenantSnapshot = await FirebaseFirestore.instance
          .collection('tenants')
          .doc(tenantId)
          .get();

      if (tenantSnapshot.exists) {
        return tenantSnapshot['name'] as String?;
      }
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.teal,
        title: Text('Editar Propiedad'),
        actions: [
          IconButton(
            icon: Icon(Icons.delete),
            onPressed: () async {
              await _deleteProperty(
                  context); // Llamar a la función para eliminar la propiedad
            },
            tooltip: 'Eliminar Propiedad',
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Nombre de la Propiedad:', style: TextStyle(fontSize: 18)),
            TextField(
              controller: _propertyNameController,
              decoration: InputDecoration(border: OutlineInputBorder()),
            ),
            SizedBox(height: 16),
            Text('Descripción:', style: TextStyle(fontSize: 18)),
            TextField(
              controller: _propertyDescriptionController,
              decoration: InputDecoration(border: OutlineInputBorder()),
              maxLines: 4,
            ),
            SizedBox(height: 16),
            Text('Dirección:', style: TextStyle(fontSize: 18)),
            TextField(
              controller: _propertyAddressController,
              decoration: InputDecoration(border: OutlineInputBorder()),
            ),
            SizedBox(height: 16),
            Text('Precio:', style: TextStyle(fontSize: 18)),
            TextField(
              controller: _propertyPriceController,
              decoration: InputDecoration(border: OutlineInputBorder()),
              keyboardType: TextInputType.number, // Solo números
            ),
            SizedBox(height: 16),
            Text('Inquilino:', style: TextStyle(fontSize: 18)),
            TextField(
              controller: _tenantController,
              decoration: InputDecoration(border: OutlineInputBorder()),
              readOnly:
                  true, // Solo lectura ya que el inquilino se selecciona por ID
            ),
            SizedBox(height: 16),
            Row(
              children: [
                Text('Ocupado:', style: TextStyle(fontSize: 18)),
                Checkbox(
                  value: _isOccupied,
                  onChanged: (value) {
                    setState(() {
                      _isOccupied = value!;
                    });
                  },
                ),
              ],
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                await _updateProperty(
                    context); // Llamar a la función para actualizar la propiedad
              },
              child: Text('Actualizar Propiedad'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _updateProperty(BuildContext context) async {
    // Obtener los valores de los campos
    String name = _propertyNameController.text;
    String description = _propertyDescriptionController.text;
    String tenant = widget.tenant; // Usar el ID del inquilino, no el nombre
    String address = _propertyAddressController.text;
    double? price = double.tryParse(
        _propertyPriceController.text); // Convertir el precio a double

    if (name.isEmpty ||
        description.isEmpty ||
        address.isEmpty ||
        price == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Por favor, llena todos los campos')),
      );
      return;
    }

    // Actualizar la propiedad en Firebase
    await FirebaseFirestore.instance
        .collection('properties')
        .doc(widget.propertyId)
        .update({
      'name': name,
      'description': description,
      'tenant': tenant, // Actualizar con el ID del inquilino
      'address': address,
      'price': price,
      'isOccupied': _isOccupied,
    }).then((_) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Propiedad actualizada exitosamente')),
      );
      Navigator.pop(context); // Regresar a la lista de propiedades
    }).catchError((error) => print("Error al actualizar la propiedad: $error"));
  }

  Future<void> _deleteProperty(BuildContext context) async {
    // Eliminar la propiedad de Firebase
    await FirebaseFirestore.instance
        .collection('properties')
        .doc(widget.propertyId)
        .delete()
        .then((_) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Propiedad eliminada exitosamente')),
      );
      Navigator.pop(context); // Regresar a la lista de propiedades
    }).catchError((error) => print("Error al eliminar la propiedad: $error"));
  }
}
