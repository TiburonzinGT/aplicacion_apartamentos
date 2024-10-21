import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart'; // Asegúrate de importar intl
import 'package:aplicacion_apartamentos/main.dart';

class TenantListPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.teal,
        title: Text(
          'Lista de Inquilinos',
          style: TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.add),
            onPressed: () {
              Navigator.pushNamed(context, '/addTenant');
            },
          ),
        ],
      ),
      body: Container(
        color: const Color(0xFF325259),
        padding: const EdgeInsets.all(8.0),
        child: StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance.collection('tenants').snapshots(),
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return const Center(
                  child: Text(
                'Error al cargar los inquilinos.',
                style: TextStyle(fontFamily: 'Poppins'),
              ));
            }

            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator());
            }

            final tenants = snapshot.data!.docs;

            if (tenants.isEmpty) {
              return Center(
                child: Text(
                  'No hay inquilinos registrados.',
                  style: TextStyle(
                      fontSize: 18, color: Colors.grey, fontFamily: 'Poppins'),
                ),
              );
            }

            return ListView.builder(
              itemCount: tenants.length,
              itemBuilder: (context, index) {
                var tenant = tenants[index];
                var tenantData = tenant.data() as Map<String, dynamic>;
                String name = tenantData['name'] ?? 'Inquilino sin nombre';
                String dpi = tenantData['dpi'] ?? 'Sin DPI';
                String phone = tenantData['phone'] ?? 'Sin teléfono';
                String paymentStatus =
                    tenantData['paymentStatus'] ?? 'Sin estado';
                String paymentDueDate =
                    tenantData['paymentDueDate'] ?? 'Sin fecha';

                // Formateo de la fecha de pago
                String formattedPaymentDueDate = paymentDueDate != 'Sin fecha'
                    ? DateFormat('dd/MM/yyyy')
                        .format(DateTime.parse(paymentDueDate))
                    : paymentDueDate;

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
                        fontFamily: 'Poppins',
                      ),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('DPI: $dpi',
                            style: TextStyle(
                                color: Colors.grey[600],
                                fontFamily: 'Poppins')),
                        SizedBox(height: 4),
                        Text('Teléfono: $phone',
                            style: TextStyle(
                                color: Colors.grey[600],
                                fontFamily: 'Poppins')),
                        SizedBox(height: 4),
                        Text('Estado de Pago: $paymentStatus',
                            style: TextStyle(
                                color: paymentStatus == 'pendiente'
                                    ? Colors.red
                                    : Colors.green,
                                fontFamily: 'Poppins')),
                        SizedBox(height: 4),
                        Text('Fecha de Pago: $formattedPaymentDueDate',
                            style: TextStyle(
                                color: Colors.grey[600],
                                fontFamily: 'Poppins')),
                      ],
                    ),
                    leading: Icon(Icons.person, color: Colors.teal),
                    trailing: IconButton(
                      icon: Icon(Icons.edit, color: Colors.teal),
                      onPressed: () {
                        Navigator.pushNamed(
                          context,
                          '/editTenant',
                          arguments: EditTenantArguments(
                            tenantId: tenant.id,
                            tenantName: name,
                            tenantDpi: dpi,
                            tenantPhone: phone,
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
          Navigator.pushNamed(context, '/addTenant');
        },
        child: Icon(Icons.add),
        tooltip: 'Agregar Inquilino',
      ),
    );
  }
}
