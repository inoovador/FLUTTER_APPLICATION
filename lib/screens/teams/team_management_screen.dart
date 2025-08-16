import 'package:flutter/material.dart';
import '../../models/team_model.dart';
import '../../services/team_service.dart';

class TeamManagementScreen extends StatefulWidget {
  const TeamManagementScreen({super.key});

  @override
  State<TeamManagementScreen> createState() => _TeamManagementScreenState();
}

class _TeamManagementScreenState extends State<TeamManagementScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TeamService _teamService = TeamService();
  
  List<Team> _myTeams = [];
  List<TeamInvitation> _invitations = [];
  bool _isLoading = true;
  
  final String _currentUserId = 'user123';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    
    try {
      final teams = await _teamService.getUserTeams(_currentUserId);
      final invitations = await _teamService.getPendingInvitations(_currentUserId);
      
      setState(() {
        _myTeams = teams;
        _invitations = invitations;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      _showError('Error al cargar datos');
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: const Color(0xFFFF6B6B),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: AppBar(
        title: const Text('Mis Equipos'),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: const Color(0xFF97FB57),
          tabs: const [
            Tab(text: 'Mis Equipos'),
            Tab(text: 'Invitaciones'),
            Tab(text: 'Buscar'),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: _showCreateTeamDialog,
          ),
        ],
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildMyTeamsTab(),
          _buildInvitationsTab(),
          _buildSearchTab(),
        ],
      ),
    );
  }

  Widget _buildMyTeamsTab() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: Color(0xFF97FB57)),
      );
    }
    
    if (_myTeams.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.groups,
              size: 80,
              color: const Color(0xFF909090).withOpacity(0.5),
            ),
            const SizedBox(height: 16),
            Text(
              'No tienes equipos aún',
              style: TextStyle(
                fontSize: 18,
                color: const Color(0xFF909090).withOpacity(0.7),
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: _showCreateTeamDialog,
              icon: const Icon(Icons.add),
              label: const Text('Crear Equipo'),
            ),
          ],
        ),
      );
    }
    
    return RefreshIndicator(
      onRefresh: _loadData,
      color: const Color(0xFF97FB57),
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _myTeams.length,
        itemBuilder: (context, index) {
          final team = _myTeams[index];
          return _buildTeamCard(team);
        },
      ),
    );
  }

  Widget _buildTeamCard(Team team) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: InkWell(
        onTap: () => _navigateToTeamDetail(team),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      color: _getTeamColor(team.sport),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Center(
                      child: Text(
                        team.name.substring(0, 2).toUpperCase(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          team.name,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          team.sport,
                          style: const TextStyle(
                            color: Color(0xFF909090),
                            fontSize: 14,
                          ),
                        ),
                        Row(
                          children: [
                            Icon(
                              _getUserRoleIcon(team.getUserRole(_currentUserId)),
                              size: 16,
                              color: const Color(0xFF97FB57),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              _getUserRoleText(team.getUserRole(_currentUserId)),
                              style: const TextStyle(
                                color: Color(0xFF97FB57),
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFF97FB57).withOpacity(0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          '${team.members.length}/${team.maxMembers}',
                          style: const TextStyle(
                            color: Color(0xFF97FB57),
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: List.generate(5, (index) {
                          return Icon(
                            index < team.rating.floor()
                                ? Icons.star
                                : Icons.star_border,
                            color: const Color(0xFFFFD93D),
                            size: 16,
                          );
                        }),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 12),
              
              // Estadísticas del equipo
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildStatItem('Partidos', team.stats.matchesPlayed.toString()),
                  _buildStatItem('Victorias', team.stats.wins.toString()),
                  _buildStatItem('Win Rate', '${team.stats.winRate.toStringAsFixed(0)}%'),
                ],
              ),
              
              const SizedBox(height: 12),
              
              // Miembros recientes
              Text(
                'Miembros:',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 8),
              SizedBox(
                height: 40,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: team.members.length > 6 ? 6 : team.members.length,
                  itemBuilder: (context, index) {
                    if (index == 5 && team.members.length > 6) {
                      return Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: const Color(0xFF2A2A2A),
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: Text(
                            '+${team.members.length - 5}',
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      );
                    }
                    
                    final member = team.members[index];
                    return Container(
                      width: 40,
                      height: 40,
                      margin: const EdgeInsets.only(right: 8),
                      decoration: BoxDecoration(
                        color: const Color(0xFF97FB57),
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Text(
                          member.name.substring(0, 1).toUpperCase(),
                          style: const TextStyle(
                            color: Color(0xFF121212),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatItem(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Color(0xFF97FB57),
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: const Color(0xFF909090).withOpacity(0.8),
          ),
        ),
      ],
    );
  }

  Widget _buildInvitationsTab() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: Color(0xFF97FB57)),
      );
    }
    
    if (_invitations.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.mail_outline,
              size: 80,
              color: const Color(0xFF909090).withOpacity(0.5),
            ),
            const SizedBox(height: 16),
            Text(
              'No tienes invitaciones pendientes',
              style: TextStyle(
                fontSize: 18,
                color: const Color(0xFF909090).withOpacity(0.7),
              ),
            ),
          ],
        ),
      );
    }
    
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _invitations.length,
      itemBuilder: (context, index) {
        final invitation = _invitations[index];
        return _buildInvitationCard(invitation);
      },
    );
  }

  Widget _buildInvitationCard(TeamInvitation invitation) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: const Color(0xFF97FB57),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Center(
                    child: Text(
                      invitation.teamName.substring(0, 2).toUpperCase(),
                      style: const TextStyle(
                        color: Color(0xFF121212),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        invitation.teamName,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'Invitado por ${invitation.inviterName}',
                        style: const TextStyle(
                          color: Color(0xFF909090),
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => _respondToInvitation(invitation, false),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Color(0xFFFF6B6B)),
                    ),
                    child: const Text(
                      'Rechazar',
                      style: TextStyle(color: Color(0xFFFF6B6B)),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => _respondToInvitation(invitation, true),
                    child: const Text('Aceptar'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchTab() {
    return const Center(
      child: Text('Búsqueda de equipos - Próximamente'),
    );
  }

  Color _getTeamColor(String sport) {
    switch (sport.toLowerCase()) {
      case 'fútbol':
        return const Color(0xFF97FB57);
      case 'básquet':
        return const Color(0xFFFF6B35);
      case 'vóley':
        return const Color(0xFF4ECDC4);
      default:
        return const Color(0xFF909090);
    }
  }

  IconData _getUserRoleIcon(TeamRole role) {
    switch (role) {
      case TeamRole.captain:
        return Icons.star;
      case TeamRole.viceCaptain:
        return Icons.star_half;
      case TeamRole.member:
        return Icons.person;
    }
  }

  String _getUserRoleText(TeamRole role) {
    switch (role) {
      case TeamRole.captain:
        return 'Capitán';
      case TeamRole.viceCaptain:
        return 'Vice-capitán';
      case TeamRole.member:
        return 'Miembro';
    }
  }

  void _navigateToTeamDetail(Team team) {
    // Navegar a detalles del equipo
  }

  void _showCreateTeamDialog() {
    showDialog(
      context: context,
      builder: (context) => const CreateTeamDialog(),
    ).then((result) {
      if (result == true) {
        _loadData();
      }
    });
  }

  Future<void> _respondToInvitation(TeamInvitation invitation, bool accept) async {
    try {
      await _teamService.respondToInvitation(
        invitation.id,
        _currentUserId,
        accept,
      );
      
      _loadData();
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            accept 
                ? '¡Te has unido al equipo!'
                : 'Invitación rechazada',
          ),
          backgroundColor: accept 
              ? const Color(0xFF97FB57)
              : const Color(0xFF909090),
        ),
      );
    } catch (e) {
      _showError('Error al procesar invitación');
    }
  }
}

