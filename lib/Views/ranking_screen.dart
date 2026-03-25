import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:gato_unison/app_colors.dart';

class RankingScreen extends StatelessWidget {
  const RankingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        title: const Text(
          "Hall de la Fama",
          style: TextStyle(color: AppColors.text, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: AppColors.primary),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('users')
            .orderBy('wins', descending: true)
            .limit(10)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return _buildErrorState(snapshot.error.toString());
          }
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: AppColors.primary));
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(
              child: Text("Aún no hay leyendas en este ranking.",
                  style: TextStyle(color: AppColors.text)),
            );
          }

          final users = snapshot.data!.docs;

          return Column(
            children: [
              _buildHeader(), // Encabezado actualizado
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  itemCount: users.length,
                  itemBuilder: (context, index) {
                    var userData = users[index].data() as Map<String, dynamic>;
                    String name = userData['username'] ?? 'Jugador';
                    int wins = userData['wins'] ?? 0;
                    int position = index + 1;

                    bool isTopThree = position <= 3;

                    return Container(
                      margin: const EdgeInsets.only(bottom: 15),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(25),
                        boxShadow: [
                          BoxShadow(
                            color: isTopThree
                                ? _getBadgeColor(position).withOpacity(0.15)
                                : Colors.black.withOpacity(0.02),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          )
                        ],
                      ),
                      child: ListTile(
                        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                        leading: _buildPositionBadge(position),
                        title: Text(
                          name,
                          style: TextStyle(
                            fontWeight: isTopThree ? FontWeight.bold : FontWeight.w500,
                            fontSize: 17,
                            color: AppColors.text,
                          ),
                        ),
                        trailing: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
                          decoration: BoxDecoration(
                            color: _getBadgeColor(position).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(15),
                          ),
                          child: Text(
                            "$wins 🏆",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              color: _getBadgeColor(position),
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(25),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.stars_rounded, color: AppColors.primary, size: 30),
          ),
          const SizedBox(width: 15),
          const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "LOS 10 MEJORES", // Texto actualizado
                style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                    color: AppColors.text,
                    letterSpacing: 1
                ),
              ),
              // Subtítulo eliminado para mayor limpieza
            ],
          )
        ],
      ),
    );
  }

  Widget _buildPositionBadge(int position) {
    if (position <= 3) {
      return Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
            color: _getBadgeColor(position),
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: _getBadgeColor(position).withOpacity(0.3),
                blurRadius: 8,
                offset: const Offset(0, 3),
              )
            ]
        ),
        child: Center(
          child: Icon(
            position == 1 ? Icons.emoji_events_rounded : Icons.workspace_premium_rounded,
            color: Colors.white,
            size: 26,
          ),
        ),
      );
    }
    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        color: AppColors.inputFill,
        shape: BoxShape.circle,
      ),
      child: Center(
        child: Text(
          "$position",
          style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.text),
        ),
      ),
    );
  }

  Color _getBadgeColor(int position) {
    switch (position) {
      case 1: return const Color(0xFFFFD700); // Oro
      case 2: return const Color(0xFFC0C0C0); // Plata
      case 3: return const Color(0xFFCD7F32); // Bronce
      default: return AppColors.primary; // Turquesa Pastel
    }
  }

  Widget _buildErrorState(String error) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(30),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline_rounded, size: 60, color: AppColors.secondary),
            const SizedBox(height: 20),
            const Text("¡Ups! Algo salió mal",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.text)),
            const SizedBox(height: 10),
            Text(error, textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.grey)),
          ],
        ),
      ),
    );
  }
}