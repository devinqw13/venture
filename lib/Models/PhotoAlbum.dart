import 'package:photo_manager/photo_manager.dart';

class PhotoAlbum {
  AssetPathEntity? album;
  List<AssetEntity>? photos;

  PhotoAlbum(AssetPathEntity input1, List<AssetEntity> input2) {
    album = input1;
    photos = input2;
  }
}