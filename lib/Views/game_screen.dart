import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:gato_unison/Views/result_screen.dart';
import 'package:gato_unison/Views/lobby_screen.dart';
import 'package:gato_unison/app_colors.dart';
import '../models/game_model.dart';
import '../models/result_model.dart' show GameResult;

class GameScreen extends StatefulWidget {
  final String gameCode;
  const GameScreen({super.key, required this.gameCode});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  final String uid = FirebaseAuth.instance.currentUser!.uid;
  bool _isDisposed = false;

  @override
  void dispose() {
    _isDisposed = true;
    _handleExit();
    super.dispose();
  }

  Future<void> _handleExit() async {
    final doc = await FirebaseFirestore.instance.collection('games').doc(widget.gameCode).get();
    if (doc.exists && doc.data()?['status'] == 'playing') {
      await FirebaseFirestore.instance.collection('games').doc(widget.gameCode).update({
        'status': 'abandoned',
      });
    }
  }

  void _checkWinner(List<String> board, GameModel game) {
    const List<List<int>> winConditions = [
      [0, 1, 2], [3, 4, 5], [6, 7, 8],
      [0, 3, 6], [1, 4, 7], [2, 5, 8],
      [0, 4, 8], [2, 4, 6],
    ];

    for (var condition in winConditions) {
      String a = board[condition[0]];
      String b = board[condition[1]];
      String c = board[condition[2]];

      if (a != "" && a == b && a == c) {
        _finishGame(a == "X" ? game.playerIds[0] : game.playerIds[1]);
        return;
      }
    }
    if (!board.contains("")) _finishGame("draw");
  }

  Future<void> _finishGame(String winnerId) async {
    await FirebaseFirestore.instance.collection('games').doc(widget.gameCode).update({
      'status': 'finished',
      'winner': winnerId,
    });
  }

  Future<void> _playTurn(int index, GameModel game) async {
    if (game.turn != uid || game.board[index] != "" || game.status != 'playing') return;

    List<String> newBoard = List.from(game.board);
    newBoard[index] = (game.playerIds[0] == uid) ? "X" : "O";
    String nextTurn = (game.playerIds[0] == uid) ? game.playerIds[1] : game.playerIds[0];

    await FirebaseFirestore.instance.collection('games').doc(widget.gameCode).update({
      'board': newBoard,
      'turn': nextTurn,
    });

    _checkWinner(newBoard, game);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background, // Usamos el crema suave
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        title: Text(
            "SALA: ${widget.gameCode}",
            style: const TextStyle(color: AppColors.text, fontWeight: FontWeight.bold, letterSpacing: 1.5)
        ),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.close_rounded, color: AppColors.text),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance.collection('games').doc(widget.gameCode).snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData || !snapshot.data!.exists) return const Center(child: CircularProgressIndicator(color: AppColors.primary));

          final data = snapshot.data!.data() as Map<String, dynamic>;
          final game = GameModel.fromMap(data);

          if (game.status == 'abandoned' && !_isDisposed) {
            WidgetsBinding.instance.addPostFrameCallback((_) => _showAbandonDialog());
          }

          if (game.status == 'finished' && !_isDisposed) {
            Future.delayed(Duration.zero, () {
              if (!_isDisposed) {
                String resultStatus = (game.winner == "draw") ? 'draw' : (game.winner == uid ? 'victory' : 'defeat');
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => ResultScreen(result: GameResult(status: resultStatus, gameCode: widget.gameCode))),
                );
              }
            });
          }

          bool isMyTurn = game.turn == uid;

          return Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Indicador de Turno Estilizado con Turquesa y Coral
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                decoration: BoxDecoration(
                  color: isMyTurn ? AppColors.primary.withOpacity(0.15) : AppColors.secondary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(30),
                ),
                child: Text(
                  isMyTurn ? "¡ES TU TURNO!" : "ESPERANDO RIVAL...",
                  style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: isMyTurn ? AppColors.primary : AppColors.secondary,
                      letterSpacing: 1.2
                  ),
                ),
              ),
              const SizedBox(height: 50),

              // Tablero de Juego (Casillas Blancas Modernas)
              Padding(
                padding: const EdgeInsets.all(30),
                child: AspectRatio(
                  aspectRatio: 1,
                  child: GridView.builder(
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: 9,
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 3,
                        mainAxisSpacing: 15,
                        crossAxisSpacing: 15
                    ),
                    itemBuilder: (context, index) {
                      String cellValue = game.board[index];
                      // Definimos el color de la ficha (X = Turquesa, O = Coral)
                      Color symbolColor = cellValue == "X" ? AppColors.primary : AppColors.secondary;

                      return GestureDetector(
                        onTap: () => _playTurn(index, game),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(25), // Bordes más redondeados
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.02),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Center(
                            child: Text(
                              cellValue,
                              style: TextStyle(
                                fontSize: 50,
                                fontWeight: FontWeight.w900,
                                color: symbolColor,
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
              const SizedBox(height: 30),

              // Nombres de Jugadores
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildPlayerLabel(game.players[0], "X", AppColors.primary, game.turn == game.playerIds[0]),
                  _buildPlayerLabel(game.players[1], "O", AppColors.secondary, game.turn == game.playerIds[1]),
                ],
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildPlayerLabel(String name, String symbol, Color color, bool active) {
    return Column(
      children: [
        Text(symbol, style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: color)),
        Text(
          name.isEmpty ? "Esperando..." : name,
          style: TextStyle(
            fontWeight: active ? FontWeight.bold : FontWeight.w500,
            fontSize: 14,
            color: active ? AppColors.text : AppColors.text.withOpacity(0.4),
          ),
        ),
        if (active)
          Container(
              margin: const EdgeInsets.only(top: 6),
              height: 4,
              width: 25,
              decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(10))
          ),
      ],
    );
  }

  void _showAbandonDialog() {
    if (_isDisposed) return;
    _isDisposed = true;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.background,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
        title: const Text("Partida Cancelada", textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.bold)),
        content: const Text("Tu oponente abandonó la partida."),
        actions: [
          TextButton(
            onPressed: () => Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context) => const LobbyScreen()), (route) => false),
            child: const Text("REGRESAR", style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }
}