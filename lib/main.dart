import 'package:aiplantidentifier/core/app_settings.dart';
import 'package:aiplantidentifier/providers/analyze.dart';
import 'package:aiplantidentifier/providers/auth_provider.dart';
import 'package:aiplantidentifier/utils/helper_methodes.dart';
import 'package:aiplantidentifier/utils/responsivehelper.dart';
import 'package:aiplantidentifier/utils/theame_data.dart';
import 'package:aiplantidentifier/providers/dairy_provider.dart';
import 'package:aiplantidentifier/views/drwer.dart';
import 'package:aiplantidentifier/views/splashscreen/splash.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  GoogleFonts.config.allowRuntimeFetching = false;
  AppSettings.initializeAppInfoInstance();
  await AppSettings.appInfo!.updateLocalVariablesWithSharedPreference();

  await AppSettings.loadAppDataToRunTimeVariables();
  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]).then((
    _,
  ) {
    runApp(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => PlantIdentificationProvider()),
          ChangeNotifierProvider(create: (_) => PlantProvider()),
          ChangeNotifierProvider(create: (_) => ForgotPasswordProvider()),
        ],
        child: MyApp(),
      ),
    );
  });
}

final GlobalKey<NavigatorState> appNavigatorKey = GlobalKey<NavigatorState>();

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: appNavigatorKey,
      debugShowCheckedModeBanner: false,
      title: 'spiffy',
      theme: AppTheme.lightTheme(context),
      darkTheme: AppTheme.darkTheme(context),
      themeMode: ThemeMode.system,
      home: SplashScreen(),
      // home: ResponsiveAppExample(),
    );
  }
}

class RoutineRefreshNotifier {
  static final ValueNotifier<int> notifier = ValueNotifier(0);

  static void refresh() {
    notifier.value++;
    printGreen('🔄 Routine refresh triggered');
  }
}

/// EXAMPLE 1: Simple Screen with Responsive Padding
class ExampleScreen1 extends StatelessWidget {
  const ExampleScreen1({super.key});

