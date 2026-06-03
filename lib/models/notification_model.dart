class NotificationModel {
  final String title;
  final String message;
  final String time;
  final String type;

  NotificationModel({
    required this.title,
    required this.message,
    required this.time,
    required this.type,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      title: json['title'],
      message: json['message'],
      time: json['time'],
      type: json['type'],
    );
  }
}