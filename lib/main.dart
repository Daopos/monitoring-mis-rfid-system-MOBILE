import 'package:agl_heights_app/pages/accesspages/forgotpassword.dart';
import 'package:agl_heights_app/pages/accesspages/getstarted.dart';
import 'package:agl_heights_app/pages/accesspages/option.dart';
import 'package:agl_heights_app/pages/accesspages/login.dart';
import 'package:agl_heights_app/pages/mainpages/application.dart';
import 'package:agl_heights_app/pages/mainpages/applicationadd.dart';
import 'package:agl_heights_app/pages/mainpages/applicationedit.dart';
import 'package:agl_heights_app/pages/mainpages/bottomnav.dart';
import 'package:agl_heights_app/pages/mainpages/chat.dart';
import 'package:agl_heights_app/pages/mainpages/gateentry.dart';
import 'package:agl_heights_app/pages/mainpages/guardchat.dart';
import 'package:agl_heights_app/pages/mainpages/home.dart';
import 'package:agl_heights_app/pages/mainpages/members.dart';
import 'package:agl_heights_app/pages/mainpages/membersadd.dart';
import 'package:agl_heights_app/pages/mainpages/notification.dart';
import 'package:agl_heights_app/pages/mainpages/officers.dart';
import 'package:agl_heights_app/pages/mainpages/paymenthistory.dart';
import 'package:agl_heights_app/pages/mainpages/pdf.dart';
import 'package:agl_heights_app/pages/mainpages/vehicleadd.dart';
import 'package:agl_heights_app/pages/mainpages/vehicles.dart';
import 'package:agl_heights_app/pages/mainpages/visitoradd.dart';
import 'package:agl_heights_app/pages/mainpages/vistors.dart';
import 'package:agl_heights_app/pages/signuppages/signup.dart';
import 'package:flutter/material.dart';
import 'package:agl_heights_app/services/preference_service.dart';

void main() async {
  WidgetsFlutterBinding
      .ensureInitialized(); // Ensures initialization before running the app

  // Retrieve token from preferences (this can be done asynchronously)
  String? token = await PreferenceService.getToken();

  // Run the app with the token passed to the MyApp constructor
  runApp(MyApp(token: token));
}

class MyApp extends StatefulWidget {
  final String? token;

  const MyApp({super.key, this.token});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        debugShowCheckedModeBanner: false,
        initialRoute: widget.token != null ? '/navpage' : '/getstarted',
        routes: {
          '/navpage': (context) => const BottomNavPage(),
          '/login': (context) => const LoginPage(),
          '/getstarted': (context) => const GetStartedPage(),
          '/option': (context) => const OptionPage(),
          '/home': (context) => const HomePage(),
          '/signup': (context) => SignUpPage(),
          '/chat': (context) => const ChatPage(),
          '/guard/chat': (context) => const GuardChatPage(),
          '/vehicles': (context) => VehiclePage(),
          '/add/vehicle': (context) => AddVehiclePage(),
          '/visitors': (context) => VisitorPage(),
          '/add/visitor': (context) => AddVisitorPage(),
          '/gate': (context) => GateEntryPage(),
          '/members': (context) => Members(),
          '/add/household': (context) => const AddHouseholdPage(),
          '/notification': (context) => const NotificationPage(),
          '/forgotpassword': (context) => ForgotPasswordPage(),
          '/officers': (context) => OfficerPage(),
          '/pdf': (context) => PdfPage(),
          '/application': (context) => ApplicationPage(),
          '/add/application': (context) => ApplicationAddPage(),
          '/editApplication': (context) => ApplicationEditPage(),
          '/paymenthistory': (context) => PaymentHistoryPPage()
        });
  }
}
