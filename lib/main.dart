import 'package:chances/services/auth_manager.dart';
import 'package:chances/services/loteria_service.dart';
import 'package:chances/providers/venta_provider.dart';
import 'package:chances/view/resultados_view.dart';
import 'package:chances/view/ventas_view.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'constants.dart';
import 'providers/loteria_provider.dart';
import 'view/login_view.dart';
import 'view/inicial_view.dart';
import 'view/juego_view.dart';

void main() => runApp(const MyApp());
final navigatorKey = GlobalKey<NavigatorState>();

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    AuthManager().init(navigatorKey);
    return MultiProvider(
      providers: [
        Provider<LoteriaApiService>(
          create: (_) => LoteriaApiService(),
        ),
        ChangeNotifierProvider<LoteriaProvider>(
          create: (context) => LoteriaProvider(
            context.read<LoteriaApiService>(),
          )..cargarLoterias(), // dispara la carga al crearse
        ),
        ChangeNotifierProvider(create: (_) => VentasProvider()),
      ],
      child: MaterialApp(
        navigatorKey: navigatorKey,
        debugShowCheckedModeBanner: false,
        title: '777',
        initialRoute: 'login',
        theme: ThemeData(
          fontFamily: 'Inconsolata',
          primaryColor: colorPrincipal,
          colorScheme: ColorScheme.fromSwatch().copyWith(
            background: colorFondoField,
            secondary: colorGrisSecundario,
            primary: colorPrincipal,
          ),
          progressIndicatorTheme: const ProgressIndicatorThemeData(
            color: colorPrincipal,
          ),
        ),
        routes: {
          'login': (_) => const LoginScreen(),
          'inicial': (_) => const InicialScreen(),
          'juegos': (_) => JuegoScreen(sorteosSeleccionados: []),
          'ventas': (_) => const VentasScreen(),
          'resultados': (_) => const ResultadosScreen(),
        },
      ),
    );
  }
}
