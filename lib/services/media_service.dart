import '../models/media_model.dart';

class MediaService {
  // Datos de ejemplo
  static final List<MediaItem> _mediaItems = [
    MediaItem(
      id: 'media1',
      type: MediaType.photo,
      url: 'https://example.com/photo1.jpg',
      title: 'Gol de la victoria',
      description: 'Momento del gol que nos dio la victoria en el último minuto',
      uploaderId: 'user123',
      uploaderName: 'Juan Pérez',
      uploadedAt: DateTime.now().subtract(const Duration(hours: 2)),
      tournamentId: '1',
      matchId: 'match1',
      tags: ['gol', 'victoria', 'emocionante'],
      likeCount: 24,
      commentCount: 8,
      isPublic: true,
      width: 1920,
      height: 1080,
      fileSize: 2048576, // 2MB
    ),
    MediaItem(
      id: 'media2',
      type: MediaType.video,
      url: 'https://example.com/video1.mp4',
      thumbnailUrl: 'https://example.com/thumb1.jpg',
      title: 'Mejores jugadas del partido',
      description: 'Compilación de las mejores jugadas del partido de ayer',
      uploaderId: 'user456',
      uploaderName: 'Carlos López',
      uploadedAt: DateTime.now().subtract(const Duration(hours: 5)),
      tournamentId: '1',
      matchId: 'match1',
      tags: ['highlights', 'jugadas', 'partido'],
      likeCount: 42,
      commentCount: 15,
      isPublic: true,
      duration: const Duration(minutes: 3, seconds: 45),
      width: 1920,
      height: 1080,
      fileSize: 52428800, // 50MB
    ),
    MediaItem(
      id: 'media3',
      type: MediaType.photo,
      url: 'https://example.com/photo2.jpg',
      title: 'Celebración del equipo',
      description: 'Todo el equipo celebrando después del partido',
      uploaderId: 'user789',
      uploaderName: 'Miguel Silva',
      uploadedAt: DateTime.now().subtract(const Duration(days: 1)),
      tournamentId: '1',
      tags: ['celebración', 'equipo', 'alegría'],
      likeCount: 31,
      commentCount: 12,
      isPublic: true,
      width: 1920,
      height: 1080,
      fileSize: 1536000, // 1.5MB
    ),
    MediaItem(
      id: 'media4',
      type: MediaType.video,
      url: 'https://example.com/video2.mp4',
      thumbnailUrl: 'https://example.com/thumb2.jpg',
      title: 'Entrevista post-partido',
      description: 'Entrevista con el capitán después de la victoria',
      uploaderId: 'user123',
      uploaderName: 'Juan Pérez',
      uploadedAt: DateTime.now().subtract(const Duration(days: 1)),
      tournamentId: '1',
      tags: ['entrevista', 'capitán', 'victoria'],
      likeCount: 18,
      commentCount: 6,
      isPublic: true,
      duration: const Duration(minutes: 2, seconds: 30),
      width: 1280,
      height: 720,
      fileSize: 31457280, // 30MB
    ),
  ];

  static final List<MediaComment> _comments = [
    MediaComment(
      id: 'comment1',
      mediaId: 'media1',
      userId: 'user456',
      userName: 'Carlos López',
      comment: '¡Qué golazo! Increíble momento 🔥',
      createdAt: DateTime.now().subtract(const Duration(hours: 1)),
      likeCount: 5,
    ),
    MediaComment(
      id: 'comment2',
      mediaId: 'media1',
      userId: 'user789',
      userName: 'Miguel Silva',
      comment: 'Me da escalofríos cada vez que lo veo',
      createdAt: DateTime.now().subtract(const Duration(minutes: 45)),
      likeCount: 3,
    ),
  ];

  static final List<MediaAlbum> _albums = [
    MediaAlbum(
      id: 'album1',
      name: 'Copa Verano 2024 - Final',
      description: 'Todos los momentos de la final del torneo',
      creatorId: 'user123',
      creatorName: 'Juan Pérez',
      createdAt: DateTime.now().subtract(const Duration(days: 2)),
      items: _mediaItems.where((item) => item.matchId == 'match1').toList(),
      isPublic: true,
      tournamentId: '1',
    ),
  ];

