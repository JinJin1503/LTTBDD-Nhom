import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

import 'package:duan_app/cores/methods.dart';
import 'package:duan_app/features/upload/long_video/video_repository.dart';

class VideoDetailsPage extends ConsumerStatefulWidget {
  final File? video;
  const VideoDetailsPage({super.key, this.video});

  @override
  ConsumerState<VideoDetailsPage> createState() => _VideoDetailsPageState();
}

class _VideoDetailsPageState extends ConsumerState<VideoDetailsPage> {
  final titleController = TextEditingController();
  final descriptionController = TextEditingController();
  final urlController = TextEditingController();
  String? videoId;
  bool isThumbnailSelected = false;
  File? image;
  String thumbnailUrl = "";
  String randomNumber = const Uuid().v4();

  YoutubePlayerController? _youtubeController;

  void _initYoutubeController(String url) {
    final id = YoutubePlayer.convertUrlToId(url);
    if (id != null) {
      videoId = id;
      _youtubeController = YoutubePlayerController(
        initialVideoId: id,
        flags: const YoutubePlayerFlags(
          autoPlay: false,
          mute: false,
        ),
      );
    } else {
      videoId = null;
      _youtubeController = null;
    }
  }

  @override
  void dispose() {
    _youtubeController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Thêm video từ YouTube")),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              TextField(
                controller: urlController,
                decoration: const InputDecoration(
                  hintText: "Dán link YouTube vào đây",
                  prefixIcon: Icon(Icons.link),
                  border: OutlineInputBorder(),
                ),
                onChanged: (value) {
                  setState(() {
                    _initYoutubeController(value);
                  });
                },
              ),
              const SizedBox(height: 12),
              _youtubeController != null
                  ? YoutubePlayer(
                      controller: _youtubeController!,
                      showVideoProgressIndicator: true,
                    )
                  : const Text("Video không hợp lệ hoặc chưa nhập URL"),
              const SizedBox(height: 20),
              TextField(
                controller: titleController,
                decoration: const InputDecoration(
                  hintText: "Tiêu đề video",
                  prefixIcon: Icon(Icons.title),
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 20),
              TextField(
                controller: descriptionController,
                maxLines: 3,
                decoration: const InputDecoration(
                  hintText: "Mô tả video",
                  prefixIcon: Icon(Icons.description),
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () async {
                  image = await pickImage();
                  isThumbnailSelected = true;
                  setState(() {});
                },
                child: const Text("Chọn thumbnail"),
              ),
              if (isThumbnailSelected && image != null)
                Padding(
                  padding: const EdgeInsets.only(top: 10),
                  child: Image.file(image!, height: 150),
                ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () async {
                  if (videoId == null || urlController.text.isEmpty) {
                    showErrorSnackBar("Bạn cần nhập URL YouTube hợp lệ", context);
                    return;
                  }

                  String thumbnail = "";
                  if (isThumbnailSelected && image != null) {
                    thumbnail = await putFileInStorage(image, randomNumber, "image");
                  }

                  ref.read(longVideoProvider).uploadVideoToFirestore(
                        videoUrl: urlController.text.trim(),
                        thumbnail: thumbnail,
                        title: titleController.text.trim(),
                        videoId: videoId!,
                        datePublished: DateTime.now(),
                        userId: FirebaseAuth.instance.currentUser!.uid,
                      );
                  Navigator.pop(context);
                },
                style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                child: const Text("Đăng video"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
