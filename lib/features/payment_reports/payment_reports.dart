import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart'; // Para formatear fechas

class PaymentReportsPage extends StatefulWidget {
  @override
  _PaymentsPageReportState createState() => _PaymentsPageReportState();
}

class _PaymentsPageReportState extends State<PaymentReportsPage> {
  DateTime selectedMonth = DateTime.now(); // Mes seleccionado
  String formattedMonth = ''; // Formato 'MMMM yyyy' solo para mostrar

  @override
  void initState() {
    super.initState();
    // Cambiar el formato a 'MMMM yyyy' (Ej: 'October 2024')
    formattedMonth = DateFormat('MMMM yyyy').format(selectedMonth);
  }

  // Función para seleccionar el mes
  Future<void> _selectMonth(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedMonth,
      firstDate: DateTime(2020),
      lastDate: DateTime(2101),
      builder: (context, child) {
        return child!;
      },
    );

    if (picked != null && picked != selectedMonth) {
      setState(() {
        selectedMonth = picked;
        // Actualizar el formato a 'MMMM yyyy'
        formattedMonth = DateFormat('MMMM yyyy').format(selectedMonth);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Reportes de Pagos'),
        backgroundColor: Colors.teal,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: ElevatedButton(
              onPressed: () => _selectMonth(context),
              child: Text('Seleccionar Mes: $formattedMonth'),
            ),
          ),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('paymentsHistory')
                  .where('month',
                      isEqualTo: DateFormat('MMMM')
                          .format(selectedMonth)) // Comparación con 'MMMM'
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Center(child: Text('Error al cargar los datos.'));
                }

                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                }

                final payments = snapshot.data!.docs;

                if (payments.isEmpty) {
                  return Center(
                      child: Text('No hay pagos registrados para este mes.'));
                }

                // Sumar el total de pagos
                double totalPayments = payments.fold(
                  0.0,
                  (sum, doc) {
                    final price =
                        (doc.data() as Map<String, dynamic>)['price'] as num? ??
                            0.0;
                    return sum + price;
                  },
                );

                return Column(
                  children: [
                    Text(
                      'Total de pagos: \$${totalPayments.toStringAsFixed(2)}',
                      style: TextStyle(fontSize: 18, color: Colors.green),
                    ),
                    Expanded(
                      child: ListView.builder(
                        itemCount: payments.length,
                        itemBuilder: (context, index) {
                          var paymentData =
                              payments[index].data() as Map<String, dynamic>;

                          String tenantId = paymentData['tenantId'] ??
                              'Inquilino desconocido';
                          double price =
                              paymentData['price'] ?? 0.0; // Monto del pago

                          return Card(
                            child: ListTile(
                              title: Text('Inquilino: $tenantId'),
                              subtitle:
                                  Text('Monto: \$${price.toStringAsFixed(2)}'),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
