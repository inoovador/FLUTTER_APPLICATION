import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../models/media_model.dart';
import '../../services/media_service.dart';

class MatchGalleryScreen extends StatefulWidget {
  final String? tournamentId;
  final String? matchId;
  
  const MatchGalleryScreen({
    super.key,
    this.tournamentId,
    this.matchId,
  });

  @override
  State<MatchGalleryScreen> createState() => _MatchGalleryScreenState();
}

class _MatchGalleryScreenState extends State<MatchGalleryScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final MediaService _mediaService = MediaService();
  
  List<MediaItem> _photos = [];
  List<MediaItem> _videos = [];
  bool _isLoading = true;
  
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadMedia();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadMedia() async {
    setState(() => _isLoading = true);
    
    try {
      final allMedia = await _mediaService.getMatchMedia(
        tournamentId: widget.tournamentId,
        matchId: widget.matchId,
      );
      
      setState(() {
        _photos = allMedia.where((item) => item.type == MediaType.photo).toList();
        _videos = allMedia.where((item) => item.type == MediaType.video).toList();
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      _showError('Error al cargar multimedia');
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
        title: Text(widget.matchId != null ? 'Galería del Partido' : 'Galería del Torneo'),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: const Color(0xFF97FB57),
          tabs: [
            Tab(
              icon: const Icon(Icons.photo_library),
              text: 'Fotos (${_photos.length})',
            ),
            Tab(
              icon: const Icon(Icons.video_library),
              text: 'Videos (${_videos.length})',
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.camera_alt),
            onPressed: _showMediaOptions,
          ),
        ],
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildPhotosTab(),
          _buildVideosTab(),
        ],
      ),
    );
  }

  Widget _buildPhotosTab() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: Color(0xFF97FB57)),
      );
    }
    
    if (_photos.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.photo_library_outlined,
              size: 80,
              color: const Color(0xFF909090).withOpacity(0.5),
            ),
            const SizedBox(height: 16),
            Text(
              'No hay fotos aún',
              style: TextStyle(
                fontSize: 18,
                color: const Color(0xFF909090).withOpacity(0.7),
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: _addPhoto,
              icon: const Icon(Icons.add_a_photo),
              label: const Text('Agregar Foto'),
            ),
          ],
        ),
      );
    }
    
    return RefreshIndicator(
      onRefresh: _loadMedia,
      color: const Color(0xFF97FB57),
      child: GridView.builder(
        padding: const EdgeInsets.all(16),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: 1,
        ),
        itemCount: _photos.length,
        itemBuilder: (context, index) {
          final photo = _photos[index];
          return _buildPhotoCard(photo);
        },
      ),
    );
  }

  Widget _buildPhotoCard(MediaItem photo) {
    return GestureDetector(
      onTap: () => _viewFullScreenMedia(photo),
      child: Card(
        clipBehavior: Clip.antiAlias,
        child: Stack(
          fit: StackFit.expand,
          children: [
            // Imagen placeholder con gradiente
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    const Color(0xFF97FB57).withOpacity(0.3),
                    const Color(0xFF97FB57).withOpacity(0.1),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: const Icon(
                Icons.photo,
                size: 50,
                color: Color(0xFF97FB57),
              ),
            ),
            
            // Información superpuesta
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.transparent,
                      Colors.black.withOpacity(0.7),
                    ],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      photo.title ?? 'Sin título',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        const Icon(
                          Icons.person,
                          size: 12,
                          color: Colors.white70,
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            photo.uploaderName,
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 10,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (photo.likeCount > 0) ...[
                          const SizedBox(width: 8),
                          const Icon(
                            Icons.favorite,
                            size: 12,
                            color: Colors.red,
                          ),
                          const SizedBox(width: 2),
                          Text(
                            photo.likeCount.toString(),
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 10,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVideosTab() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: Color(0xFF97FB57)),
      );
    }
    
    if (_videos.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.video_library_outlined,
              size: 80,
              color: const Color(0xFF909090).withOpacity(0.5),
            ),
            const SizedBox(height: 16),
            Text(
              'No hay videos aún',
              style: TextStyle(
                fontSize: 18,
                color: const Color(0xFF909090).withOpacity(0.7),
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: _addVideo,
              icon: const Icon(Icons.videocam),
              label: const Text('Agregar Video'),
            ),
          ],
        ),
      );
    }
    
    return RefreshIndicator(
      onRefresh: _loadMedia,
      color: const Color(0xFF97FB57),
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _videos.length,
        itemBuilder: (context, index) {
          final video = _videos[index];
          return _buildVideoCard(video);
        },
      ),
    );
  }

  Widget _buildVideoCard(MediaItem video) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: InkWell(
        onTap: () => _playVideo(video),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Thumbnail del video
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  gradient: LinearGradient(
                    colors: [
                      const Color(0xFF97FB57).withOpacity(0.3),
                      const Color(0xFF97FB57).withOpacity(0.1),
                    ],
                  ),
                ),
                child: const Stack(
                  alignment: Alignment.center,
                  children: [
                    Icon(
                      Icons.video_library,
                      size: 30,
                      color: Color(0xFF97FB57),
                    ),
                    Positioned(
                      bottom: 4,
                      right: 4,
                      child: Icon(
                        Icons.play_circle_filled,
                        size: 24,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
              
              const SizedBox(width: 16),
              
              // Información del video
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      video.title ?? 'Video sin título',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      video.description ?? '',
                      style: const TextStyle(
                        color: Color(0xFF909090),
                        fontSize: 14,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Icon(
                          Icons.person,
                          size: 16,
                          color: Color(0xFF909090),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          video.uploaderName,
                          style: const TextStyle(
                            color: Color(0xFF909090),
                            fontSize: 12,
                          ),
                        ),
                        const Spacer(),
                        if (video.duration != null) ...[
                          const Icon(
                            Icons.access_time,
                            size: 14,
                            color: Color(0xFF909090),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            _formatDuration(video.duration!),
                            style: const TextStyle(
                              color: Color(0xFF909090),
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(
                          Icons.favorite,
                          size: 14,
                          color: Colors.red,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          video.likeCount.toString(),
                          style: const TextStyle(
                            color: Color(0xFF909090),
                            fontSize: 12,
                          ),
                        ),
                        const SizedBox(width: 16),
                        const Icon(
                          Icons.comment,
                          size: 14,
                          color: Color(0xFF909090),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          video.commentCount.toString(),
                          style: const TextStyle(
                            color: Color(0xFF909090),
                            fontSize: 12,
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
      ),
    );
  }

  void _showMediaOptions() {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1A1A1A),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt, color: Color(0xFF97FB57)),
              title: const Text('Tomar Foto'),
              onTap: () {
                Navigator.pop(context);
                _addPhoto();
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library, color: Color(0xFF97FB57)),
              title: const Text('Seleccionar de Galería'),
              onTap: () {
                Navigator.pop(context);
                _selectFromGallery();
              },
            ),
            ListTile(
              leading: const Icon(Icons.videocam, color: Color(0xFF97FB57)),
              title: const Text('Grabar Video'),
              onTap: () {
                Navigator.pop(context);
                _addVideo();
              },
            ),
            ListTile(
              leading: const Icon(Icons.video_library, color: Color(0xFF97FB57)),
              title: const Text('Seleccionar Video'),
              onTap: () {
                Navigator.pop(context);
                _selectVideoFromGallery();
              },
            ),
          ],
        ),
      ),
    );
  }

  void _addPhoto() {
    // Implementar captura de foto
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Función de cámara próximamente'),
        backgroundColor: Color(0xFF97FB57),
      ),
    );
  }

  void _selectFromGallery() {
    // Implementar selección de galería
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Selección de galería próximamente'),
        backgroundColor: Color(0xFF97FB57),
      ),
    );
  }

  void _addVideo() {
    // Implementar grabación de video
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Grabación de video próximamente'),
        backgroundColor: Color(0xFF97FB57),
      ),
    );
  }

  void _selectVideoFromGallery() {
    // Implementar selección de video
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Selección de video próximamente'),
        backgroundColor: Color(0xFF97FB57),
      ),
    );
  }

  void _viewFullScreenMedia(MediaItem media) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => FullScreenMediaViewer(media: media),
      ),
    );
  }

  void _playVideo(MediaItem video) {
    // Implementar reproductor de video
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Reproduciendo: ${video.title}'),
        backgroundColor: const Color(0xFF97FB57),
      ),
    );
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return '$minutes:$seconds';
  }
}

class FullScreenMediaViewer extends StatelessWidget {
  final MediaItem media;
  
  const FullScreenMediaViewer({
    super.key,
    required this.media,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: Text(media.title ?? 'Media'),
        actions: [
          IconButton(
            icon: const Icon(Icons.favorite_border),
            onPressed: () {
              // Dar like
            },
          ),
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: () {
              // Compartir
            },
          ),
        ],
      ),
      body: Center(
        child: media.type == MediaType.photo
            ? InteractiveViewer(
                child: Container(
                  width: double.infinity,
                  height: double.infinity,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        const Color(0xFF97FB57).withOpacity(0.3),
                        const Color(0xFF97FB57).withOpacity(0.1),
                      ],
                    ),
                  ),
                  child: const Icon(
                    Icons.photo,
                    size: 200,
                    color: Color(0xFF97FB57),
                  ),
                ),
              )
            : Container(
                width: double.infinity,
                height: 300,
                color: Colors.black,
                child: const Center(
                  child: Icon(
                    Icons.play_circle_filled,
                    size: 100,
                    color: Color(0xFF97FB57),
                  ),
                ),
              ),
      ),
    );
  }
}