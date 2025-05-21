import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';
import '../services/photo_sync_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:amrric_app/services/auth_service.dart';
import 'package:flutter/foundation.dart';

class AnimalPhotoGallery extends ConsumerStatefulWidget {
  final String animalId;
  final List<String> existingPhotos;
  final PhotoSyncService photoSyncService;
  final void Function(List<String>)? onPhotoListChanged;

  const AnimalPhotoGallery({
    Key? key,
    required this.animalId,
    required this.photoSyncService,
    this.existingPhotos = const [],
    this.onPhotoListChanged,
  }) : super(key: key);

  @override
  ConsumerState<AnimalPhotoGallery> createState() => _AnimalPhotoGalleryState();
}

class _AnimalPhotoGalleryState extends ConsumerState<AnimalPhotoGallery> {
  final List<String> _photos = [];
  final ImagePicker _picker = ImagePicker();
  bool _isLoading = false;
  bool _isSyncing = false;
  double _syncProgress = 0.0;
  int _pendingSyncCount = 0;

  @override
  void initState() {
    super.initState();
    _loadPhotos();
    _checkPendingSync();
  }

  Future<void> _checkPendingSync() async {
    final count = await widget.photoSyncService.getPendingSyncCount();
    if (mounted) {
      setState(() {
        _pendingSyncCount = count;
      });
    }
  }

