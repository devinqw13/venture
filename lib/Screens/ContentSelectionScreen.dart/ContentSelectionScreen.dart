import 'dart:typed_data';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:venture/Components/VideoPlayer.dart';
import 'package:venture/Helpers/DeleteContent.dart';
import 'package:venture/Helpers/Toast.dart';
import 'package:zoom_tap_animation/zoom_tap_animation.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:extended_image/extended_image.dart';
import 'package:image_editor/image_editor.dart';
import 'package:venture/Components/PhotoBuilder.dart';
import 'package:venture/Constants.dart';
import 'package:venture/Models/PhotoAlbum.dart';
import 'package:venture/Components/SlideOverlay.dart';
import 'package:venture/Controllers/ThemeController.dart';

class ContentSelectionScreen extends StatefulWidget {
  final bool allowMultiSelect;
  final bool photoOnly;
  final bool circleMask;
  ContentSelectionScreen({Key? key, required this.allowMultiSelect, required this.photoOnly, this.circleMask = false}) : super(key: key);

  @override
  _ContentSelectionScreenState createState() => _ContentSelectionScreenState();
}

class _ContentSelectionScreenState extends State<ContentSelectionScreen> {
  final ThemesController _themesController = Get.find();
  ValueNotifier<WidgetStatus> status = ValueNotifier<WidgetStatus>(WidgetStatus.HIDDEN);
  List<PhotoAlbum> albums = [];
  List<AssetEntity> entities = [];
  List<CustomAssetEntity> entityList = [];
  List<CustomAssetEntity> multiSelectedPhotos = [];
  String selectedAlbum = "";
  AssetEntity? selectedPhoto;
  Uint8List? u8List;
  GlobalKey<ExtendedImageEditorState> editorKey = GlobalKey();
  String contentType = 'post';
  bool isLoading = false;
  late bool allowMultiSelect;
  bool multiSelect = false;
  late bool photoOnly;
  late String test;
  bool showMultiSelectHelper = false;

  @override
  void initState() {
    super.initState();
    allowMultiSelect = widget.allowMultiSelect;
    photoOnly = widget.photoOnly;
    _initializeAsyncDependencies();
  }

  _initializeAsyncDependencies() async {
    await initializePhotoDependencies();
    await initizalizeHelpers();
  }

  initizalizeHelpers() {
    final storage = GetStorage();
    bool? multiSelect = storage.read('helper_content_selection_multi_select');
    if(multiSelect == null || !multiSelect) {
      showMultiSelectHelper = true;
    }
  }

  Future<void> initializePhotoDependencies() async {
    final PermissionState _ps = await PhotoManager.requestPermissionExtend();
    if (_ps.isAuth) {
      RequestType reqType = photoOnly ? RequestType.image : RequestType.common;
      List<AssetPathEntity> results = await PhotoManager.getAssetPathList(type: reqType);
      initializeAlbums(results);
      initializePhotos(results);
    } else {
      // Limited(iOS) or Rejected, use `==` for more precise judgements.
      // You can call `PhotoManager.openSetting()` to open settings for further steps.
    }
  }

  initializeAlbums(List<AssetPathEntity> results) async {
    for (AssetPathEntity item in results) {
      int assetCount = await item.assetCountAsync;
      if(assetCount > 0) {
        List<AssetEntity> result = await item.getAssetListRange(start: 0 , end: assetCount);
        PhotoAlbum i = PhotoAlbum(item, result);
        albums.add(i);
      }
    }
  }

  initializePhotos(List<AssetPathEntity> results) async {
    int count = await results.firstWhere((e) => e.isAll).assetCountAsync;
    entities = await results.firstWhere((e) => e.isAll).getAssetListRange(start: 0 , end: count);
    Uint8List? bytes = await entities.first.originBytes;

    List<CustomAssetEntity> eList = [];
    for(var item in entities) {
      CustomAssetEntity entity = CustomAssetEntity(entity: item);
      eList.add(entity);
    }

    setState(() {
      entityList = eList;
      // editorKey = entityList.first.editorKey;
      selectedAlbum = results.firstWhere((e) => e.isAll).name;
      selectedPhoto = entities.first;
      entityList.first.selected = true;
      entityList.first.highlight = true;
      u8List = bytes;
    });
  }

