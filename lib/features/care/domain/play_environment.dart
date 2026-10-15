import 'package:flutter/material.dart';

/// Environnements / Décors interactifs dans lesquels l'enfant peut faire jouer Pi.
/// Conforme à la demande utilisateur : Salon, Jardin, Plage et Forêt.
enum PlayEnvironment {
  livingRoom(
    id: 'living_room',
    icon: Icons.weekend_rounded,
    labelFr: 'Salon',
    labelEn: 'Living Room',
    welcomeFr: 'Bienvenue dans le salon !',
    welcomeEn: 'Welcome to the living room!',
    skyColor: Color(0xFFF1F5F9),
    groundColor: Color(0xFFE2E8F0),
    accentColor: Color(0xFF94A3B8),
  ),
  garden(
    id: 'garden',
    icon: Icons.park_rounded,
    labelFr: 'Jardin',
    labelEn: 'Garden',
    welcomeFr: 'Bienvenue dans le jardin !',
    welcomeEn: 'Welcome to the garden!',
    skyColor: Color(0xFFBAE6FD),
    groundColor: Color(0xFF86EFAC),
    accentColor: Color(0xFF22C55E),
  ),
  beach(
    id: 'beach',
    icon: Icons.beach_access_rounded,
    labelFr: 'Plage',
    labelEn: 'Beach',
    welcomeFr: 'Bienvenue à la plage !',
    welcomeEn: 'Welcome to the beach!',
    skyColor: Color(0xFF7DD3FC),
    groundColor: Color(0xFFFDE68A),
    accentColor: Color(0xFF0284C7),
  ),
  forest(
    id: 'forest',
    icon: Icons.forest_rounded,
    labelFr: 'Forêt',
    labelEn: 'Forest',
    welcomeFr: 'Bienvenue dans la forêt !',
    welcomeEn: 'Welcome to the forest!',
    skyColor: Color(0xFFC7D2FE),
    groundColor: Color(0xFFA7F3D0),
    accentColor: Color(0xFF059669),
  );

  final String id;
  final IconData icon;
  final String labelFr;
  final String labelEn;
  final String welcomeFr;
  final String welcomeEn;
  final Color skyColor;
  final Color groundColor;
  final Color accentColor;

  const PlayEnvironment({
    required this.id,
    required this.icon,
    required this.labelFr,
    required this.labelEn,
    required this.welcomeFr,
    required this.welcomeEn,
    required this.skyColor,
    required this.groundColor,
    required this.accentColor,
  });

  String getLabel(bool isFrench) => isFrench ? labelFr : labelEn;

  String getWelcome(bool isFrench) => isFrench ? welcomeFr : welcomeEn;

  static PlayEnvironment fromId(String id) {
    for (final env in PlayEnvironment.values) {
      if (env.id == id) return env;
    }
    return PlayEnvironment.livingRoom;
  }
}
