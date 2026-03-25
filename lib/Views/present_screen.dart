import 'package:flutter/material.dart';
import 'package:gato_unison/Views/login_screen.dart';
import 'package:gato_unison/app_colors.dart';

class PresentScreen extends StatelessWidget {
  const PresentScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final Color primaryPastel = AppColors.primary;
    final Color backgroundPage = AppColors.background;
    final Color textColor = AppColors.text;

    return Scaffold(
      backgroundColor: backgroundPage,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 40),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(25),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(35),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.03),
                        blurRadius: 25,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(15),
                    child: Image.asset(
                      'assets/images/unison_logo.jpg',
                      height: 110,
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
                const SizedBox(height: 45),

                Text(
                  'The Cat',
                  style: TextStyle(
                    fontSize: 38,
                    fontWeight: FontWeight.w900,
                    color: textColor,
                    letterSpacing: -0.5,
                  ),
                ),

                const SizedBox(height: 50),

                // Sección de Integrantes estilizada
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 25, horizontal: 15),
                  decoration: BoxDecoration(
                    color: primaryPastel.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(25),
                    border: Border.all(color: Colors.white),
                  ),
                  child: Column(
                    children: [
                      Text(
                        'EQUIPO DE DESARROLLO',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w900,
                          color: primaryPastel,
                          letterSpacing: 1.5,
                        ),
                      ),
                      const SizedBox(height: 20),
                      _buildMemberName('Carlos G. Grijalva Castillo', textColor),
                      _buildMemberName('Jorge Luis Ruiz Muños', textColor),
                      _buildMemberName('Isaac Moreno Gonzalez', textColor),
                      _buildMemberName('Carlos Rene Quijada Ruiz', textColor),
                    ],
                  ),
                ),

                const SizedBox(height: 60),

                // Botón Estilo Moderno Turquesa
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const LoginPage()),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryPastel,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(horizontal: 45, vertical: 22),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(22),
                    ),
                    shadowColor: primaryPastel.withOpacity(0.4),
                  ).copyWith(
                    elevation: WidgetStateProperty.resolveWith((states) => 10),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'COMENZAR',
                        style: TextStyle(
                            fontWeight: FontWeight.w800,
                            fontSize: 16,
                            letterSpacing: 1.2
                        ),
                      ),
                      SizedBox(width: 12),
                      Icon(Icons.arrow_forward_ios_rounded, size: 18),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMemberName(String name, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Text(
        name,
        style: TextStyle(
          fontSize: 15,
          color: color.withOpacity(0.8),
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}