
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
  int? index;

  // message
  String? message;

  // comment
  String? comment;
  String? contentPhoto;

  // comment / reaction
  int? contentKey;

  Map<String, dynamic> toJson() {
    if(notificationType == NotificationType.comment) {
      return {
        'comment': comment,
        'content_key': contentKey,
        'content_photo': contentPhoto,
        'firebase_id': firebaseId,
        'read': read,
        'timestamp': timestamp.toUtc()
      };
    }else if(notificationType == NotificationType.reaction) {
      return {
        'content_key': contentKey,
        'content_photo': contentPhoto,
        'firebase_id': firebaseId,
        'read': read,
        'timestamp': timestamp.toUtc()
      };
    }else if(notificationType == NotificationType.followed) {
      return {
        'firebase_id': firebaseId,
        'read': read,
        'timestamp': timestamp.toUtc()
      };
    }else { // Messages
      return {
        'message': message,
        'firebase_id': firebaseId,
        'read': read,
        'timestamp': timestamp.toUtc()
      };
    }
  } 
  
  VentureNotification.fromMap(Map<String, dynamic> input, NotificationType type, int i) {
    if(type == NotificationType.message) {
      notificationType = type;
      index = i;
      firebaseId = input['firebase_id'];
      message = input['message'];
      read = input['read'];
      timestamp = input['timestamp'].toDate();
    }

    if(type == NotificationType.followed) {
      notificationType = type;
      index = i;
      firebaseId = input['firebase_id'];
      timestamp = input['timestamp'].toDate();
      read = input['read'];
    }

    if(type == NotificationType.comment) {
      notificationType = type;
      index = i;
      firebaseId = input['firebase_id'];
      timestamp = input['timestamp'].toDate();
      read = input['read'];
      comment = input['comment'];
      contentPhoto = input['content_photo'];
      contentKey = input['content_key'];
    }

    if(type == NotificationType.reaction) {
      notificationType = type;
      index = i;
      firebaseId = input['firebase_id'];
      timestamp = input['timestamp'].toDate();
      read = input['read'];
      contentPhoto = input['content_photo'];
      contentKey = input['content_key'];
    }
  }
}