  Future<List<MediaItem>> getMatchMedia({
    String? tournamentId,
    String? matchId,
    String? teamId,
  }) async {
    await Future.delayed(const Duration(milliseconds: 600));
    
    var items = List<MediaItem>.from(_mediaItems);
    
    if (tournamentId != null) {
      items = items.where((item) => item.tournamentId == tournamentId).toList();
    }
    
    if (matchId != null) {
      items = items.where((item) => item.matchId == matchId).toList();
    }
    
    if (teamId != null) {
      items = items.where((item) => item.teamId == teamId).toList();
    }
    
    // Ordenar por fecha de subida (más reciente primero)
    items.sort((a, b) => b.uploadedAt.compareTo(a.uploadedAt));
    
    return items;
  }

  Future<List<MediaItem>> getUserMedia(String userId) async {
    await Future.delayed(const Duration(milliseconds: 400));
    
    return _mediaItems
        .where((item) => item.uploaderId == userId)
        .toList()
      ..sort((a, b) => b.uploadedAt.compareTo(a.uploadedAt));
  }

  Future<MediaItem> uploadPhoto({
    required String filePath,
    required String uploaderId,
    required String uploaderName,
    String? title,
    String? description,
    String? tournamentId,
    String? matchId,
    String? teamId,
    List<String> tags = const [],
    bool isPublic = true,
  }) async {
    // Simular subida
    await Future.delayed(const Duration(seconds: 2));
    
    final mediaItem = MediaItem(
      id: 'media_${DateTime.now().millisecondsSinceEpoch}',
      type: MediaType.photo,
      url: 'https://example.com/uploaded_photo.jpg',
      title: title,
      description: description,
      uploaderId: uploaderId,
      uploaderName: uploaderName,
      uploadedAt: DateTime.now(),
      tournamentId: tournamentId,
      matchId: matchId,
      teamId: teamId,
      tags: tags,
      likeCount: 0,
      commentCount: 0,
      isPublic: isPublic,
      width: 1920,
      height: 1080,
      fileSize: 1024000, // 1MB simulado
    );
    
    _mediaItems.add(mediaItem);
    return mediaItem;
  }

  Future<MediaItem> uploadVideo({
    required String filePath,
    required String uploaderId,
    required String uploaderName,
    String? title,
    String? description,
    String? tournamentId,
    String? matchId,
    String? teamId,
    List<String> tags = const [],
    bool isPublic = true,
    Duration? duration,
  }) async {
    // Simular subida (más lenta para videos)
    await Future.delayed(const Duration(seconds: 5));
    
    final mediaItem = MediaItem(
      id: 'media_${DateTime.now().millisecondsSinceEpoch}',
      type: MediaType.video,
      url: 'https://example.com/uploaded_video.mp4',
      thumbnailUrl: 'https://example.com/uploaded_thumb.jpg',
      title: title,
      description: description,
      uploaderId: uploaderId,
      uploaderName: uploaderName,
      uploadedAt: DateTime.now(),
      tournamentId: tournamentId,
      matchId: matchId,
      teamId: teamId,
      tags: tags,
      likeCount: 0,
      commentCount: 0,
      isPublic: isPublic,
      duration: duration ?? const Duration(minutes: 1),
      width: 1920,
      height: 1080,
      fileSize: 20971520, // 20MB simulado
    );
    
    _mediaItems.add(mediaItem);
    return mediaItem;
  }

  Future<bool> likeMedia(String mediaId, String userId) async {
    await Future.delayed(const Duration(milliseconds: 200));
    
    final index = _mediaItems.indexWhere((item) => item.id == mediaId);
    if (index != -1) {
      final item = _mediaItems[index];
      _mediaItems[index] = MediaItem(
        id: item.id,
        type: item.type,
        url: item.url,
        thumbnailUrl: item.thumbnailUrl,
        title: item.title,
        description: item.description,
        uploaderId: item.uploaderId,
        uploaderName: item.uploaderName,
        uploadedAt: item.uploadedAt,
        tournamentId: item.tournamentId,
        matchId: item.matchId,
        teamId: item.teamId,
        tags: item.tags,
        likeCount: item.likeCount + 1,
        commentCount: item.commentCount,
        isPublic: item.isPublic,
        duration: item.duration,
        width: item.width,
        height: item.height,
        fileSize: item.fileSize,
      );
      return true;
    }
    return false;
  }

