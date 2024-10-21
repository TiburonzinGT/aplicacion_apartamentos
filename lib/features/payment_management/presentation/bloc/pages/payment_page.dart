import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class PaymentsPage extends StatefulWidget {
  @override
  _PaymentsPageState createState() => _PaymentsPageState();
}

class _PaymentsPageState extends State<PaymentsPage> {
  DateTime selectedMonth =
      DateTime(DateTime.now().year, DateTime.now().month, 1);
  final GlobalKey<ScaffoldMessengerState> _scaffoldMessengerKey =
      GlobalKey<ScaffoldMessengerState>();

  @override
  Widget build(BuildContext context) {
    return ScaffoldMessenger(
      key: _scaffoldMessengerKey,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.teal,
          title: Text(
            'Pagos de Propiedades',
            style:
                TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.bold),
          ),
        ),
        body: Container(
          color: const Color(0xFF325259),
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: [
              DropdownButton<DateTime>(
                value: selectedMonth,
                items: _generateMonthItems(),
                onChanged: (DateTime? newValue) {
                  if (newValue != null) {
                    setState(() {
                      selectedMonth = newValue;
                    });
                  }
                },
              ),
              Expanded(
                child: StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection('properties')
                      .where('isOccupied', isEqualTo: true)
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (snapshot.hasError) {
                      return const Center(
                          child: Text('Error al cargar los pagos.'));
                    }

                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Center(child: CircularProgressIndicator());
                    }

                    final properties = snapshot.data!.docs;

                    if (properties.isEmpty) {
                      return Center(
                        child: Text('No hay propiedades registradas.',
                            style: TextStyle(fontSize: 18, color: Colors.grey)),
                      );
                    }

                    // Obtener fechas de inicio y fin del mes seleccionado
                    final startOfMonth =
                        DateTime(selectedMonth.year, selectedMonth.month, 1);
                    final endOfMonth = DateTime(
                        selectedMonth.year, selectedMonth.month + 1, 0);

                    // Agrupar propiedades por mes
                    List<Map<String, dynamic>> paymentsByMonth = [];

                    for (var property in properties) {
                      var propertyData =
                          property.data() as Map<String, dynamic>;
                      String tenantId = propertyData['tenant'] ?? '';
                      bool isPaid = propertyData['isPaid'] == true;

                      // Verifica si la fecha de vencimiento está dentro del mes seleccionado
                      DateTime? paymentDueDate =
                          propertyData['paymentDueDate'] != null
                              ? (propertyData['paymentDueDate'] as Timestamp)
                                  .toDate()
                              : null;

                      if (paymentDueDate != null &&
                          paymentDueDate.isAfter(startOfMonth) &&
                          paymentDueDate
                              .isBefore(endOfMonth.add(Duration(days: 1)))) {
                        paymentsByMonth.add({
                          'property': propertyData['name'],
                          'tenantId': tenantId,
                          'isPaid': isPaid,
                          'paymentDueDate': paymentDueDate,
                          'propertyId': property.id,
                          'price': propertyData[
                              'price'], // Asegúrate de obtener el precio aquí
                        });
                      }
                    }

                    return ListView.builder(
                      itemCount: paymentsByMonth.length,
                      itemBuilder: (context, index) {
                        var payment = paymentsByMonth[index];

                        return FutureBuilder<DocumentSnapshot>(
                          future: FirebaseFirestore.instance
                              .collection('tenants')
                              .doc(payment['tenantId'])
                              .get(),
                          builder: (context, tenantSnapshot) {
                            if (tenantSnapshot.connectionState ==
                                ConnectionState.waiting) {
                              return Card(
                                child: ListTile(
                                  title: Text(payment['property']),
                                  subtitle:
                                      Text('Cargando nombre del inquilino...'),
                                ),
                              );
                            }

                            if (tenantSnapshot.hasError) {
                              return Card(
                                child: ListTile(
                                  title: Text(payment['property']),
                                  subtitle:
                                      Text('Error al cargar el inquilino.'),
                                ),
                              );
                            }

                            var tenantData = tenantSnapshot.data?.data()
                                as Map<String, dynamic>?;
                            String tenantName =
                                tenantData?['name'] ?? 'Sin inquilino';

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
                                  payment['property'],
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.teal[700],
                                      fontFamily: 'Poppins'),
                                ),
                                subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('Inquilino: $tenantName',
                                        style: TextStyle(
                                            color: Colors.grey[600],
                                            fontFamily: 'Poppins')),
                                    SizedBox(height: 4),
                                    Text(
                                        'Fecha de Vencimiento: ${DateFormat('dd/MM/yyyy').format(payment['paymentDueDate'])}',
                                        style: TextStyle(
                                            color: Colors.grey[600],
                                            fontFamily: 'Poppins')),
                                    SizedBox(height: 4),
                                    Text(
                                        'Estado: ${payment['isPaid'] ? 'Pagado' : 'Pendiente'}',
                                        style: TextStyle(
                                            color: payment['isPaid']
                                                ? Colors.teal
                                                : Colors.red,
                                            fontFamily: 'Poppins')),
                                  ],
                                ),
                                leading: Icon(Icons.home, color: Colors.teal),
                                trailing: payment['isPaid']
                                    ? null
                                    : IconButton(
                                        icon: Icon(Icons.check_circle,
                                            color: Color(0xFF05F29B)),
                                        onPressed: () {
                                          _markAsPaid(context, payment);
                                        },
                                      ),
                              ),
                            );
                          },
                        );
                      },
                    );
                  },
                ),
              ),
              Expanded(
                child: StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection('paymentsHistory')
                      .where('month',
                          isEqualTo: DateFormat('MMMM').format(selectedMonth))
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (snapshot.hasError) {
                      return const Center(
                          child:
                              Text('Error al cargar el historial de pagos.'));
                    }

                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Center(child: CircularProgressIndicator());
                    }

                    final paymentsHistory = snapshot.data!.docs;

                    if (paymentsHistory.isEmpty) {
                      return Center(
                        child: Text('No hay pagos registrados para este mes.',
                            style: TextStyle(fontSize: 18, color: Colors.grey)),
                      );
                    }

                    return ListView.builder(
                      itemCount: paymentsHistory.length,
                      itemBuilder: (context, index) {
                        var payment = paymentsHistory[index].data()
                            as Map<String, dynamic>;
                        return Card(
                          child: ListTile(
                            title: Text(payment['property']),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                    'Pagado el: ${DateFormat('dd/MM/yyyy').format(payment['paymentDate'].toDate())}'),
                                SizedBox(height: 4),
                                Text(
                                  'Precio: \$${payment['price'] != null ? payment['price'].toStringAsFixed(2) : '0.00'}',
                                ), // Mostrar el precio
                              ],
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  List<DropdownMenuItem<DateTime>> _generateMonthItems() {
    List<DropdownMenuItem<DateTime>> months = [];
    for (int i = -5; i <= 5; i++) {
      DateTime month = DateTime.now().add(Duration(days: i * 30));
      month = DateTime(month.year, month.month, 1);
      if (!months.any((item) => item.value == month)) {
        months.add(
          DropdownMenuItem(
            value: month,
            child: Text(DateFormat('MMMM yyyy').format(month)),
          ),
        );
      }
    }
    return months;
  }

  Future<void> _markAsPaid(
      BuildContext context, Map<String, dynamic> payment) async {
    try {
      // Actualiza el estado de pago
      await FirebaseFirestore.instance
          .collection('properties')
          .doc(payment['propertyId'])
          .update({
        'isPaid': true,
        'paymentDate': Timestamp.now(),
      });

      // Guarda el historial de pago en la colección paymentsHistory
      await FirebaseFirestore.instance.collection('paymentsHistory').add({
        'property': payment['property'],
        'tenantId': payment['tenantId'],
        'paymentDate': Timestamp.now(),
        'month': DateFormat('MMMM').format(payment['paymentDueDate']),
        'price': payment['price'], // Asegúrate de agregar el precio
      });

      // Obtén la información de la propiedad para programar el próximo pago
      var propertyDoc = await FirebaseFirestore.instance
          .collection('properties')
          .doc(payment['propertyId'])
          .get();
      var propertyData = propertyDoc.data() as Map<String, dynamic>?;

      DateTime? paymentDueDate = propertyData?['paymentDueDate']?.toDate();

      if (paymentDueDate != null) {
        DateTime nextPaymentDueDate = DateTime(
            paymentDueDate.year, paymentDueDate.month + 1, paymentDueDate.day);

        await FirebaseFirestore.instance
            .collection('properties')
            .doc(payment['propertyId'])
            .update({
          'paymentDueDate': Timestamp.fromDate(nextPaymentDueDate),
          'isPaid': false,
        });
      }

      _scaffoldMessengerKey.currentState?.showSnackBar(SnackBar(
          content:
              Text('Pago marcado como realizado y próximo pago programado.')));
    } catch (e) {
      _scaffoldMessengerKey.currentState?.showSnackBar(
          SnackBar(content: Text('Error al marcar como pagado: $e')));
    }
  }
}
