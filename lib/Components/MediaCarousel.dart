import 'dart:async';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:better_player/better_player.dart';
import 'package:mime/mime.dart';
import 'package:venture/Components/CarouselIndicator/carousel_indicator.dart';
import 'package:venture/Components/DropShadow.dart';
import 'package:venture/Components/Skeleton.dart';
import 'package:get/get.dart';
// ignore: implementation_imports
import 'package:better_player/src/video_player/video_player.dart';
// ignore: implementation_imports
import 'package:better_player/src/video_player/video_player_platform_interface.dart';

class MediaCarousel extends StatefulWidget {
  final List<String> contentUrls;
  final bool touchToMute;
  final bool showPauseIndicator;
  final bool initMute;
  final bool setVideoAspectRatio;
  final bool showProgressIndicator;
  MediaCarousel({Key? key, required this.contentUrls, this.touchToMute = false, this.showPauseIndicator = true, this.initMute = false, this.setVideoAspectRatio = true, this.showProgressIndicator = true}) : super(key: key);

  @override
  _MediaCarousel createState() => _MediaCarousel();
}

class _MediaCarousel extends State<MediaCarousel> with TickerProviderStateMixin {
  int index = 0;
  // double _position = 0;
  // double _buffer = 0;
  bool _lock = true;
  Map<String, BetterPlayerController> _controllers = {};
  Map<int, Function(BetterPlayerEvent)> _listeners = {};
  late Set<String> _urls;

  AnimationController? _pauseAnimationController;
  Animation<double>? _pauseAnimation;

  @override
  void initState() {
    super.initState();

    _urls = widget.contentUrls.toSet();

    if (_urls.isNotEmpty) {
      if(isVideo(_urls.elementAt(0))) {
        _initController(0).then((_) {
          // _playController(0);
        });
      }
    }

    if (_urls.length > 1) {
      if (isVideo(_urls.elementAt(1))) {
        _initController(1).whenComplete(() => _lock = false);
      } else {
        _lock = false;
      }
    }

    if(widget.showPauseIndicator) {
      _pauseAnimationController = AnimationController(
        duration: const Duration(milliseconds: 100),
        vsync: this,
      );
      _pauseAnimation = CurvedAnimation(
        parent: _pauseAnimationController!,
        curve: Curves.easeIn,
      );
    }
  }

  @override
  void dispose() {
    super.dispose();
    // print("Video controllers destroyed: ${_controllers.values.length}");
    _controllers.values.forEach((element) {
      element.dispose(forceDispose: true);
    });

    if(_pauseAnimationController != null) {
      _pauseAnimationController!.dispose();
    }
  }

  Function(BetterPlayerEvent) _listenerSpawner(index) {
    return (BetterPlayerEvent event) {
      // int dur = _controller(index).videoPlayerController?.value.duration?.inMilliseconds ?? 0;
      // int pos = _controller(index).videoPlayerController?.value.position.inMilliseconds ?? 0;
      // int buf = _controller(index).videoPlayerController?.value.buffered.last.end.inMilliseconds ?? 0;

      // setState(() {
      //   if (dur <= pos) {
      //     _position = 0;
      //     return;
      //   }
      //   _position = pos / dur;
      //   _buffer = buf / dur;
      // });

      if(event.betterPlayerEventType == BetterPlayerEventType.pause && _pauseAnimationController != null) {
        _pauseAnimationController!.forward();
      }
      if(event.betterPlayerEventType == BetterPlayerEventType.play && _pauseAnimationController != null) {
        _pauseAnimationController!.reverse();
      }
      
      //go to next video once current is finished
      // if (dur - pos < 1) {
      //   if (index < _urls.length - 1) {
      //     _nextVideo();
      //   }
      // }
    };
  }

  BetterPlayerController _controller(int index) {
    return _controllers[_urls.elementAt(index)]!;
  }