  _toggleAlbumSelector() {
    if (status.value == WidgetStatus.HIDDEN) {
      setState(() {
        status.value = WidgetStatus.VISIBLE;
      });
    } else {
      setState(() {
        status.value = WidgetStatus.HIDDEN;
      });
    }
  }

  toggleMultiSelect() {
    entityList.forEach((e) => e.highlight = false);
    if(multiSelect) {
      for (var item in entityList) {
        if(item.createdPhoto != null) deleteFile(item.createdPhoto!);
        setState(() {
          item.createdPhoto = null;
          item.selected = false;
        });
      }
      // entityList.forEach((e) => e.selected = false);
      multiSelectedPhotos.clear();
      setState(() {
        entityList.firstWhere((e) => e.entity == selectedPhoto).selected = true;
        entityList.firstWhere((e) => e.entity == selectedPhoto).highlight = true;
        multiSelect = false;
      });
    }else {
      setState(() {
        multiSelectedPhotos.add(entityList.firstWhere((e) => e.entity == selectedPhoto));
        entityList.firstWhere((e) => e.entity == selectedPhoto).selected = true;
        entityList.firstWhere((e) => e.entity == selectedPhoto).highlight = true;
        multiSelect = true;
      });
    }
  }

  _changeAlbum(PhotoAlbum album) async {
    Uint8List? bytes = await album.photos!.first.originBytes;
    _toggleAlbumSelector();

    List<CustomAssetEntity> eList = [];
    for(var item in album.photos!) {
      CustomAssetEntity entity = CustomAssetEntity(entity: item);
      eList.add(entity);
    }

    setState(() {
      entities = album.photos!;
      entityList = eList;
      selectedAlbum = album.album!.name;
      selectedPhoto = album.photos!.first;
      u8List = bytes;
    });
  }

  goToSubmit() async {
    List<File?> content = entityList.where((e) => e.createdPhoto != null).toList().map((f) => f.createdPhoto).toList();

    // get any selected videos and add to list
    var videoEntities = entityList.where((e) => e.entity.type == AssetType.video && e.selected).toList();
    List<File?> videos = [];
    for(var item in videoEntities) {
      var result = await item.entity.file;
      videos.add(result);
      content.add(result);
    }

    if (selectedPhoto!.type == AssetType.image) {
      setState(() => isLoading = true);
      File? file = await crop();
      setState(() => isLoading = false);
      if(file == null) {
        showToast(context: context, msg: "There was an error processing content.");
        return;
      }
      content.add(file);
    }

    // if(videos.isNotEmpty) {
    //   print("go to trim screen");
    // }else {
    //   Navigator.pop(context, content);
    // }
    Navigator.pop(context, content);
  }

  Future<File?> crop() async {
    final ExtendedImageEditorState? state = editorKey.currentState;
    if (state == null) return null;

    final Rect? rect = state.getCropRect();
    if (rect == null) {
      return null;
    }

    final Uint8List? img = state.rawImageData;
    if (img == null) {
      return null;
    }

    final ImageEditorOption option = ImageEditorOption();
    option.addOption(ClipOption.fromRect(rect));
    option.outputFormat = const OutputFormat.png();

    // final Uint8List? result = await ImageEditor.editImage(
    //   image: img,
    //   imageEditorOption: option,
    // );

    final File? result = await ImageEditor.editImageAndGetFile(
      image: img,
      imageEditorOption: option
    );

    return result;
  }

  void showPreviewDialog({Uint8List? image, File? file}) {
    showDialog<void>(
      context: context,
      builder: (BuildContext ctx) => GestureDetector(
        onTap: () => Navigator.pop(context),
        child: Container(
          color: Colors.grey.withOpacity(0.5),
          child: Center(
            child: Container(
              child: Image.file(file!),
            ),
          ),
        ),
      ),
    );
  }