  Future<void> _loadPhotos() async {
    setState(() => _isLoading = true);
    try {
      print('Gallery loading photos: [34m${widget.existingPhotos}[0m');
      _photos.clear();
      final user = ref.read(authStateProvider);
      final userId = user?.id;
      if (userId == null) {
        setState(() => _isLoading = false);
        return;
      }
      final directory = await getApplicationDocumentsDirectory();
      // For each photo in existingPhotos (file names), reconstruct local path and check existence
      for (final fileName in widget.existingPhotos) {
        final localPath = '${directory.path}/$fileName';
        final file = File(localPath);
        if (await file.exists()) {
          _photos.add(localPath);
        } else {
          // Try to fetch from Upstash only if online
          try {
            final photoData = await widget.photoSyncService.getPhoto(
              userId: userId,
              photoId: fileName,
              filePath: localPath,
            );
            if (photoData != null && await File(localPath).exists()) {
              _photos.add(localPath);
            } else {
              // If not available, add a placeholder
              _photos.add('');
            }
          } catch (e) {
            // If error (e.g. offline), add a placeholder
            _photos.add('');
          }
        }
      }
      // Also add any locally queued/synced photos for this animal
      final syncedPhotos = await widget.photoSyncService.getAnimalPhotos(widget.animalId);
      for (final path in syncedPhotos) {
        if (!_photos.contains(path)) {
          _photos.add(path);
        }
      }
      setState(() {});
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading photos: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _takePhoto() async {
    try {
      setState(() => _isLoading = true);
      final XFile? photo = await _picker.pickImage(
        source: ImageSource.camera,
        imageQuality: 80,
      );
      final user = ref.read(authStateProvider);
      final userId = user?.id;
      if (photo != null && userId != null) {
        final String photoPath = await _savePhoto(photo.path);
        setState(() {
          _photos.add(photoPath);
        });
        await widget.photoSyncService.queuePhotoForSync(widget.animalId, photoPath, userId);
        await _checkPendingSync();
        _notifyPhotoListChanged();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error taking photo: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _pickFromGallery() async {
    try {
      setState(() => _isLoading = true);
      final XFile? photo = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 80,
      );
      final user = ref.read(authStateProvider);
      final userId = user?.id;
      if (photo != null && userId != null) {
        final String photoPath = await _savePhoto(photo.path);
        setState(() {
          _photos.add(photoPath);
        });
        await widget.photoSyncService.queuePhotoForSync(widget.animalId, photoPath, userId);
        await _checkPendingSync();
        _notifyPhotoListChanged();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error picking photo: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<String> _savePhoto(String tempPath) async {
    final directory = await getApplicationDocumentsDirectory();
    final String fileName = '${widget.animalId}_${const Uuid().v4()}.jpg';
    final String newPath = '${directory.path}/$fileName';
    
    await File(tempPath).copy(newPath);
    return newPath;
  }

  Future<void> _deletePhoto(int index) async {
    try {
      final photoPath = _photos[index];
      final file = File(photoPath);
      final fileName = photoPath.split('/').last;
      await widget.photoSyncService.deletePhoto(widget.animalId, fileName);
      if (await file.exists()) {
        await file.delete();
      }
      setState(() {
        _photos.removeAt(index);
      });
      _notifyPhotoListChanged();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error deleting photo: $e')),
        );
      }
    }
  }

  Future<void> _syncPhotos() async {
    if (_isSyncing) return;
    
    setState(() {
      _isSyncing = true;
      _syncProgress = 0.0;
    });
    
    try {
      await widget.photoSyncService.syncPhotos(
        onProgress: (progress) {
          if (mounted) {
            setState(() {
              _syncProgress = progress;
            });
          }
        },
      );
      await _checkPendingSync();
      await _loadPhotos();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error syncing photos: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSyncing = false;
          _syncProgress = 0.0;
        });
      }
    }
  }

  Future<void> _clearLocalPhotos() async {
    await widget.photoSyncService.clearLocalPhotos();
    if (mounted) {
      setState(() {
        _photos.clear();
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('All local photo records cleared.')),
      );
    }
  }

  void _notifyPhotoListChanged() {
    final photoFileNames = _photos
      .where((p) => p.isNotEmpty)
      .map((p) => p.split('/').last)
      .toList();
    if (widget.onPhotoListChanged != null) {
      widget.onPhotoListChanged!(photoFileNames);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Animal Photos',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                Row(
                  children: [
                    if (kDebugMode)
                      IconButton(
                        icon: const Icon(Icons.delete_sweep, color: Colors.red),
                        tooltip: 'Clear Local Photo Records',
                        onPressed: _clearLocalPhotos,
                      ),
                    if (_isSyncing)
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8.0),
                        child: SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            value: _syncProgress,
                          ),
                        ),
                      )
                    else if (_pendingSyncCount > 0)
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8.0),
                        child: Badge(
                          label: Text('$_pendingSyncCount'),
                          child: IconButton(
                            icon: const Icon(Icons.sync),
                            onPressed: _syncPhotos,
                            tooltip: 'Sync Photos',
                          ),
                        ),
                      )
                    else
                      IconButton(
                        icon: const Icon(Icons.sync),
                        onPressed: _syncPhotos,
                        tooltip: 'Sync Photos',
                      ),
                    IconButton(
                      icon: const Icon(Icons.camera_alt),
                      onPressed: _isLoading ? null : _takePhoto,
                      tooltip: 'Take Photo',
                    ),
                    IconButton(
                      icon: const Icon(Icons.photo_library),
                      onPressed: _isLoading ? null : _pickFromGallery,
                      tooltip: 'Choose from Gallery',
                    ),
                  ],
                ),
              ],
            ),
          ),
          if (_isLoading)
            const Center(child: CircularProgressIndicator())
          else if (_photos.isEmpty)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: Text('No photos available'),
              ),
            )
          else
            SizedBox(
              height: 200,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: _photos.length,
                itemBuilder: (context, index) {
                  final photoPath = _photos[index];
                  return Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Stack(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: photoPath.isNotEmpty && File(photoPath).existsSync()
                              ? Image.file(
                                  File(photoPath),
                                  width: 200,
                                  height: 200,
                                  fit: BoxFit.cover,
                                )
                              : Container(
                                  width: 200,
                                  height: 200,
                                  color: Colors.grey[300],
                                  child: const Center(child: Icon(Icons.image_not_supported, size: 48, color: Colors.grey)),
                                ),
                        ),
                        Positioned(
                          top: 8,
                          right: 8,
                          child: IconButton(
                            icon: const Icon(Icons.delete, color: Colors.white),
                            onPressed: () => _deletePhoto(index),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
        ],
      ),
    );
  }
} 