  @override
  Widget build(BuildContext context) {
    final spacing = context.spacing;
    final typography = context.typography;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'My App',
          style: TextStyle(fontSize: typography.headingMedium),
        ),
      ),
      body: ResponsiveBox(
        addPadding: true,
        backgroundColor: Colors.white,
        child: SingleChildScrollView(
          child: Column(
            children: [
              Text(
                'Welcome',
                style: TextStyle(
                  fontSize: typography.headingLarge,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: spacing.lg),
              Text(
                'This is a responsive app',
                style: TextStyle(fontSize: typography.bodyMedium),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// EXAMPLE 2: Responsive Grid Layout
class ExampleScreen2 extends StatelessWidget {
  const ExampleScreen2({super.key});

  @override
  Widget build(BuildContext context) {
    final gridHelper = context.gridHelper;
    final spacing = context.spacing;
    final typography = context.typography;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Grid Layout',
          style: TextStyle(fontSize: typography.headingMedium),
        ),
      ),
      body: Padding(
        padding: EdgeInsets.all(spacing.md),
        child: GridView.builder(
          gridDelegate: gridHelper.defaultGridDelegate,
          itemCount: 12,
          itemBuilder: (context, index) {
            return Container(
              decoration: BoxDecoration(
                color: Colors.green.shade100,
                borderRadius: BorderRadius.circular(spacing.mediumRadius),
              ),
              child: Center(
                child: Text(
                  'Item $index',
                  style: TextStyle(fontSize: typography.bodyMedium),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

/// EXAMPLE 3: Responsive List with Cards
class ExampleScreen3 extends StatelessWidget {
  const ExampleScreen3({super.key});

  @override
  Widget build(BuildContext context) {
    final spacing = context.spacing;
    final typography = context.typography;
    final iconSize = context.iconSize;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Plant List',
          style: TextStyle(fontSize: typography.headingMedium),
        ),
      ),
      body: ListView.builder(
        padding: EdgeInsets.all(spacing.md),
        itemCount: 10,
        itemBuilder: (context, index) {
          return Card(
            margin: EdgeInsets.only(bottom: spacing.md),
            child: ListTile(
              leading: Icon(
                Icons.local_florist,
                size: iconSize.md,
                color: Colors.green,
              ),
              title: Text(
                'Plant $index',
                style: TextStyle(fontSize: typography.bodyLarge),
              ),
              subtitle: Text(
                'This is a plant description',
                style: TextStyle(fontSize: typography.bodySmall),
              ),
              trailing: Icon(Icons.arrow_forward, size: iconSize.sm),
            ),
          );
        },
      ),
    );
  }
}

/// EXAMPLE 4: Responsive Dialog/Bottom Sheet
class ExampleScreen4 extends StatelessWidget {
  const ExampleScreen4({super.key});

  void _showResponsiveDialog(BuildContext context) {
    final typography = context.typography;
    final buttonSize = context.buttonSize;

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(
            'Confirm Action',
            style: TextStyle(fontSize: typography.headingSmall),
          ),
          content: Text(
            'Are you sure you want to proceed?',
            style: TextStyle(fontSize: typography.bodyMedium),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                'Cancel',
                style: TextStyle(fontSize: buttonSize.mediumFontSize),
              ),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              style: ElevatedButton.styleFrom(
                padding: buttonSize.mediumPadding,
              ),
              child: Text(
                'Confirm',
                style: TextStyle(fontSize: buttonSize.mediumFontSize),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    // final spacing = context.spacing;
    final typography = context.typography;
    final buttonSize = context.buttonSize;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Responsive Dialog',
          style: TextStyle(fontSize: typography.headingMedium),
        ),
      ),
      body: Center(
        child: ElevatedButton(
          onPressed: () => _showResponsiveDialog(context),
          style: ElevatedButton.styleFrom(padding: buttonSize.largePadding),
          child: Text(
            'Show Dialog',
            style: TextStyle(fontSize: buttonSize.largeFontSize),
          ),
        ),
      ),
    );
  }
}

class ResponsiveCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final VoidCallback? onTap;

  const ResponsiveCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.icon,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final spacing = context.spacing;
    final typography = context.typography;
    final iconSize = context.iconSize;

    return Card(
      margin: EdgeInsets.only(bottom: spacing.md),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(spacing.mediumRadius),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(spacing.mediumRadius),
        child: Padding(
          padding: EdgeInsets.all(spacing.md),
          child: Row(
            children: [
              Icon(icon, size: iconSize.lg, color: Colors.green),
              SizedBox(width: spacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: typography.bodyLarge,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: spacing.xs),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: typography.bodySmall,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(Icons.chevron_right, size: iconSize.md),
            ],
          ),
        ),
      ),
    );
  }
}

/// EXAMPLE 6: Using ResponsiveWidget wrapper
class ExampleScreen5 extends StatelessWidget {
  const ExampleScreen5({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Responsive Widget Example')),
      body: ResponsiveWidget(
        builder: (context, screenType, spacing, typography) {
          return ListView(
            padding: EdgeInsets.all(spacing.md),
            children: [
              Text(
                'Screen Type: ${screenType.toString().split('.').last}',
                style: TextStyle(
                  fontSize: typography.bodyLarge,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: spacing.lg),
              for (int i = 0; i < 5; i++)
                ResponsiveCard(
                  title: 'Item $i',
                  subtitle: 'Description for item $i',
                  icon: Icons.local_florist,
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Tapped item $i'),
                        duration: const Duration(seconds: 1),
                      ),
                    );
                  },
                ),
            ],
          );
        },
      ),
    );
  }
}

/// EXAMPLE 7: Responsive Button with all sizes
class ResponsiveButtonExample extends StatelessWidget {
  const ResponsiveButtonExample({super.key});

  @override
  Widget build(BuildContext context) {
    final spacing = context.spacing;
    final buttonSize = context.buttonSize;

    return Scaffold(
      appBar: AppBar(title: const Text('Responsive Buttons')),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(spacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Small Button
            ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(padding: buttonSize.smallPadding),
              child: Text(
                'Small Button',
                style: TextStyle(fontSize: buttonSize.smallFontSize),
              ),
            ),
            SizedBox(height: spacing.md),

            // Medium Button
            ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                padding: buttonSize.mediumPadding,
              ),
              child: Text(
                'Medium Button',
                style: TextStyle(fontSize: buttonSize.mediumFontSize),
              ),
            ),
            SizedBox(height: spacing.md),

            // Large Button
            ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(padding: buttonSize.largePadding),
              child: Text(
                'Large Button',
                style: TextStyle(fontSize: buttonSize.largeFontSize),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// EXAMPLE 8: Responsive Text
class ResponsiveTextExample extends StatelessWidget {
  const ResponsiveTextExample({super.key});

  @override
  Widget build(BuildContext context) {
    final spacing = context.spacing;
    final typography = context.typography;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Responsive Text',
          style: TextStyle(fontSize: typography.headingMedium),
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(spacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Display Large',
              style: TextStyle(fontSize: typography.displayLarge),
            ),
            SizedBox(height: spacing.md),
            Text(
              'Display Medium',
              style: TextStyle(fontSize: typography.displayMedium),
            ),
            SizedBox(height: spacing.md),
            Text(
              'Heading Large',
              style: TextStyle(fontSize: typography.headingLarge),
            ),
            SizedBox(height: spacing.md),
            Text(
              'Body Large',
              style: TextStyle(fontSize: typography.bodyLarge),
            ),
            SizedBox(height: spacing.md),
            Text(
              'Body Small',
              style: TextStyle(fontSize: typography.bodySmall),
            ),
          ],
        ),
      ),
    );
  }
}

