import 'package:flutter/material.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:venture/Components/DropShadow.dart';
import 'package:video_player/video_player.dart';
import 'package:get/get.dart';
import 'package:visibility_detector/visibility_detector.dart';

class VideoContentPlayer extends StatefulWidget {
  final String? path;
  final AssetEntity? video;
  final bool showPauseIndicator;
  final bool muteAudio;
  final bool setVideoAspectRatio;
  // final bool autoPlay;
  VideoContentPlayer({Key? key, this.path, this.video, this.showPauseIndicator = true, this.muteAudio = false, this.setVideoAspectRatio = true}) : super(key: key);

  @override
  _VideoContentPlayer createState() => _VideoContentPlayer();
}

class _VideoContentPlayer extends State<VideoContentPlayer> with TickerProviderStateMixin, AutomaticKeepAliveClientMixin<VideoContentPlayer> {
  late Rx video;
  VideoPlayerController? _controller;
  late double ratio;

  late final AnimationController _animationController;
  late final Animation<double> _animation;

  bool manuallyPaused = false;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();

    if(widget.video != null) {
      video = widget.video.obs;
    }else if(widget.path != null) {
      video = widget.path.obs;
    }

    _animationController = AnimationController(
      duration: const Duration(milliseconds: 100),
      vsync: this,
    );

    _animation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeIn,
    );

    // _initializeAsyncDependencies();

    video.listen((p0) {
      _onControllerChange(p0);
    });
  }

  @override
  void dispose() {
    super.dispose();
    _controller!.dispose();
    _animationController.dispose();
  }

  _initializeAsyncDependencies() async {
    await setVideo();
  }

  Future<void> _onControllerChange(var link) async {
    if (_controller == null) {
      // If there was no controller, just create a new one
      _initializeAsyncDependencies();
    } else {
      // If there was a controller, we need to dispose of the old one first
      final oldController = _controller;

      // Registering a callback for the end of next frame
      // to dispose of an old controller
      // (which won't be used anymore after calling setState)
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        await oldController!.dispose();
        
        _animationController.reverse();
        // Initing new controller
        setVideo(video: link);
      });

      // Making sure that controller is not used by setting it to null
      setState(() {
        _controller = null;
      });
    }
  }

  Future<void> setVideo({var video}) async {
    if(video != null) {
      if(video.runtimeType == AssetEntity) {
        AssetEntity entity = video;
        var file = await entity.file;

        _controller = VideoPlayerController.file(
          file!)
        ..setLooping(true)
        ..initialize().then((_) {
          // Ensure the first frame is shown after the video is initialized, even before the play button has been pressed.
          // setState(() {});
          if(widget.muteAudio) toggleVolume(level: 0.0);
          _controller!.seekTo(const Duration(seconds: 1));
          setState(() {
            ratio = _controller!.value.aspectRatio;
          });
          // _controller!.play();
        });
      }else {
        _controller = VideoPlayerController.network(
        video)
        ..setLooping(true)
        ..initialize().then((_) {
          // Ensure the first frame is shown after the video is initialized, even before the play button has been pressed.
          // setState(() {});
          if(widget.muteAudio) toggleVolume(level: 0.0);
          _controller!.seekTo(const Duration(seconds: 1));
          setState(() {
            ratio = _controller!.value.aspectRatio;
          });
          // _controller!.play();
        });
      }
    }else if(widget.video != null) {
      var file = await widget.video!.file;

      _controller = VideoPlayerController.file(
        file!)
      ..setLooping(true)
      ..initialize().then((_) {
        // Ensure the first frame is shown after the video is initialized, even before the play button has been pressed.
        // setState(() {});
        if(widget.muteAudio) toggleVolume(level: 0.0);
        _controller!.seekTo(const Duration(seconds: 1));
        setState(() {
          ratio = _controller!.value.aspectRatio;
        });
        // _controller!.play();
      });
    } else {
      _controller = VideoPlayerController.network(
        widget.path!)
      ..setLooping(true)
      ..initialize().then((_) {
        // Ensure the first frame is shown after the video is initialized, even before the play button has been pressed.
        // setState(() {});
        if(widget.muteAudio) toggleVolume(level: 0.0);
        _controller!.seekTo(const Duration(seconds: 1));
        setState(() {
          ratio = _controller!.value.aspectRatio;
        });
        // _controller!.play();
      });
    }
  }

  toggleVolume({double? level}) {
    if(level != null) {
      _controller!.setVolume(level);
    }
  }

  _buildVideoPlayer() {
    return Stack(
      children: [
        // VideoPlayer(_controller!),
        SizedBox.expand(
          child: FittedBox(
            fit: BoxFit.cover,
            child: SizedBox(
              width: _controller?.value.size.width ?? 0,
              height: _controller?.value.size.height ?? 0,
              child: VideoPlayer(_controller!),
            ),
          ),
        ),

        widget.showPauseIndicator ? Align(
          alignment: Alignment.center,
          child: FadeTransition(
            opacity: _animation,
            child: DropShadow(
              offset: Offset(1, 1),
              child: Icon(
                Icons.play_arrow,
                size: 70,
                color: Colors.grey[50]!.withOpacity(0.8),
              )
            ),
          )
        ) : Container(),
        Positioned.fill(
          child: GestureDetector(
            onTap: () {
              if(_controller!.value.isPlaying) {
                _controller!.pause();
                _animationController.forward();
                setState(() => manuallyPaused = true);
              }else {
                _controller!.play();
                _animationController.reverse();
                setState(() => manuallyPaused = false);
              }
            },
          )
        )
      ]
    );
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    video.value = widget.video ?? (widget.path ?? video);
    
    return widget.path == null && widget.video == null ? Container() : _controller != null && _controller!.value.isInitialized ? 
    VisibilityDetector(
      key: UniqueKey(),
      onVisibilityChanged: (d) {
        if(d.visibleFraction > 0.5) {
          if(!manuallyPaused) _controller!.play();
        }else {
          _controller!.pause();
        }
      },
      child: Center(
        child: widget.setVideoAspectRatio ? AspectRatio(
          aspectRatio: ratio,
          child: _buildVideoPlayer()
        ) : _buildVideoPlayer()
      ),
    )
    : Container();
  }
}

// enum VideoLocation {
//   file,
//   network
// }