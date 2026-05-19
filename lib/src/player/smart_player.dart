import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class SmartPlayer extends StatefulWidget {
  final String url;
  final bool autoPlay;
  final bool looping;

  const SmartPlayer.network(
      this.url, {
        super.key,
        this.autoPlay = true,
        this.looping = false,
      });

  @override
  State<SmartPlayer> createState() => _SmartPlayerState();
}

class _SmartPlayerState extends State<SmartPlayer> {
  late VideoPlayerController _controller;

  bool isLoading = true;

  @override
  void initState() {
    super.initState();

    _controller = VideoPlayerController.networkUrl(
      Uri.parse(widget.url),
    )
      ..initialize().then((_) async {
        await _controller.setLooping(widget.looping);

        if (widget.autoPlay) {
          await _controller.play();
        }

        setState(() {
          isLoading = false;
        });
      });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void togglePlayPause() {
    if (_controller.value.isPlaying) {
      _controller.pause();
    } else {
      _controller.play();
    }

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    return AspectRatio(
      aspectRatio: _controller.value.aspectRatio,
      child: Stack(
        alignment: Alignment.center,
        children: [
          VideoPlayer(_controller),

          GestureDetector(
            onTap: togglePlayPause,
            child: Container(
              color: Colors.transparent,
              child: Center(
                child: Icon(
                  _controller.value.isPlaying
                      ? Icons.pause_circle
                      : Icons.play_circle,
                  size: 70,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}