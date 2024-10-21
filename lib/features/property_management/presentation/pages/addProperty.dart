import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class AddPropertyPage extends StatefulWidget {
  @override
  _AddPropertyPageState createState() => _AddPropertyPageState();
}

class _AddPropertyPageState extends State<AddPropertyPage> {
  final TextEditingController _propertyNameController = TextEditingController();
  final TextEditingController _propertyDescriptionController =
      TextEditingController();
  final TextEditingController _propertyAddressController =
      TextEditingController();
  final TextEditingController _propertyPriceController =
      TextEditingController();
  String? _selectedTenant; // Campo para seleccionar inquilino
  bool _isOccupied = false; // Estado de ocupación
  DateTime? _paymentDate; // Fecha de pago

  // Función para guardar la propiedad en Firebase
  Future<void> _saveProperty() async {
    String name = _propertyNameController.text;
    String description = _propertyDescriptionController.text;
    String address = _propertyAddressController.text;
    String price = _propertyPriceController.text;

    // Asegurarse de que no estén vacíos
    if (name.isEmpty ||
        description.isEmpty ||
        address.isEmpty ||
        price.isEmpty ||
        _selectedTenant == null ||
        _paymentDate == null) {
      // Verifica si se han completado todos los campos
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Por favor, completa todos los campos')),
      );
      return;
    }

    // Crear un mapa de datos que se va a guardar en Firestore
    Map<String, dynamic> propertyData = {
      'name': name,
      'description': description,
      'address': address,
      'price': double.tryParse(price), // Convertir el precio a double
      'isOccupied': _isOccupied, // Agregar el estado de ocupación
      'tenant': _selectedTenant, // Agregar el inquilino seleccionado
      'paymentDueDate':
          Timestamp.fromDate(_paymentDate!), // Fecha de vencimiento
      'hasPaid': false, // Inicialmente no está pagado
    };

    // Guardar la propiedad en la colección 'properties' en Firebase
    await FirebaseFirestore.instance
        .collection('properties')
        .add(propertyData) // Deja que Firebase genere automáticamente el ID
        .then((_) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Propiedad guardada correctamente')),
      );
    }).catchError((error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al guardar la propiedad: $error')),
      );
    });

    // Limpiar los campos después de guardar
    _propertyNameController.clear();
    _propertyDescriptionController.clear();
    _propertyAddressController.clear();
    _propertyPriceController.clear();
    setState(() {
      _selectedTenant = null;
      _isOccupied = false;
      _paymentDate = null;
    });
  }

  // Función para seleccionar la fecha de pago
  Future<void> _selectPaymentDate(BuildContext context) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: _paymentDate ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2101),
    );

    if (pickedDate != null && pickedDate != _paymentDate) {
      setState(() {
        _paymentDate = pickedDate; // Asignar la fecha de pago seleccionada
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.teal,
        title: Text('Agregar Propiedad'),
      ),
      body: Container(
        color: Color(0xFF325259), // Color de fondo
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Nombre de la Propiedad:',
                style: TextStyle(fontSize: 18, color: Colors.white)),
            TextField(
              controller: _propertyNameController,
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                filled: true,
                fillColor: Colors.white,
              ),
            ),
            SizedBox(height: 5),
            Text('Descripción:',
                style: TextStyle(fontSize: 18, color: Colors.white)),
            TextField(
              controller: _propertyDescriptionController,
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                filled: true,
                fillColor: Colors.white,
              ),
              maxLines: 1,
            ),
            SizedBox(height: 16),
            Text('Dirección:',
                style: TextStyle(fontSize: 18, color: Colors.white)),
            TextField(
              controller: _propertyAddressController,
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                filled: true,
                fillColor: Colors.white,
              ),
            ),
            SizedBox(height: 16),
            Text('Precio:',
                style: TextStyle(fontSize: 18, color: Colors.white)),
            TextField(
              controller: _propertyPriceController,
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                filled: true,
                fillColor: Colors.white,
              ),
              keyboardType: TextInputType.number, // Solo números
            ),
            SizedBox(height: 16),
            Text('Inquilino:',
                style: TextStyle(fontSize: 18, color: Colors.white)),
            FutureBuilder<QuerySnapshot>(
              future: FirebaseFirestore.instance.collection('tenants').get(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return CircularProgressIndicator();
                }
                if (snapshot.hasError) {
                  return Text('Error al cargar inquilinos');
                }

                final tenants = snapshot.data!.docs;
                return DropdownButton<String>(
                  hint: Text('Selecciona un inquilino'),
                  value: _selectedTenant,
                  onChanged: (newValue) {
                    setState(() {
                      _selectedTenant = newValue;
                    });
                  },
                  items: tenants.map((tenant) {
                    var tenantData = tenant.data() as Map<String, dynamic>;
                    return DropdownMenuItem<String>(
                      value: tenant.id,
                      child: Text(tenantData['name'] ?? 'Inquilino sin nombre',
                          style: TextStyle(color: Colors.black)),
                    );
                  }).toList(),
                );
              },
            ),
            SizedBox(height: 8),
            Text('Fecha de Pago:',
                style: TextStyle(fontSize: 18, color: Colors.white)),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  _paymentDate != null
                      ? '${_paymentDate!.toLocal()}'.split(' ')[0]
                      : 'Seleccionar fecha',
                  style: TextStyle(color: Colors.white),
                ),
                ElevatedButton(
                  onPressed: () => _selectPaymentDate(context),
                  child: Text('Seleccionar'),
                ),
              ],
            ),
            SizedBox(height: 3),
            Row(
              children: [
                Switch(
                  value: _isOccupied,
                  onChanged: (bool value) {
                    setState(() {
                      _isOccupied = value; // Cambiar el estado de ocupación
                    });
                  },
                ),
                Text('Estado de ocupación',
                    style: TextStyle(color: Color(0xFF05F29B))),
              ],
            ),
            SizedBox(height: 1),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                await _saveProperty(); // Llamar a la función para guardar la propiedad en Firebase
                Navigator.pop(context); // Regresar a la lista de propiedades
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFF05F29B), // Color de fondo del botón
                foregroundColor: Colors.black, // Color del texto del botón
                padding: EdgeInsets.symmetric(
                    vertical: 16.0, horizontal: 32.0), // Espaciado interno
              ),
              child: Text(
                'Guardar Propiedad',
                style: TextStyle(fontSize: 18), // Cambiar el tamaño del texto
              ),
            ),
          ],
        ),
      ),
    );
  }
}