  buildBody() {
    return Column(
      mainAxisSize: MainAxisSize.max,
      children: [
        selectedPhoto?.type == AssetType.image ?
          u8List != null ?
          AspectRatio(
            aspectRatio: 1,
            child: ExtendedImage(
              filterQuality: FilterQuality.high,
              image: ExtendedMemoryImageProvider(u8List!, cacheRawData: true),
              extendedImageEditorKey: editorKey,
              mode: ExtendedImageMode.editor,
              fit: BoxFit.contain,
              initEditorConfigHandler: (_) => EditorConfig(
                // editActionDetailsIsChanged: (details) {
                //   if(multiSelect) {
                //     CustomAssetEntity? ent = entityList.firstWhere((e) => e.entity == selectedPhoto);
                //     print(ent.entity.createDateTime);
                //     setState(() {
                //       ent.editState = ent.editorKey.currentState;
                //     });
                //   }
                // },
                maxScale: 5.0,
                cropLayerPainter: widget.circleMask ? CircleEditorCropLayerPainter() : EditorCropLayerPainter(),
                cropRectPadding: const EdgeInsets.all(0.0),
                hitTestSize: 20.0,
                initCropRectType: InitCropRectType.layoutRect,
                cropAspectRatio: 4 / 5, // Portrait: 4 / 5 , Square: 1/1, Landscape: 1.91 / 1 OR 16 / 9
              ),
            ),
          ) : Container() :
        selectedPhoto?.type == AssetType.video ?
          AspectRatio(
            aspectRatio: 1,
            child: VideoContentPlayer(
              video: selectedPhoto,
            )
          )
          : Container(),
        Container(
          color: _themesController.getContainerBgColor(),
          padding: EdgeInsets.symmetric(vertical: 10, horizontal: 10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              allowMultiSelect ?
              GestureDetector(
                onTap: () => toggleMultiSelect(),
                child: Container(
                  padding: EdgeInsets.all(5),
                  decoration: BoxDecoration(
                    color: multiSelect ? Colors.blue : Get.isDarkMode ? ColorConstants.gray500 : Colors.white,
                    // shape: BoxShape.circle,
                    borderRadius: BorderRadius.circular(50),
                    border: Border.all(
                      color: multiSelect ? Colors.blue : Colors.grey,
                      width: 0.2
                    )
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      showMultiSelectHelper ?
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 5),
                        child: Text(
                          "Select mulitple",
                          style: TextStyle(
                            color: multiSelect ? Colors.white : null
                          ),
                        )
                      ) : Container(),
                      Icon(
                        Icons.photo_library_outlined,
                        size: 18,
                        color: multiSelect ? Colors.white : null,
                      ),
                    ],
                  )
                ),
              ) : Container()
            ],
          )
        ),
        Expanded(
          child: Container(
            color: _themesController.getContainerBgColor(),
            child: GridView.builder(
              shrinkWrap: true,
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 4,
                mainAxisSpacing: 1.0,
                crossAxisSpacing: 1.0,
                childAspectRatio: 0.9
              ),
              itemCount: entityList.length,
              itemBuilder: (contex, i) {
                return GestureDetector(
                  onTap: () async {
                    Uint8List? bytes;
                    if(entityList[i].entity.type == AssetType.image) {
                      bytes = await entityList[i].entity.originBytes;
                    }

                    if(multiSelect) {
                      if(entityList[i].selected && selectedPhoto == entityList[i].entity) {
                        multiSelectedPhotos.removeWhere((e) => e.entity == entityList[i].entity);
                        setState(() {
                          entityList[i].selected = false;
                        });
                      }else {
                        bool isImage = entityList.firstWhere((e) => e.entity == selectedPhoto).entity.type == AssetType.image;

                        if(entityList.firstWhere((e) => e.entity == selectedPhoto).createdPhoto == null && isImage) {
                          File? file = await crop();
                          if(file == null) {
                            showToast(context: context, msg: "There was an error processing content.");
                            return;
                          }

                          entityList.firstWhere((e) => e.entity == selectedPhoto).createdPhoto = file;
                        }

                        entityList.forEach((e) => e.highlight = false);
                        if(!entityList[i].selected)multiSelectedPhotos.add(entityList[i]);
                        setState(() {
                          entityList[i].selected = true;
                          entityList[i].highlight = true;
                        });
                      }
                    }else {
                      entityList.forEach((e) => e.selected = false);
                      entityList.forEach((e) => e.highlight = false);
                      setState(() {
                        entityList[i].selected = true;
                        entityList[i].highlight = true;
                      });
                    }

                    setState(() {
                      if(selectedPhoto != entityList[i].entity && entityList[i].entity.type == AssetType.image) {
                        u8List = bytes;
                      }

                      selectedPhoto = entityList[i].entity;
                    });

                    if(entityList[i].createdPhoto != null && multiSelect) {
                      deleteFile(entityList[i].createdPhoto!);
                      setState(() => entityList[i].createdPhoto = null);
                    }

                  },
                  child: PhotoBuilder(
                    entity: entityList[i].entity,
                    multiSelect: multiSelect,
                    selected: entityList[i].selected,
                    highlighted: entityList[i].highlight,
                    index: multiSelectedPhotos.indexWhere((e) => e.entity == entityList[i].entity) + 1
                  ),
                );
              },
            )
          )
        )
      ],
    );
  }

  buildAlbumList() {
    return ListView.builder(
      itemCount: albums.length,
      itemBuilder: (context, i) {
        return ZoomTapAnimation(
          onTap: () => _changeAlbum(albums[i]),
          child: Padding(
            padding: EdgeInsets.all(10.0),
            child: Row(
              children: [
                Container(
                  child: PhotoBuilder(
                    size: 90,
                    entity: albums[i].photos!.first
                  )
                ),
                SizedBox(width: 10.0),
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(albums[i].album!.name,
                      style: TextStyle(
                        fontWeight: FontWeight.bold
                      ),
                    ),
                    SizedBox(height: 10.0),
                    Text(albums[i].photos!.length.toString(),
                      style: TextStyle(
                          fontWeight: FontWeight.bold
                      )
                    )
                  ],
                )
              ]
            )
          )
        );
      }
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        leading: status.value == WidgetStatus.VISIBLE ? 
          ZoomTapAnimation(
            child: Icon(Icons.close, size: 28),
            onTap: () => _toggleAlbumSelector(),
          ) : null,
        title: ValueListenableBuilder(
          valueListenable: status, 
          builder: (context, value, _) { 
            return status.value == WidgetStatus.HIDDEN ? ZoomTapAnimation(
              onTap: () => _toggleAlbumSelector(),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(selectedAlbum,
                    style: TextStyle(
                      color: Get.isDarkMode ? Colors.white : Colors.black,
                      fontWeight: FontWeight.bold
                    ),
                  ),
                  Icon(Icons.keyboard_arrow_down_rounded)
                ]
              )
            ) :
            Text("Select album",
              style: TextStyle(
                color: Get.isDarkMode ? Colors.white : Colors.black,
                fontWeight: FontWeight.bold
              ),
            );
          }
        ),
        actions: [
          !isLoading ? Center(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 15),
              child: ZoomTapAnimation(
                onTap: () => goToSubmit(),
                child: Text("Next",
                  style: theme.textTheme.headline6!.copyWith(color: primaryOrange, fontWeight: FontWeight.bold),
                ),
              )
            )
          ):
          // CircularProgressIndicator(color: primaryOrange)
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 15),
            child: CupertinoActivityIndicator(
              radius: 13,
            )
          )
        ],
      ),
      body: Stack(
        children: [
          buildBody(),
          SlideOverlay(
            height: MediaQuery.of(context).size.height,
            status: status,
            child: buildAlbumList()
          )
        ],
      ),
    );
  }
}

