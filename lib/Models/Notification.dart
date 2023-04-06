
enum NotificationType {
  message,
  comment,
  followed,
  reaction
}

class VentureNotification {
  // global
  late NotificationType notificationType;
  late String firebaseId;
  late DateTime timestamp;
  late bool read;

  // message
  String? message;

  // comment
  String? comment;
  String? contentPhoto;
  
  VentureNotification.fromMap(Map<String, dynamic> input, NotificationType type) {
    if(type == NotificationType.message) {
      notificationType = type;
      firebaseId = input['firebase_id'];
      message = input['message'];
      read = input['read'];
      timestamp = input['timestamp'].toDate();
    }

    if(type == NotificationType.followed) {
      notificationType = type;
      firebaseId = input['firebase_id'];
      timestamp = input['timestamp'].toDate();
      read = input['read'];
    }

    if(type == NotificationType.comment) {
      notificationType = type;
      firebaseId = input['firebase_id'];
      timestamp = input['timestamp'].toDate();
      read = input['read'];
      comment = input['comment'];
      contentPhoto = input['content_photo'];
    }
  }
}