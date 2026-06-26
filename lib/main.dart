import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

import 'app/app_controller.dart';
import 'app/app_texts.dart';
import 'pages/home_page.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  unawaited(MobileAds.instance.initialize());
  runApp(const PaperPilotBootstrap());
}

class PaperPilotBootstrap extends StatefulWidget {
  const PaperPilotBootstrap({super.key});

  @override
  State<PaperPilotBootstrap> createState() => _PaperPilotBootstrapState();
}

class _PaperPilotBootstrapState extends State<PaperPilotBootstrap> {
  final AppController _controller = AppController();

  @override
  void initState() {
    super.initState();
    unawaited(_controller.load());
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        return AppControllerScope(
          controller: _controller,
          child: MaterialApp(
            title: AppTexts(_controller.language).appName,
            debugShowCheckedModeBanner: false,
            locale: _controller.locale,
            supportedLocales: const [Locale('en'), Locale('tr')],
            localizationsDelegates: const [
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            theme: ThemeData(
              useMaterial3: true,
              colorSchemeSeed: const Color(0xFF2457D6),
              scaffoldBackgroundColor: const Color(0xFFF7F8FC),
              appBarTheme: const AppBarTheme(
                backgroundColor: Color(0xFFF7F8FC),
                surfaceTintColor: Colors.transparent,
              ),
              filledButtonTheme: FilledButtonThemeData(
                style: FilledButton.styleFrom(
                  minimumSize: const Size.fromHeight(52),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
              ),
              cardTheme: CardThemeData(
                margin: EdgeInsets.zero,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(22),
                ),
              ),
            ),
            home: const HomePage(),
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