  Future<MediaComment> addComment({
    required String mediaId,
    required String userId,
    required String userName,
    required String comment,
    String? parentCommentId,
  }) async {
    await Future.delayed(const Duration(milliseconds: 300));
    
    final newComment = MediaComment(
      id: 'comment_${DateTime.now().millisecondsSinceEpoch}',
      mediaId: mediaId,
      userId: userId,
      userName: userName,
      comment: comment,
      createdAt: DateTime.now(),
      likeCount: 0,
      parentCommentId: parentCommentId,
    );
    
    _comments.add(newComment);
    
    // Incrementar contador de comentarios
    final index = _mediaItems.indexWhere((item) => item.id == mediaId);
    if (index != -1) {
      final item = _mediaItems[index];
      _mediaItems[index] = MediaItem(
        id: item.id,
        type: item.type,
        url: item.url,
        thumbnailUrl: item.thumbnailUrl,
        title: item.title,
        description: item.description,
        uploaderId: item.uploaderId,
        uploaderName: item.uploaderName,
        uploadedAt: item.uploadedAt,
        tournamentId: item.tournamentId,
        matchId: item.matchId,
        teamId: item.teamId,
        tags: item.tags,
        likeCount: item.likeCount,
        commentCount: item.commentCount + 1,
        isPublic: item.isPublic,
        duration: item.duration,
        width: item.width,
        height: item.height,
        fileSize: item.fileSize,
      );
    }
    
    return newComment;
  }

  Future<List<MediaComment>> getMediaComments(String mediaId) async {
    await Future.delayed(const Duration(milliseconds: 200));
    
    return _comments
        .where((comment) => comment.mediaId == mediaId)
        .toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  Future<bool> deleteMedia(String mediaId, String userId) async {
    await Future.delayed(const Duration(milliseconds: 300));
    
    final index = _mediaItems.indexWhere((item) => 
        item.id == mediaId && item.uploaderId == userId);
    
    if (index != -1) {
      _mediaItems.removeAt(index);
      // También eliminar comentarios asociados
      _comments.removeWhere((comment) => comment.mediaId == mediaId);
      return true;
    }
    
    return false;
  }

  Future<List<MediaAlbum>> getAlbums({
    String? tournamentId,
    String? teamId,
    String? userId,
  }) async {
    await Future.delayed(const Duration(milliseconds: 400));
    
    var albums = List<MediaAlbum>.from(_albums);
    
    if (tournamentId != null) {
      albums = albums.where((album) => album.tournamentId == tournamentId).toList();
    }
    
    if (teamId != null) {
      albums = albums.where((album) => album.teamId == teamId).toList();
    }
    
    if (userId != null) {
      albums = albums.where((album) => album.creatorId == userId).toList();
    }
    
    return albums..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  Future<MediaAlbum> createAlbum({
    required String name,
    required String description,
    required String creatorId,
    required String creatorName,
    String? tournamentId,
    String? teamId,
    bool isPublic = true,
  }) async {
    await Future.delayed(const Duration(milliseconds: 500));
    
    final album = MediaAlbum(
      id: 'album_${DateTime.now().millisecondsSinceEpoch}',
      name: name,
      description: description,
      creatorId: creatorId,
      creatorName: creatorName,
      createdAt: DateTime.now(),
      items: [],
      isPublic: isPublic,
      tournamentId: tournamentId,
      teamId: teamId,
    );
    
    _albums.add(album);
    return album;
  }

  Future<List<MediaItem>> searchMedia({
    String? query,
    MediaType? type,
    List<String>? tags,
    String? tournamentId,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    await Future.delayed(const Duration(milliseconds: 700));
    
    var results = List<MediaItem>.from(_mediaItems);
    
    if (query != null && query.isNotEmpty) {
      final lowerQuery = query.toLowerCase();
      results = results.where((item) =>
          (item.title?.toLowerCase().contains(lowerQuery) ?? false) ||
          (item.description?.toLowerCase().contains(lowerQuery) ?? false) ||
          item.tags.any((tag) => tag.toLowerCase().contains(lowerQuery))
      ).toList();
    }
    
    if (type != null) {
      results = results.where((item) => item.type == type).toList();
    }
    
    if (tags != null && tags.isNotEmpty) {
      results = results.where((item) =>
          tags.any((tag) => item.tags.contains(tag))
      ).toList();
    }
    
    if (tournamentId != null) {
      results = results.where((item) => item.tournamentId == tournamentId).toList();
    }
    
    if (startDate != null) {
      results = results.where((item) => 
          item.uploadedAt.isAfter(startDate)).toList();
    }
    
    if (endDate != null) {
      results = results.where((item) => 
          item.uploadedAt.isBefore(endDate)).toList();
    }
    
    return results..sort((a, b) => b.uploadedAt.compareTo(a.uploadedAt));
  }
}