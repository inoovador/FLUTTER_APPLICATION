enum MediaType {
  photo,
  video,
}

class MediaItem {
  final String id;
  final MediaType type;
  final String url;
  final String? thumbnailUrl;
  final String? title;
  final String? description;
  final String uploaderId;
  final String uploaderName;
  final DateTime uploadedAt;
  final String? tournamentId;
  final String? matchId;
  final String? teamId;
  final List<String> tags;
  final int likeCount;
  final int commentCount;
  final bool isPublic;
  final Duration? duration; // Solo para videos
  final int? width;
  final int? height;
  final int fileSize; // en bytes
  
  MediaItem({
    required this.id,
    required this.type,
    required this.url,
    this.thumbnailUrl,
    this.title,
    this.description,
    required this.uploaderId,
    required this.uploaderName,
    required this.uploadedAt,
    this.tournamentId,
    this.matchId,
    this.teamId,
    required this.tags,
    required this.likeCount,
    required this.commentCount,
    required this.isPublic,
    this.duration,
    this.width,
    this.height,
    required this.fileSize,
  });
  
  String get fileSizeFormatted {
    if (fileSize < 1024) return '${fileSize}B';
    if (fileSize < 1024 * 1024) return '${(fileSize / 1024).toStringAsFixed(1)}KB';
    if (fileSize < 1024 * 1024 * 1024) return '${(fileSize / (1024 * 1024)).toStringAsFixed(1)}MB';
    return '${(fileSize / (1024 * 1024 * 1024)).toStringAsFixed(1)}GB';
  }
  
  Map<String, dynamic> toJson() => {
    'id': id,
    'type': type.toString(),
    'url': url,
    'thumbnailUrl': thumbnailUrl,
    'title': title,
    'description': description,
    'uploaderId': uploaderId,
    'uploaderName': uploaderName,
    'uploadedAt': uploadedAt.toIso8601String(),
    'tournamentId': tournamentId,
    'matchId': matchId,
    'teamId': teamId,
    'tags': tags,
    'likeCount': likeCount,
    'commentCount': commentCount,
    'isPublic': isPublic,
    'duration': duration?.inSeconds,
    'width': width,
    'height': height,
    'fileSize': fileSize,
  };
  
  factory MediaItem.fromJson(Map<String, dynamic> json) => MediaItem(
    id: json['id'],
    type: MediaType.values.firstWhere(
      (t) => t.toString() == json['type'],
    ),
    url: json['url'],
    thumbnailUrl: json['thumbnailUrl'],
    title: json['title'],
    description: json['description'],
    uploaderId: json['uploaderId'],
    uploaderName: json['uploaderName'],
    uploadedAt: DateTime.parse(json['uploadedAt']),
    tournamentId: json['tournamentId'],
    matchId: json['matchId'],
    teamId: json['teamId'],
    tags: List<String>.from(json['tags']),
    likeCount: json['likeCount'],
    commentCount: json['commentCount'],
    isPublic: json['isPublic'],
    duration: json['duration'] != null 
        ? Duration(seconds: json['duration'])
        : null,
    width: json['width'],
    height: json['height'],
    fileSize: json['fileSize'],
  );
}

class MediaComment {
  final String id;
  final String mediaId;
  final String userId;
  final String userName;
  final String comment;
  final DateTime createdAt;
  final int likeCount;
  final String? parentCommentId;
  
  MediaComment({
    required this.id,
    required this.mediaId,
    required this.userId,
    required this.userName,
    required this.comment,
    required this.createdAt,
    required this.likeCount,
    this.parentCommentId,
  });
  
  Map<String, dynamic> toJson() => {
    'id': id,
    'mediaId': mediaId,
    'userId': userId,
    'userName': userName,
    'comment': comment,
    'createdAt': createdAt.toIso8601String(),
    'likeCount': likeCount,
    'parentCommentId': parentCommentId,
  };
  
  factory MediaComment.fromJson(Map<String, dynamic> json) => MediaComment(
    id: json['id'],
    mediaId: json['mediaId'],
    userId: json['userId'],
    userName: json['userName'],
    comment: json['comment'],
    createdAt: DateTime.parse(json['createdAt']),
    likeCount: json['likeCount'],
    parentCommentId: json['parentCommentId'],
  );
}

class MediaAlbum {
  final String id;
  final String name;
  final String description;
  final String creatorId;
  final String creatorName;
  final DateTime createdAt;
  final List<MediaItem> items;
  final String? coverImageUrl;
  final bool isPublic;
  final String? tournamentId;
  final String? teamId;
  
  MediaAlbum({
    required this.id,
    required this.name,
    required this.description,
    required this.creatorId,
    required this.creatorName,
    required this.createdAt,
    required this.items,
    this.coverImageUrl,
    required this.isPublic,
    this.tournamentId,
    this.teamId,
  });
  
  int get photoCount => items.where((item) => item.type == MediaType.photo).length;
  int get videoCount => items.where((item) => item.type == MediaType.video).length;
  
  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'description': description,
    'creatorId': creatorId,
    'creatorName': creatorName,
    'createdAt': createdAt.toIso8601String(),
    'items': items.map((item) => item.toJson()).toList(),
    'coverImageUrl': coverImageUrl,
    'isPublic': isPublic,
    'tournamentId': tournamentId,
    'teamId': teamId,
  };
  
  factory MediaAlbum.fromJson(Map<String, dynamic> json) => MediaAlbum(
    id: json['id'],
    name: json['name'],
    description: json['description'],
    creatorId: json['creatorId'],
    creatorName: json['creatorName'],
    createdAt: DateTime.parse(json['createdAt']),
    items: (json['items'] as List)
        .map((item) => MediaItem.fromJson(item))
        .toList(),
    coverImageUrl: json['coverImageUrl'],
    isPublic: json['isPublic'],
    tournamentId: json['tournamentId'],
    teamId: json['teamId'],
  );
}