import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:venture/Helpers/DeleteContent.dart';
import 'package:venture/Helpers/Toast.dart';
import 'package:venture/Screens/UploadContentScreen/SubmitContentFormScreen.dart';
import 'package:zoom_tap_animation/zoom_tap_animation.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:extended_image/extended_image.dart';
import 'package:image_editor/image_editor.dart';
import 'package:venture/Components/PhotoBuilder.dart';
import 'package:venture/Constants.dart';
import 'package:venture/Models/PhotoAlbum.dart';
import 'package:venture/Components/SlideOverlay.dart';
import 'package:venture/Controllers/ThemeController.dart';
import 'dart:io';

class UploadContentScreen extends StatefulWidget {
  UploadContentScreen({Key? key}) : super(key: key);

  @override
  _UploadContentScreenState createState() => _UploadContentScreenState();
}

class _UploadContentScreenState extends State<UploadContentScreen> {
  final ThemesController _themesController = Get.find();
  ValueNotifier<WidgetStatus> status = ValueNotifier<WidgetStatus>(WidgetStatus.HIDDEN);
  List<PhotoAlbum> albums = [];
  List<AssetEntity> entities = [];
  String selectedAlbum = "";
  AssetEntity? selectedPhoto;
  Uint8List? u8List;
  final GlobalKey<ExtendedImageEditorState> editorKey = GlobalKey();
  String contentType = 'post';
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    _initializeAsyncDependencies();

  }

  _initializeAsyncDependencies() async {
    final PermissionState _ps = await PhotoManager.requestPermissionExtend();
    if (_ps.isAuth) {
      List<AssetPathEntity> results = await PhotoManager.getAssetPathList(type: RequestType.common);
      initializeAlbums(results);
      initializePhotos(results);
    } else {
      // Limited(iOS) or Rejected, use `==` for more precise judgements.
      // You can call `PhotoManager.openSetting()` to open settings for further steps.
    }
  }

  initializeAlbums(List<AssetPathEntity> results) async {
    for (AssetPathEntity item in results) {
      List<AssetEntity> result = await item.getAssetListRange(start: 0 , end: item.assetCount);
      PhotoAlbum i = PhotoAlbum(item, result);
      albums.add(i);
    }
  }

  initializePhotos(List<AssetPathEntity> results) async {
    entities = await results.firstWhere((e) => e.isAll).getAssetListRange(start: 0 , end: results.firstWhere((e) => e.isAll).assetCount);
    Uint8List? bytes = await entities.first.originBytes;

    setState(() {
      selectedAlbum = results.firstWhere((e) => e.isAll).name;
      selectedPhoto = entities.first;
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

  _changeAlbum(PhotoAlbum album) async {
    Uint8List? bytes = await album.photos!.first.originBytes;
    _toggleAlbumSelector();

    setState(() {
      entities = album.photos!;
      selectedAlbum = album.album!.name;
      selectedPhoto = album.photos!.first;
      u8List = bytes;
    });
  }

  goToSubmit() async {
    setState(() => isLoading = true);
    File? file = await crop();
    setState(() => isLoading = false);

    if(file == null) {
      showToast(context: context, msg: "There was an error processing content.");
      return;
    }

    SubmitContentFormScreen screen = SubmitContentFormScreen(file: file,contentType: contentType);
    bool? result = await Navigator.of(context).push(MaterialPageRoute(builder: (context) => screen));

    if(result != null && !result) {
      deleteFile(file);
    }
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
      children: [
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
              maxScale: 8.0,
              cropRectPadding: const EdgeInsets.all(0.0),
              hitTestSize: 20.0,
              initCropRectType: InitCropRectType.layoutRect,
              cropAspectRatio: 1,
            ),
          ),
        ) : Container(),
        Expanded(
          child: Container(
            color: _themesController.getContainerBgColor(),
            child: GridView.builder(
              shrinkWrap: true,
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                mainAxisSpacing: 5.0,
                crossAxisSpacing: 5.0,
                childAspectRatio: 0.9
              ),
              itemCount: entities.length,
              itemBuilder: (contex, i) {
                return GestureDetector(
                  onTap: () async {
                    Uint8List? bytes = await entities[i].originBytes;
                    setState(() {
                      selectedPhoto = entities[i];
                      u8List = bytes;
                    });
                  },
                  child: PhotoBuilder(
                    entity: entities[i]
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
                    Text(albums[i].album!.assetCount.toString(),
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