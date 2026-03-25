class GameModel {
  final String gameCode;      // Código único de 6 caracteres [cite: 28]
  final List<String> players; // Nombres de los dos jugadores [cite: 60]
  final List<String> playerIds; // UIDs de Firebase para controlar turnos
  final List<String> board;   // El tablero de 9 celdas (3x3) [cite: 33]
  final String turn;          // UID del jugador que tiene el turno actual [cite: 39]
  final String status;        // 'waiting', 'playing', 'finished' [cite: 25, 43]
  final String winner;        // ID del ganador, 'draw' o vacío [cite: 43, 63]
  final List<Map<String, dynamic>> moves; // Historial de movimientos (fila, col)

  GameModel({
    required this.gameCode,
    required this.players,
    required this.playerIds,
    required this.board,
    required this.turn,
    required this.status,
    required this.winner,
    required this.moves,
  });

  // Convierte el mapa de Firestore a un objeto GameModel
  factory GameModel.fromMap(Map<String, dynamic> map) {
    return GameModel(
      gameCode: map['gameCode'] ?? '',
      players: List<String>.from(map['players'] ?? []),
      playerIds: List<String>.from(map['playerIds'] ?? []),
      board: List<String>.from(map['board'] ?? List.filled(9, "")),
      turn: map['turn'] ?? '',
      status: map['status'] ?? 'waiting',
      winner: map['winner'] ?? '',
      moves: List<Map<String, dynamic>>.from(map['moves'] ?? []),
    );
  }

  // Convierte el objeto GameModel a un mapa para guardarlo en Firestore [cite: 58]
  Map<String, dynamic> toMap() {
    return {
      'gameCode': gameCode,
      'players': players,
      'playerIds': playerIds,
      'board': board,
      'turn': turn,
      'status': status,
      'winner': winner,
      'moves': moves,
    };
  }
}