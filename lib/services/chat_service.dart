import 'dart:async';
import '../models/chat_model.dart';

class ChatService {
  // Simulación de base de datos en memoria
  static final List<Chat> _chats = [
    Chat(
      id: 'chat1',
      name: 'Copa Verano 2024',
      participants: ['user123', 'org1'],
      type: ChatType.tournament,
      lastMessage: 'Bienvenidos al torneo!',
      lastMessageTime: DateTime.now().subtract(const Duration(hours: 2)),
      unreadCount: 2,
      tournamentId: '1',
    ),
    Chat(
      id: 'chat2',
      name: 'Academia Deportiva Juan',
      participants: ['user123', 'org1'],
      type: ChatType.private,
      lastMessage: 'Gracias por tu inscripción',
      lastMessageTime: DateTime.now().subtract(const Duration(days: 1)),
      unreadCount: 0,
    ),
  ];
  
  static final List<ChatMessage> _messages = [
    ChatMessage(
      id: 'msg1',
      chatId: 'chat1',
      senderId: 'org1',
      senderName: 'Organizador',
      message: 'Bienvenidos al torneo Copa Verano 2024!',
      timestamp: DateTime.now().subtract(const Duration(hours: 3)),
      isRead: true,
      messageType: MessageType.text,
    ),
    ChatMessage(
      id: 'msg2',
      chatId: 'chat1',
      senderId: 'org1',
      senderName: 'Organizador',
      message: 'Recuerden que el torneo empieza este sábado a las 9:00 AM',
      timestamp: DateTime.now().subtract(const Duration(hours: 2)),
      isRead: false,
      messageType: MessageType.text,
    ),
  ];
  
  // Stream controllers para actualizaciones en tiempo real
  final _chatStreamController = StreamController<List<Chat>>.broadcast();
  final _messageStreamController = StreamController<List<ChatMessage>>.broadcast();
  
  // Obtener lista de chats
  Future<List<Chat>> getChats(String userId) async {
    // Simular delay de red
    await Future.delayed(const Duration(milliseconds: 500));
    
    // Filtrar chats donde el usuario es participante
    final userChats = _chats.where((chat) => 
      chat.participants.contains(userId)
    ).toList();
    
    // Ordenar por última actividad
    userChats.sort((a, b) {
      final aTime = a.lastMessageTime ?? DateTime(2000);
      final bTime = b.lastMessageTime ?? DateTime(2000);
      return bTime.compareTo(aTime);
    });
    
    return userChats;
  }
  
  // Obtener mensajes de un chat
  Future<List<ChatMessage>> getMessages(String chatId) async {
    await Future.delayed(const Duration(milliseconds: 300));
    
    final messages = _messages.where((msg) => msg.chatId == chatId).toList();
    messages.sort((a, b) => a.timestamp.compareTo(b.timestamp));
    
    return messages;
  }
  
  // Enviar mensaje
  Future<void> sendMessage({
    required String chatId,
    required String senderId,
    required String senderName,
    required String message,
    required String recipientId,
    MessageType messageType = MessageType.text,
    String? fileUrl,
    String? fileName,
  }) async {
    await Future.delayed(const Duration(milliseconds: 200));
    
    final newMessage = ChatMessage(
      id: 'msg_${DateTime.now().millisecondsSinceEpoch}',
      chatId: chatId,
      senderId: senderId,
      senderName: senderName,
      message: message,
      timestamp: DateTime.now(),
      isRead: false,
      messageType: messageType,
      fileUrl: fileUrl,
      fileName: fileName,
    );
    
    _messages.add(newMessage);
    
    // Actualizar último mensaje del chat
    final chatIndex = _chats.indexWhere((c) => c.id == chatId);
    if (chatIndex != -1) {
      final chat = _chats[chatIndex];
      _chats[chatIndex] = Chat(
        id: chat.id,
        name: chat.name,
        participants: chat.participants,
        type: chat.type,
        lastMessage: message,
        lastMessageTime: DateTime.now(),
        unreadCount: chat.participants
            .where((p) => p != senderId)
            .fold(0, (sum, _) => sum + 1),
        tournamentId: chat.tournamentId,
        teamId: chat.teamId,
        imageUrl: chat.imageUrl,
      );
    }
    
    // Notificar cambios
    _messageStreamController.add(_messages.where((m) => m.chatId == chatId).toList());
    
    // Simular respuesta automática para demo
    if (senderId == 'user123' && chatId == 'chat1') {
      _simulateAutoResponse(chatId);
    }
  }
  
  // Marcar mensajes como leídos
  Future<void> markMessagesAsRead(String chatId, String userId) async {
    await Future.delayed(const Duration(milliseconds: 100));
    
    for (int i = 0; i < _messages.length; i++) {
      final msg = _messages[i];
      if (msg.chatId == chatId && msg.senderId != userId && !msg.isRead) {
        _messages[i] = msg.copyWith(isRead: true);
      }
    }
    
    // Actualizar contador de no leídos
    final chatIndex = _chats.indexWhere((c) => c.id == chatId);
    if (chatIndex != -1) {
      final chat = _chats[chatIndex];
      _chats[chatIndex] = Chat(
        id: chat.id,
        name: chat.name,
        participants: chat.participants,
        type: chat.type,
        lastMessage: chat.lastMessage,
        lastMessageTime: chat.lastMessageTime,
        unreadCount: 0,
        tournamentId: chat.tournamentId,
        teamId: chat.teamId,
        imageUrl: chat.imageUrl,
      );
    }
  }
  
  // Crear nuevo chat
  Future<Chat> createChat({
    required String name,
    required List<String> participants,
    required ChatType type,
    String? tournamentId,
    String? teamId,
  }) async {
    await Future.delayed(const Duration(milliseconds: 300));
    
    final newChat = Chat(
      id: 'chat_${DateTime.now().millisecondsSinceEpoch}',
      name: name,
      participants: participants,
      type: type,
      tournamentId: tournamentId,
      teamId: teamId,
    );
    
    _chats.add(newChat);
    _chatStreamController.add(_chats);
    
    return newChat;
  }
  
  // Stream de chats
  Stream<List<Chat>> get chatStream => _chatStreamController.stream;
  
  // Stream de mensajes
  Stream<List<ChatMessage>> getMessageStream(String chatId) {
    return _messageStreamController.stream
        .map((messages) => messages.where((m) => m.chatId == chatId).toList());
  }
  
  // Simular respuesta automática
  void _simulateAutoResponse(String chatId) {
    Future.delayed(const Duration(seconds: 2), () {
      final responses = [
        '¡Gracias por tu mensaje!',
        'Estamos aquí para ayudarte.',
        'Cualquier duda, no dudes en preguntar.',
        '¡Nos vemos en el torneo!',
      ];
      
      final randomResponse = responses[
        DateTime.now().millisecondsSinceEpoch % responses.length
      ];
      
      sendMessage(
        chatId: chatId,
        senderId: 'org1',
        senderName: 'Organizador',
        message: randomResponse,
        recipientId: 'user123',
      );
    });
  }
  
  // Limpiar recursos
  void dispose() {
    _chatStreamController.close();
    _messageStreamController.close();
  }
}