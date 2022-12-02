import 'package:cloud_firestore/cloud_firestore.dart';

class BugReport {
  final String userId;
  final String userName;
  final String device;
  final String dateTime;
  final String report;

  BugReport({
    required this.userId,
    required this.userName,
    required this.dateTime,
    required this.device,
    required this.report,
  });

  BugReport copyWith({
    String? userId,
    String? userName,
    String? device,
    String? dateTime,
    String? report,
  }) {
    return BugReport(
      userId: userId ?? this.userId,
      userName: userName ?? this.userName,
      device: device ?? this.device,
      dateTime: dateTime ?? this.dateTime,
      report: report ?? this.report,
    );
  }

  Map<String, dynamic> toDocument() {
    return {
      'userId': userId,
      'userName': userName,
      'device': device,
      'dateTime': dateTime,
      'report': report,
    };
  }

  factory BugReport.fromSnapshot(DocumentSnapshot snap) {
    return BugReport(
      userId: snap['userId'],
      userName: snap['userName'],
      device: snap['device'],
      dateTime: snap['dateTime'],
      report: snap['report'],
    );
  }
}
