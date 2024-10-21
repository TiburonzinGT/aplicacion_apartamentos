import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'features/authentication/presentation/pages/login_page.dart';
import 'features/authentication/presentation/pages/register_page.dart';
import 'features/authentication/presentation/pages/recover_password_page.dart';
import 'features/authentication/presentation/pages/dashboard_page.dart';
import 'features/property_management/presentation/pages/property_list_page.dart';
import 'features/property_management/presentation/pages/edit_propertypage.dart';
import 'features/property_management/presentation/pages/addproperty.dart';
import 'features/property_management/presentation/pages/tenant/tenant_list_page.dart'; // Lista de inquilinos
import 'features/property_management/presentation/pages/tenant/add_tenant.dart'; // Agregar inquilinos
import 'features/property_management/presentation/pages/tenant/edit_tenant.dart'; // Editar inquilinos
import 'features/payment_management/presentation/bloc/pages/payment_page.dart'; // Nueva página para pagos
import 'features/payment_reports/payment_reports.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Rental Management App',
      debugShowCheckedModeBanner: false, // Ocultar el banner de debug
      initialRoute: '/',
      routes: {
        '/': (context) => const LoginPage(),
        '/register': (context) => const RegisterPage(),
        '/recover': (context) => const RecoverPasswordPage(),
        '/dashboard': (context) => DashboardPage(),
        '/properties': (context) => PropertyListPage(),
        '/addProperty': (context) => AddPropertyPage(),
        '/editProperty': (context) {
          final args = ModalRoute.of(context)!.settings.arguments
              as EditPropertyArguments;
          return EditPropertyPage(
            propertyId: args.propertyId,
            propertyName: args.propertyName,
            propertyDescription: args.propertyDescription,
            tenant: args.tenant,
            propertyAddress: args.propertyAddress,
            propertyPrice: args.propertyPrice,
          );
        },
        '/tenants': (context) => TenantListPage(), // Lista de inquilinos
        '/addTenant': (context) => AddTenantPage(), // Agregar inquilinos
        '/editTenant': (context) {
          final args =
              ModalRoute.of(context)!.settings.arguments as EditTenantArguments;
          return EditTenantPage(
            tenantId: args.tenantId,
            tenantName: args.tenantName,
            tenantDpi: args.tenantDpi,
            tenantPhone: args.tenantPhone,
          );
        },
        '/payments': (context) => PaymentsPage(), // Nueva ruta para pagos
        '/reports': (context) => PaymentReportsPage(),
      },
    );
  }
}

// Clase para los argumentos de edición de propiedades
class EditPropertyArguments {
  final String propertyId;
  final String propertyName;
  final String propertyDescription;
  final String tenant; // Nombre del inquilino
  final String propertyAddress;
  final double propertyPrice;

  EditPropertyArguments({
    required this.propertyId,
    required this.propertyName,
    required this.propertyDescription,
    required this.tenant,
    required this.propertyAddress,
    required this.propertyPrice,
  });
}

// Clase para los argumentos de edición de inquilinos
class EditTenantArguments {
  final String tenantId;
  final String tenantName;
  final String tenantDpi;
  final String tenantPhone;

  EditTenantArguments({
    required this.tenantId,
    required this.tenantName,
    required this.tenantDpi,
    required this.tenantPhone,
  });
}
