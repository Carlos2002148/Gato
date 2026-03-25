class UserModel {
  final String uid;           // ID único de Firebase Auth
  final String username;      // Nombre de usuario elegido en el registro
  final String email;         // Correo electrónico
  final int wins;             // Número de victorias para el Top 10
  final int gamesPlayed;      // Número de partidas jugadas

  UserModel({
    required this.uid,
    required this.username,
    required this.email,
    this.wins = 0,
    this.gamesPlayed = 0,
  });

  // Para leer de Firestore
  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      uid: map['uid'] ?? '',
      username: map['username'] ?? '',
      email: map['email'] ?? '',
      wins: map['wins'] ?? 0,
      gamesPlayed: map['gamesPlayed'] ?? 0,
    );
  }

  // Para guardar en Firestore
  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'username': username,
      'email': email,
      'wins': wins,
      'gamesPlayed': gamesPlayed,
    };
  }
}