  Future<void> _initController(int index) async {
    BetterPlayerConfiguration betterPlayerConfiguration = BetterPlayerConfiguration(
      // aspectRatio: 16 / 9,
      fit: widget.setVideoAspectRatio ? BoxFit.contain : BoxFit.cover,
      expandToFill: false,
      looping: true,
      autoPlay: false,
      autoDispose: false,
      playerVisibilityChangedBehavior: (vf) {
        if (vf > 0.5) {
          // if(!manuallyPaused) _controller!.play();
          _playController(index);
        } else {
          _stopController(index);
        }
      },
      controlsConfiguration: BetterPlayerControlsConfiguration(
        showControls: false,
        showControlsOnInitialize: false
      )
    );
    final bufferConfig = BetterPlayerBufferingConfiguration(
      minBufferMs: 1000,
      maxBufferMs: 5000, //13107200,
      bufferForPlaybackMs: 1000,
      bufferForPlaybackAfterRebufferMs: 5000,
    );
    final cacheConfig = BetterPlayerCacheConfiguration(
      useCache: true,
      maxCacheSize: 10 * 1024 * 1024,
      maxCacheFileSize: 10 * 1024 * 1024,
      preCacheSize: 3 * 1024 * 1024
    );

    BetterPlayerDataSource dataSource = BetterPlayerDataSource(
      BetterPlayerDataSourceType.network,
      _urls.elementAt(index),
      cacheConfiguration: cacheConfig,
      bufferingConfiguration: bufferConfig
    );

    var controller = BetterPlayerController(
      betterPlayerConfiguration,
      betterPlayerDataSource: dataSource
    );

    _controllers[_urls.elementAt(index)] = controller;
    // await controller.initialize();
  }

  void _removeController(int index) {
    if(mounted) _controller(index).dispose();
    _controllers.remove(_urls.elementAt(index));
    _listeners.remove(index);
  }

  void _stopController(int index) {
    _controller(index).removeEventsListener(_listeners[index]!);
    _controller(index).pause();
    _controller(index).seekTo(Duration(milliseconds: 0));
  }

  void _playController(int index) async {
    if (!_listeners.keys.contains(index)) {
      _listeners[index] = _listenerSpawner(index);
    }
    _controller(index).addEventsListener(_listeners[index]!);
    _controller(index).videoPlayerController!.setMixWithOthers(true); //keep video playing with other app videos simultaneously
    await _controller(index).play();
    setState(() {});
  }

  void _previousVideo() {
    if (_lock || index == 0) {
      return;
    }
    _lock = true;

    if(isVideo(_urls.elementAt(index))) {
      _stopController(index);
    }

    if (index + 1 < _urls.length && isVideo(_urls.elementAt(index + 1))) {
      _removeController(index + 1);
    }

    if(isVideo(_urls.elementAt(index - 1))) {
      _playController(--index);
    }else {
      --index;
      setState(() {});
    }

    if (index == 0) {
      _lock = false;
    } else {
      if(isVideo(_urls.elementAt(index - 1))) {
        _initController(index - 1).whenComplete(() => _lock = false);
      }else {
        _lock = false;
      }
    }
  }

  void _nextVideo() async {
    if (_lock || index == _urls.length - 1) {
      return;
    }
    _lock = true;

    if(isVideo(_urls.elementAt(index))) {
      _stopController(index);
    }

    if (index - 1 >= 0 && isVideo(_urls.elementAt(index - 1))) {
      _removeController(index - 1);
    }

    if(isVideo(_urls.elementAt(index + 1))) {
      _playController(++index);
    }else {
      ++index;
      setState(() {});
    }

    if (index == _urls.length - 1) {
      _lock = false;
    } else {
      if(isVideo(_urls.elementAt(index + 1))) {
        _initController(index + 1).whenComplete(() => _lock = false);
      }else {
        _lock = false;
      }
    }
  }

  bool isVideo(String url) {
    return lookupMimeType(url)!.contains("video");
  }

