// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';
import 'package:duan_app/features/auth/model/user_model.dart';
import 'package:duan_app/features/auth/provider/user_provider.dart';
import 'package:duan_app/features/upload/long_video/video_model.dart';
import 'package:timeago/timeago.dart' as timeago;

class Post extends ConsumerStatefulWidget {
  final VideoModel video;
  const Post({
    Key? key,
    required this.video,
  }) : super(key: key);

  @override
  ConsumerState<Post> createState() => _PostState();
}

class _PostState extends ConsumerState<Post> {
  YoutubePlayerController? _youtubeController;

  @override
  void initState() {
    super.initState();

    // Convert video URL to video ID
    final videoId = YoutubePlayer.convertUrlToId(widget.video.videoUrl);
    if (videoId != null) {
      _youtubeController = YoutubePlayerController(
        initialVideoId: videoId,
        flags: const YoutubePlayerFlags(
          autoPlay: false,
          mute: false,
        ),
      );
    }
  }

  @override
  void dispose() {
    _youtubeController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final AsyncValue<UserModel> userModel =
        ref.watch(anyUserDataProvider(widget.video.userId));
    final user = userModel.whenData((user) => user);

    return user.value == null
        ? const SizedBox()
        : GestureDetector(
            onTap: () async {
              // Tăng lượt xem
              await FirebaseFirestore.instance
                  .collection("videos")
                  .doc(widget.video.videoId)
                  .update({
                "views": FieldValue.increment(1),
              });
            },
            child: Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Video player
                    if (_youtubeController != null)
                      YoutubePlayer(
                        controller: _youtubeController!,
                        showVideoProgressIndicator: true,
                        progressColors: const ProgressBarColors(
                          playedColor: Colors.red,
                          handleColor: Colors.redAccent,
                        ),
                      )
                    else
                      const Center(child: Text("Không phát được video")),

                    const SizedBox(height: 8),

                    // Title + menu
                    Row(
                      children: [
                        const SizedBox(width: 8),
                        CircleAvatar(
                          radius: 20,
                          backgroundImage: CachedNetworkImageProvider(
                            user.value!.profilePic,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            widget.video.title,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ),
                        IconButton(
                          onPressed: () {},
                          icon: const Icon(Icons.more_vert),
                        ),
                      ],
                    ),

                    const SizedBox(height: 4),

                    // Info line: display name - views - time ago
                    Padding(
                      padding: const EdgeInsets.only(left: 60, right: 8),
                      child: Row(
                        children: [
                          Text(
                            user.value!.displayName,
                            style: const TextStyle(color: Colors.blueGrey),
                          ),
                          const SizedBox(width: 10),
                          Text(
                            widget.video.views == 0
                                ? "No View"
                                : "${widget.video.views} views",
                            style: const TextStyle(color: Colors.blueGrey),
                          ),
                          const SizedBox(width: 10),
                          Text(
                            timeago.format(widget.video.datePublished),
                            style: const TextStyle(color: Colors.blueGrey),
                          ),
                        ],
                      ),
                    )
                  ],
                ),
              )
            ),
          );
  }
}
