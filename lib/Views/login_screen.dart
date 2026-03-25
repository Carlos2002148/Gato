import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:gato_unison/Models/user_model.dart';
import 'package:gato_unison/Views/lobby_screen.dart';
import 'package:gato_unison/app_colors.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _usernameController = TextEditingController();
  bool isLogin = true;

  Future<void> _handleAuth() async {
    if (_formKey.currentState!.validate()) {
      try {
        if (isLogin) {
          await FirebaseAuth.instance.signInWithEmailAndPassword(
            email: _emailController.text.trim(),
            password: _passwordController.text.trim(),
          );
        } else {
          UserCredential cred = await FirebaseAuth.instance.createUserWithEmailAndPassword(
            email: _emailController.text.trim(),
            password: _passwordController.text.trim(),
          );

          UserModel newUser = UserModel(
            uid: cred.user!.uid,
            username: _usernameController.text.trim(),
            email: _emailController.text.trim(),
            wins: 0,
            gamesPlayed: 0,
          );

          await FirebaseFirestore.instance
              .collection('users')
              .doc(cred.user!.uid)
              .set(newUser.toMap());
        }

        if (mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const LobbyScreen()),
          );
        }
      } on FirebaseAuthException catch (e) {
        String errorMsg = e.code == 'email-already-in-use'
            ? "El correo ya está registrado."
            : e.code == 'wrong-password' ? "Contraseña incorrecta." : "Error de acceso.";

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMsg),
            backgroundColor: AppColors.primary, // <--- Usando AppColors
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          ),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error: ${e.toString()}")),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background, // <--- Usando AppColors
      appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          iconTheme: const IconThemeData(color: AppColors.primary) // <--- Usando AppColors
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 40),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(22),
                  decoration: BoxDecoration(
                    color: AppColors.primaryLight, // <--- Usando AppColors
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.auto_awesome_rounded, size: 45, color: AppColors.primary),
                ),
                const SizedBox(height: 35),

                Text(
                  isLogin ? '¡Hola de nuevo!' : 'Únete al Gato',
                  style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: AppColors.text),
                ),
                const SizedBox(height: 10),
                Text(
                  isLogin ? 'Ingresa tus datos para jugar' : 'Regístrate en unos segundos',
                  style: TextStyle(fontSize: 15, color: AppColors.text.withOpacity(0.6)),
                ),
                const SizedBox(height: 45),

                if (!isLogin) ...[
                  _buildTextField(
                    controller: _usernameController,
                    label: 'Nombre de usuario',
                    icon: Icons.face_rounded,
                  ),
                  const SizedBox(height: 18),
                ],

                _buildTextField(
                  controller: _emailController,
                  label: 'Correo',
                  icon: Icons.email_outlined,
                  keyboardType: TextInputType.emailAddress,
                ),
                const SizedBox(height: 18),

                _buildTextField(
                  controller: _passwordController,
                  label: 'Contraseña',
                  icon: Icons.lock_open_rounded,
                  obscureText: true,
                ),

                const SizedBox(height: 45),

                ElevatedButton(
                  onPressed: _handleAuth,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary, // <--- Usando AppColors
                    foregroundColor: Colors.white,
                    elevation: 0,
                    minimumSize: const Size.fromHeight(62),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
                  ),
                  child: Text(
                    isLogin ? 'ENTRAR' : 'CREAR CUENTA',
                    style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700, letterSpacing: 1.5),
                  ),
                ),

                const SizedBox(height: 25),

                TextButton(
                  onPressed: () => setState(() => isLogin = !isLogin),
                  child: Text(
                    isLogin ? '¿No tienes cuenta? Regístrate' : '¿Ya tienes cuenta? Entra aquí',
                    style: TextStyle(color: AppColors.text.withOpacity(0.8), fontWeight: FontWeight.w500),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    bool obscureText = false,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      style: const TextStyle(color: AppColors.text),
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: AppColors.primary.withOpacity(0.7), size: 22),
        filled: true,
        fillColor: AppColors.inputFill,
        labelStyle: TextStyle(color: AppColors.text.withOpacity(0.4), fontSize: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: BorderSide(color: AppColors.primary.withOpacity(0.3), width: 2),
        ),
      ),
      validator: (val) {
        if (val == null || val.isEmpty) return 'Campo requerido';
        return null;
      },
    );
  }
}