  buildMedia(int i) {
    if(isVideo(_urls.elementAt(i))) {
      if(_controllers.keys.contains(_urls.elementAt(i))) {
        return Stack(
          children: [
            Positioned.fill(
              child: BetterPlayer(controller: _controller(i))
            ),
            // Center(
            //   child: widget.setVideoAspectRatio ? AspectRatio(
            //     aspectRatio: _controller(i).videoPlayerController!.value.aspectRatio,
            //     child: BetterPlayer(controller: _controller(i))
            //   ) : SizedBox.expand(
            //     child: FittedBox(
            //       fit: BoxFit.cover,
            //       child: SizedBox(
            //         width: _controller(i).videoPlayerController?.value.size?.width ?? 0,
            //         height: _controller(i).videoPlayerController?.value.size?.height ?? 0,
            //         child: BetterPlayer(controller: _controller(i)),
            //       )
            //     )
            //   )
            // ),

            widget.showPauseIndicator || !widget.touchToMute ? Align(
              alignment: Alignment.center,
              child: FadeTransition(
                opacity: _pauseAnimation!,
                child: DropShadow(
                  offset: Offset(0.5, 0.5),
                  color: Colors.black.withOpacity(0.4),
                  child: Icon(
                    Icons.play_arrow,
                    size: 70,
                    color: Colors.grey[50]!.withOpacity(0.7),
                  )
                ),
              )
            ) : Container(),

            Column(
              mainAxisSize: MainAxisSize.max,
              children: [
                widget.showProgressIndicator && _controller(i).isVideoInitialized()! ? VideoProgressBar(
                  _controller(i).videoPlayerController, 
                  _controller(i),
                  handleHeight: 2.5,
                  barHeight: 2.5,
                  colors: ProgressColors(
                    playedColor: Colors.white,
                    handleColor: Colors.white,
                    bufferedColor: Colors.transparent,
                    backgroundColor: Colors.grey.withOpacity(0.5)
                  ),
                ) : Container(),
                Expanded(
                  child: GestureDetector(
                    onLongPressStart: (_) => widget.touchToMute ? _controller(index).pause() : null,
                    onLongPressEnd: (_) => widget.touchToMute ? _controller(index).play() : null,
                    onTap: () {
                      if(widget.touchToMute) {
                        _controller(index).videoPlayerController!.value.volume == 1.0 ? _controller(index).setVolume(0.0) : _controller(index).setVolume(1.0);
                      } else {
                        if(_controller(index).isPlaying()!) {
                          _controller(index).pause();
                          // setState(() => manuallyPaused = true);
                        }else {
                          _controller(index).play();
                          // setState(() => manuallyPaused = false);
                        }
                      }
                    },
                  ),
                )
              ],
            )
          ]
        );
      }else {
        // If controller is not created return empty widget
        return Container();
      }
    }else {
      return ClipRRect(
        child: CachedNetworkImage(
          fit: BoxFit.cover,
          imageUrl: _urls.elementAt(i),
          progressIndicatorBuilder: (context, url, downloadProgress) {
            return Skeleton.rectangular(
              height: 250,
              // borderRadius: 20.0
            );
          }
        )
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned.fill(
          child: CarouselSlider(
            items: List<Widget>.generate(_urls.length, (i) {
              return buildMedia(i);
            }),
            options: CarouselOptions(
              // pageViewKey: PageStorageKey(UniqueKey()),
              enableInfiniteScroll: false,
              disableCenter: true,
              viewportFraction: 1.0,
              onPageChanged: (i, _) {
                if(i > index) {
                  _nextVideo();
                }else {
                  _previousVideo();
                }
              }
            )
          )
        ),
        _urls.length > 1 ? IgnorePointer(
          child: Padding(
          padding: EdgeInsets.symmetric(vertical: 5),
            child: Row(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Indicator(
                  length: _urls.length,
                  index: index
                ),
              ],
            )
          )
        ): Container()
      ]
    );
  }
}

class Indicator extends StatefulWidget {
  final int length;
  final int index;
  Indicator({Key? key, required this.length, required this.index}) : super(key: key);

  @override
  _Indicator createState() => _Indicator();
}

class _Indicator extends State<Indicator> {
  var id = 0.obs;
  bool _visible = true;
  Timer? timer;

  @override
  void initState() {
    super.initState();
    _setTimer();

    id.listen((p0) {
      timer!.cancel();
      setState(() => _visible = true);
      timer = Timer(Duration(seconds: 3), () {
        if (mounted) { 
          setState(() {
            _visible=false; 
          });
        }
      });
    });
  }

