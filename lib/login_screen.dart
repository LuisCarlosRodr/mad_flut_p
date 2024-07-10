import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  bool _isLoading = false;

  Future<void> _signInWithEmailAndPassword() async {
    setState(() {
      _isLoading = true;
    });
    try {
      final UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
      );

      final User? user = userCredential.user;
      if (user != null) {
        print('Login successful!');
        // Navegar a la pantalla principal
      } else {
        print('Login failed: user is null');
      }
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        _showErrorDialog('No hay usuario registrado con este correo.');
      } else if (e.code == 'wrong-password') {
        _showErrorDialog('La contraseña ingresada es incorrecta.');
      } else {
        _showErrorDialog('Error al iniciar sesión: ${e.message}');
      }
    } catch (e) {
      _showErrorDialog('Error desconocido: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _registerWithEmailAndPassword() async {
    setState(() {
      _isLoading = true;
    });
    try {
      final UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
      );

      final User? user = userCredential.user;
      if (user != null) {
        print('Registration successful!');
        // Navegar a la pantalla principal
      } else {
        print('Registration failed: user is null');
      }
    } on FirebaseAuthException catch (e) {
      if (e.code == 'weak-password') {
        _showErrorDialog('La contraseña es demasiado débil.');
      } else if (e.code == 'email-already-in-use') {
        _showErrorDialog('El correo electrónico ya está en uso.');
      } else {
        _showErrorDialog('Error al registrar usuario: ${e.message}');
      }
    } catch (e) {
      _showErrorDialog('Error desconocido: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Error'),
        content: Text(message),
        actions: <Widget>[
          TextButton(
            child: const Text('OK'),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.blue.shade200, Colors.blueGrey.shade900],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
            child: Card(
              elevation: 8.0,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.0)),
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    const Text(
                      'GPSNow',
                      style: TextStyle(fontSize: 28.0, fontWeight: FontWeight.bold, color: Colors.blueGrey),
                    ),
                    const SizedBox(height: 16.0),
                    _buildTextField(emailController, 'Email', Icons.email),
                    const SizedBox(height: 16.0),
                    _buildTextField(passwordController, 'Password', Icons.lock, obscureText: true),
                    const SizedBox(height: 24.0),
                    _isLoading
                        ? const CircularProgressIndicator()
                        : Column(
                      children: [
                        ElevatedButton(
                          onPressed: _signInWithEmailAndPassword,
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0), backgroundColor: Colors.blueGrey,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
                          ),
                          child: const Text('LOG IN',
                          style: TextStyle(color: Colors.white),),
                        ),
                        const SizedBox(height: 16.0),
                        TextButton(
                          onPressed: _registerWithEmailAndPassword,
                          child: const Text(
                            'SIGN UP',
                            style: TextStyle(color: Colors.blueGrey),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String labelText, IconData icon, {bool obscureText = false}) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        labelText: labelText,
        prefixIcon: Icon(icon, color: Colors.blueGrey),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8.0)),
      ),
      obscureText: obscureText,
    );
  }
}
