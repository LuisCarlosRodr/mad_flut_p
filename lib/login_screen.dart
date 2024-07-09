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
      final UserCredential userCredential =
      await _auth.signInWithEmailAndPassword(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
      );

      // Si llegamos aquí, el login fue exitoso
      final User? user = userCredential.user;
      if (user != null) {
        print('Login successful!');
      } else {
        print('Login failed: user is null');
      }
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        _showErrorDialog('No hay usuario registrado con este correo.');
      } else if (e.code == 'wrong-password') {
        _showErrorDialog('La contraseña ingresada es incorrecta.');
      } else {
        print('Error al iniciar sesión: ${e.message}');
        _showErrorDialog('Error al iniciar sesión: ${e.message}');
      }
    } catch (e) {
      print('Error desconocido: $e');
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
      final UserCredential userCredential =
      await _auth.createUserWithEmailAndPassword(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
      );

      // Si llegamos aquí, el registro fue exitoso
      final User? user = userCredential.user;
      if (user != null) {
        print('Registration successful!');
        // Aquí puedes realizar acciones adicionales después del registro, como navegar a la página principal
        // Por ejemplo, Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => MainScreen()));
      } else {
        print('Registration failed: user is null');
      }
    } on FirebaseAuthException catch (e) {
      if (e.code == 'weak-password') {
        _showErrorDialog('La contraseña es demasiado débil.');
      } else if (e.code == 'email-already-in-use') {
        _showErrorDialog('El correo electrónico ya está en uso.');
      } else {
        print('Error al registrar usuario: ${e.message}');
        _showErrorDialog('Error al registrar usuario: ${e.message}');
      }
    } catch (e) {
      print('Error desconocido: $e');
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
        title: Text('Error'),
        content: Text(message),
        actions: <Widget>[
          TextButton(
            child: Text('OK'),
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
      appBar: AppBar(title: const Text("Iniciar sesión")),
      body: _isLoading
          ? Center(
        child: CircularProgressIndicator(),
      )
          : Column(
        children: <Widget>[
          TextField(
            controller: emailController,
            decoration: const InputDecoration(labelText: 'Email'),
          ),
          TextField(
            controller: passwordController,
            decoration: const InputDecoration(labelText: 'Password'),
            obscureText: true,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: <Widget>[
              ElevatedButton(
                onPressed: _signInWithEmailAndPassword,
                child: const Text('Login'),
              ),
              ElevatedButton(
                onPressed: _registerWithEmailAndPassword,
                child: const Text('Register'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
