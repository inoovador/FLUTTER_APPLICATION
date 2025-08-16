import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../models/chat_model.dart';
import '../../services/chat_service.dart';
import 'chat_screen.dart';

class ChatListScreen extends StatefulWidget {
  const ChatListScreen({super.key});

  @override
  State<ChatListScreen> createState() => _ChatListScreenState();
}

class _ChatListScreenState extends State<ChatListScreen> {
  final ChatService _chatService = ChatService();
  List<Chat> _chats = [];
  bool _isLoading = true;
  
  // Usuario actual (temporal)
  final String _currentUserId = 'user123';

  @override
  void initState() {
    super.initState();
    _loadChats();
  }

  Future<void> _loadChats() async {
    setState(() => _isLoading = true);
    
    try {
      final chats = await _chatService.getChats(_currentUserId);
      setState(() {
        _chats = chats;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      _showError('Error al cargar chats');
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
        title: const Text('Mensajes'),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              // TODO: Implementar búsqueda
            },
          ),
        ],
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(
                color: Color(0xFF97FB57),
              ),
            )
          : _chats.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.chat_bubble_outline,
                        size: 100,
                        color: const Color(0xFF909090).withOpacity(0.5),
                      ),
                      const SizedBox(height: 24),
                      Text(
                        'No tienes conversaciones',
                        style: TextStyle(
                          fontSize: 18,
                          color: const Color(0xFF909090).withOpacity(0.7),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Los chats aparecerán aquí',
                        style: TextStyle(
                          fontSize: 14,
                          color: const Color(0xFF909090).withOpacity(0.5),
                        ),
                      ),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _loadChats,
                  color: const Color(0xFF97FB57),
                  child: ListView.builder(
                    itemCount: _chats.length,
                    itemBuilder: (context, index) {
                      final chat = _chats[index];
                      return _buildChatTile(chat);
                    },
                  ),
                ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // TODO: Crear nuevo chat
        },
        backgroundColor: const Color(0xFF97FB57),
        child: const Icon(
          Icons.chat,
          color: Color(0xFF121212),
        ),
      ),
    );
  }

  Widget _buildChatTile(Chat chat) {
    final hasUnread = chat.unreadCount > 0;
    final timeString = _formatTime(chat.lastMessageTime);
    
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ChatScreen(
              chatId: chat.id,
              recipientName: chat.name,
              recipientId: chat.participants.firstWhere(
                (p) => p != _currentUserId,
                orElse: () => '',
              ),
              chatType: chat.type,
            ),
          ),
        ).then((_) => _loadChats());
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: const Color(0xFF909090).withOpacity(0.2),
              width: 1,
            ),
          ),
        ),
        child: Row(
          children: [
            // Avatar
            Stack(
              children: [
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: _getChatColor(chat.type),
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Icon(
                      _getChatIcon(chat.type),
                      color: Colors.white,
                      size: 28,
                    ),
                  ),
                ),
                if (hasUnread)
                  Positioned(
                    right: 0,
                    top: 0,
                    child: Container(
                      width: 12,
                      height: 12,
                      decoration: const BoxDecoration(
                        color: Color(0xFF97FB57),
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
              ],
            ),
            
            const SizedBox(width: 12),
            
            // Contenido
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Nombre del chat
                      Expanded(
                        child: Text(
                          chat.name,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: hasUnread 
                                ? FontWeight.bold 
                                : FontWeight.normal,
                            color: hasUnread 
                                ? Colors.white 
                                : const Color(0xFFF6F2F2),
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      
                      // Hora
                      Text(
                        timeString,
                        style: TextStyle(
                          fontSize: 12,
                          color: hasUnread
                              ? const Color(0xFF97FB57)
                              : const Color(0xFF909090),
                        ),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 4),
                  
                  Row(
                    children: [
                      // Último mensaje
                      Expanded(
                        child: Text(
                          chat.lastMessage ?? 'Sin mensajes',
                          style: TextStyle(
                            fontSize: 14,
                            color: hasUnread
                                ? const Color(0xFFF6F2F2)
                                : const Color(0xFF909090),
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      
                      // Contador de no leídos
                      if (hasUnread)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFF97FB57),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            chat.unreadCount.toString(),
                            style: const TextStyle(
                              fontSize: 12,
                              color: Color(0xFF121212),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getChatColor(ChatType type) {
    switch (type) {
      case ChatType.tournament:
        return const Color(0xFF97FB57);
      case ChatType.team:
        return const Color(0xFF4ECDC4);
      case ChatType.private:
        return const Color(0xFF909090);
    }
  }

  IconData _getChatIcon(ChatType type) {
    switch (type) {
      case ChatType.tournament:
        return Icons.emoji_events;
      case ChatType.team:
        return Icons.group;
      case ChatType.private:
        return Icons.person;
    }
  }

  String _formatTime(DateTime? time) {
    if (time == null) return '';
    
    final now = DateTime.now();
    final difference = now.difference(time);
    
    if (difference.inDays == 0) {
      return DateFormat('HH:mm').format(time);
    } else if (difference.inDays == 1) {
      return 'Ayer';
    } else if (difference.inDays < 7) {
      return DateFormat('EEEE', 'es').format(time);
    } else {
      return DateFormat('dd/MM/yy').format(time);
    }
  }
}