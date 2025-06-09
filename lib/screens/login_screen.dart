import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tienda_app/main.dart';
import '../providers/product_providers.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  String _username = '';
  String _password = '';
  bool _isLoading = false;
  String _errorMessage = '';

  void _submit() async {
    final isValid = _formKey.currentState?.validate() ?? false;
    if (!isValid) return;

    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    _formKey.currentState?.save();
    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    final success = await authProvider.login(_username, _password);

    if (success) {
      Navigator.pushReplacement(
        // ignore: use_build_context_synchronously
        context,
        MaterialPageRoute(builder: (_) => const Tienda()),
      );
    } else {
      setState(() {
        _errorMessage = 'Credenciales inválidas';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Iniciar Sesión')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Center(
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  decoration: const InputDecoration(labelText: 'Usuario'),
                  onSaved: (value) => _username = value!,
                  validator:
                      (value) =>
                          value == null || value.isEmpty
                              ? 'Ingresa tu usuario'
                              : null,
                ),
                TextFormField(
                  decoration: const InputDecoration(labelText: 'Contraseña'),
                  obscureText: true,
                  onSaved: (value) => _password = value!,
                  validator:
                      (value) =>
                          value == null || value.isEmpty
                              ? 'Ingresa tu contraseña'
                              : null,
                ),
                const SizedBox(height: 16),
                if (_errorMessage.isNotEmpty)
                  Text(
                    _errorMessage,
                    style: const TextStyle(color: Colors.red),
                  ),
                const SizedBox(height: 16),
                _isLoading
                    ? const CircularProgressIndicator()
                    : ElevatedButton(
                      onPressed: _submit,
                      child: const Text('Iniciar sesión'),
                    ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
