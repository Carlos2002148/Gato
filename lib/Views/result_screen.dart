import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:gato_unison/Views/lobby_screen.dart';
import 'package:gato_unison/Views/game_screen.dart';
import 'package:gato_unison/app_colors.dart';

import '../models/result_model.dart' show GameResult;

class ResultScreen extends StatefulWidget {
  final GameResult result;
  const ResultScreen({super.key, required this.result});

  @override
  State<ResultScreen> createState() => _ResultScreenState();
}

class _ResultScreenState extends State<ResultScreen> with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );

    _scaleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.elasticOut),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    _animationController.forward();
    if (widget.result.status == 'victory') _updateWinCount();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _updateWinCount() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final userRef = FirebaseFirestore.instance.collection('users').doc(user.uid);
      await userRef.update({'wins': FieldValue.increment(1)});
    }
  }

  Future<void> _handleRematch() async {
    try {
      await FirebaseFirestore.instance.collection('games').doc(widget.result.gameCode).update({
        'board': List.filled(9, ""),
        'status': 'playing',
        'winner': '',
        'moves': [],
      });
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => GameScreen(gameCode: widget.result.gameCode)),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error: $e")));
    }
  }

  // Colores Dinámicos basados en AppColors
  Color get statusColor {
    if (widget.result.status == 'victory') return AppColors.primary; // Turquesa
    if (widget.result.status == 'defeat') return AppColors.secondary; // Coral
    return const Color(0xFFFFCC80); // Naranja Pastel para Empate
  }

  String get title => widget.result.status == 'victory' ? "¡GANASTE!" : (widget.result.status == 'defeat' ? "DERROTA" : "EMPATE");

  // --- NUEVOS ICONOS UNIVERSALES Y LIMPIOS ---
  IconData get iconData {
    if (widget.result.status == 'victory') {
      return Icons.military_tech_rounded;
    }
    if (widget.result.status == 'defeat') {
      return Icons.assistant_photo_rounded;
    }
    return Icons.handshake_rounded;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [statusColor.withOpacity(0.8), statusColor],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  ScaleTransition(
                    scale: _scaleAnimation,
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 50, horizontal: 20),
                      decoration: BoxDecoration(
                        color: AppColors.background,
                        borderRadius: BorderRadius.circular(35),
                        boxShadow: [
                          BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 20,
                              offset: const Offset(0, 10)
                          )
                        ],
                      ),
                      child: Column(
                        children: [
                          Icon(iconData, size: 140, color: statusColor),
                          const SizedBox(height: 30),
                          Text(
                            title,
                            style: TextStyle(
                                fontSize: 42,
                                fontWeight: FontWeight.w900,
                                color: statusColor,
                                letterSpacing: 2
                            ),
                          ),
                          const SizedBox(height: 15),
                          Text(
                            "Tu récord se ha actualizado.",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                fontSize: 14,
                                color: AppColors.text.withOpacity(0.5),
                                fontStyle: FontStyle.italic
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 60),

                  FadeTransition(
                    opacity: _fadeAnimation,
                    child: Row(
                      children: [
                        Expanded(
                          child: _buildButton(
                            label: 'INICIO',
                            icon: Icons.home_rounded,
                            onPressed: () {
                              Navigator.pushAndRemoveUntil(
                                context,
                                MaterialPageRoute(builder: (context) => const LobbyScreen()),
                                    (route) => false,
                              );
                            },
                            isPrimary: false,
                          ),
                        ),
                        const SizedBox(width: 20),
                        Expanded(
                          child: _buildButton(
                            label: 'REVANCHA',
                            icon: Icons.replay_rounded,
                            onPressed: _handleRematch,
                            isPrimary: true,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildButton({required String label, required IconData icon, required VoidCallback onPressed, required bool isPrimary}) {
    return SizedBox(
      height: 75,
      child: isPrimary
          ? ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.background,
          foregroundColor: statusColor,
          elevation: 4,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 26),
            const SizedBox(height: 4),
            Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
          ],
        ),
      )
          : OutlinedButton(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.background,
          side: const BorderSide(color: AppColors.background, width: 2.5),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 26),
            const SizedBox(height: 4),
            Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }
}