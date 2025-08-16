import 'package:flutter/material.dart';
import '../../models/rating_model.dart';

class PlayerStatsScreen extends StatefulWidget {
  const PlayerStatsScreen({super.key});

  @override
  State<PlayerStatsScreen> createState() => _PlayerStatsScreenState();
}

class _PlayerStatsScreenState extends State<PlayerStatsScreen> {
  // Datos de ejemplo del jugador
  final PlayerStats _playerStats = PlayerStats(
    playerId: 'user123',
    playerName: 'Juan Pérez',
    totalMatches: 48,
    wins: 28,
    losses: 12,
    draws: 8,
    goalsScored: 45,
    goalsReceived: 23,
    averageRating: 4.3,
    totalRatings: 156,
    categoryRatings: {
      'Habilidad': 4.5,
      'Deportividad': 4.8,
      'Puntualidad': 4.2,
      'Trabajo en Equipo': 3.7,
    },
    achievements: [
      Achievement(
        id: '1',
        name: 'Goleador',
        description: 'Anota 50 goles',
        icon: '⚽',
        unlockedAt: DateTime.now(),
        type: AchievementType.goals,
        progress: 45,
        maxProgress: 50,
      ),
      Achievement(
        id: '2',
        name: 'Invicto',
        description: 'Gana 10 partidos seguidos',
        icon: '🏆',
        unlockedAt: DateTime.now(),
        type: AchievementType.wins,
        progress: 7,
        maxProgress: 10,
      ),
    ],
    ranking: 5,
    tier: 'Oro',
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: AppBar(
        title: const Text('Mis Estadísticas'),
        actions: [
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: () {
              // Compartir estadísticas
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Header con información principal
            _buildHeaderSection(),
            
            // Estadísticas generales
            _buildStatsSection(),
            
            // Calificaciones por categoría
            _buildRatingsSection(),
            
            // Logros
            _buildAchievementsSection(),
            
            // Historial reciente
            _buildRecentHistorySection(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeaderSection() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            _playerStats.tierColor.withOpacity(0.3),
            const Color(0xFF121212),
          ],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: Column(
        children: [
          Stack(
            alignment: Alignment.bottomRight,
            children: [
              CircleAvatar(
                radius: 60,
                backgroundColor: _playerStats.tierColor,
                child: Text(
                  _playerStats.playerName.substring(0, 2).toUpperCase(),
                  style: const TextStyle(
                    fontSize: 48,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF121212),
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFF121212),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: _playerStats.tierColor,
                    width: 3,
                  ),
                ),
                child: Text(
                  _playerStats.tierIcon,
                  style: const TextStyle(fontSize: 24),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            _playerStats.playerName,
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: _playerStats.tierColor.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: _playerStats.tierColor,
                    width: 1,
                  ),
                ),
                child: Row(
                  children: [
                    Text(
                      _playerStats.tier,
                      style: TextStyle(
                        color: _playerStats.tierColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Icon(
                      Icons.trending_up,
                      color: _playerStats.tierColor,
                      size: 20,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFF97FB57).withOpacity(0.2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.star,
                      color: Color(0xFF97FB57),
                      size: 20,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      _playerStats.averageRating.toStringAsFixed(1),
                      style: const TextStyle(
                        color: Color(0xFF97FB57),
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Ranking #${_playerStats.ranking}',
            style: const TextStyle(
              fontSize: 18,
              color: Color(0xFF909090),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsSection() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Estadísticas Generales',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  'Partidos',
                  _playerStats.totalMatches.toString(),
                  Icons.sports_soccer,
                  const Color(0xFF4ECDC4),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatCard(
                  'Victorias',
                  _playerStats.wins.toString(),
                  Icons.emoji_events,
                  const Color(0xFF97FB57),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  'Goles',
                  _playerStats.goalsScored.toString(),
                  Icons.sports_soccer,
                  const Color(0xFFFF6B6B),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatCard(
                  'Win Rate',
                  '${_playerStats.winRate.toStringAsFixed(1)}%',
                  Icons.trending_up,
                  const Color(0xFFFFD93D),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Icon(icon, size: 32, color: color),
            const SizedBox(height: 8),
            Text(
              value,
              style: const TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              label,
              style: TextStyle(
                fontSize: 14,
                color: const Color(0xFF909090).withOpacity(0.8),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRatingsSection() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Calificaciones',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                '${_playerStats.totalRatings} evaluaciones',
                style: TextStyle(
                  fontSize: 14,
                  color: const Color(0xFF909090).withOpacity(0.8),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ..._playerStats.categoryRatings.entries.map((entry) {
            return _buildRatingBar(entry.key, entry.value);
          }).toList(),
        ],
      ),
    );
  }

  Widget _buildRatingBar(String category, double rating) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                category,
                style: const TextStyle(fontSize: 16),
              ),
              Text(
                rating.toStringAsFixed(1),
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF97FB57),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          LinearProgressIndicator(
            value: rating / 5,
            backgroundColor: const Color(0xFF2A2A2A),
            valueColor: AlwaysStoppedAnimation<Color>(
              Color.lerp(
                const Color(0xFFFF6B6B),
                const Color(0xFF97FB57),
                rating / 5,
              )!,
            ),
            minHeight: 8,
          ),
        ],
      ),
    );
  }

  Widget _buildAchievementsSection() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Logros',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 120,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: _playerStats.achievements.length,
              itemBuilder: (context, index) {
                final achievement = _playerStats.achievements[index];
                return _buildAchievementCard(achievement);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAchievementCard(Achievement achievement) {
    return Container(
      width: 100,
      margin: const EdgeInsets.only(right: 12),
      child: Card(
        color: achievement.isUnlocked
            ? const Color(0xFF97FB57).withOpacity(0.2)
            : const Color(0xFF2A2A2A),
        child: InkWell(
          onTap: () {
            // Mostrar detalles del logro
          },
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Opacity(
                  opacity: achievement.isUnlocked ? 1.0 : 0.3,
                  child: Text(
                    achievement.icon,
                    style: const TextStyle(
                      fontSize: 32,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  achievement.name,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: achievement.isUnlocked
                        ? Colors.white
                        : const Color(0xFF909090),
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                LinearProgressIndicator(
                  value: achievement.progressPercentage / 100,
                  backgroundColor: const Color(0xFF2A2A2A),
                  valueColor: AlwaysStoppedAnimation<Color>(
                    achievement.isUnlocked
                        ? const Color(0xFF97FB57)
                        : const Color(0xFF909090),
                  ),
                  minHeight: 4,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRecentHistorySection() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Historial Reciente',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          // Aquí irían los partidos recientes
          Card(
            child: ListTile(
              leading: const CircleAvatar(
                backgroundColor: Color(0xFF97FB57),
                child: Text(
                  'V',
                  style: TextStyle(
                    color: Color(0xFF121212),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              title: const Text('Copa Verano 2024'),
              subtitle: const Text('vs Los Halcones - 3:1'),
              trailing: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.star,
                    color: Color(0xFF97FB57),
                    size: 20,
                  ),
                  Text(
                    '4.5',
                    style: TextStyle(
                      color: const Color(0xFF909090).withOpacity(0.8),
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}