class CustomAssetEntity {
  bool selected = false; // also used for multi selection
  bool highlight = false;
  AssetEntity entity;
  File? createdPhoto;
  // ExtendedImageEditorState? editState;
  // GlobalKey<ExtendedImageEditorState> editorKey = GlobalKey();

  CustomAssetEntity({required this.entity});
}

class CircleEditorCropLayerPainter extends EditorCropLayerPainter {
  const CircleEditorCropLayerPainter();

  @override
  void paintCorners(
      Canvas canvas, Size size, ExtendedImageCropLayerPainter painter) {
    // do nothing
  }

  @override
  void paintMask(
      Canvas canvas, Size size, ExtendedImageCropLayerPainter painter) {
    final Rect rect = Offset.zero & size;
    final Rect cropRect = painter.cropRect;
    final Color maskColor = painter.maskColor;
    canvas.saveLayer(rect, Paint());
    canvas.drawRect(
        rect,
        Paint()
          ..style = PaintingStyle.fill
          ..color = maskColor);
    canvas.drawCircle(cropRect.center, cropRect.width / 2.0,
        Paint()..blendMode = BlendMode.clear);
    canvas.restore();
  }

  @override
  void paintLines(
      Canvas canvas, Size size, ExtendedImageCropLayerPainter painter) {
    final Rect cropRect = painter.cropRect;
    if (painter.pointerDown) {
      canvas.save();
      canvas.clipPath(Path()..addOval(cropRect));
      super.paintLines(canvas, size, painter);
      canvas.restore();
    }
  }
}