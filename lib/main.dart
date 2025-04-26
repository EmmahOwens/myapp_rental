import 'package:flutter/material.dart';
import '../screens/landlord_signup_screen.dart';
import '../screens/welcome_screen.dart';
import '../theme/theme.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

Future<void> main() async {
  // Load environment variables
  await dotenv.load(fileName: ".env");

  // Start the app
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
   MyApp({super.key});

  // This widget is the root of your application.
   final ValueNotifier<ThemeMode> _notifier = ValueNotifier(ThemeMode.light);
  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
        valueListenable: _notifier,
        builder: (context, mode, child){
          return MaterialApp(
            title: 'Rental Management',
            theme: lightTheme,
            darkTheme: darkTheme,
            themeMode: mode,
            home: WelcomeScreen(
              toggleTheme: (){

                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => LandlordSignupScreen()),
                );

                _notifier.value = _notifier.value == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;
              },
            )
          );
        }
    );
  }
}

class LandlordDashboard extends StatelessWidget {
  const LandlordDashboard({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Landlord Dashboard')),
      body: const Center(
        child: Text('Welcome to Landlord Dashboard!'),
      ),
    );
  }
}

class TenantDashboard extends StatelessWidget {
  const TenantDashboard({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Tenant Dashboard')),
      body: const Center(
        child: Text('Welcome to Tenant Dashboard!'),
      ),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});


  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {

  @override
  Widget build(BuildContext context) {
    return const Placeholder();
  }
}



/*  return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // TRY THIS: Try running your application with "flutter run". You'll see
        // the application has a purple toolbar. Then, without quitting the app,
        // try changing the seedColor in the colorScheme below to Colors.green
        // and then invoke "hot reload" (save your changes or press the "hot
        // reload" button in a Flutter-supported IDE, or press "r" if you used
        // the command line to start the app).
        //
        // Notice that the counter didn't reset back to zero; the application
        // state is not lost during the reload. To reset the state, use hot
        // restart instead.
        //
        // This works for code too, not just values: Most code changes can be
        // tested with just a hot reload.
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home:  MyHomePage(title: 'Flutter Demo Home Page'),
    );*/






