import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:permission_handler/permission_handler.dart';

import 'models/alarm.dart';
import 'models/sleep_record.dart';
import 'models/alarm_stats.dart';
import 'services/alarm_service.dart';
import 'services/notification_service.dart';
import 'services/preset_service.dart';
import 'services/sleep_tracking_service.dart';
import 'theme/app_theme.dart';
import 'screens/home_shell.dart';
import 'screens/onboarding_screen.dart';
import 'screens/settings_screen.dart';
import 'screens/alarm_edit_screen.dart';
import 'screens/alarm_ring_screen.dart';
import 'screens/sleep_tracking_screen.dart';

/// MethodChannel for receiving intents from native side
const MethodChannel _intentChannel = MethodChannel('com.rise.app.intent');

/// Global navigator key for routing from outside widget tree
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize timezone data
  tz.initializeTimeZones();
  
  // Initialize Isar database
  final dir = await getApplicationDocumentsDirectory();
  final isar = await Isar.open(
    [AlarmSchema, SleepRecordSchema, AlarmStatsSchema, AggregatedStatsSchema],
    directory: dir.path,
  );
  
  // Initialize notification service
  await NotificationService.initialize();
  
  // Initialize alarm service
  await AlarmService.initialize(isar);

  // Initialize sleep tracking service
  await SleepTrackingService.initialize(isar);

  // Wire bedtime notification tap → navigate to sleep tracking with autoStart
  NotificationService.setBedtimeTapCallback(() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      navigatorKey.currentState?.push(
        MaterialPageRoute(
          builder: (_) => SleepTrackingScreen(isar: isar, autoStart: true),
        ),
      );
    });
  });
  
  // Request critical permissions
  await _requestPermissions();
  
  // Lock orientation to portrait
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
  ]);
  
  runApp(WakeMeUpProApp(isar: isar));
}

Future<void> _requestPermissions() async {
  // Request notification permissions
  await Permission.notification.request();
  
  // Android-specific permissions
  if (await Permission.scheduleExactAlarm.isDenied) {
    await Permission.scheduleExactAlarm.request();
  }
  
  // Camera permission (for missions)
  await Permission.camera.request();
}

class WakeMeUpProApp extends StatefulWidget {
  final Isar isar;
  
  const WakeMeUpProApp({Key? key, required this.isar}) : super(key: key);

  @override
  State<WakeMeUpProApp> createState() => _WakeMeUpProAppState();
}

class _WakeMeUpProAppState extends State<WakeMeUpProApp> with WidgetsBindingObserver {
  Map<String, dynamic>? _pendingAlarmData;
  
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _setupIntentChannel();
    _checkInitialIntent();
  }
  
  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }
  
  /// Set up handler for incoming intents from native
  void _setupIntentChannel() {
    _intentChannel.setMethodCallHandler((call) async {
      if (call.method == 'launchAlarm') {
        final alarmData = Map<String, dynamic>.from(call.arguments);
        _navigateToAlarmRing(alarmData);
      }
    });
  }
  
  /// Check if app was launched with alarm intent
  Future<void> _checkInitialIntent() async {
    try {
      final result = await _intentChannel.invokeMethod('getInitialIntent');
      if (result != null) {
        _pendingAlarmData = Map<String, dynamic>.from(result);
      }
    } catch (e) {
      // Channel not set up yet on native side, ignore
      print('No initial intent available: $e');
    }
  }
  
  /// Navigate to alarm ring screen with parameters
  void _navigateToAlarmRing(Map<String, dynamic> alarmData) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      navigatorKey.currentState?.pushNamed(
        '/alarm-ring',
        arguments: alarmData,
      );
    });
  }
  
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      SleepTrackingService.instance.onAppForeground();
      if (_pendingAlarmData != null) {
        _navigateToAlarmRing(_pendingAlarmData!);
        _pendingAlarmData = null;
      }
    } else if (state == AppLifecycleState.paused) {
      SleepTrackingService.instance.onAppBackground();
    }
  }

  /// A sensible default for a new alarm: the next occurrence of 07:00.
  static DateTime _newAlarmTime() {
    final now = DateTime.now();
    final candidate = DateTime(now.year, now.month, now.day, 7);
    return candidate.isAfter(now)
        ? candidate
        : candidate.add(const Duration(days: 1));
  }

  static Alarm _newAlarm() => Alarm.create(time: _newAlarmTime());

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Rise',
      navigatorKey: navigatorKey,
      debugShowCheckedModeBanner: false,
      theme: buildAppTheme(),
      initialRoute: '/',
      onGenerateRoute: (settings) {
        // Check for pending alarm data on initial route
        if (settings.name == '/' && _pendingAlarmData != null) {
          final alarmData = _pendingAlarmData;
          _pendingAlarmData = null;
          return MaterialPageRoute(
            settings: const RouteSettings(name: '/alarm-ring'),
            builder: (context) => AlarmRingScreen(initialData: alarmData),
          );
        }
        
        switch (settings.name) {
          case '/':
            return MaterialPageRoute(
              builder: (context) => _RootGate(
                isar: widget.isar,
                onOnboardingDone: () {
                  navigatorKey.currentState
                      ?.pushReplacementNamed('/');
                },
              ),
            );
          case '/alarm-ring':
            final args = settings.arguments as Map<String, dynamic>?;
            return MaterialPageRoute(
              settings: settings,
              builder: (context) => AlarmRingScreen(initialData: args),
            );
          case '/alarm-new':
            return MaterialPageRoute(
              settings: settings,
              builder: (context) => AlarmEditScreen(
                isar: widget.isar,
                alarm: _newAlarm(),
              ),
            );
          case '/settings':
            return MaterialPageRoute(
              settings: settings,
              builder: (context) => SettingsScreen(isar: widget.isar),
            );
          default:
            return MaterialPageRoute(
              builder: (context) => _RootGate(
                isar: widget.isar,
                onOnboardingDone: () {
                  navigatorKey.currentState
                      ?.pushReplacementNamed('/');
                },
              ),
            );
        }
      },
    );
  }
}

/// Decides whether to show onboarding or the app.
///
/// The check happens once per app start. Onboarding is only shown when no
/// preset has ever been applied, so a configured user is never asked again.
class _RootGate extends StatefulWidget {
  const _RootGate({required this.isar, required this.onOnboardingDone});

  final Isar isar;
  final VoidCallback onOnboardingDone;

  @override
  State<_RootGate> createState() => _RootGateState();
}

class _RootGateState extends State<_RootGate> {
  Future<bool>? _configured;

  @override
  void initState() {
    super.initState();
    _configured = PresetService.isConfigured();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<bool>(
      future: _configured,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        if (snapshot.data == true) {
          return HomeShell(isar: widget.isar);
        }
        return OnboardingScreen(onDone: widget.onOnboardingDone);
      },
    );
  }
}
