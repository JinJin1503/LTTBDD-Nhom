// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:duan_app/cores/widgets/flat_button.dart';
import 'package:duan_app/features/upload/short_video/repository/short_video_repository.dart';

class ShortVideoDetailsPage extends ConsumerStatefulWidget {
  const ShortVideoDetailsPage({Key? key}) : super(key: key);

  @override
  ConsumerState<ShortVideoDetailsPage> createState() =>
      _ShortVideoDetailsPageState();
}

class _ShortVideoDetailsPageState
    extends ConsumerState<ShortVideoDetailsPage> {
  final captionController = TextEditingController();
  final urlController = TextEditingController();
  final DateTime date = DateTime.now();
  bool isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Video ngắn",
          style: TextStyle(color: Colors.white),
        ),
        centerTitle: true,
        backgroundColor: Colors.red,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.only(top: 20, left: 10, right: 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextField(
                controller: captionController,
                decoration: const InputDecoration(
                  hintText: "Viết caption...",
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 20),
              TextField(
                controller: urlController,
                decoration: const InputDecoration(
                  hintText: "Dán link video vào đây",
                  prefixIcon: Icon(Icons.link),
                  border: OutlineInputBorder(),
                ),
              ),
              const Spacer(),
              Padding(
                padding: const EdgeInsets.only(bottom: 30),
                child: isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : FlatButton(
                        text: "Đăng video",
                        onPressed: () async {
                          if (captionController.text.isEmpty ||
                              urlController.text.isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                  content:
                                      Text("Please enter caption and URL")),
                            );
                            return;
                          }

                          setState(() {
                            isLoading = true;
                          });

                          try {
                            await ref
                                .read(shortVideoProvider)
                                .addShortVideoToFirestore(
                                  caption: captionController.text,
                                  video: urlController.text.trim(),
                                  datePublished: date,
                                );
                            if (mounted) Navigator.pop(context);
                          } catch (e) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text("Error: $e")),
                            );
                          } finally {
                            setState(() {
                              isLoading = false;
                            });
                          }
                        },
                        colour: Colors.green,
                      ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
