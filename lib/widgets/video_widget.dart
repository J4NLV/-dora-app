import 'package:flutter/material.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';
import 'rich_text_helper.dart';

class VideoWidget extends StatefulWidget {
  final Map<String, dynamic> data;

  const VideoWidget({super.key, required this.data});

  @override
  State<VideoWidget> createState() => _VideoWidgetState();
}

class _VideoWidgetState extends State<VideoWidget> {
  YoutubePlayerController? _controller;
  bool _hasValidVideo = false;

  @override
  void initState() {
    super.initState();
    _initPlayer();
  }

  void _initPlayer() {
    final rawUrl = widget.data['Url_Youtube'] ?? widget.data['urlYoutube'] ?? '';
    final videoId = YoutubePlayer.convertUrlToId(rawUrl.toString());

    if (videoId != null && videoId.isNotEmpty) {
      _hasValidVideo = true;
      _controller = YoutubePlayerController(
        initialVideoId: videoId,
        flags: const YoutubePlayerFlags(
          autoPlay: false,
          mute: false,
          enableCaption: true,
          showLiveFullscreenButton: false,
        ),
      );
    } else {
      _hasValidVideo = false;
      _controller = null;
    }
  }

  @override
  void didUpdateWidget(covariant VideoWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    final oldUrl = oldWidget.data['Url_Youtube'] ?? oldWidget.data['urlYoutube'] ?? '';
    final newUrl = widget.data['Url_Youtube'] ?? widget.data['urlYoutube'] ?? '';
    if (oldUrl != newUrl) {
      _controller?.dispose();
      _controller = null;
      _initPlayer();
      setState(() {});
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_hasValidVideo || _controller == null) {
      return _buildBody(context);
    }

    return YoutubePlayerBuilder(
      player: YoutubePlayer(
        controller: _controller!,
        showVideoProgressIndicator: true,
        progressIndicatorColor: const Color(0xFF7B5BA3),
        progressColors: const ProgressBarColors(
          playedColor: Color(0xFF7B5BA3),
          handleColor: Color(0xFF5B3A82),
        ),
      ),
      builder: (context, player) {
        return _buildBody(context, player: player);
      },
    );
  }

  Widget _buildBody(BuildContext context, {Widget? player}) {
    return Container(
      constraints: const BoxConstraints.expand(),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(15),
              child: player ??
                  Container(
                    height: 200,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.black38,
                      borderRadius: BorderRadius.circular(15),
                      border: Border.all(color: Colors.white24, width: 2),
                    ),
                    child: const Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.video_library_rounded, color: Colors.white70, size: 54),
                        SizedBox(height: 10),
                        Text(
                          "Video explicativo próximamente",
                          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                      ],
                    ),
                  ),
            ),
            const SizedBox(height: 25),
            FormattedText(
              text: widget.data['Tema'] ?? "Sin título",
              baseStyle: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
              boldStyle: const TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: Colors.yellowAccent),
            ),
            const SizedBox(height: 15),
            FormattedText(
              text: widget.data['Explicación'] ?? "",
              baseStyle: const TextStyle(fontSize: 16, height: 1.5, color: Colors.white),
              boldStyle: const TextStyle(fontSize: 16, height: 1.5, fontWeight: FontWeight.w900, color: Colors.yellowAccent),
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }
}