class CreateTeamDialog extends StatefulWidget {
  const CreateTeamDialog({super.key});

  @override
  State<CreateTeamDialog> createState() => _CreateTeamDialogState();
}

class _CreateTeamDialogState extends State<CreateTeamDialog> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  String _selectedSport = 'Fútbol';
  bool _isCreating = false;

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _createTeam() async {
    if (_nameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('El nombre del equipo es requerido'),
          backgroundColor: Color(0xFFFF6B6B),
        ),
      );
      return;
    }

    setState(() => _isCreating = true);

    try {
      final teamService = TeamService();
      await teamService.createTeam(
        name: _nameController.text.trim(),
        sport: _selectedSport,
        description: _descriptionController.text.trim(),
        captainId: 'user123',
      );

      Navigator.pop(context, true);
    } catch (e) {
      setState(() => _isCreating = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Error al crear equipo'),
          backgroundColor: Color(0xFFFF6B6B),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: const Color(0xFF1A1A1A),
      title: const Text('Crear Nuevo Equipo'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Nombre del equipo',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: _selectedSport,
              decoration: const InputDecoration(
                labelText: 'Deporte',
                border: OutlineInputBorder(),
              ),
              dropdownColor: const Color(0xFF2A2A2A),
              items: ['Fútbol', 'Básquet', 'Vóley', 'Tenis']
                  .map((sport) => DropdownMenuItem(
                        value: sport,
                        child: Text(sport),
                      ))
                  .toList(),
              onChanged: (value) {
                setState(() => _selectedSport = value!);
              },
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _descriptionController,
              decoration: const InputDecoration(
                labelText: 'Descripción (opcional)',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancelar'),
        ),
        ElevatedButton(
          onPressed: _isCreating ? null : _createTeam,
          child: _isCreating
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text('Crear'),
        ),
      ],
    );
  }
}