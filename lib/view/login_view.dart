import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../constants.dart';
import '../services/login_service.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool _recordarme = false;
  final LoginService _authService = LoginService();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  bool _isLoading = false; // Variable para manejar el estado de carga

  @override
  void initState() {
    super.initState();
    _cargarPreferencias(); // Carga los datos si estaban guardados
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final screenHeight = screenSize.height;
    final screenWidth = screenSize.width;

    return Scaffold(
      backgroundColor: colorFondoField,
      body: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              barraSuperior(context, 0.16, "", 60.0),
              Padding(
                  padding: const EdgeInsets.all(40.0),
                  child: Column(
                    children: [
                      Image.asset('assets/images/logo.jpeg'),
                      SizedBox(height: screenHeight * 0.03),
                      inputUsuario(
                        'Usuario',
                        false,
                        _usernameController,
                        const Icon(Icons.person, color: colorPrincipal),
                      ),
                      SizedBox(height: screenHeight * 0.02),
                      inputUsuario(
                        'Contraseña',
                        true,
                        _passwordController,
                        const Icon(Icons.lock, color: colorPrincipal),
                      ),
                      Row(
                        children: [
                          Checkbox(
                            value: _recordarme,
                            onChanged: (value) {
                              setState(() {
                                _recordarme = value ?? false;
                              });
                            },
                          ),
                          const Text('Recordarme en este dispositivo'),
                        ],
                      ),
                      SizedBox(height: screenHeight * 0.04),
                      _isLoading
                          ? const CircularProgressIndicator(
                              color: colorPrincipal,
                            )
                          : SizedBox(
                              width: screenWidth * 0.6,
                              height: screenHeight * 0.07,
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: colorPrincipal,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),
                                onPressed: _login,
                                child: const Text(
                                  'Iniciar Sesión',
                                  style: TextStyle(
                                      fontSize: 18, color: Colors.white),
                                ),
                              ),
                            ),
                      SizedBox(height: screenHeight * 0.08),
                      const Text("Version: 1.0", style: TextStyle(color: colorGrisSecundario, fontSize: 16),)
                    ],
                  )),
            ],
          ),
        ),
      ),
    );
  }

  TextFormField inputUsuario(
    String label,
    bool ocultar,
    TextEditingController controller,
    Icon icono,
  ) {
    return TextFormField(
      cursorColor: colorPrincipal,
      controller: controller,
      obscureText: ocultar,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: colorPrincipal),
        prefixIcon: icono,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: colorFondoField),
          borderRadius: BorderRadius.circular(10),
        ),
        filled: true,
        fillColor: Colors.white,
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Por favor ingresa tu $label';
        }
        return null;
      },
    );
  }

  Future<void> _guardarPreferenciaRecordarme() async {
    final prefs = await SharedPreferences.getInstance();
    if (_recordarme) {
      await prefs.setBool('recordarme', true);
      await prefs.setString('usuario', _usernameController.text);
      await prefs.setString('password', _passwordController.text);
    } else {
      await prefs.remove('recordarme');
      await prefs.remove('usuario');
      await prefs.remove('password');
    }
  }

  Future<void> _cargarPreferencias() async {
    final prefs = await SharedPreferences.getInstance();
    final recordarme = prefs.getBool('recordarme') ?? false;

    if (recordarme) {
      setState(() {
        _recordarme = true;
        _usernameController.text = prefs.getString('usuario') ?? '';
        _passwordController.text = prefs.getString('password') ?? '';
      });
    }
  }

  Future<void> _login() async {
    // Validamos el formulario antes de intentar hacer el login
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true; // Iniciar el estado de carga
    });

    try {
      await _authService.login(
        _usernameController.text,
        _passwordController.text,
      );
      await _guardarPreferenciaRecordarme();
      Navigator.pushReplacementNamed(context, 'inicial');
    } catch (error) {
      String errorMessage =
          error.toString().contains('Credenciales incorrectas')
              ? 'Usuario o contraseña incorrectos'
              : 'Error en el inicio de sesión';

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(errorMessage)),
      );
    } finally {
      setState(() {
        _isLoading = false; // Detener el estado de carga
      });
    }
  }
}
