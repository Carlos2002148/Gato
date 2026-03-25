import 'dart:math';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:gato_unison/Views/game_screen.dart';
import 'package:gato_unison/Views/login_screen.dart';
import 'package:gato_unison/app_colors.dart';
import 'ranking_screen.dart';

class LobbyScreen extends StatefulWidget {
  const LobbyScreen({super.key});

  @override
  State<LobbyScreen> createState() => _LobbyScreenState();
}

class _LobbyScreenState extends State<LobbyScreen> {
  final TextEditingController _codeController = TextEditingController();
  String? username;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final doc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
      if (mounted) {
        setState(() {
          username = doc.data()?['username'] ?? 'Jugador';
          isLoading = false;
        });
      }
    }
  }

  String _generateRoomCode() {
    const chars = 'ABCDEF1234567890';
    return List.generate(6, (index) => chars[Random().nextInt(chars.length)]).join();
  }

  Future<void> _createGame() async {
    String code = _generateRoomCode();
    final user = FirebaseAuth.instance.currentUser;

    await FirebaseFirestore.instance.collection('games').doc(code).set({
      'gameCode': code,
      'players': [username, ""],
      'playerIds': [user?.uid, ""],
      'board': List.filled(9, ""),
      'turn': user?.uid,
      'status': 'waiting',
      'winner': '',
      'moves': [],
    });

    if (!mounted) return;
    _showWaitingDialog(code);
  }

  void _showWaitingDialog(String code) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return StreamBuilder<DocumentSnapshot>(
          stream: FirebaseFirestore.instance.collection('games').doc(code).snapshots(),
          builder: (context, snapshot) {
            if (snapshot.hasData && snapshot.data!.exists) {
              var data = snapshot.data!.data() as Map<String, dynamic>;
              if (data['status'] == 'playing') {
                Future.delayed(Duration.zero, () {
                  Navigator.pop(context);
                  Navigator.push(context, MaterialPageRoute(builder: (context) => GameScreen(gameCode: code)));
                });
              }
            }

            return AlertDialog(
              backgroundColor: AppColors.background,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
              title: const Text("Esperando Rival", textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.text)),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text("Comparte este código:", style: TextStyle(color: Colors.grey)),
                  const SizedBox(height: 15),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    decoration: BoxDecoration(
                      color: AppColors.secondaryLight,
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: SelectableText(
                      code,
                      style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: AppColors.secondary, letterSpacing: 4),
                    ),
                  ),
                  const SizedBox(height: 25),
                  const CircularProgressIndicator(color: AppColors.secondary, strokeWidth: 3),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text("Cancelar", style: TextStyle(color: AppColors.secondary)),
                )
              ],
            );
          },
        );
      },
    );
  }

  Future<void> _joinGame() async {
    String code = _codeController.text.trim().toUpperCase();
    if (code.length != 6) return;

    final user = FirebaseAuth.instance.currentUser;
    final docRef = FirebaseFirestore.instance.collection('games').doc(code);
    final doc = await docRef.get();

    if (doc.exists && doc.data()?['status'] == 'waiting') {
      await docRef.update({
        'players': [doc.data()?['players'][0], username],
        'playerIds': [doc.data()?['playerIds'][0], user?.uid],
        'status': 'playing',
      });

      if (!mounted) return;
      Navigator.push(context, MaterialPageRoute(builder: (context) => GameScreen(gameCode: code)));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text("Código inválido"),
          backgroundColor: AppColors.secondary,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) return const Scaffold(backgroundColor: AppColors.background, body: Center(child: CircularProgressIndicator(color: AppColors.primary)));

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        title: const Text("The Cat", style: TextStyle(color: AppColors.text, fontWeight: FontWeight.w900, letterSpacing: 1)),
        actions: [
          IconButton(
            icon: const Icon(Icons.power_settings_new_rounded, color: AppColors.secondary, size: 28),
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
              if (mounted) Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context) => const LoginPage()), (route) => false);
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 30),
        child: Column(
          children: [
            const SizedBox(height: 20),

            // TARJETA DE PERFIL
            Container(
              padding: const EdgeInsets.all(25),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(30),
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 20, offset: const Offset(0, 10))],
              ),
              child: Row(
                children: [
                  CircleAvatar(
                      radius: 30,
                      backgroundColor: AppColors.primaryLight,
                      child: const Icon(Icons.face_rounded, size: 35, color: AppColors.primary)
                  ),
                  const SizedBox(width: 15),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text("Bienvenido,", style: TextStyle(color: Colors.grey, fontSize: 13)),
                        Text(username!, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.text)),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.leaderboard_rounded, color: AppColors.primary, size: 30),
                    onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const RankingScreen())),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 40),

            // SECCIÓN CREAR (SALMÓN / CORAL PASTEL) - ICONO RESTAURADO
            _buildActionCard(
              title: "NUEVA PARTIDA",
              buttonLabel: "CREAR SALA",
              color: AppColors.secondary,
              icon: Icons.add_rounded, // <--- Icono restaurado aquí
              onPressed: _createGame,
            ),

            const Padding(
              padding: EdgeInsets.symmetric(vertical: 30),
              child: Row(
                children: [
                  Expanded(child: Divider()),
                  Padding(padding: EdgeInsets.symmetric(horizontal: 15), child: Text("Ó", style: TextStyle(color: Colors.grey))),
                  Expanded(child: Divider()),
                ],
              ),
            ),

            // SECCIÓN UNIRSE (TURQUESA PASTEL)
            // SECCIÓN UNIRSE (TURQUESA PASTEL)
            Container(
              padding: const EdgeInsets.all(25),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(30),
                border: Border.all(color: AppColors.primary.withOpacity(0.1)),
              ),
              child: Column(
                children: [
                  TextField(
                    controller: _codeController,
                    textAlign: TextAlign.center,
                    textCapitalization: TextCapitalization.characters,
                    maxLength: 6,
                    style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, letterSpacing: 8, color: AppColors.primary),
                    decoration: InputDecoration(
                      // --- CAMBIO AQUÍ ---
                      labelText: "Ingresa el código", // Usamos labelText en lugar de hintText para que pueda elevarse
                      floatingLabelBehavior: FloatingLabelBehavior.auto, // Esto hace que se eleve al dar clic
                      floatingLabelAlignment: FloatingLabelAlignment.center, // Centra la etiqueta al elevarse
                      labelStyle: TextStyle(letterSpacing: 0, fontSize: 14, color: AppColors.text.withOpacity(0.5)),

                      counterText: "",
                      filled: true,
                      fillColor: AppColors.inputFill,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none),
                      contentPadding: const EdgeInsets.symmetric(vertical: 20), // Ajuste de altura interna
                    ),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: _joinGame,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      minimumSize: const Size.fromHeight(60),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                      elevation: 0,
                    ),
                    child: const Text("UNIRSE AHORA", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionCard({required String title, required String buttonLabel, required Color color, required IconData icon, required VoidCallback onPressed}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(30),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 40),
          const SizedBox(height: 10),
          Text(title, style: TextStyle(color: color, fontWeight: FontWeight.w900, fontSize: 14, letterSpacing: 1.5)),
          const SizedBox(height: 15),
          ElevatedButton(
            onPressed: onPressed,
            style: ElevatedButton.styleFrom(
              backgroundColor: color,
              foregroundColor: Colors.white,
              minimumSize: const Size.fromHeight(55),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
              elevation: 4,
              shadowColor: color.withOpacity(0.3),
            ),
            child: Text(buttonLabel, style: const TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }
}