Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  await NotificationService().init();

  runApp(const ArrivoApp());
}

class ArrivoApp extends StatelessWidget {
  const ArrivoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider<AuthService>(create: (_) => AuthService()),
        ChangeNotifierProvider<AlarmProvider>(create: (_) => AlarmProvider()),
      ],
      child: MaterialApp(
        title: 'Arrivo',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorSchemeSeed: Colors.indigo,
          useMaterial3: true,
        ),
        home: const _AuthGate(),
      ),
    );
  }
}

/// Swaps between the login flow and the home screen based on auth state,
/// and starts/stops the alarm stream to match.
class _AuthGate extends StatelessWidget {
  const _AuthGate();

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: context.read<AuthService>().authStateChanges,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        final user = snapshot.data;
        final alarmProvider = context.read<AlarmProvider>();

        if (user == null) {
          alarmProvider.stopListening();
          return const LoginScreen();
        }

        alarmProvider.listenTo(user.uid);
        // TODO: kick off AppGeofenceService.syncGeofences() once alarms load.
        return const HomeScreen();
      },
    );
  }
}