import 'package:flutter/material.dart';
import '../../models/rating_model.dart';

class PlayerRatingScreen extends StatefulWidget {
  final String playerId;
  final String playerName;
  final String tournamentId;
  final String matchId;
  
  const PlayerRatingScreen({
    super.key,
    required this.playerId,
    required this.playerName,
    required this.tournamentId,
    required this.matchId,
  });

  @override
  State<PlayerRatingScreen> createState() => _PlayerRatingScreenState();
}

class _PlayerRatingScreenState extends State<PlayerRatingScreen> {
  double _skillRating = 3.0;
  double _sportsmanshipRating = 3.0;
  double _punctualityRating = 3.0;
  double _teamworkRating = 3.0;
  final TextEditingController _commentController = TextEditingController();
  bool _isSubmitting = false;

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  Future<void> _submitRating() async {
    setState(() => _isSubmitting = true);
    
    try {
      // Aquí se enviaría la calificación al servidor
      await Future.delayed(const Duration(seconds: 1));
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('¡Calificación enviada exitosamente!'),
            backgroundColor: Color(0xFF97FB57),
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Error al enviar calificación'),
            backgroundColor: Color(0xFFFF6B6B),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: AppBar(
        title: const Text('Calificar Jugador'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Información del jugador
            Center(
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 50,
                    backgroundColor: const Color(0xFF97FB57),
                    child: Text(
                      widget.playerName.substring(0, 2).toUpperCase(),
                      style: const TextStyle(
                        fontSize: 36,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF121212),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    widget.playerName,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Calificación General: ${_calculateOverallRating().toStringAsFixed(1)}',
                    style: const TextStyle(
                      fontSize: 18,
                      color: Color(0xFF97FB57),
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 32),
            
            // Categorías de calificación
            _buildRatingCategory(
              'Habilidad',
              'Nivel técnico y desempeño en el juego',
              Icons.sports_soccer,
              _skillRating,
              (value) => setState(() => _skillRating = value),
            ),
            
            _buildRatingCategory(
              'Deportividad',
              'Respeto, fair play y actitud',
              Icons.handshake,
              _sportsmanshipRating,
              (value) => setState(() => _sportsmanshipRating = value),
            ),
            
            _buildRatingCategory(
              'Puntualidad',
              'Asistencia y llegada a tiempo',
              Icons.access_time,
              _punctualityRating,
              (value) => setState(() => _punctualityRating = value),
            ),
            
            _buildRatingCategory(
              'Trabajo en Equipo',
              'Colaboración y comunicación',
              Icons.groups,
              _teamworkRating,
              (value) => setState(() => _teamworkRating = value),
            ),
            
            const SizedBox(height: 24),
            
            // Comentarios
            Text(
              'Comentarios (opcional)',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _commentController,
              maxLines: 3,
              decoration: InputDecoration(
                hintText: 'Comparte tu experiencia jugando con ${widget.playerName}',
                hintStyle: TextStyle(
                  color: const Color(0xFF909090).withOpacity(0.7),
                ),
                filled: true,
                fillColor: const Color(0xFF1A1A1A),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
              style: const TextStyle(color: Colors.white),
            ),
            
            const SizedBox(height: 32),
            
            // Botón de enviar
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: _isSubmitting ? null : _submitRating,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF97FB57),
                  foregroundColor: const Color(0xFF121212),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(28),
                  ),
                ),
                child: _isSubmitting
                    ? const CircularProgressIndicator(
                        color: Color(0xFF121212),
                      )
                    : const Text(
                        'Enviar Calificación',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRatingCategory(
    String title,
    String description,
    IconData icon,
    double rating,
    Function(double) onChanged,
  ) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: const Color(0xFF97FB57)),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        description,
                        style: TextStyle(
                          fontSize: 12,
                          color: const Color(0xFF909090).withOpacity(0.8),
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFF97FB57).withOpacity(0.2),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    rating.toStringAsFixed(1),
                    style: const TextStyle(
                      color: Color(0xFF97FB57),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: List.generate(5, (index) {
                final starValue = index + 1;
                return Expanded(
                  child: GestureDetector(
                    onTap: () => onChanged(starValue.toDouble()),
                    child: Icon(
                      starValue <= rating 
                          ? Icons.star 
                          : Icons.star_border,
                      color: starValue <= rating
                          ? const Color(0xFF97FB57)
                          : const Color(0xFF909090),
                      size: 36,
                    ),
                  ),
                );
              }),
            ),
          ],
        ),
      ),
    );
  }

  double _calculateOverallRating() {
    return (_skillRating + _sportsmanshipRating + 
            _punctualityRating + _teamworkRating) / 4;
  }
}