  _setTimer() {
    timer = Timer(Duration(seconds: 3), () {
      if (mounted) { 
        setState(() {
          _visible=false; 
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    id.value = widget.index;
    return AnimatedOpacity(
      duration: const Duration(milliseconds: 500),
      curve: Curves.fastOutSlowIn,
      // opacity: _visible ? 1 : 0,
      opacity: 1,
      child: Container(
        padding: EdgeInsets.all(5),
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.6),
          borderRadius: BorderRadius.circular(20)
        ),
        child: AnimatedSmoothIndicator(
          activeIndex: widget.index,  
          count: widget.length,  
          effect: ScrollingDotsEffect(
            activeDotColor: Colors.white,
            dotColor: Colors.grey.shade500,
            dotHeight: 6,
            dotWidth: 6,
            spacing: 6,
            activeDotScale: 1.0
          ),
        ),
      )
    );
  }
}

class VideoProgressBar extends StatefulWidget {
  VideoProgressBar(
    this.controller,
    this.betterPlayerController, {
    this.barHeight = 5.0,
    this.handleHeight = 6.0,
    ProgressColors? colors,
    this.onDragEnd,
    this.onDragStart,
    this.onDragUpdate,
    this.onTapDown,
    Key? key,
  })  : colors = colors ?? ProgressColors(),
        super(key: key);

  final VideoPlayerController? controller;
  final BetterPlayerController? betterPlayerController;
  final double barHeight;
  final double handleHeight;
  final ProgressColors colors;
  final Function()? onDragStart;
  final Function()? onDragEnd;
  final Function()? onDragUpdate;
  final Function()? onTapDown;

  @override
  _VideoProgressBarState createState() {
    return _VideoProgressBarState();
  }
}

class _VideoProgressBarState
    extends State<VideoProgressBar> {
  _VideoProgressBarState() {
    listener = () {
      if (mounted) setState(() {});
    };
  }

  late VoidCallback listener;
  bool _controllerWasPlaying = false;

  VideoPlayerController? get controller => widget.controller;

  BetterPlayerController? get betterPlayerController =>
      widget.betterPlayerController;

  bool shouldPlayAfterDragEnd = false;
  Duration? lastSeek;
  Timer? _updateBlockTimer;

  @override
  void initState() {
    super.initState();
    controller!.addListener(listener);
  }

  @override
  void deactivate() {
    controller!.removeListener(listener);
    _cancelUpdateBlockTimer();
    super.deactivate();
  }

  @override
  Widget build(BuildContext context) {
    final bool enableProgressBarDrag = betterPlayerController!
        .betterPlayerControlsConfiguration.enableProgressBarDrag;
    return GestureDetector(
      onHorizontalDragStart: (DragStartDetails details) {
        if (!controller!.value.initialized || !enableProgressBarDrag) {
          return;
        }
        _controllerWasPlaying = controller!.value.isPlaying;
        if (_controllerWasPlaying) {
          controller!.pause();
        }

        if (widget.onDragStart != null) {
          widget.onDragStart!();
        }
      },
      onHorizontalDragUpdate: (DragUpdateDetails details) {
        if (!controller!.value.initialized || !enableProgressBarDrag) {
          return;
        }
        seekToRelativePosition(details.globalPosition);

        if (widget.onDragUpdate != null) {
          widget.onDragUpdate!();
        }
      },
      onHorizontalDragEnd: (DragEndDetails details) {
        if (!enableProgressBarDrag) {
          return;
        }
        if (_controllerWasPlaying) {
          betterPlayerController?.play();
          shouldPlayAfterDragEnd = true;
        }
        _setupUpdateBlockTimer();

        if (widget.onDragEnd != null) {
          widget.onDragEnd!();
        }
      },
      onTapDown: (TapDownDetails details) {
        if (!controller!.value.initialized || !enableProgressBarDrag) {
          return;
        }

        seekToRelativePosition(details.globalPosition);
        _setupUpdateBlockTimer();
        if (widget.onTapDown != null) {
          widget.onTapDown!();
        }
      },
      child: Center(
        child: Container(
          // height: MediaQuery.of(context).size.height,
          height: widget.barHeight + widget.handleHeight + 1,
          width: MediaQuery.of(context).size.width,
          color: Colors.transparent,
          child: CustomPaint(
            painter: _ProgressBarPainter(
              value: _getValue(),
              colors: widget.colors,
              barHeight: widget.barHeight,
              handleHeight: widget.handleHeight
            ),
          ),
        ),
      ),
    );
  }

  void _setupUpdateBlockTimer() {
    _updateBlockTimer = Timer(const Duration(milliseconds: 1000), () {
      lastSeek = null;
      _cancelUpdateBlockTimer();
    });
  }

  void _cancelUpdateBlockTimer() {
    _updateBlockTimer?.cancel();
    _updateBlockTimer = null;
  }

  VideoPlayerValue _getValue() {
    if (lastSeek != null) {
      return controller!.value.copyWith(position: lastSeek);
    } else {
      return controller!.value;
    }
  }

  void seekToRelativePosition(Offset globalPosition) async {
    final RenderObject? renderObject = context.findRenderObject();
    if (renderObject != null) {
      final box = renderObject as RenderBox;
      final Offset tapPos = box.globalToLocal(globalPosition);
      final double relative = tapPos.dx / box.size.width;
      if (relative > 0) {
        final Duration position = controller!.value.duration! * relative;
        lastSeek = position;
        await betterPlayerController!.seekTo(position);
        onFinishedLastSeek();
        if (relative >= 1) {
          lastSeek = controller!.value.duration;
          await betterPlayerController!.seekTo(controller!.value.duration!);
          onFinishedLastSeek();
        }
      }
    }
  }

  void onFinishedLastSeek() {
    if (shouldPlayAfterDragEnd) {
      shouldPlayAfterDragEnd = false;
      betterPlayerController?.play();
    }
  }
}

class _ProgressBarPainter extends CustomPainter {
  final VideoPlayerValue value;
  final ProgressColors colors;
  final double barHeight;
  final double handleHeight;

  _ProgressBarPainter({required this.value, required this.colors, required this.barHeight, required this.handleHeight});

  @override
  bool shouldRepaint(CustomPainter painter) {
    return true;
  }

  @override
  void paint(Canvas canvas, Size size) {
    // const barHeight = 5.0;
    // const handleHeight = 6.0;
    final baseOffset = size.height / 2 - barHeight / 2.0;

    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromPoints(
          Offset(0.0, baseOffset),
          Offset(size.width, baseOffset + barHeight),
        ),
        const Radius.circular(4.0),
      ),
      colors.backgroundPaint,
    );
    if (!value.initialized) {
      return;
    }
    final double playedPartPercent =
        value.position.inMilliseconds / value.duration!.inMilliseconds;
    final double playedPart =
        playedPartPercent > 1 ? size.width : playedPartPercent * size.width;
    for (final DurationRange range in value.buffered) {
      final double start = range.startFraction(value.duration!) * size.width;
      final double end = range.endFraction(value.duration!) * size.width;
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromPoints(
            Offset(start, baseOffset),
            Offset(end, baseOffset + barHeight),
          ),
          const Radius.circular(4.0),
        ),
        colors.bufferedPaint,
      );
    }
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromPoints(
          Offset(0.0, baseOffset),
          Offset(playedPart, baseOffset + barHeight),
        ),
        const Radius.circular(4.0),
      ),
      colors.playedPaint,
    );

    final shadowPath = Path()
      ..addOval(Rect.fromCircle(
          center: Offset(playedPart, baseOffset + barHeight / 2),
          radius: handleHeight));

    canvas.drawShadow(shadowPath, Colors.black, 0.2, false);
    canvas.drawCircle(
      Offset(playedPart, baseOffset + barHeight / 2),
      handleHeight,
      colors.handlePaint,
    );
  }
}

class ProgressColors {
  ProgressColors({
    Color playedColor = const Color.fromRGBO(255, 0, 0, 0.7),
    Color bufferedColor = const Color.fromRGBO(30, 30, 200, 0.2),
    Color handleColor = const Color.fromRGBO(200, 200, 200, 1.0),
    Color backgroundColor = const Color.fromRGBO(200, 200, 200, 0.5),
  })  : playedPaint = Paint()..color = playedColor,
        bufferedPaint = Paint()..color = bufferedColor,
        handlePaint = Paint()..color = handleColor,
        backgroundPaint = Paint()..color = backgroundColor;

  final Paint playedPaint;
  final Paint bufferedPaint;
  final Paint handlePaint;
  final Paint backgroundPaint;
}