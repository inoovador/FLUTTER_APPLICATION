enum ChatType {
  private,
  tournament,
  team,
}

enum MessageType {
  text,
  image,
  file,
  system,
}

class Chat {
  final String id;
  final String name;
  final List<String> participants;
  final ChatType type;
  final String? lastMessage;
  final DateTime? lastMessageTime;
  final int unreadCount;
  final String? tournamentId;
  final String? teamId;
  final String? imageUrl;
  
  Chat({
    required this.id,
    required this.name,
    required this.participants,
    required this.type,
    this.lastMessage,
    this.lastMessageTime,
    this.unreadCount = 0,
    this.tournamentId,
    this.teamId,
    this.imageUrl,
  });
  
  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'participants': participants,
    'type': type.toString(),
    'lastMessage': lastMessage,
    'lastMessageTime': lastMessageTime?.toIso8601String(),
    'unreadCount': unreadCount,
    'tournamentId': tournamentId,
    'teamId': teamId,
    'imageUrl': imageUrl,
  };
  
  factory Chat.fromJson(Map<String, dynamic> json) => Chat(
    id: json['id'],
    name: json['name'],
    participants: List<String>.from(json['participants']),
    type: ChatType.values.firstWhere(
      (e) => e.toString() == json['type'],
    ),
    lastMessage: json['lastMessage'],
    lastMessageTime: json['lastMessageTime'] != null 
        ? DateTime.parse(json['lastMessageTime'])
        : null,
    unreadCount: json['unreadCount'] ?? 0,
    tournamentId: json['tournamentId'],
    teamId: json['teamId'],
    imageUrl: json['imageUrl'],
  );
}

class ChatMessage {
  final String id;
  final String chatId;
  final String senderId;
  final String senderName;
  final String message;
  final DateTime timestamp;
  final bool isRead;
  final MessageType messageType;
  final String? fileUrl;
  final String? fileName;
  final Map<String, dynamic>? metadata;
  
  ChatMessage({
    required this.id,
    required this.chatId,
    required this.senderId,
    required this.senderName,
    required this.message,
    required this.timestamp,
    required this.isRead,
    required this.messageType,
    this.fileUrl,
    this.fileName,
    this.metadata,
  });
  
  Map<String, dynamic> toJson() => {
    'id': id,
    'chatId': chatId,
    'senderId': senderId,
    'senderName': senderName,
    'message': message,
    'timestamp': timestamp.toIso8601String(),
    'isRead': isRead,
    'messageType': messageType.toString(),
    'fileUrl': fileUrl,
    'fileName': fileName,
    'metadata': metadata,
  };
  
  factory ChatMessage.fromJson(Map<String, dynamic> json) => ChatMessage(
    id: json['id'],
    chatId: json['chatId'],
    senderId: json['senderId'],
    senderName: json['senderName'],
    message: json['message'],
    timestamp: DateTime.parse(json['timestamp']),
    isRead: json['isRead'] ?? false,
    messageType: MessageType.values.firstWhere(
      (e) => e.toString() == json['messageType'],
    ),
    fileUrl: json['fileUrl'],
    fileName: json['fileName'],
    metadata: json['metadata'],
  );
  
  ChatMessage copyWith({
    bool? isRead,
  }) {
    return ChatMessage(
      id: id,
      chatId: chatId,
      senderId: senderId,
      senderName: senderName,
      message: message,
      timestamp: timestamp,
      isRead: isRead ?? this.isRead,
      messageType: messageType,
      fileUrl: fileUrl,
      fileName: fileName,
      metadata: metadata,
    );
  }
}