/// EXAMPLE 9: Checking screen type and conditional rendering
class ResponsiveConditionalExample extends StatelessWidget {
  const ResponsiveConditionalExample({super.key});

  @override
  Widget build(BuildContext context) {
    // final spacing = context.spacing;
    final typography = context.typography;

    // Check screen type
    if (context.isMobile) {
      return Scaffold(
        appBar: AppBar(title: const Text('Mobile View')),
        body: Center(
          child: Text(
            'This is Mobile View',
            style: TextStyle(fontSize: typography.headingMedium),
          ),
        ),
      );
    } else if (context.isTablet) {
      return Scaffold(
        appBar: AppBar(title: const Text('Tablet View')),
        body: Row(
          children: [
            Expanded(
              child: Container(
                color: Colors.green.shade100,
                child: Center(
                  child: Text(
                    'Left Panel',
                    style: TextStyle(fontSize: typography.bodyLarge),
                  ),
                ),
              ),
            ),
            Expanded(
              child: Container(
                color: Colors.green.shade200,
                child: Center(
                  child: Text(
                    'Right Panel',
                    style: TextStyle(fontSize: typography.bodyLarge),
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    } else {
      // Large Tablet
      return Scaffold(
        appBar: AppBar(title: const Text('Large Tablet View')),
        body: Row(
          children: [
            Expanded(
              flex: 1,
              child: Container(
                color: Colors.green.shade100,
                child: Center(
                  child: Text(
                    'Left Panel',
                    style: TextStyle(fontSize: typography.bodyLarge),
                  ),
                ),
              ),
            ),
            Expanded(
              flex: 2,
              child: Container(
                color: Colors.green.shade200,
                child: Center(
                  child: Text(
                    'Center Panel',
                    style: TextStyle(fontSize: typography.bodyLarge),
                  ),
                ),
              ),
            ),
            Expanded(
              flex: 1,
              child: Container(
                color: Colors.green.shade300,
                child: Center(
                  child: Text(
                    'Right Panel',
                    style: TextStyle(fontSize: typography.bodyLarge),
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    }
  }
}

/// EXAMPLE 10: Complete App with all responsive features
class ResponsiveAppExample extends StatefulWidget {
  const ResponsiveAppExample({super.key});

  @override
  State<ResponsiveAppExample> createState() => _ResponsiveAppExampleState();
}

class _ResponsiveAppExampleState extends State<ResponsiveAppExample> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    // final spacing = context.spacing;
    // final typography = context.typography;

    final screens = [
      ExampleScreen1(),
      ExampleScreen2(),
      ExampleScreen3(),
      ExampleScreen4(),
      ExampleScreen5(),
    ];

    return Scaffold(
      body: screens[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.grid_3x3), label: 'Grid'),
          BottomNavigationBarItem(icon: Icon(Icons.list), label: 'List'),
          BottomNavigationBarItem(
            icon: Icon(Icons.description),
            label: 'Dialog',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.widgets), label: 'Widget'),
        ],
      ),
    );
  }
}
