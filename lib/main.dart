import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:simulador_nasa/presentation/screens/home_screen.dart';
import 'package:sizer/sizer.dart';

void main() {
  runApp(
    // Envolve a aplicação para prover estado (Riverpod)
    const ProviderScope(child: HabitatApp()),
  );
}

class HabitatApp extends StatelessWidget {
  const HabitatApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Sizer necessita envelopar a MaterialApp para definir as dimensões dinâmicas
    return Sizer(
      builder: (context, orientation, screenType) {
        return MaterialApp(
          title: 'Habitat Control',
          debugShowCheckedModeBanner: false,
          theme: ThemeData(
            colorScheme: ColorScheme.fromSeed(
              seedColor: const Color(0xFF0D47A1), // Azul profundo
              brightness: Brightness.light,
            ),
            // Aplica as fontes do Google (GoogleFonts)
            textTheme: GoogleFonts.interTextTheme(Theme.of(context).textTheme)
                .copyWith(
                  displaySmall: GoogleFonts.oswald(
                    textStyle: Theme.of(context).textTheme.displaySmall,
                  ),
                ),
            useMaterial3: true,
          ),
          home: const HomeScreen(),
        );
      },
    );
  }
}
