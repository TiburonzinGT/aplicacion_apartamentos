import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:aplicacion_apartamentos/main.dart'; // Asegúrate de importar tu clase

class PropertyListPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.teal,
        title: Text('Lista de Propiedades'),
        actions: [
          IconButton(
            icon: Icon(Icons.add),
            onPressed: () {
              Navigator.pushNamed(context, '/addProperty');
            },
          ),
        ],
      ),
      body: Container(
        color: const Color(0xFF325259),
        padding: const EdgeInsets.all(8.0),
        child: StreamBuilder<QuerySnapshot>(
          stream:
              FirebaseFirestore.instance.collection('properties').snapshots(),
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return const Center(
                  child: Text('Error al cargar las propiedades.'));
            }

            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator());
            }

            final properties = snapshot.data!.docs;

            if (properties.isEmpty) {
              return Center(
                child: Text(
                  'No hay propiedades disponibles.',
                  style: TextStyle(fontSize: 18, color: Colors.grey),
                ),
              );
            }

            return ListView.builder(
              itemCount: properties.length,
              itemBuilder: (context, index) {
                var property = properties[index];
                var propertyData = property.data() as Map<String, dynamic>;
                String name = propertyData['name'] ?? 'Propiedad sin nombre';
                String description =
                    propertyData['description'] ?? 'Sin descripción';
                String tenantId =
                    propertyData['tenant'] ?? ''; // ID del inquilino
                double price = propertyData['price'] ?? 0.0;
                bool isOccupied = propertyData['isOccupied'] ?? false;

                return Card(
                  color: Colors.white,
                  shadowColor: Colors.teal,
                  elevation: 4,
                  margin: EdgeInsets.symmetric(vertical: 8.0),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: ListTile(
                    title: Text(
                      name,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.teal[700],
                      ),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          description,
                          style: TextStyle(
                            color: Colors.black,
                          ),
                        ),
                        SizedBox(height: 4),
                        tenantId.isNotEmpty
                            ? FutureBuilder<DocumentSnapshot>(
                                future: FirebaseFirestore.instance
                                    .collection('tenants')
                                    .doc(tenantId)
                                    .get(),
                                builder: (context, tenantSnapshot) {
                                  if (tenantSnapshot.connectionState ==
                                      ConnectionState.waiting) {
                                    return CircularProgressIndicator();
                                  }

                                  if (tenantSnapshot.hasError) {
                                    return Text('Error al cargar el inquilino');
                                  }

                                  if (!tenantSnapshot.hasData ||
                                      !tenantSnapshot.data!.exists) {
                                    return Text('Inquilino no encontrado');
                                  }

                                  var tenantData = tenantSnapshot.data!.data()
                                      as Map<String, dynamic>?;
                                  String tenantName = tenantData?['name'] ??
                                      'Inquilino sin nombre';

                                  return Text(
                                    'Inquilino: $tenantName',
                                    style: TextStyle(
                                      color: Colors.grey[700],
                                    ),
                                  );
                                },
                              )
                            : Text(
                                'Inquilino: Sin asignar',
                                style: TextStyle(
                                  color: Colors.grey[700],
                                ),
                              ),
                        Text(
                          'Precio: \$${price.toStringAsFixed(2)}', // Formatear el precio
                          style: TextStyle(
                            color: Colors.grey[700],
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          isOccupied ? 'Ocupada' : 'Disponible',
                          style: TextStyle(
                            color: isOccupied ? Colors.red : Colors.green,
                          ),
                        ),
                      ],
                    ),
                    leading: Icon(Icons.house, color: Colors.teal),
                    trailing: IconButton(
                      icon: Icon(Icons.edit, color: Colors.teal),
                      onPressed: () {
                        Navigator.pushNamed(
                          context,
                          '/editProperty',
                          arguments: EditPropertyArguments(
                            propertyId:
                                property.id, // Pasar el ID de la propiedad
                            propertyName:
                                name, // Pasar el nombre de la propiedad
                            propertyDescription:
                                description, // Pasar la descripción de la propiedad
                            tenant: tenantId, // Pasar el ID del inquilino
                            propertyAddress: propertyData['address'] ??
                                '', // Pasar la dirección
                            propertyPrice: price, // Pasar el precio
                          ),
                        );
                      },
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.teal,
        onPressed: () {
          Navigator.pushNamed(context, '/addProperty');
        },
        child: Icon(Icons.add),
        tooltip: 'Agregar Propiedad',
      ),
    );
  }
}
