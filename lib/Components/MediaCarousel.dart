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

class MediaCarousel extends StatefulWidget {
  final List<String> contentUrls;
  final bool touchToMute;
  final bool showPauseIndicator;
  final bool initMute;
  MediaCarousel({Key? key, required this.contentUrls, this.touchToMute = false, this.showPauseIndicator = true, this.initMute = false}) : super(key: key);

  @override
  _MediaCarousel createState() => _MediaCarousel();
}

class _MediaCarousel extends State<MediaCarousel> with TickerProviderStateMixin {
  int index = 0;
  double _position = 0;
  double _buffer = 0;
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

    _pauseAnimationController?.dispose();
  }

  Function(BetterPlayerEvent) _listenerSpawner(index) {
    return (BetterPlayerEvent event) {
      int dur = _controller(index).videoPlayerController?.value.duration?.inMilliseconds ?? 0;
      int pos = _controller(index).videoPlayerController?.value.position.inMilliseconds ?? 0;
      int buf = _controller(index).videoPlayerController?.value.buffered.last.end.inMilliseconds ?? 0;

      setState(() {
        if (dur <= pos) {
          _position = 0;
          return;
        }
        _position = pos / dur;
        _buffer = buf / dur;
      });

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
      // controlsConfiguration: BetterPlayerControlsConfiguration(
      //   loadingColor: Colors.deepOrange,
      //   progressBarBufferedColor: Colors.red, //very useful
      //   progressBarHandleColor: Colors.blue,
      //   progressBarBackgroundColor: Colors.white
      // )
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
            Center(
              child: AspectRatio(
                aspectRatio: _controller(i).videoPlayerController!.value.aspectRatio,
                child: Center(child: BetterPlayer(controller: _controller(i)))
              ),
            ),

            widget.showPauseIndicator ? Align(
              alignment: Alignment.center,
              child: FadeTransition(
                opacity: _pauseAnimation!,
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

            Stack(
              children: [
                Positioned(
                  child: Container(
                    height: 2,
                    width: MediaQuery.of(context).size.width * _buffer,
                    color: Colors.white.withOpacity(0.2),
                  ),
                ),
                Positioned(
                  child: Container(
                    height: 2,
                    width: MediaQuery.of(context).size.width * _position,
                    color: Colors.grey.withOpacity(0.8),
                  ),
                ),
              ],
            ),

            GestureDetector(
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
          // effect: ExpandingDotsEffect(
          //   activeDotColor: Colors.white,
          //   dotColor: Colors.grey.shade500,
          //   dotHeight: 6,
          //   dotWidth: 6,
          //   spacing: 3,
          //   expansionFactor: 8
          // ),  
        ),
      )
    );
  }
}
